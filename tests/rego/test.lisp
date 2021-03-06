(in-package :incudine-tests)

(regofile->list-test regofile->list.1 "t1.rego"
  ((0.0 REGO-TEST-2 440 0.3 0.5 :ID 1)
   (0.8 REGO-TEST-2 880 0.3 0.5 :ID 2)
   (1.22 SET-CONTROL 1 :FREQ 200)
   (1.22 SET-CONTROL 2 :FREQ 208)
   (2.45 SET-CONTROLS 1 :FREQ 300 :AMP 0.1 :POS 0.1)
   (2.45 SET-CONTROLS 2 :FREQ 312 :AMP 0.1 :POS 0.9)
   (3.49 SET-CONTROL 1 :FREQ 220)
   (3.49 SET-CONTROL 2 :FREQ 231)
   (4.9 FREE 0)))

(regofile->list-test regofile->list.2 "t2.rego"
  ((0.0 REGO-TEST-2 440 0.3 0.5 :ID 1)
   (0.8 REGO-TEST-2 880 0.3 0.5 :ID 2)
   (1.22 SET-CONTROL 1 :FREQ 200)
   (1.22 SET-CONTROL 2 :FREQ 208)
   (2.45 SET-CONTROLS 1 :FREQ 300 :AMP 0.1 :POS 0.1)
   (2.45 SET-CONTROLS 2 :FREQ 312 :AMP 0.1 :POS 0.9)
   (3.49 SET-CONTROL 1 :FREQ 220)
   (3.49 SET-CONTROL 2 :FREQ 231)
   (4.9 FREE 0)))

(regofile->list-test regofile->list.3 "loop-1.rego"
  ((0.0 REGO-TEST-1 440 0.2 :ID 1)
   (1.0 REGO-TEST-1 448 0.2 :ID 2)
   (3.0 REGO-TEST-1 661 0.2 :ID 3)
   (4.0 FREE 0)))

(regofile->list-test regofile->list.4 "jump-1.rego"
  ((0.0 REGO-TEST-3 440 0.3 0.3)
   (0.5 REGO-TEST-3 660 0.3 0.29)
   (0.98 REGO-TEST-3 880 0.3 0.28)
   (1.45 REGO-TEST-3 1100 0.3 0.27)
   (1.88 REGO-TEST-3 1320 0.3 0.25)
   (2.28 REGO-TEST-3 1540 0.3 0.23)
   (2.64 REGO-TEST-3 1760 0.3 0.21)
   (2.95 REGO-TEST-3 1980 0.3 0.19)
   (3.22 REGO-TEST-3 2200 0.3 0.18)
   (3.45 REGO-TEST-3 2420 0.3 0.17)
   (3.65 REGO-TEST-3 2640 0.3 0.16)
   (3.83 REGO-TEST-3 2860 0.3 0.15)
   (4.0 REGO-TEST-3 3080 0.3 0.14)
   (4.17 REGO-TEST-3 3300 0.3 0.14)))

(regofile->list-test regofile->list.5 "test-1.sco"
  ((0.0 REGO-TEST-3 440 0.3 2.2)
   (1.0 REGO-TEST-3 448 0.2 1.35)
   (1.5 REGO-TEST-3 666 0.2 3.0)
   (2.8 REGO-TEST-3 881 0.1 1.95)
   (3.2 REGO-TEST-3 220 0.1 0.88)))

(regofile->list-test regofile->list.6 "test-2.sco"
  ((0.0 REGO-TEST-3 440 0.3 2.2)
   (1.0 REGO-TEST-3 448 0.2 1.35)
   (1.5 REGO-TEST-3 666 0.2 3.0)
   (2.8 REGO-TEST-3 881 0.1 1.95)
   (3.2 REGO-TEST-3 220 0.1 0.88)))

;; Error caused by a recursive inclusion.
(regofile->list-test regofile->list.7 "include-loop-1.rego"
  ((0.0 REGO-TEST-2 880 0.2 0.2)
   (0.0 REGO-TEST-2 660 0.2 0.8)
   (2.0 REGO-TEST-2 440 0.3 0)
   (2.0 REGO-TEST-2 447 0.3 1)))

