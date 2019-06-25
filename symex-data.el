;;; symex-data.el --- An evil way to edit Lisp symbolic expressions as trees -*- lexical-binding: t -*-

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Data abstractions for symex mode.  Defines the linguistic primitives
;; of the symex DSL: moves, maneuvers, precautions, protocols,
;; circuits, and detours.
;;

;;; Code:


;;;;;;;;;;;;;;;;;;;;;;;;;
;;; DATA ABSTRACTIONS ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(defun symex-make-move (x y)
  "Construct a tree 'move'.

A move represents the number of steps to be taken along the X or
forward-backward axis, and the Y or in-out axis."
  (list 'move x y))

(defun symex--move-x (move)
  "X (horizontal) component of MOVE."
  (nth 1 move))

(defun symex--move-y (move)
  "Y (vertical) component of MOVE."
  (nth 2 move))

(defun is-move? (obj)
  "Check if OBJ specifies a move."
  (condition-case nil
      (equal 'move
             (nth 0 obj))
    (error nil)))

(defconst move-zero (symex-make-move 0 0))
(defconst move-go-forward (symex-make-move 1 0))
(defconst move-go-backward (symex-make-move -1 0))
(defconst move-go-in (symex-make-move 0 1))
(defconst move-go-out (symex-make-move 0 -1))

(defun are-moves-equal? (m1 m2)
  "Check if two moves M1 and M2 are identical."
  (equal m1 m2))

(defun symex--add-moves (moves)
  "Add MOVES together as vectors.

This sum indicates height and distance along the branches of the tree."
  (if moves
      (let ((current (car moves))
            (remaining (cdr moves)))
        (let ((result (symex--add-moves remaining)))
          (symex-make-move (+ (symex--move-x current)
                              (symex--move-x result))
                           (+ (symex--move-y current)
                              (symex--move-y result)))))
    move-zero))

(defun symex--move-length (move)
  "Compute the length of the MOVE.

This is most naturally meaningful when the move is entirely along one axis,
but a result will be returned even if the move is across multiple axes,
as standard linear vector magnitude computation is used."
  (let ((x (symex--move-x move))
        (y (symex--move-y move)))
    (if (not (= x 0))
        x
      y)))

(cl-defun symex-make-precaution (traversal &key pre-condition post-condition)
  "A specification to check conditions before/after execution of a TRAVERSAL.

PRE-CONDITION is a boolean function executed before the traversal. The
traversal is not executed unless this returns true.
POST-CONDITION is a boolean function executed after the traversal. The
executed traversal is reversed if this returns false."
  (let ((pre-condition (or pre-condition (lambda () t)))
        (post-condition (or post-condition (lambda () t))))
    (list 'precaution
          traversal
          pre-condition
          post-condition)))

(defun symex--precaution-traversal (precaution)
  "The traversal component of the PRECAUTION.

This is the traversal that is to be executed 'with precautions'."
  (nth 1 precaution))

(defun symex--precaution-pre-condition (precaution)
  "Pre-condition of PRECAUTION."
  (nth 2 precaution))

(defun symex--precaution-post-condition (precaution)
  "Post-condition of PRECAUTION."
  (nth 3 precaution))

(defun is-precaution? (obj)
  "Check if OBJ specifies a precaution."
  (condition-case nil
      (equal 'precaution
             (nth 0 obj))
    (error nil)))

(defun symex-make-circuit (traversal &optional times)
  "A specification to repeat a TRAVERSAL TIMES times.

If TIMES is nil, repeat indefinitely until the traversal fails."
  (list 'circuit
        traversal
        times))

(defun symex--circuit-traversal (circuit)
  "Get the traversal component of the CIRCUIT.

This is the traversal that is intended to be looped."
  (nth 1 circuit))

(defun symex--circuit-times (circuit)
  "Get the times component of the CIRCUIT.

This is the number of times the traversal should be repeated."
  (nth 2 circuit))

(defun is-circuit? (obj)
  "Check if OBJ specifies a circuit."
  (condition-case nil
      (equal 'circuit
             (nth 0 obj))
    (error nil)))

(defun symex-make-maneuver (&rest phases)
  "Construct a maneuver from the given PHASES."
  (list 'maneuver
        phases))

(defun symex--maneuver-phases (maneuver)
  "Get the phases of a MANEUVER.

Each phase could be any traversal."
  (nth 1 maneuver))

(defun is-maneuver? (obj)
  "Check if OBJ specifies a maneuver."
  (condition-case nil
      (equal 'maneuver
             (nth 0 obj))
    (error nil)))

(defun symex-make-detour (reorientation traversal)
  "Construct a detour.

A detour consists of two components -- a TRAVERSAL that we wish to execute, and
a REORIENTATION which is a transformation we want to apply prior to attempting
the traversal.  Both the reorientation as well as the traversal could be any
type of traversal, for instance a detour or a maneuver.

The reorientation is applied repeatedly and the traversal is re-attempted each
time, until it succeeds.  If the reorientation itself fails, then the detour
fails as well."
  (list 'detour
        reorientation
        traversal))

(defun symex--detour-reorientation (detour)
  "Get the reorientation component of the DETOUR."
  (nth 1 detour))

(defun symex--detour-traversal (detour)
  "Get the traversal component of the DETOUR."
  (nth 2 detour))

(defun is-detour? (obj)
  "Check if OBJ specifies a detour."
  (condition-case nil
      (equal 'detour
             (nth 0 obj))
    (error nil)))

(defun symex-make-protocol (&rest options)
  "Construct a protocol abstraction for the given OPTIONS.

An option could be either a maneuver, or a protocol itself."
  (list 'protocol
        options))

(defun symex--protocol-options (protocol)
  "Get the set of options that are part of the PROTOCOL."
  (nth 1 protocol))

(defun is-protocol? (obj)
  "Check if OBJ specifies a protocol."
  (condition-case nil
      (equal 'protocol
             (nth 0 obj))
    (error nil)))

(defun is-traversal? (obj)
  "Check if OBJ specifies a traversal."
  (or (is-move? obj)
      (is-maneuver? obj)
      (is-circuit? obj)
      (is-detour? obj)
      (is-precaution? obj)
      (is-protocol? obj)))


(provide 'symex-data)
;;; symex-data.el ends here
