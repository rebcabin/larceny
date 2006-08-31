; Copyright 1998 Lars T Hansen.
;
; $Id$
;
; Larceny FFI -- simple load script.

(define (load-ffi)

  (define architecture
    (let* ((f   (system-features))
	   (os  (cdr (assq 'os-name f)))
	   (maj (cdr (assq 'os-major-version f))))
      (cond ((string=? os "SunOS")
	     (case maj
	       ((4) 'sun4-sunos4)
	       ((5) 'sun4-sunos5)
	       (else 
		(error "FFI: unsupported SunOS version " maj))))
	    ((string=? os "Win32")
	     'i386-win32)
	    ((and (string=? os "Linux")
		  (zero?
		   (system "test \"`uname -m | grep 'i.86'`x\" != \"x\"")))
	     'i386-linux)
	    (else
	     (error "FFI: unsupported operating system " os)))))

  (require "memory")			; For non-conservative collectors
  (require "tramp")			; Trampoline builder (driver)
  (require "ffi-lower")		; FFI/apply and all that
  (require "ffi-upper")		; High-level load/link code
  (require "ffi-util")		; Data conversion

  (case architecture
    ((sun4-sunos4)
     (require "ffi-sparc")
     (require "ffi-sunos4")
     (ffi/libraries (list (ffi/sun4-sunos4-libc)))
     (values architecture
	     ffi/SPARC-sunos4-C-callout-stdabi
	     ffi/SPARC-sunos4-C-callback-stdabi))
    ((sun4-sunos5)
     (require "ffi-sparc")
     (require "ffi-sunos5")
     (ffi/libraries (list (ffi/sun4-sunos5-libc)))
     (values architecture
	     ffi/SPARC-sunos5-C-callout-stdabi
	     ffi/SPARC-sunos5-C-callback-stdabi))
    ((i386-win32)
     (require "ffi-i386")
     (require "ffi-win32")
     (values architecture
	     ffi/i386-win32-C-callout-cdecl
	     #f))
    ((i386-linux)
     (require "ffi-i386")
     (require "ffi-linux-x86")
     (ffi/libraries (list (ffi/x86-linux-libc)))
     (values architecture
	     ffi/i386-linux-C-callout-cdecl
	     #f))
    (else
     (error "Unknown FFI architecture " *ffi-architecture*))))

; eof