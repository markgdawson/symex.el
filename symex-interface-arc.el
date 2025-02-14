;;; symex-interface-arc.el --- An evil way to edit Lisp symbolic expressions as trees -*- lexical-binding: t -*-

;; URL: https://github.com/countvajhula/symex.el

;; This program is "part of the world," in the sense described at
;; http://drym.org.  From your perspective, this is no different than
;; MIT or BSD or other such "liberal" licenses that you may be
;; familiar with, that is to say, you are free to do whatever you like
;; with this program.  It is much more than BSD or MIT, however, in
;; that it isn't a license at all but an idea about the world and how
;; economic systems could be set up so that everyone wins.  Learn more
;; at drym.org.
;;
;; This work transcends traditional legal and economic systems, but
;; for the purposes of any such systems within which you may need to
;; operate:
;;
;; This is free and unencumbered software released into the public domain.
;; The authors relinquish any copyright claims on this work.
;;

;;; Commentary:
;;
;; Interface for the Arc language
;;

;;; Code:

(require 'arc nil 'noerror)

(declare-function arc-send-last-sexp "ext:arc")
(declare-function arc-send-definition "ext:arc")
(declare-function arc--repl-last-sexp-start "ext:arc")
(declare-function arc--send-to-repl "ext:arc")
(declare-function arc-repl "ext:arc")

(defun symex-eval-arc ()
  "Eval last sexp.

Accounts for different point location in evil vs Emacs mode."
  (interactive)
  (arc-send-last-sexp))

(defun symex-eval-definition-arc ()
  "Eval entire containing definition."
  (arc-send-definition))

(defun symex-eval-pretty-arc ()
  "Evaluate symex and render the result in a useful string form."
  (interactive)
  (symex-eval-arc))

(defun symex-eval-thunk-arc ()
  "Evaluate symex as a 'thunk,' i.e. as a function taking no arguments."
  (interactive)
  (let ((thunk-code (string-join
                     `("("
                       ,(buffer-substring (arc--repl-last-sexp-start)
                                          (point))
                       ")"))))
    (arc--send-to-repl thunk-code)))

(defun symex-eval-print-arc ()
  "Eval symex and print result in buffer."
  (interactive)
  nil)

(defun symex-describe-symbol-arc ()
  "Describe symbol at point."
  (interactive)
  nil)

(defun symex-repl-arc ()
  "Go to REPL."
  (arc-repl)
  (goto-char (point-max)))

(defun symex-run-arc ()
  "Evaluate buffer."
  (error "Not implemented"))


(provide 'symex-interface-arc)
;;; symex-interface-arc.el ends here
