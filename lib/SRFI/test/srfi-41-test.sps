; Test suite for SRFI-41
;
; $Id$
;
; Examples taken from the SRFI document and lightly modified.

; This is ERR5RS/R6RS code.
;
;(cond-expand (srfi-41))

(import (rnrs) (srfi :41 streams))

(define (writeln . xs)
  (for-each display xs)
  (newline))

(define (fail token . more)
  (writeln "Error: test failed: " token)
  #f)

(define (pythagorean-triples-using-streams n)
  (stream-ref
    (stream-of (list a b c)
      (n in (stream-from 1))
      (a in (stream-range 1 n))
      (b in (stream-range a n))
      (c is (- n a b))
      (= (+ (* a a) (* b b)) (* c c)))
    n))

(define (pythagorean-triples-using-loops nth)
  (call-with-current-continuation
   (lambda (return)
     (let ((count 0))
       (do ((n 1 (+ n 1)))
           ((> n 228))
         (do ((a 1 (+ a 1)))
             ((> a n))
           (do ((b a (+ b 1)))
               ((> b n))
             (let ((c (- n a b)))
               (if (= (+ (* a a) (* b b)) (* c c))
                   (begin (set! count (+ count 1))
                          (if (> count nth)
                              (return (list a b c)))))))))))))

(if (not (equal? (pythagorean-triples-using-streams 50)
                 (pythagorean-triples-using-loops 50)))
    (fail 'pythagorean-triples))

(writeln "Done.")

