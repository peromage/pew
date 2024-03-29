;;; elpa-lang-powershell.el --- powershell mode -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Package: powershell
(pewcfg::use-package powershell
  :defer t
  :hook (powershell-mode . pew::powershell-mode::oninit)
  :config
  (defun pew::powershell-mode::oninit ()
    "`powershell-mode' initialization."
    (lsp-deferred)))

(provide 'elpa-lang-powershell)
;;; elpa-lang-powershell.el ends here
