;;; elpa-majormode-markdown-mode.el --- Markdown mode -*- lexical-binding: t -*-
;;; Commentary:

;; When writting in `markdown-mode' some configurations are slightly different than coding modes.

;;; Code:

(defun pew/markdown-mode/setup ()
  "My markdown mode hook."
  (setq line-move-visual t)
  (visual-line-mode))

(use-package markdown-mode
  :hook (markdown-mode . pew/markdown-mode/setup))

(provide 'elpa-majormode-markdown-mode)
;;; elpa-majormode-markdown-mode.el ends here
