;;; main.el --- Entry point for Bible Org generation

;; Determine project root (directory containing this file)
(defvar project-root
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name))))
  "Root directory of the Bible Org project.")

;; Add subdirectories to load-path
(add-to-list 'load-path (expand-file-name "src" project-root))
(add-to-list 'load-path (expand-file-name "sword-to-org" project-root))

;; Load dependencies
(require 'sword-to-org)
(require 'bible-to-org-chapters)

;; User configuration
(setq bible-org-module "BSB")
(setq bible-org-output-directory
      "~/manual/bible/")

;; Generate all chapters
(bible-org-generate-all)

;; becareful when using this
;; (dolist (file (directory-files bible-org-output-directory  t "\\.org$"))
;;       (with-current-buffer (find-file-noselect file)
;;         (org-hugo-export-wim-to-md)))