(regofile->list-test regofile->list.8 "include-1.rego"
  ((0.0 REGO-TEST-1 440 0.2 :ID 1)
   (0.5 REGO-TEST-1 448 0.2 :ID 2)
   (1.5 REGO-TEST-1 661 0.2 :ID 3)
   (2.0 FREE 0)
   (2.05 REGO-TEST-3 440 0.3 1.1)
   (2.55 REGO-TEST-3 448 0.2 0.68)
   (2.8 REGO-TEST-3 666 0.2 1.5)
   (3.0 REGO-TEST-3 1100 0.3 1.5)
   (3.45 REGO-TEST-3 881 0.1 0.98)
   (3.65 REGO-TEST-3 220 0.1 0.44)))

;; Include four times the same rego file.
(regofile->list-test regofile->list.9 "include-2.rego"
  ((0.0 REGO-TEST-1 440 0.2 :ID 1)
   (0.25 REGO-TEST-1 448 0.2 :ID 2)
   (0.75 REGO-TEST-1 661 0.2 :ID 3)
   (1.0 FREE 0)
   (1.27 REGO-TEST-1 440 0.2 :ID 1)
   (1.27 REGO-TEST-1 220 0.2 :ID 97)
   (1.52 REGO-TEST-1 448 0.2 :ID 2)
   (2.02 REGO-TEST-1 661 0.2 :ID 3)
   (2.27 FREE 0)
   (2.53 REGO-TEST-1 440 0.2 :ID 1)
   (2.78 REGO-TEST-1 448 0.2 :ID 2)
   (3.28 REGO-TEST-1 661 0.2 :ID 3)
   (3.53 FREE 0)
   (3.77 REGO-TEST-1 220 0.2 :ID 97)
   (3.78 REGO-TEST-1 440 0.2 :ID 1)
   (4.03 REGO-TEST-1 448 0.2 :ID 2)
   (4.53 REGO-TEST-1 661 0.2 :ID 3)
   (4.78 FREE 0)))

;; Lisp tag shadowed in the included rego file.
(regofile->list-test regofile->list.10 "include-3.rego"
  ((0.0 REGO-TEST-3 114 0.3 0.3)
   (0.05 REGO-TEST-3 228 0.3 0.3)
   (0.1 REGO-TEST-3 342 0.3 0.3)
   (0.5 REGO-TEST-3 456 0.3 0.29)
   (0.55 REGO-TEST-3 570 0.3 0.29)
   (0.6 REGO-TEST-3 684 0.3 0.29)
   (0.98 REGO-TEST-3 798 0.3 0.28)
   (1.03 REGO-TEST-3 912 0.3 0.28)
   (1.08 REGO-TEST-3 1026 0.3 0.28)
   (1.45 REGO-TEST-3 1140 0.3 0.27)
   (1.5 REGO-TEST-3 1254 0.3 0.26)
   (1.55 REGO-TEST-3 1368 0.3 0.26)
   (1.88 REGO-TEST-3 1482 0.3 0.25)
   (1.93 REGO-TEST-3 1596 0.3 0.25)
   (1.98 REGO-TEST-3 1710 0.3 0.24)
   (2.28 REGO-TEST-3 1824 0.3 0.23)
   (2.33 REGO-TEST-3 1938 0.3 0.23)
   (2.38 REGO-TEST-3 2052 0.3 0.22)
   (2.64 REGO-TEST-3 2166 0.3 0.21)
   (2.69 REGO-TEST-3 2280 0.3 0.21)
   (2.74 REGO-TEST-3 2394 0.3 0.21)
   (2.95 REGO-TEST-3 2508 0.3 0.19)
   (3.0 REGO-TEST-3 2622 0.3 0.19)
   (3.05 REGO-TEST-3 2736 0.3 0.19)
   (3.22 REGO-TEST-3 2850 0.3 0.18)
   (3.27 REGO-TEST-3 2964 0.3 0.18)
   (3.32 REGO-TEST-3 3078 0.3 0.18)
   (3.45 REGO-TEST-3 3192 0.3 0.17)
   (3.5 REGO-TEST-3 3306 0.3 0.17)
   (3.55 REGO-TEST-3 3420 0.3 0.16)
   (3.65 REGO-TEST-3 3534 0.3 0.16)
   (3.7 REGO-TEST-3 3648 0.3 0.16)
   (3.75 REGO-TEST-3 3762 0.3 0.15)
   (3.83 REGO-TEST-3 3876 0.3 0.15)
   (3.88 REGO-TEST-3 3990 0.3 0.15)
   (3.93 REGO-TEST-3 4104 0.3 0.15)
   (4.0 REGO-TEST-3 4218 0.3 0.14)
   (4.05 REGO-TEST-3 4332 0.3 0.14)
   (4.1 REGO-TEST-3 4446 0.3 0.14)
   (4.17 REGO-TEST-3 4560 0.3 0.14)
   (4.22 REGO-TEST-3 4674 0.3 0.13)
   (4.27 REGO-TEST-3 4788 0.3 0.13)))

