(setq package-enable-at-startup nil)
(require 'subr-x)
(defconst +cc4s-start-time+ (current-time))
(defmacro cc4s-log (fmt &rest args)
  `(let ((elapsed (time-to-seconds (time-since +cc4s-start-time+))))
     (message ,(concat "%d "
                       "\x1b[35m∷CC4S» "
                       fmt
                       "\x1b[0m")
              elapsed ,@args)))
(defun !!done () (cc4s-log "\t✓ done"))
(defmacro use-package! (name &rest body)
  `(progn
     (cc4s-log "\t→ %s" ',name)
     (use-package ,name ,@body)))

(defvar cc4s-root-directory (expand-file-name
                             (format "%s../"
                                     (file-name-directory load-file-name))))

(setq package-user-dir (format "%s.emacs/packages" cc4s-root-directory))
(setq user-emacs-directory (format "%s.emacs" cc4s-root-directory))

(cc4s-log "Manual root directory :: %s" cc4s-root-directory)

;; Minimize garbage collection during startup
(setq gc-cons-threshold most-positive-fixnum)

(cc4s-log "Requiring package")
(require 'package)
(cc4s-log "Installed packages go to %s" package-user-dir)

(setq package-enable-at-startup t)
(setq package-archives
      '(("gnu"   . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.org/packages/"   )))

(cc4s-log "Initializing packages")
(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))



(cc4s-log "\t- get use-package")
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(cc4s-log "\t\t-Requiring use-package")
(eval-when-compile
  (require 'use-package))

(use-package! org
              :ensure t
              :config
              (setq org-src-fontify-natively t
                    org-src-preserve-indentation t
                    org-src-tab-acts-natively t)
              (setq org-confirm-babel-evaluate nil))
(require 'org)

(use-package! htmlize
              :defer t
              :ensure t)

(use-package! citeproc :defer t :ensure t)
(use-package! org-ref
              :defer t
              :ensure t
              :config
              (setq bibtex-completion-bibliography
                    (list (format "%s/%s" cc4s-root-directory "group.bib")))
              (cc4s-log "Bib files: %s" bibtex-completion-bibliography))

(use-package! yaml-mode
              :defer t
              :ensure t)

(use-package! org-plus-contrib
              :defer t
              :ensure nil)

(use-package! ox-rst
              :ensure t)

(require 'org)
(require 'ox-html)
(require 'ox-rst)
(require 'org-ref)
(require 'org-id)

(cc4s-log "loading theme..")
(load-theme 'tsdh-light)
(!!done)

(setq bibtex-completion-bibliography
      (list (format "%s/%s" cc4s-root-directory "group.bib")))
(setq org-cite-global-bibliography (list (format "%s/%s" cc4s-root-directory "group.bib")))
(setq org-directory cc4s-root-directory)

;; ORG-ID for id:links
(setq-default org-id-locations-file (concat cc4s-root-directory "id-locations")
              publish-directory (format "%s/user-manual/" cc4s-root-directory)
              org-publish-timestamp-directory (format "%s/.emacs/org-timestamps" cc4s-root-directory))

(defun cc4s/handle-id-links ()
  (require 'org-id)
  (if (file-exists-p org-id-locations-file)
      (progn (cc4s-log "loading id:links from %s" org-id-locations-file)
             (org-id-locations-load)
             (!!done))
    (progn (cc4s-log "Updating id: links")
           (org-id-update-id-locations
            (directory-files-recursively cc4s-root-directory
                                         ".org$"))
           (!!done))))

(cc4s/handle-id-links)
