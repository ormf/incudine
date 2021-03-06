(in-package :incudine-tests)

(defun gen-partials-test-1 (lst)
  (cffi:with-foreign-object (arr 'sample 64)
    (funcall (gen:partials lst) arr 64)
    (loop for i below 64 collect (sample->fixnum (smp-ref arr i)))))

(deftest gen-partials.1
    (gen-partials-test-1 '(100))
  (0 9 19 29 38 47 55 63 70 77 83 88 92 95 98 99 100 99 98 95 92 88 83
   77 70 63 55 47 38 29 19 9 0 -10 -20 -30 -39 -48 -56 -64 -71 -78 -84
   -89 -93 -96 -99 -100 -100 -100 -99 -96 -93 -89 -84 -78 -71 -64 -56
   -48 -39 -30 -20 -10))

(deftest gen-partials.2
    (gen-partials-test-1 '(100 0 50 0 25 0 12 0 6 0 3 0 1))
  (0 51 88 105 106 101 96 91 85 79 75 72 70 69 67 67 67 67 67 69 70 72
   75 79 85 91 96 101 106 105 88 51 0 -52 -89 -106 -107 -102 -97 -92 -86
   -80 -76 -73 -71 -70 -68 -68 -67 -68 -68 -70 -71 -73 -76 -80 -86 -92 -97
   -102 -107 -106 -89 -52))

(deftest gen-partials.3
    (gen-partials-test-1 '((1 100) (3 50) (5 25) (7 12) (9 6) (11 3) (13 1)))
  (0 51 88 105 106 101 96 91 85 79 75 72 70 69 67 67 67 67 67 69 70 72
   75 79 85 91 96 101 106 105 88 51 0 -52 -89 -106 -107 -102 -97 -92 -86
   -80 -76 -73 -71 -70 -68 -68 -67 -68 -68 -70 -71 -73 -76 -80 -86 -92 -97
   -102 -107 -106 -89 -52))

(deftest gen-partials.4
    (gen-partials-test-1 '((1 50 .75 50)))
  (0 0 0 2 3 5 8 11 14 18 22 26 30 35 40 45 49 54 59 64 69 73 77 81 85 88
   91 94 96 97 99 99 100 99 99 97 96 94 91 88 85 81 77 73 69 64 59 54 50
   45 40 35 30 26 22 18 14 11 8 5 3 2 0 0))

(deftest gen-partials.5
    (let ((buf (make-buffer 64 :fill-function (gen:partials '((1 50 .75 50))
                                                            :normalize-p nil))))
      (loop for i below 64
            collect (sample->fixnum (smp-ref (buffer-data buf) i))))
  (0 0 0 2 3 5 8 11 14 18 22 26 30 35 40 45 49 54 59 64 69 73 77 81 85 88
   91 94 96 97 99 99 100 99 99 97 96 94 91 88 85 81 77 73 69 64 59 54 50
   45 40 35 30 26 22 18 14 11 8 5 3 2 0 0))

(deftest gen-partials.6
    (let ((buf (make-buffer 64)))
      (fill-buffer buf (gen:partials '(100) :normalize-p nil))
      (loop for i below 64
            collect (sample->fixnum (smp-ref (buffer-data buf) i))))
  (0 9 19 29 38 47 55 63 70 77 83 88 92 95 98 99 100 99 98 95 92 88 83
   77 70 63 55 47 38 29 19 9 0 -10 -20 -30 -39 -48 -56 -64 -71 -78 -84
   -89 -93 -96 -99 -100 -100 -100 -99 -96 -93 -89 -84 -78 -71 -64 -56
   -48 -39 -30 -20 -10))

(deftest gen-partials.7
    (with-cleanup
      (flet ((partest (lst)
               (mapcar #'sample->fixnum
                 (buffer->list
                   (make-buffer 16
                     :fill-function (gen:partials lst :normalize-p nil))))))
        (equal (partest '(1000 -1000 1000 -1000))
               (partest '(1000 (2 1000 .5) 1000 (4 1000 .5))))))
  t)

(defun quasi-sawtooth-test (partials)
  (loop for i from 1 to partials
        with s = #(1 1 -1 -1)
        collect (* (svref s (logand i 3)) (/ 100 i))))

(defun gen-chebyshev-test-1 (&key (mult 1000) offset-p)
  (cffi:with-foreign-object (arr 'sample 64)
    (funcall (gen:chebyshev-1 (quasi-sawtooth-test 20) :offset-p offset-p)
             arr 64)
    (loop for i below 64
          collect (sample->fixnum (* mult (smp-ref arr i))))))

(deftest gen-chebyshev-1.1
    (gen-chebyshev-test-1)
  (-108328 -109507 -107281 -112973 -109628 -101386 -97255 -99190 -102773 -102925
   -98001 -90201 -83373 -80349 -81407 -84389 -86049 -83776 -76834 -66655 -56152
   -48429 -45415 -46942 -50592 -52324 -47688 -33221 -7597 27801 69056 110584
   146448 171757 183786 182523 170520 152104 132192 115043 103276 97435 96179
   97012 97294 95198 90287 83511 76663 71495 68882 68412 68621 67809 65047 60793
   56648 54214 53719 53575 51770 48409 46264 45985))

(deftest gen-chebyshev-1.2
    (gen-chebyshev-test-1 :offset-p t)
  (-254777 -255956 -253730 -259422 -256077 -247834 -243703 -245638
   -249222 -249373 -244450 -236650 -229822 -226797 -227855 -230837
   -232498 -230225 -223283 -213103 -202600 -194878 -191863 -193391
   -197041 -198773 -194137 -179669 -154045 -118648 -77393 -35864
   0
   25308 37337 36075 24072 5655 -14256 -31406 -43173 -49013 -50269
   -49437 -49155 -51250 -56162 -62937 -69785 -74953 -77566 -78036
   -77827 -78639 -81401 -85655 -89801 -92235 -92729 -92873 -94678
   -98040 -100185 -100463))
