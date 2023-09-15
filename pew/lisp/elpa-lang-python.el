;;; elpa-lang-python.el --- python mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Package: lsp-pyright
(use-package lsp-pyright
  :hook (python-mode . pew::python-mode::oninit)
  :config
  (pewcfg
    :setq
    (lsp-pyright-python-executable-cmd "python3")

    :eval
    (defun pew::python-mode::oninit ()
      "`python-mode' initialization."
      (setq-local indent-tabs-mode nil)
      (setq-local tab-width 4)
      (require 'lsp-pyright)
      (require 'dap-python)
      (lsp-deferred))))

(provide 'elpa-lang-python)
;;; elpa-lang-python.el ends here
