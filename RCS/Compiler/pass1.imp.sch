; MacScheme v4 compiler; Larceny version
; Implementation-defined stuff for pass 1.
;
; $Id$

(define hash-bang-unspecified '#&(a))

(define **macros**
  `((and ,(lambda (l)
	    (cond ((null? (cdr l)) #t)
		  ((null? (cddr l)) (cadr l))
		  (else (let ((temp (gensym "T")))
			  `(let ((,temp ,(cadr l)))
			     (if ,temp (and ,@(cddr l)) #f)))))))
    (case ,(lambda (l)
	     (error "Case not implemented.")))
    (let* ,(lambda (l)
	     (error "let* not implemented.")))))

; What about these?
;
; (define-macro caar (lambda (l) `(car (car ,(cadr l)))))
; (define-macro cadr (lambda (l) `(car (cdr ,(cadr l)))))
; (define-macro cdar (lambda (l) `(cdr (car ,(cadr l)))))
; (define-macro cddr (lambda (l) `(cdr (cdr ,(cadr l)))))
; (define-macro caaar (lambda (l) `(car (car (car ,(cadr l))))))
; (define-macro caadr (lambda (l) `(car (car (cdr ,(cadr l))))))
; (define-macro cadar (lambda (l) `(car (cdr (car ,(cadr l))))))
; (define-macro caddr (lambda (l) `(car (cdr (cdr ,(cadr l))))))
; (define-macro cdaar (lambda (l) `(cdr (car (car ,(cadr l))))))
; (define-macro cdadr (lambda (l) `(cdr (car (cdr ,(cadr l))))))
; (define-macro cddar (lambda (l) `(cdr (cdr (car ,(cadr l))))))
; (define-macro cdddr (lambda (l) `(cdr (cdr (cdr ,(cadr l))))))
; (define-macro caaaar (lambda (l) `(car (car (car (car ,(cadr l)))))))
; (define-macro caaadr (lambda (l) `(car (car (car (cdr ,(cadr l)))))))
; (define-macro caadar (lambda (l) `(car (car (cdr (car ,(cadr l)))))))
; (define-macro caaddr (lambda (l) `(car (car (cdr (cdr ,(cadr l)))))))
; (define-macro cadaar (lambda (l) `(car (cdr (car (car ,(cadr l)))))))
; (define-macro cadadr (lambda (l) `(car (cdr (car (cdr ,(cadr l)))))))
; (define-macro caddar (lambda (l) `(car (cdr (cdr (car ,(cadr l)))))))
; (define-macro cadddr (lambda (l) `(car (cdr (cdr (cdr ,(cadr l)))))))
; (define-macro cdaaar (lambda (l) `(cdr (car (car (car ,(cadr l)))))))
; (define-macro cdaadr (lambda (l) `(cdr (car (car (cdr ,(cadr l)))))))
; (define-macro cdadar (lambda (l) `(cdr (car (cdr (car ,(cadr l)))))))
; (define-macro cdaddr (lambda (l) `(cdr (car (cdr (cdr ,(cadr l)))))))
; (define-macro cddaar (lambda (l) `(cdr (cdr (car (car ,(cadr l)))))))
; (define-macro cddadr (lambda (l) `(cdr (cdr (car (cdr ,(cadr l)))))))
; (define-macro cdddar (lambda (l) `(cdr (cdr (cdr (car ,(cadr l)))))))
; (define-macro cddddr (lambda (l) `(cdr (cdr (cdr (cdr ,(cadr l)))))))

(extend-syntax (define-macro)
  ((define-macro boing-keyword boing-transformer)
   (install-macro (quote boing-keyword) boing-transformer)))

(define $usual-integrable-procedures$
  `((debugvsm 0 debugvsm #f 0)
    (reset 0 reset #f 1)
    (exit 0 exit #f 2)
    (break 0 break #f 3)
    (time 0 time #f 4)
    (gc 1 gc #f 5)
    (dumpheap 0 dumpheap #f 6)
    (creg 0 creg #f 7)
    (undefined 0 undefined #f 8)
    
    ;(**identity** 1 identity #f #x10)
    (typetag 1 typetag #f #x11)
    (not 1 not #f #x18)
    (null? 1 null? #f #x19)
    (pair? 1 pair? #f #x1a)
    (car 1 car #f #x1b)
    (cdr 1 cdr #f #x1c)
    ;(length 1 length #f #x1d)
    (symbol? 1 symbol? #f #x1f)
    (number? 1 complex? #f #x20)
    (complex? 1 complex? #f #x20)
    (real? 1 rational? #f #x21)
    (rational? 1 rational? #f #x21)
    (integer? 1 integer? #f #x22)
    (fixnum? 1 fixnum? #f #x23)
    (exact? 1 exact? #f #x24)
    (inexact? 1 inexact? #f #x25)
    (exact->inexact 1 exact->inexact #f #x26)
    (inexact->exact 1 inexact->exact #f #x27)
    (round 1 round #f #x28)
    (truncate 1 truncate #f #x29)
    (zero? 1 zero? #f #x2c)
    (-- 1 -- #f #x2d)
    (lognot 1 lognot #f #x2f)
    (sqrt 1 sqrt #f #x38)
    (real-part 1 real-part #f #x3e)
    (imag-part 1 imag-part #f #x3f)
    (char? 1 char? #f #x40)
    (char->integer 1 char->integer #f #x41)
    (integer->char 1 integer->char #f #x42)
    (string? 1 string? #f #x50)
    (string-length 1 string-length #f #x51)
    (vector? 1 vector? #f #x52)
    (vector-length 1 vector-length #f #x53)
    (bytevector? 1 bytevector? #f #x54)
    (bytevector-length 1 bytevector-length #f #x55)
    (make-bytevector 1 make-bytevector #f #x56)
    (procedure? 1 procedure? #f #x58)
    (procedure-length 1 procedure-length #f #x59)
    (make-procedure 1 make-procedure #f #x5a)
    (creg-set! 1 creg-set! #f #x71)
    (make-cell 1 make-cell #f #x7e)
    (,(string->symbol "MAKE-CELL") 1 make-cell #f #x7e)
    (cell-ref 1 cell-ref #f #x7f)
    (,(string->symbol "CELL-REF") 1 cell-ref #f #x7f)
    
    ; These next few entries are for the disassembler only.
    
    (#f 2 typetag-set! #f #x80)
    (#f 2 eq? #f #x81)
    (#f 2 + #f #x82)
    (#f 2 - #f #x83)
    (#f 2 < #f #x84)
    (#f 2 <= #f #x85)
    (#f 2 = #f #x86)
    (#f 2 > #f #x87)
    (#f 2 >= #f #x88)
    (#f 2 char<? #f #x89)
    (#f 2 char<=? #f #x8a)
    (#f 2 char=? #f #x8b)
    (#f 2 char>? #f #x8c)
    (#f 2 char>=? #f #x8d)
    (#f 2 string-ref #f #x90)
    (#f 2 vector-ref #f #x91)
    (#f 2 bytevector-ref #f #x92)
    
    (typetag-set! 2 typetag-set! ,(lambda (x)
                                          (and (fixnum? x)
                                               (<= 0 x 7)))   ; used to be 31
                                 #xa0)
    (eq? 2 eq? ,byte? #xa1)
    (eqv? 2 eqv? #f #xa2)
    (cons 2 cons #f #xa8)
    (set-car! 2 set-car! #f #xa9)
    (set-cdr! 2 set-cdr! #f #xaa)
    ;(memq 2 memq #f #xab)
    ;(assq 2 assq #f #xac)
    (+ 2 + ,byte? #xb0)
    (- 2 - ,byte? #xb1)
    (* 2 * ,byte? #xb2)
    (/ 2 / #f #xb3)
    (quotient 2 quotient #f #xb4)
    (< 2 < ,byte? #xb5)
    (<= 2 <= ,byte? #xb6)
    (= 2 = ,byte? #xb7)
    (> 2 > ,byte? #xb8)
    (>= 2 >= ,byte? #xb9)
    (logand 2 logand #f #xc0)
    (logior 2 logior #f #xc1)
    (logxor 2 logxor #f #xc2)
    (lsh 2 lsh #f #xc3)
    (rot 2 rot #f #xc4)
    (make-rectangular 2 make-rectangular #f #xcf)
    (string-ref 2 string-ref ,byte? #xd1)
    (make-vector 2 make-vector #f #xd2)
    (vector-ref 2 vector-ref ,byte? #xd3)
    (bytevector-ref 2 bytevector-ref ,byte? #xd5)
    (procedure-ref 2 procedure-ref #f #xd7)
    (cell-set! 2 cell-set! #f #xdf)
    (,(string->symbol "CELL-SET!") 2 cell-set! #f #xdf)
    (char<? 2 char<? ,char? #xe0)
    (char<=? 2 char<=? ,char? #xe1)
    (char=? 2 char=? ,char? #xe2)
    (char>? 2 char>? ,char? #xe3)
    (char>=? 2 char>=? ,char? #xe4)
    
    (vector-set! 3 vector-set! #f #xf1)
    (bytevector-set! 3 bytevector-set! #f #xf2)
    (procedure-set! 3 procedure-set! #f #xf3)
    (bytevector-like? 1 bytevector-like? #f -1)
    (vector-like? 1 vector-like? #f -1)
    (bytevector-like-ref 2 bytevector-like-ref #f -1)
    (bytevector-like-set! 3 bytevector-like-set! #f -1)
    (vector-like-ref 2 vector-like-ref #f -1)
    (vector-like-set! 3 vector-like-set! #f -1)
    (vector-like-length 1 vector-like-length #f -1)
    (bytevector-like-length 1 bytevector-like-length #f -1)
    (remainder 2 remainder #f -1)
    (modulo 2 modulo #f -1)))

(define $immediate-primops$
  '((typetag-set! #x80)
    (eq? #x81)
    (+ #x82)
    (- #x83)
    (< #x84)
    (<= #x85)
    (= #x86)
    (> #x87)
    (>= #x88)
    (char<? #x89)
    (char<=? #x8a)
    (char=? #x8b)
    (char>? #x8c)
    (char>=? #x8d)
    (string-ref #x90)
    (vector-ref #x91)
    (bytevector-ref #x92)
    (bytevector-like-ref -1)
    (vector-like-ref -1)))
