;;; Copyright (c) 2013-2014 Tito Latini
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

(in-package :incudine)

(defvar *init-p* t)
(declaim (type boolean *init-p*))

;;; Borrowed from sbcl/src/code/late-extensions.lisp
(defun call-hooks (kind hooks &key (on-error :error))
  (dolist (hook hooks)
    (handler-case
        (funcall hook)
      (error (c)
        (if (eq :warn on-error)
            (warn "Problem running ~A hook ~S:~%  ~A" kind hook c)
            (with-simple-restart (continue "Skip this ~A hook." kind)
              (error "Problem running ~A hook ~S:~%  ~A" kind hook c)))))))

(defun init (&optional force-p)
  (when (or force-p *init-p*)
    (call-hooks "Incudine initialization" *initialize-hook*)
    (setf *init-p* nil)
    t))

;;; FUNCTIONS are generated by the function defined with DSP!.
;;; The last function is an arbitrary function without arguments;
;;; it is useful to define recursive sequences.
(defmacro dsp-seq (&rest functions)
  (with-gensyms (n)
    (labels ((%dsp-seq (functions)
               (if (null functions)
                   nil
                   (if (cdr functions)
                       (append (car functions)
                               (list :stop-hook
                                     `(list (lambda (,n)
                                              (declare (ignore ,n))
                                              ,(%dsp-seq (cdr functions))))))
                       (car functions)))))
      (%dsp-seq functions))))

(defgeneric free (obj))

(defgeneric free-p (obj))

(defmacro copy-struct-slots (struct-name slot-names from to)
  `(setf ,@(loop for name in slot-names
                 for slot-name = (format-symbol *package* "~A-~A"
                                                struct-name name)
                 collect `(,slot-name ,to)
                 collect `(,slot-name ,from))))

(in-package :incudine.util)

;;; TYPES

;; NON-NEGATIVE-FIXNUM64 used to get a better optimization
;; on 64bit machines. MOST-POSITIVE-FIXNUM 2^59-1 is good
;; at least with SBCL and CCL.
(define-constant most-positive-fixnum64 (1- (ash 1 59)))

(deftype non-negative-fixnum64 () '(integer 0 #.(1- (ash 1 59))))

;; FLOAT with arbitrary range between -2^63 and 2^63.
;; Used in SBCL on X86 with SIN, COS and TAN.
(deftype limited-sample () (let ((high (coerce 4.0e18 'sample)))
                             `(,*sample-type* ,(- high) ,high)))

(deftype maybe-limited-sample () #+(and sbcl x86) 'limited-sample
                                 #-(and sbcl x86) 'sample)

(deftype channel-number () '(integer 0 1023))

(deftype bus-number () '(integer 0 16383))

;;; MISC

(defvar *dummy-function-without-args* (lambda ()))
(declaim (type function *dummy-function-without-args*))

(defvar *sf-metadata-keywords*
  '(:title :copyright :software :artist :comment
    :date :album :license :tracknumber :genre))

(declaim (inline incudine-version))
(defun incudine-version ()
  #.(format nil "~D.~D.~D"
            incudine.config::+incudine-major+
            incudine.config::+incudine-minor+
            incudine.config::+incudine-patch+))

(defmacro with-ensure-symbol (names &body forms)
  `(let ,(mapcar (lambda (name) `(,name (ensure-symbol ,(symbol-name name))))
                 names)
     ,@forms))

;;; Defined as macro to reduce the inlined functions inside the
;;; definition of a DSP
(defmacro sample (number)
  `(coerce ,number 'sample))

(defun apply-sample-coerce (form)
  (if (atom form)
      (cond ((and (numberp form) (floatp form))
             (sample form))
            ((eq form 'pi) '(sample pi))
            (t form))
      (cons (apply-sample-coerce (car form))
            (apply-sample-coerce (cdr form)))))

(defun alloc-multi-channel-data (channels size)
  (declare (type channel-number channels) (type positive-fixnum size))
  (let ((ptr (cffi:foreign-alloc :pointer :count channels)))
    (dotimes (ch channels ptr)
      (declare (type channel-number ch))
      (setf (cffi:mem-aref ptr :pointer ch)
            (foreign-alloc-sample size)))))

(defun free-multi-channel-data (data channels)
  (dotimes (ch channels)
    (let ((frame (cffi:mem-aref data :pointer ch)))
      (unless (cffi:null-pointer-p frame)
        (foreign-free frame))))
  (foreign-free data)
  (values))

(defmacro dochannels ((var channels &optional (result nil))
                      &body body)
  `(do ((,var 0 (1+ ,var)))
       ((>= ,var ,channels) ,result)
     (declare (type channel-number ,var))
     ,@body))

(declaim (inline lin->db))
(defun lin->db (x)
  (let ((in (if (zerop x) least-positive-sample x)))
    (* (sample 20) (log in (sample 10)))))

(declaim (inline db->lin))
(defun db->lin (x)
  (expt (sample 10) (* x (sample 0.05))))

(declaim (inline linear-interp))
(defun linear-interp (in y0 y1)
  (declare (type sample in y0 y1))
  (+ y0 (* in (- y1 y0))))

(declaim (inline cos-interp))
(defun cos-interp (in y0 y1)
  (declare (type sample in y0 y1))
  (linear-interp (* (- 1 (cos (the limited-sample (* in (sample pi)))))
                    0.5) y0 y1))

;;; Catmull-Rom spline
(declaim (inline cubic-interp))
(defun cubic-interp (in y0 y1 y2 y3)
  (declare (type sample in y0 y1 y2 y3))
  (let ((a0 (+ (* -0.5 y0) (* 1.5 y1) (* -1.5 y2) (* 0.5 y3)))
        (a1 (+ y0 (* -2.5 y1) (* 2.0 y2) (* -0.5 y3)))
        (a2 (+ (* -0.5 y0) (* 0.5 y2))))
    (+ (* in (+ (* in (+ (* a0 in) a1)) a2)) y1)))

(declaim (inline t60->pole))
(defun t60->pole (time)
  "Return a real pole for a 60dB exponential decay in TIME seconds."
  (if (plusp time)
      ;; tau = time / log(0.001) = time / 6.9077
      (exp (/ (* +log001+ *sample-duration*) time))
      +sample-zero+))

(declaim (inline set-sample-rate))
(defun set-sample-rate (value)
  (setf *sample-rate* (sample value)
        *sample-duration* (/ 1.0 *sample-rate*))
  (mapc #'funcall sample-rate-hook)
  (mapc #'funcall sample-duration-hook)
  *sample-rate*)

(declaim (inline set-sample-duration))
(defun set-sample-duration (value)
  (setf *sample-duration* (sample value)
        *sample-rate* (/ 1.0 *sample-duration*))
  (mapc #'funcall sample-rate-hook)
  (mapc #'funcall sample-duration-hook)
  *sample-duration*)

(declaim (inline set-sound-velocity))
(defun set-sound-velocity (value)
  (setf *sound-velocity*   (sample value)
        *r-sound-velocity* (/ 1.0 *sound-velocity*))
  (mapc #'funcall sound-velocity-hook)
  *sound-velocity*)

(declaim (inline sample->fixnum))
(defun sample->fixnum (x)
  (declare (type (sample
                  #.(coerce (ash most-negative-fixnum -1) 'sample)
                  #.(coerce (ash most-positive-fixnum -1) 'sample)) x))
  (multiple-value-bind (result rem) (floor x)
    (declare (ignore rem))
    result))

(declaim (inline sample->int))
(defun sample->int (x)
  (declare (type sample x))
  (multiple-value-bind (result rem) (floor x)
    (declare (ignore rem))
    result))

(declaim (inline calc-lobits))
(defun calc-lobits (size)
  (declare (type non-negative-fixnum size))
  (if (>= size +table-maxlen+)
      0
      (do ((i size (ash i 1))
           (lobits 0 (1+ lobits)))
          ((plusp (logand i +table-maxlen+)) lobits)
        (declare (type non-negative-fixnum i lobits)))))

(declaim (inline rt-thread-p))
(defun rt-thread-p ()
  (eq (bt:current-thread) *rt-thread*))

(declaim (inline allow-rt-memory-p))
(defun allow-rt-memory-p ()
  (and (rt-thread-p) *allow-rt-memory-pool-p*))

(defmacro smp-ref (samples index)
  `(mem-ref ,samples 'sample (the non-negative-fixnum
                                  (* ,index +foreign-sample-size+))))

(defmacro with-complex (real-and-imag-vars pointer &body body)
  `(symbol-macrolet ((,(car real-and-imag-vars) (smp-ref ,pointer 0))
                     (,(cadr real-and-imag-vars) (smp-ref ,pointer 1)))
     ,@body))

(defmacro do-complex ((realpart-var imagpart-var pointer size) &body body)
  (with-gensyms (i addr)
    `(do ((,i 0 (1+ ,i))
          (,addr (pointer-address ,pointer)
                 (pointer-address (inc-pointer (make-pointer ,addr)
                                               +foreign-complex-size+))))
         ((>= ,i ,size))
       (declare (type unsigned-byte ,i))
       (symbol-macrolet ((,realpart-var (foreign-slot-value (make-pointer ,addr)
                                          '(:struct sample-complex) 'realpart))
                         (,imagpart-var (foreign-slot-value (make-pointer ,addr)
                                          '(:struct sample-complex) 'imagpart)))
         ,@body))))