(regofile->list-test regofile->list.11 "org-mode.rego"
  ((0.0 REGO-TEST-1 440 0.5)
   (0.44 REGO-TEST-1 448 0.35)
   (0.89 REGO-TEST-1 2200 0.1)
   (1.33 REGO-TEST-1 770 0.03)
   (1.56 REGO-TEST-1 880 0.03)
   (1.78 REGO-TEST-1 990 0.03)
   (2.0 REGO-TEST-1 1100 0.03)
   (3.11 FREE 0)))

(regofile->list-test regofile->list.12 "paral-1.rego"
  ((0.0 REGO-TEST-1 440 0.08)
   (0.0 REGO-TEST-1 550 0.1)
   (0.0 REGO-TEST-1 660 0.05)
   (0.0 REGO-TEST-1 770 0.1)
   (1.5 REGO-TEST-1 330 0.03)
   (2.3 REGO-TEST-1 220 0.02)
   (2.3 REGO-TEST-1 772 0.07)))

(regofile->list-test regofile->list.13 "paral-2.rego"
  ((0.0 REGO-TEST-1 440 0.08)
   (0.0 REGO-TEST-1 550 0.1)
   (0.0 REGO-TEST-1 770 0.1)
   (1.5 REGO-TEST-1 330 0.03)
   (2.3 REGO-TEST-1 220 0.02)
   (2.3 REGO-TEST-1 772 0.07)))

(with-dsp-test (rego.1 :channels 2
      :md5 #(245 220 65 244 25 76 31 230 109 144 248 153 16 170 160 134))
  (test-regofile "t1.rego"))

(with-dsp-test (rego.2 :channels 2
      :md5 #(245 220 65 244 25 76 31 230 109 144 248 153 16 170 160 134))
  (test-regofile "t2.rego"))

(with-dsp-test (rego.3
      :md5 #(151 116 137 222 25 122 7 35 219 181 202 137 145 62 243 213))
  (test-regofile "loop-1.rego"))

(with-dsp-test (rego.4 :channels 2
      :md5 #(192 230 74 116 183 85 84 254 178 104 90 143 40 64 30 174))
  (test-regofile "jump-1.rego"))

(with-dsp-test (sco.1 :channels 2
      :md5 #(149 130 145 190 25 180 110 107 19 22 165 34 75 197 126 100))
  (test-regofile "test-1.sco"))

(with-dsp-test (sco.2 :channels 2
      :md5 #(149 130 145 190 25 180 110 107 19 22 165 34 75 197 126 100))
  (test-regofile "test-2.sco"))

(with-dsp-test (include-rego-loop-error :channels 2
      :md5 #(224 78 104 237 105 222 73 188 82 233 83 242 152 133 181 19))
  ;; Error caused by a recursive inclusion.
  (test-regofile "include-loop-1.rego"))

(with-dsp-test (include-rego.1 :channels 2
      :md5 #(56 166 167 61 131 160 225 141 167 208 51 30 97 92 54 119))
  (test-regofile "include-1.rego"))

(with-dsp-test (include-rego.2
      :md5 #(135 85 80 12 247 185 67 6 96 133 75 171 136 8 254 246))
  ;; Include four times the same rego file.
  (test-regofile "include-2.rego"))

(with-dsp-test (include-rego.3 :channels 2
      :md5 #(98 130 80 23 173 199 134 29 162 36 18 244 15 47 123 198))
  ;; Lisp tag shadowed in the included rego file.
  (test-regofile "include-3.rego"))

(with-dsp-test (org-mode.1
      :md5 #(216 196 146 164 88 88 197 20 138 165 207 215 200 7 22 251))
  (test-regofile "org-mode.rego"))

(with-dsp-test (paral.1
      :md5 #(132 22 147 114 139 210 67 6 172 195 244 193 123 100 193 191))
  (test-regofile "paral-1.rego"))

(with-dsp-test (paral.2
      :md5 #(225 98 8 15 231 24 109 114 111 196 54 172 233 204 51 11))
  (test-regofile "paral-2.rego"))
