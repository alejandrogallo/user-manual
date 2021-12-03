;; type only y or n
(defalias 'yes-or-no-p 'y-or-n-p)

;; good for discovery
(use-package which-key
  :ensure t
  :init
  (which-key-mode +1))

;; better undo for vim
(use-package undo-tree
  :ensure t
  :config
  (global-undo-tree-mode 1))

;; VIMMMMMMMMMMMMMMMMMMM ;)
(use-package evil
  :ensure t
  :hook (after-init . evil-mode)
  :init
  (evil-mode +1)
  :config
  (evil-set-undo-system 'undo-tree))
