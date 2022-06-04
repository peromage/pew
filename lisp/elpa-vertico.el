;;; elpa-vertico.el --- Vertico completion framework -*- lexical-binding: t -*-
;;; Commentary:

;; Vertico and its related packages
;; Package bundle recommended in: https://github.com/minad/vertico#complementary-packages

;;; Code:

;; Vertico itself
(use-package vertico
  :demand t
  :init
  ;; File sorting
  (defun pew/vertico/sort-directories-first (files)
    "Sort directories before files."
    (setq files_ (vertico-sort-history-length-alpha files))
    (nconc (seq-filter (lambda (x) (string-suffix-p "/" x)) files_)
           (seq-remove (lambda (x) (string-suffix-p "/" x)) files_)))

  :bind (:map vertico-map
         ("RET" . vertico-directory-enter)
         ("DEL" . vertico-directory-delete-char)
         ("M-DEL" . vertico-directory-delete-word)
         ("M-q 1" . vertico-multiform-vertical)
         ("M-q 2" . vertico-multiform-grid)
         ("M-q 3" . vertico-multiform-flat)
         ("M-q 4" . vertico-multiform-reverse)
         ("M-q 5" . vertico-multiform-unobtrusive))
  :custom
  ;; Default views for different commands/results
  ;; NOTE: `vertico-multiform-commands' takes precedence over `vertico-multiform-categories'
  (vertico-multiform-commands '((consult-imenu buffer indexed)
                                (consult-outline buffer)))
  (vertico-multiform-categories '((file (vertico-sort-function . pew/vertico/sort-directories-first))))
  :config
  (vertico-mode 1)
  (vertico-multiform-mode 1))

;; Search and navigation commands
(use-package consult
  :init
  ;; Toggle auto preview
  (defvar pew/consult/stored--preview-key 'any "Stored consult preview key.")
  (defun pew/consult/toggle-preview ()
    "Toggle Consult auto preview function."
    (interactive)
    ;; Assume `consult-preview-key' is not 'any by default or this does nothing
    (cond ((eq 'any consult-preview-key)
           (setq consult-preview-key pew/consult/stored--preview-key)
           (setq pew/consult/stored--preview-key nil))
          (t
           (setq pew/consult/stored--preview-key consult-preview-key)
           (setq consult-preview-key 'any))))

  ;; Completion in region replacement
  (defun pew/consult/completion-in-region (&rest args)
    "Use consult for region completion."
    (apply (if vertico-mode #'consult-completion-in-region #'completion--in-region) args))

  ;; CRM indicator
  (define-advice completing-read-multiple (:filter-args (args) pew/consult/crm-indicator)
    "Add an indicator for multi-occur mode."
    (cons (format "[CRM] %s" (car args)) (cdr args)))

  :bind (("C-s" . consult-line)
         ("C-c b l" . consult-line)
         ("C-c b L" . consult-line-multi)
         ("C-c b O" . consult-multi-occur)
         ("C-c b b" . consult-buffer)
         ("C-c b B" . consult-buffer-other-window)
         ("C-c b p" . consult-project-buffer)
         ("C-c b i" . consult-imenu)
         ("C-c b I" . consult-imenu-multi)
         ("C-c b k" . consult-focus-lines)
         ("C-c b K" . consult-keep-lines)
         ("C-c b f" . consult-find)
         ("C-c b F" . consult-grep)
         ("C-c b g" . consult-ripgrep)
         ("C-c b G" . consult-git-grep)
         ("C-c b s" . consult-isearch-history)
         ("C-c b h" . consult-history)
         ([remap imenu] . consult-imenu)
         ([remap goto-line] . consult-goto-line)
         ([remap bookmark-jump] . consult-bookmark)
         ([remap recentf-open-files] . consult-recent-file)
         ([remap evil-show-marks] . consult-mark)
         :map minibuffer-local-map
         ("M-h" . consult-history)
         :map isearch-mode-map
         ("M-s" . consult-line)
         ("M-r" . consult-line-multi)
         ("M-h" . consult-isearch-history))
  :custom
  (register-preview-function #'consult-register-format)
  (xref-show-xrefs-function #'consult-xref)
  (xref-show-definitions-function #'consult-xref)
  (completion-in-region-function #'pew/consult/completion-in-region)
  (consult-async-min-input 2)
  (consult-narrow-key (kbd "<"))
  ;; Disable all auto previews
  (consult-preview-key (kbd ">"))
  ;; Don't display special buffers
  (consult-buffer-filter pew/hidden-buffers)
  :config
  ;; Enable preview for certain completions
  (consult-customize consult-theme
                     :preview-key '(:debounce 0.2 any)
                     consult-line
                     consult-line-multi
                     :preview-key 'any))

;; Rich annotations in the minibuffer
(use-package marginalia
  :after vertico
  ;; :bind would cause lazy loading which is not we expect
  :demand t
  :bind (:map vertico-map
         ("M-q q" . marginalia-cycle))
  :config
  (marginalia-mode 1))

;; Completion matching
(use-package orderless
  :init
  ;; Don't use orderless in company completion
  (with-eval-after-load 'company
    (defvar pew/orderless/default-completion-styles (eval (car (get 'completion-styles 'standard-value))))
    (define-advice company-capf--candidates (:around (oldfunc &rest args) pew/orderless/company-completing)
      (let ((completion-styles pew/orderless/default-completion-styles))
        (apply oldfunc args))))
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion))))
  (orderless-matching-styles '(orderless-literal orderless-regexp)))

;; Minibuffer actions and context menu
(use-package embark
  :demand t
  :bind (("C-c o o" . embark-act)
         ("C-c o j" . embark-dwim)
         ([remap describe-bindings] . embark-bindings)
         :map minibuffer-local-map
         ("M-o" . embark-act)
         ("M-j" . embark-dwim))
  :hook (embark-collect-mode . pew/reuse-window-setup)
  :custom
  (prefix-help-command #'embark-prefix-help-command))

;; Consult and embark integration
(use-package embark-consult
  :after (consult embark))

(use-package wgrep
  :after (consult embark))

(provide 'elpa-vertico)
;;; elpa-vertico.el ends here
