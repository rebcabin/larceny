; Given a dfa in the representation generated by regexp.sch,
; construct a lexical analyzer written in Java.
; The states are integers beginning with 0.
; For the moment, comments and whitespace must be handled
; by editing the generated Java code.
; Also character classes such as letters and digits are best
; handled by editing the generated Java code.
;
; In short, this is quick-and-dirty code to save me the trouble
; of writing lexical analyzers in Java for my compiler classes.
; I may clean it up later, and make it more general.
;
; Uses output routines from ParseGen:parsegen.java.sch.

; Inelegant hacks.
; Whitespace is handled specially.
; The following symbols are recognized and treated specially:
;    letter
;    digit

(define character-classes
  `((letter ,(string->symbol "Character.isLetter"))
    (digit ,(string->symbol "Character.isDigit"))
    (space ,(string->symbol "Character.isWhitespace"))
    (lowercase ,(string->symbol "Character.isLowerCase"))
    (uppercase ,(string->symbol "Character.isUpperCase"))))

(define (generate-java-for-lexer dfa)
  (let ((dfa (mysort (lambda (entry1 entry2)
                       (let ((blocked1? (null? (nfa-entry-transitions entry1)))
                             (blocked2? (null? (nfa-entry-transitions entry2))))
                         (or (eq? entry1 (car dfa))
                             (and (not blocked1?) blocked2?)
                             (and (not blocked1?)
                                  (not blocked2?)
                                  (<= (nfa-entry-state entry1)
                                      (nfa-entry-state entry2)))
                             (and blocked1?
                                  blocked2?
                                  (<= (nfa-entry-state entry1)
                                      (nfa-entry-state entry2))))))
                     dfa)))
    (gen-java 4 "private int scanner0() {" #\newline)
    (gen-java 4 "    int state = 0\;" #\newline)
    (gen-java 4 "    char c = scanChar()\;" #\newline)
    (gen-java 4 #\newline)
    (gen-java 4 "    /*  Edit here to consume whitespace.  */" #\newline)
    (gen-java 4 "    while (Character.isWhitespace(c)) {" #\newline)
    (gen-java 4 "        consumeChar()\;" #\newline)
    (gen-java 4 "        string_accumulator.setLength(0)\;" #\newline)
    (gen-java 4 "        c = scanChar()\;" #\newline)
    (gen-java 4 "    }" #\newline)
    (gen-java 4 #\newline)
    (gen-java 4 "    if (c == EOF)" #\newline)
    (gen-java 4 "        return accept(Parser.zeof)\;" #\newline)
    (gen-java 4 "    else do switch (state) {" #\newline)
    (for-each (lambda (entry)
                (generate-java-for-lexer-state entry dfa))
              dfa)
    (gen-java 4 "        default:" #\newline)
    (gen-java 4 "            return scannerError(errIllegalChar)\;" #\newline)
    (gen-java 4 "    } while (state >= 0)\;" #\newline)
    (gen-java 4 "    return scannerError(errLexGenBug)\;" #\newline)
    (gen-java 4 "}" #\newline)
    (gen-java 4 #\newline)))

(define (generate-java-for-lexer-state entry dfa)
  (let ((transitions (nfa-entry-transitions entry))
        (gen-char-transitions
         (lambda (transitions)

           ; Given a list of transitions sorted by target,
           ; groups them by target and returns a list of
           ; the groups; each group is itself a list

           (define (group-by-target transitions)
             (define (loop target group groups transitions)
               (cond ((null? transitions)
                      (cons group groups))
                     ((= target (transition-target (car transitions)))
                      (loop target
                            (cons (car transitions) group)
                            groups
                            (cdr transitions)))
                     (else
                      (loop (transition-target (car transitions))
                            '()
                            (cons group groups)
                            transitions))))
             (if (null? transitions)
                 transitions
                 (loop (transition-target (car transitions))
                       '() '() transitions)))

           (let* ((transitions
                   (mysort (lambda (t1 t2)
                             (<= (transition-target t1)
                                 (transition-target t2)))
                           transitions))
                  (grouped-transitions
                   (group-by-target transitions)))

             (generate-java-for-char-transitions grouped-transitions dfa))))

        (gen-symbol-transition (lambda (t)
                                 (generate-java-for-symbol-transition t dfa)))

        (char-transition? (lambda (t)
                            (char? (transition-token t))))
        (symbol-transition? (lambda (t)
                              (not (char? (transition-token t))))))

    (if (not (null? transitions))
        (begin
         (gen-java 12 "case " (nfa-entry-state entry) ":" #\newline)
         (gen-java 12 "    switch (c) {" #\newline)
         (gen-char-transitions
          (filter char-transition? transitions))
         (gen-java 12 "        default:" #\newline)
         (for-each gen-symbol-transition
                   (filter symbol-transition? transitions))
         (generate-java-for-blocked-state 24 entry)
         (gen-java 12 "    }" #\newline)
         (gen-java 12 "    break\;" #\newline)))))

(define (generate-java-for-blocked-state n entry)
  (let ((accepts (nfa-entry-accepts entry)))
    (cond ((or (not accepts)
               (null? accepts))
           (gen-java n "if (true) return scannerError(errIncompleteToken)\;"
                       #\newline)
           #t)
          ((eq? accepts 'whitespace)
           (gen-java n "string_accumulator.setLength(0)\;" #\newline)
           (gen-java n "c = scanChar()\;" #\newline)
           (gen-java n "state = 0\;" #\newline)
           (gen-java n "break\;" #\newline)
           #f)
          ((symbol? accepts)
           (gen-java n "if (true) return accept(Parser."
                    (string-append "z" (symbol->string accepts))
                    ")\;"
                    #\newline)
           #t)
          ((and (pair? accepts) (symbol? (car accepts)))
           (generate-java-for-blocked-state
            n
            (make-nfa-entry (nfa-entry-state entry)
                            (car accepts)
                            '())))
          (else
           (gen-java n "/*  WHAT GOES HERE?  */" #\newline)
           (gen-java n "state = -1\;" #\newline)
           (gen-java n "break\;" #\newline)
           #f))))

; Given a list of grouped char transitions,
; outputs a sequence of switch clauses.

(define (generate-java-for-char-transitions transitions dfa)
  (for-each (lambda (group) (generate-java-for-lexer-transition group dfa))
            transitions))

(define (generate-java-for-lexer-transition group dfa)
  (let* ((transition (car group))
         (tokens (map transition-token group))
         (target (transition-target transition))
         (entry (select (lambda (entry)
                          (eqv? target (nfa-entry-state entry)))
                        dfa)))
    (for-each (lambda (c)
                (if (char=? c #\')
                    (gen-java 20 "case '\\" c "':" #\newline)
                    (gen-java 20 "case '" c "':" #\newline)))
              tokens)
    (gen-java 20 "    consumeChar()\;" #\newline)
    (if (null? (nfa-entry-transitions entry))
        (generate-java-for-blocked-state 24 entry)
        (begin
         (gen-java 20 "    c = scanChar()\;" #\newline)
         (gen-java 20 "    state = " target "\;" #\newline)
         (gen-java 20 "    break\;" #\newline)))))

(define (generate-java-for-symbol-transition transition dfa)
  (let* ((token (transition-token transition))
         (target (transition-target transition))
         (entry (select (lambda (entry)
                          (eqv? target (nfa-entry-state entry)))
                        dfa)))
    (let ((handler (assq token character-classes)))
      (if handler
          (gen-java 20 "    if (" (cadr handler) "(c)) {" #\newline)
          (gen-java 20 "    {   /*  " token "  */" #\newline))
      (gen-java 20 "        consumeChar()\;" #\newline)
      (if (null? (nfa-entry-transitions entry))
          (generate-java-for-blocked-state 24 entry)
          (begin
           (gen-java 20 "        c = scanChar()\;" #\newline)
           (gen-java 20 "        state = " target "\;" #\newline)
           (gen-java 20 "        break\;" #\newline)))
      (if handler
          (gen-java 20 "    } else" #\newline)
          (gen-java 20 "    }" #\newline)))))

; To do:
;
; Transitions to states that always block can be replaced by in-line code.
; Then the cases for such states are never used.
; (This assumes the start state is not such a state, but big deal.)
;
; Handling of output-port1.
;
; Messages for scannerError.