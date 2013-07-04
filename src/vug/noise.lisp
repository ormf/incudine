;;; Copyright (c) 2013 Tito Latini
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2 of the License, or
;;; (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

(in-package :incudine.vug)

(define-vug white-noise (amp)
  (with-samples ((rmax (* amp 2.0d0)))
    (- (random rmax) amp)))

;;; Pink Noise generator using the Gardner method with the James
;;; McCartney's optimization (http://www.firstpr.com.au/dsp/pink-noise).
;;; Based on Phil Burk's code in C.
(define-vug-macro pink-noise (amp &key (number-of-bands 20))
  (let* ((max-random-rows 30)
         (number-of-rows (let ((nb number-of-bands))
                           (cond ((< nb 4) 4)
                                 ((> nb 30) 30)
                                 (t nb))))
         (random-limit32 4294967296)
         (random-limit24 16777216)
         (random-bits 24)
         (mask (1- (ash 1 number-of-rows)))
         (scale (/ 1.0d0 (* (1+ number-of-rows)
                            (ash 1 (1- random-bits))))))
    (with-gensyms (#-x86-64 rows-wrap
                   rows counter rand32 new-random total index mult)
      `(with (#+x86-64
              (,rows (make-array ,max-random-rows :initial-element 0))
              #-x86-64
              (,rows-wrap (make-foreign-array ,max-random-rows :int32 :zero-p t))
              #-x86-64
              (,rows (foreign-array-data ,rows-wrap))
              (,counter 0)
              (,rand32 0)
              (,new-random 0)
              (,total 0)
              (,index 0)
              (,mult (* ,amp ,scale)))
         (declare (type (unsigned-byte 32) ,rand32 ,new-random ,counter ,index)
                  (type (signed-byte 32) ,total)
                  (type (integer 0 ,max-random-rows) ,index)
                  (type sample ,mult))
         (initialize (dotimes (i ,number-of-rows)
                       (setf #+x86-64 (svref ,rows i)
                             #-x86-64 (mem-aref ,rows :int32 i)
                             (random ,random-limit24))))
         (setf ,rand32 (random ,random-limit32))
         ;; Magnus Jonsson's suggestion
         (setf ,counter (logand ,rand32 ,mask))
         (unless (zerop ,counter)
           (setf ,index (ctz ,counter))
           (setf ,new-random (ash ,rand32 -8))
           (incf ,total (the (signed-byte 32)
                          (- ,new-random
                             #+x86-64 (the fixnum (svref ,rows ,index))
                             #-x86-64 (mem-aref ,rows :int32 ,index))))
           (setf #+x86-64 (svref ,rows ,index)
                 #-x86-64 (mem-aref ,rows :int32 ,index)
                 ,new-random))
         (* ,mult (the (signed-byte 32)
                    (+ ,total (random ,random-limit24))))))))

;;; Noise generator based on a chaotic function (used in SuperCollider).
(define-vug crackle (param amp)
  (with-samples (y0 (y1 0.3d0) y2)
    (setf y0 (abs (- (* y1 param) y2 0.05d0))
          y2 y1 y1 y0)
    (* amp y0)))

(define-vug-macro rand (&whole whole distribution
                        &key a b c n n1 n2 p alpha beta mu nu sigma tt zeta seed)
  (declare (ignorable a b c n n1 n2 p alpha beta mu nu sigma tt zeta))
  (let ((spec (gen::find-rand-func-spec distribution))
        (pl (cddr whole)))
    (destructuring-bind (type-list (lisp-name foreign-name)
                         return-type &rest args)
        spec
      (declare (ignore type-list foreign-name return-type))
      (let ((keys (mapcar (lambda (x) (make-keyword (caar x))) args)))
        (with-gensyms (rng)
          `(with (,@(loop for arg in args
                          for key in keys
                          for value = (or (getf pl key) (cdr arg))
                          collect `(,(caar arg)
                                     ,(if (eq (cadar arg) :double)
                                          `(coerce ,value 'double-float)
                                          value)))
                  (,rng (incudine.external::gsl-random-generator)))
             ,@(let ((samples (loop for arg in args
                                    when (eq (cadar arg) :double)
                                    collect (caar arg))))
                 (when samples
                   `((declare (type ,(if (eq incudine::*sample-type* 'double-float)
                                         'sample
                                         'double-float)
                                    ,@samples)))))
             (declare (type foreign-pointer ,rng))
             (,lisp-name ,rng ,@(mapcar #'caar args))))))))

;;;
;;; FRACTAL-NOISE
;;;
;;; References:
;;;
;;;   [1] R. Saletti. A comparison between two methods to generate 1/(f^gamma) noise.
;;;   In Proc. IEEE, volume 74, pp. 1595-1596, November 1986.
;;;
;;;   [2] G. Corsini and R. Saletti. A 1/(f^gamma) power spectrum noise sequence
;;;   generator. IEEE Trans. on Instrumentation and Measurement, 37(4):615-619,
;;;   December 1988.
;;;
;;;   [3] The Sounding Object, edited by Davide Rocchesso and Federico Fontana,
;;;   Edizioni di Mondo Estremo. Chapter 8 by Federico Avanzini, pp. 154-157.
;;;
(declaim (inline fractal-noise-coeff-calc))
(defun fractal-noise-coeff-calc (freq)
  (- (exp (- (* 2.0d0 pi freq *sample-duration*)))))

(define-vug-macro fractal-noise (amp beta &key (poles-density 6) (filter-order 15)
                                 (lowest-freq 50))
  (with-gensyms (in c1 c2 p z a b sec r-poles-density)
    `(with-samples ((,in (white-noise 1.0d0))
                    (,r-poles-density (locally (declare #.*reduce-warnings*)
                                        (/ 1.0d0 ,poles-density)))
                    (,c1 (expt 10.0d0 ,r-poles-density))
                    (,c2 (expt 10.0d0 (* ,beta ,r-poles-density 0.5d0)))
                    ,@(loop for i from 1 to filter-order
                            for pole = (format-symbol :incudine.vug "~A~D" p i)
                            for pole-value = (coerce lowest-freq 'sample)
                                             then `(* ,(format-symbol :incudine.vug
                                                                      "~A~D" p (1- i))
                                                      ,c1)
                            for zero = (format-symbol :incudine.vug "~A~D" z i)
                            collect `(,pole ,pole-value)
                            collect `(,(format-symbol :incudine.vug "~A~D" a i)
                                       (fractal-noise-coeff-calc ,pole))
                            collect `(,zero (* ,pole ,c2))
                            collect `(,(format-symbol :incudine.vug "~A~D" b i)
                                       (fractal-noise-coeff-calc ,zero)))
                    ,@(loop for i from 1 to (/ filter-order 2)
                            for j from 1 by 2
                            for input = in then sec-name
                            for sec-name = (format-symbol :incudine.vug "~A~D" sec i)
                            for b1 = (format-symbol :incudine.vug "~A~D" b j)
                            for b2 = (format-symbol :incudine.vug "~A~D" b (1+ j))
                            for a1 = (format-symbol :incudine.vug "~A~D" a j)
                            for a2 = (format-symbol :incudine.vug "~A~D" a (1+ j))
                            collect `(,sec-name (biquad ,input 1 (+ ,b1 ,b2) (* ,b1 ,b2)
                                                        1 (+ ,a1 ,a2) (* ,a1 ,a2)))))
       (* ,amp ,(let ((last-sec (format-symbol :incudine.vug "~A~D"
                                               sec (floor (/ filter-order 2)))))
                  (if (oddp filter-order)
                      `(biquad ,last-sec
                               1 ,(format-symbol :incudine.vug "~A~D" b filter-order)
                               0 1 ,(format-symbol :incudine.vug "~A~D" a filter-order) 0)
                      last-sec))))))
