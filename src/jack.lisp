;;; Copyright (c) 2013-2016 Tito Latini
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

(in-package :incudine.external)

(cffi:defcfun ("ja_initialize" rt-audio-init) :int
  (sample-rate sample)
  (input-channels :unsigned-int)
  (output-channels :unsigned-int)
  (frames-per-buffer :unsigned-int)
  (client-name :pointer)
  (sample-counter-ptr :pointer))

(cffi:defcfun ("ja_start" rt-audio-start) :int)

(cffi:defcfun ("ja_stop" rt-audio-stop) :int)

(declaim (inline rt-set-io-buffers))
(cffi:defcfun ("ja_set_lisp_io" rt-set-io-buffers) :void
  (input :pointer)
  (output :pointer))

(declaim (inline rt-cycle-begin))
(cffi:defcfun ("ja_cycle_begin" rt-cycle-begin) :uint32)

(declaim (inline rt-cycle-end))
(cffi:defcfun ("ja_cycle_end" rt-cycle-end) :void
  (frames :uint32))

(cffi:defcfun ("ja_get_cycle_start_time" rt-cycle-start-time) sample)

(cffi:defcfun ("ja_client" rt-client) :pointer)

(declaim (inline rt-condition-wait))
(cffi:defcfun ("ja_condition_wait" rt-condition-wait) :void)

(declaim (inline rt-transfer-to-c-thread))
(cffi:defcfun ("ja_transfer_to_c_thread" rt-transfer-to-c-thread) :void)

(declaim (inline rt-buffer-size))
(cffi:defcfun ("ja_get_buffer_size" rt-buffer-size) :int)

(declaim (inline rt-sample-rate))
(cffi:defcfun ("ja_get_sample_rate" rt-sample-rate) sample)

(declaim (inline rt-set-busy-state))
(cffi:defcfun ("ja_set_lisp_busy_state" rt-set-busy-state) :void
  (status :boolean))

(cffi:defcfun ("ja_get_error_msg" rt-get-error-msg) :string)

(cffi:defcfun ("ja_silent_errors" rt-silent-errors) :void
  (silent-p :boolean))

(defun silent-jack-errors ()
  (rt-silent-errors t))