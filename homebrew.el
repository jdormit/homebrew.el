;;; homebrew.el --- An Emacs interface to Homebrew   -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jeremy Dormitzer

;; Author: Jeremy Dormitzer <jeremy.dormitzer@gmail.com>
;; Package-Requires: ((s "1.12.0") (with-editor "20210117.2008"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This is an Emacs interface to the Homebrew package manager (https://brew.sh)

;;; Code:

(defun homebrew--get-package-list ()
  (sort (append (s-split "\n" (shell-command-to-string "brew formulae") t)
                (s-split "\n" (shell-command-to-string "brew casks") t))
        #'string-collate-lessp))

(defun homebrew--get-installed-package-list ()
  (sort (append (s-split "\n" (shell-command-to-string "brew list --formula") t)
                (s-split "\n" (shell-command-to-string "brew list --cask") t))
        #'string-collate-lessp))

(define-minor-mode homebrew-run-brew-minor-mode
  "Minor mode for buffers running brew commands"
  :keymap '(("q" .  bury-buffer)))

(with-eval-after-load 'evil
  (evil-define-key* 'normal homebrew-run-brew-minor-mode-map "q" #'bury-buffer))

(defun homebrew--run-brew (subcmd &rest args)
  (let* ((name (format "brew-%s" subcmd))
         (buf (format "*%s*" name)))
    (with-editor-async-shell-command (format "brew %s%s%s"
                                             subcmd
                                             (if args " " "")
                                             (string-join args " "))
                                     buf)
    (with-current-buffer buf
      (homebrew-run-brew-minor-mode))))

;;;###autoload
(defun homebrew-install (package)
  "Install `package' via Homebrew"
  (interactive (list (completing-read "Formula: "
                                      (homebrew--get-package-list)
                                      nil
                                      t)))
  (homebrew--run-brew "install" package))

;;;###autoload
(defun homebrew-upgrade (package)
  "Upgrade `package' to the latest version"
  (interactive (list (completing-read "Formula: "
                                      (homebrew--get-installed-package-list)
                                      nil
                                      t)))
  (homebrew--run-brew "upgrade" package))

;;;###autoload
(defun homebrew-update ()
  "Update the Homebrew installation"
  (interactive)
  (homebrew--run-brew "update"))


;;;###autoload
(defun homebrew-edit (package)
  "Edit the formula for `package'"
  (interactive (list (completing-read "Formula: "
                                      (homebrew--get-installed-package-list)
                                      nil
                                      t)))
  (homebrew--run-brew "edit" package))

;;;###autoload
(defun homebrew-info ()
  "Display general `brew info' output"
  (interactive)
  (message "%s" (shell-command-to-string "brew info")))

;;;###autoload
(defun homebrew-package-info (package)
  "Display `brew info' output for `package'"
  (interactive (list (completing-read "Formula: "
                                      (homebrew--get-installed-package-list)
                                      nil
                                      t)))
  (message "%s" (shell-command-to-string (format "brew info %s" package))))

(provide 'homebrew)
;;; homebrew.el ends here
