;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one-light)
;; Specify both a dark and light theme, like so and Doom will choose which one
;; to load based on your system light/dark setting:
;;
;;   (setq doom-theme '(doom-one   . doom-one-light))   ; (DARK . LIGHT)
;;
;; If you want more pro-active theme switching based on OS light/dark mode, look
;; up the `auto-dark' package.

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `with-eval-after-load' block, otherwise Doom's defaults may override your
;; settings. E.g.
;;
;;   (with-eval-after-load 'PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look them up).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Gradle: groovy highlighting for build files, plus gradle-mode commands
(use-package! groovy-mode
  :mode "\\.gr\\(?:oovy\\|adle\\)\\'")
(use-package! gradle-mode
  :hook (java-mode . gradle-mode)
  :hook (groovy-mode . gradle-mode))
(use-package! kotlin-mode
  :mode "\\.gradle\\.kts\\'")

;; WSL: render the preview with pandoc (GFM tables) plus mermaid.js, and open it
;; in the Windows browser from a Windows-visible path. eww has no JavaScript, so
;; it can't draw mermaid diagrams. Mermaid is loaded from a CDN (needs internet).
(defvar my/md-preview-file
  "/mnt/c/Users/ramvi00p/AppData/Local/Temp/emacs-md-preview.html")

(defun my/markdown-preview-browser ()
  "Render the current markdown buffer to HTML and open it in the Windows browser."
  (interactive)
  (let ((header (expand-file-name "md-preview-header.html" doom-user-dir)))
    (unless (zerop (call-process-region
                    (point-min) (point-max) "pandoc" nil "*md-preview-errors*" nil
                    "-f" "gfm" "-t" "html5" "-s"
                    "--metadata" (format "title=%s" (buffer-name))
                    "--include-in-header" header
                    "-o" my/md-preview-file))
      (user-error "pandoc failed, see *md-preview-errors*"))
    (start-process "md-preview" nil "explorer.exe"
                   (string-trim (shell-command-to-string
                                 (format "wslpath -w %s"
                                         (shell-quote-argument my/md-preview-file)))))))

(after! markdown-mode
  (setq markdown-command "pandoc -f gfm -t html")
  (advice-add 'markdown-preview :override #'my/markdown-preview-browser))

;; Gradle/Maven build output: ignore at every level (the leading * means "any depth").
(after! projectile
  (dolist (d '("*build" "*target" "*.gradle"))
    (add-to-list 'projectile-globally-ignored-directories d)))
