;;; elpa-vterm.el --- Terminal in Emacs -*- lexical-binding: t -*-
;;; Commentary:

;; Vterm is a decent terminal emulator inside of Emacs.
;; NOTE: Not available on Windows.

;;; Code:
;;;; Helper functions

(defun pew/vterm/new ()
  "Create a new vterm window with a unique name."
  (interactive)
  (vterm)
  (set-buffer "*vterm*")
  (rename-buffer "vterm" t))

;;;; Libvterm

(use-package vterm
  :if (memq system-type '(gnu gnu/linux gnu/kfreebsd darwin))
  :hook (vterm-mode . pew/terminal-setup)
  :commands (vterm vterm-other-window)
  :custom
  (vterm-kill-buffer-on-exit t)
  (vterm-max-scrollback 10000))

(provide 'elpa-vterm)
;;; elpa-vterm.el ends here
