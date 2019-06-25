;;; symex-interface-racket.el --- An evil way to edit Lisp symbolic expressions as trees -*- lexical-binding: t -*-

;; This program is "part of the world," in the sense described at
;; http://drym.org.  From your perspective, this is no different than
;; MIT or BSD or other such "liberal" licenses that you may be
;; familiar with, that is to say, you are free to do whatever you like
;; with this program.  It is much more than BSD or MIT, however, in
;; that it isn't a license at all but an idea about the world and how
;; economic systems could be set up so that everyone wins.  Learn more
;; at drym.org.

;;; Commentary:
;;
;; Interface for the Racket language
;;

;;; Code:


(require 'racket-mode)


(defun symex-eval-racket ()
  "Eval last sexp.

Accounts for different point location in evil vs Emacs mode."
  (interactive)
  (save-excursion
    (when (equal evil-state 'normal)
      (forward-char))
    (racket-send-last-sexp)))

(defun symex-eval-definition-racket ()
  "Eval entire containing definition."
  (racket-send-definition nil))

(defun symex-eval-pretty-racket ()
  "Evaluate symex and render the result in a useful string form."
  (interactive)
  (let ((pretty-code (string-join
                      `("(let ([result "
                        ,(buffer-substring (racket--repl-last-sexp-start)
                                           (point))
                        "])"
                        " (cond [(stream? result) (stream->list result)]
                                  [(sequence? result) (sequence->list result)]
                                  [else result]))"))))
    (racket--send-to-repl pretty-code)))

(defun symex-describe-symbol-racket ()
  "Describe symbol at point."
  (interactive)
  (racket-describe nil))

(defun symex-repl-racket ()
  "Go to REPL."
  (racket-repl))


(provide 'symex-interface-racket)
;;; symex-interface-racket.el ends here