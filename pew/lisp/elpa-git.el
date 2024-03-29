;;; elpa-git.el --- git packages -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; Package: magit -- Frontend
(pewcfg::use-package magit
  :commands magit-status
  :bind ( :map pew::M-u-map
          ("g" . magit-status)
          ("G" . magit-file-dispatch) )

  :custom
  ;; Don't use the default bindings under "C-x" prefix
  (magit-define-global-key-bindings nil))

;;; Package: git-gutter -- Margin status
(pewcfg::use-package git-gutter
  :custom
  (git-gutter:modified-sign "**")
  (git-gutter:added-sign "++")
  (git-gutter:deleted-sign "--")
  (git-gutter:unchanged-sign nil)
  (git-gutter:separator-sign nil)
  (git-gutter:update-interval 2)
  (git-gutter:visual-line nil)
  (git-gutter:hide-gutter nil)
  (git-gutter:verbosity 0)

  :config/face
  (git-gutter:modified   :foreground  "yellow"       :background  "unspecified")
  (git-gutter:added      :foreground  "green"        :background  "unspecified")
  (git-gutter:deleted    :foreground  "red"          :background  "unspecified")
  (git-gutter:unchanged  :foreground  "unspecified"  :background  "unspecified")
  (git-gutter:separator  :foreground  "unspecified"  :background  "unspecified")

  :config
  (global-git-gutter-mode 1))

(provide 'elpa-git)
;;; elpa-git.el ends here
