{ config, pkgs, lib, ... }:

with lib;

let
  sources = import ../../nix/sources.nix;

  nur = import sources.nur { };

  pcfg = config.programs.emacs.init.usePackage;

  python3 = pkgs.python311;

  enableNotMuch = false && pcfg.notmuch.enable;

in
{
  imports = [
    nur.repos.rycee.hmModules.emacs-init
    nur.repos.rycee.hmModules.emacs-notmuch
  ];

  nixpkgs.overlays = [ (import sources.emacs-overlay) ];

  programs.emacs.init = {
    enable = false;
    packageQuickstart = false;
    recommendedGcSettings = true;
    usePackageVerbose = false;

    earlyInit = ''
      (setq use-package-compute-statistics t)

      ;; Disable some GUI distractions. We set these manually to avoid starting
      ;; the corresponding minor modes.
      (push '(menu-bar-lines . 0) default-frame-alist)
      (push '(tool-bar-lines . nil) default-frame-alist)
      (push '(vertical-scroll-bars . nil) default-frame-alist)

      ;; hide obsolete warnings like "package cl is deprecated"
      (setq byte-compile-warnings '(not obsolete))

      ;; Set up fonts early.
      (set-face-attribute 'default
                          nil
                          :height 120
                          :family "FiraCode Nerd Font Mono")
      (set-face-attribute 'variable-pitch
                          nil
                          :family "FiraCode Nerd Font")

      ;; Configure color theme and modeline in early init to avoid flashing
      ;; during start.
      (load-theme 'modus-vivendi)

      ;; linum
      (setq linum-format "%4d \u2502 ")
      (setq-default left-fringe-width  20)
      (setq-default right-fringe-width  20)
      (global-linum-mode t)
      (set-face-foreground 'linum "lightgrey")
      (set-face-background 'linum "grey20")
      (set-face-attribute 'fringe nil :background "black")

      ;;(set-face-background 'completions-common-part "white smoke")

      ;;(require 'doom-modeline)
      ;;(setq doom-modeline-buffer-file-name-style 'truncate-except-project)
      ;;(doom-modeline-mode)

      ;;forge load-path
      (add-to-list 'load-path "~/.config/custom/")
    '';

    prelude = ''
      ;; Disable startup message.
      (setq inhibit-startup-screen t
            inhibit-startup-echo-area-message (user-login-name))

      (setq initial-major-mode 'fundamental-mode
            initial-scratch-message nil)

      ;; Don't blink the cursor.
      (setq blink-cursor-mode nil)

      ;; Set frame title.
      (setq frame-title-format
            '("" invocation-name ": "(:eval
                                      (if (buffer-file-name)
                                          (abbreviate-file-name (buffer-file-name))
                                        "%b"))))

      ;; Make sure the mouse cursor is visible at all times.
      (set-face-background 'mouse "#ffffff")
      (set-cursor-color "#ffffff")

      ;; Accept 'y' and 'n' rather than 'yes' and 'no'.
      (defalias 'yes-or-no-p 'y-or-n-p)

      ;; default to insert replace
      (delete-selection-mode 1)

      ;; Don't want to move based on visual line.
      (setq line-move-visual nil)

      ;; Stop creating backup and autosave files.
      (setq make-backup-files nil
            auto-save-default nil)

      ;; Acknowledge filesystem changes
      (global-auto-revert-mode t)

      ;; Default is 4k, which is too low for LSP.
      (setq read-process-output-max (* 1024 1024))

      ;; Always show line and column number in the mode line.
      (line-number-mode)
      (column-number-mode)

      ;; Enable some features that are disabled by default.
      (put 'narrow-to-region 'disabled nil)

      ;; Typically, I only want spaces when pressing the TAB key. I also
      ;; want 4 of them.
      (setq-default indent-tabs-mode nil
                    tab-width 4
                    c-basic-offset 4)

      ;; Trailing white space are banned!
      (setq-default show-trailing-whitespace t)
      (add-hook 'before-save-hook 'whitespace-cleanup)

      ;; Use one space to end sentences.
      (setq sentence-end-double-space nil)

      ;; I typically want to use UTF-8.
      (prefer-coding-system 'utf-8)

      ;; Nicer handling of regions.
      (transient-mark-mode 1)

      ;; Make moving cursor past bottom only scroll a single line rather
      ;; than half a page.
      (setq scroll-step 1
            scroll-conservatively 5)

      ;; Enable highlighting of current line.
      (global-hl-line-mode 1)
      ;;(set-face-underline 'highlight nil)
      ;;(set-face-attribute 'highlight nil :background "DarkSlateGrey")
      (set-face-attribute 'highlight nil :background "#294F6E")

      ;; Improved handling of clipboard in GNU/Linux and otherwise.
      (setq select-enable-clipboard t
            select-enable-primary nil
            save-interprogram-paste-before-kill t)

      ;; Pasting with middle click should insert at point, not where the
      ;; click happened.
      (setq mouse-yank-at-point t)

      ;; Enable a few useful commands that are initially disabled.
      (put 'upcase-region 'disabled nil)
      (put 'downcase-region 'disabled nil)

      (setq custom-file (locate-user-emacs-file "custom.el"))
      (when (file-exists-p custom-file)
       (load custom-file))

      ;; When finding file in non-existing directory, offer to create the
      ;; parent directory.
      (defun with-buffer-name-prompt-and-make-subdirs ()
        (let ((parent-directory (file-name-directory buffer-file-name)))
          (when (and (not (file-exists-p parent-directory))
                     (y-or-n-p (format "Directory `%s' does not exist! Create it? " parent-directory)))
            (make-directory parent-directory t))))

      (add-to-list 'find-file-not-found-functions #'with-buffer-name-prompt-and-make-subdirs)

      ;; Don't want to complete .hi files.
      (add-to-list 'completion-ignored-extensions ".hi")

      (defun rah-disable-trailing-whitespace-mode ()
        (setq show-trailing-whitespace nil))

      ;; Shouldn't highlight trailing spaces in terminal mode.
      (add-hook 'term-mode #'rah-disable-trailing-whitespace-mode)
      (add-hook 'term-mode-hook #'rah-disable-trailing-whitespace-mode)

      ;; Ignore trailing white space in compilation mode.
      (add-hook 'compilation-mode-hook #'rah-disable-trailing-whitespace-mode)

      (defun rah-prog-mode-setup ()
        ;; Use a bit wider fill column width in programming modes
        ;; since we often work with indentation to start with.
        (setq fill-column 80))

      (add-hook 'prog-mode-hook #'rah-prog-mode-setup)

      (defun rah-lsp ()
        (interactive)
        (envrc-mode)
        (lsp))

      ;(defun rah-sort-lines-ignore-case ()
      ;  (interactive)
      ;  (let ((sort-fold-case t))
      ;    (call-interactively 'sort-lines)))

      ; work-around for recentf lock issue on refocus
      ; see github.com/syl20bnr/spacemacs/issues/5554
      (defun ask-user-about-lock (file other-user)
       "A value of t says to grab the lock on the file"
       t)

      ; Unfortunately scala-mode doesn't indent a highlighted region
      ;  when hitting tab. But it does properly indent a single line.
      ; The following function allows us to apply any arbitrary function
      ; line by line to a selected region, such as indent.
      ; See https://stackoverflow.com/a/6539916/1241878
      (defun apply-function-to-region-lines (fn)
        (interactive "aFunction to apply to lines in region: ")
        (save-excursion
          (goto-char (region-end))
          (let ((end-marker (copy-marker (point-marker)))
                next-line-marker)
            (goto-char (region-beginning))
            (if (not (bolp))
                (forward-line 1))
            (setq next-line-marker (point-marker))
            (while (< next-line-marker end-marker)
              (let ((start nil)
                    (end nil))
                (goto-char next-line-marker)
                (save-excursion
                  (setq start (point))
                  (forward-line 1)
                  (set-marker next-line-marker (point))
                  (setq end (point)))
                (save-excursion
                  (let ((mark-active nil))
                    (narrow-to-region start end)
                    (funcall fn)
                    (widen)))))
            (set-marker end-marker nil)
            (set-marker next-line-marker nil))))

      ; indent line by line
      (defun indent-for-tab-command-line-by-line ()
        (interactive)
        (funcall 'apply-function-to-region-lines 'indent-for-tab-command))
    '';

    usePackage = {
      abbrev = {
        enable = true;
        functions = [ "org-in-src-block-p" ];
        hook = [
          "(text-mode . abbrev-mode)"

          # When used in org-mode we want to disable expansion inside source
          # blocks. See https://emacs.stackexchange.com/a/63581.
          ''
            (org-mode .
              (lambda ()
                (setq abbrev-expand-function
                  (lambda ()
                    (unless (org-in-src-block-p) (abbrev--default-expand))))))
          ''
        ];
        config = ''
          (define-abbrev-table 'text-mode-abbrev-table
            '(("acl" "article")
              ("afaik" "as far as I know")
              ("atm" "at the moment")
              ("btw" "by the way")
              ("f" "the")
              ("F" "The")
              ("i" "I")
              ("ndr" "understand")
              ("tnk" "think")))
        '';
      };

      adoc-mode = {
        enable = true;
        mode = [ ''"\\.adoc\\'"'' ];
        hook = [''
          (adoc-mode . (lambda ()
                         (visual-line-mode)
                         (buffer-face-mode)))
        ''];
        config = ''
          (set-face-background 'markup-verbatim-face nil)
        '';
      };

      autorevert = {
        enable = true;
        command = [ "auto-revert-mode" ];
      };

      back-button = {
        enable = true;
        # package = epkgs:
        #   epkgs.back-button.overrideAttrs (drv:
        #     let
        #       isNotUcsUtils = p:
        #         (builtins.parseDrvName p.name).name != "emacs-ucs-utils";
        #     in {
        #       patches = [
        #         # ucs-utils makes Emacs shutdown very slow, remove its use through this patch.
        #         (pkgs.fetchpatch {
        #           name = "remove-ucs-utils.patch";
        #           url =
        #             "https://github.com/rutger-eiq/back-button/commit/164cf6e2a536a8da6e45c0365922ea1887acde79.patch";
        #           sha256 =
        #             "0czii9hdk7l6j3palpb68377phms9jw9ldb51apjhbmscjyr55q3";
        #         })
        #       ];

        #       # Also need to remove ucs-utils from the various build inputs.
        #       buildInputs = builtins.filter isNotUcsUtils drv.buildInputs;
        #       propagatedBuildInputs =
        #         builtins.filter isNotUcsUtils drv.propagatedBuildInputs;
        #       propagatedUserEnvPkgs =
        #         builtins.filter isNotUcsUtils drv.propagatedUserEnvPkgs;
        #     });
        defer = 2;
        bind = {
          "C-x <left>" = "back-button-local";
          "C-x <right>" = "back-button-local-foward";
          "C-x x <left>" = "back-button-global";
          "C-x x <right>" = "back-button-global-forward";
        };
        command = [ "back-button-mode" ];
        config = ''
          (back-button-mode 1)

          ;; Make mark ring larger.
          (setq global-mark-ring-max 50)

          ;; Don't clobber rectangle-mark-mode!!!
          (unbind-key "C-x <SPC>" back-button-mode-map)
        '';
      };

      calc = {
        enable = true;
        command = [ "calc" ];
        config = ''
          (setq calc-date-format '(YYYY "-" MM "-" DD " " Www " " hh ":" mm ":" ss))
        '';
      };

      compile = {
        enable = true;
        defer = true;
        after = [ "xterm-color" ];
        config = ''
          (setq compilation-environment '("TERM=xterm-256color"))
          (defun rah-advice-compilation-filter (f proc string)
            (funcall f proc (xterm-color-filter string)))
          (advice-add 'compilation-filter :around #'rah-advice-compilation-filter)
        '';
      };

      beacon = {
        enable = false;
        command = [ "beacon-mode" ];
        defer = 1;
        config = "(beacon-mode 1)";
      };

      browse-at-remote = { command = [ "browse-at-remote" ]; };

      cue-mode.enable = true;

      cc-mode = {
        enable = true;
        defer = true;
        hook = [''
          (c-mode-common . (lambda ()
                             (subword-mode)
                             (c-set-offset 'arglist-intro '++)))
        ''];
      };

      consult = {
        enable = true;
        bind = {
          "C-s" = "consult-line";
          "C-x b" = "my-consult-buffer";
          "C-x 4 b" = "consult-buffer-other-window";
          "C-x 5 b" = "consult-buffer-other-frame";
          "C-x x l" = "consult-global-mark";
          "M-g M-g" = "consult-goto-line";
          "M-g g" = "consult-goto-line";
          "M-s f" = "consult-find";
          "M-s r" = "consult-ripgrep";
          "M-y" = "consult-yank-pop";
        };
        command = [ "consult-completing-read-multiple" ];
        config = ''
          (defun my-consult-buffer ()
            "Variant of `consult-buffer' to fix some invalid key runtime bug."
            (interactive)
            (let ((consult--buffer-display #'switch-to-buffer))
              (consult-buffer)))

          (defvar rah/consult-line-map
            (let ((map (make-sparse-keymap)))
              (define-key map "\C-s" #'vertico-next)
              map))

          (advice-add #'completing-read-multiple
                      :override #'consult-completing-read-multiple)

          (advice-add #'project-find-regexp
                      :override #'consult-ripgrep)

          (consult-customize
            consult-line
              :history t ;; disable history
              :keymap rah/consult-line-map
            consult-buffer consult-find consult-ripgrep
              :preview-key (kbd "M-.")
            consult-theme
              :preview-key '(:debounce 1 any)
          )
        '';
        functions = [
          "consult-project-root-function"
          "my-consult-buffer"
        ];
      };

      consult-ag = { enable = true; };
      consult-dir = {
        enable = true;
        bind = {
          "C-x C-d" = "consult-dir";
        };
        bindLocal = {
          minibuffer-local-completion-map = {
            "C-x C-d" = "consult-dir";
            "C-x C-j" = "consult-dir-jump-file";
          };
        };
      };
      consult-flycheck = { enable = true; };
      consult-flyspell = { enable = true; };
      consult-ls-git = {
        enable = true;
        bind = {
          "C-c g f" = "consult-ls-git";
          "C-c g F" = "consult-ls-git-other-window";
        };
      };
      consult-lsp = {
        enable = true;
        extraConfig = ''
          :bind (:map lsp-mode-map
                      ([remap xref-find-apropros] . company-complete-common))
        '';
      };
      consult-notmuch = { enable = enableNotMuch; };
      consult-project-extra = {
        enable = true;
        bind = {
          "C-c p f" = "consult-project-extra-find";
          "C-c p o" = "consult-project-extra-find-other-window";
        };
      };
      consult-projectile = { enable = true; };
      consult-yasnippet = { enable = true; };

      consult-xref = {
        enable = true;
        after = [ "consult" "xref" ];
        command = [ "consult-xref" ];
        init = ''
          (setq xref-show-definitions-function #'consult-xref
                xref-show-xrefs-function #'consult-xref)
        '';
      };

      deadgrep = {
        enable = true;
        bind = { "C-x f" = "deadgrep"; };
      };

      dhall-mode = {
        enable = true;
        hook = [ "(dhall-mode . subword-mode)" ];
        config = ''
          (setq dhall-use-header-line nil)
        '';
      };

      exec-path-from-shell = {
        enable = true;
        config = ''
          (exec-path-from-shell-initialize)
        '';
      };

      lsp-dhall = {
        enable = true;
        defer = true;
        hook = [ "(dhall-mode . rah-lsp)" ];
      };

      docker = {
        enable = true;
        bind = { "C-c D" = "docker"; };
      };
      dockerfile-mode.enable = true;
      docker-compose-mode.enable = true;

      drag-stuff = {
        enable = true;
        bind = {
          "M-<up>" = "drag-stuff-up";
          "M-<down>" = "drag-stuff-down";
        };
      };

      ediff = {
        enable = true;
        defer = true;
        config = ''
          (setq ediff-window-setup-function 'ediff-setup-windows-plain)
        '';
      };

      eldoc = {
        enable = true;
        command = [ "eldoc-mode" ];
      };

      # Enable Electric Indent mode to do automatic indentation on RET.
      electric = {
        enable = true;
        command = [ "electric-indent-local-mode" ];
        hook = [
          "(prog-mode . electric-indent-mode)"

          # Disable for some modes.
          "(purescript-mode . (lambda () (electric-indent-local-mode -1)))"
        ];
      };

      elm-mode.enable = true;

      envrc = {
        enable = true;
        command = [ "envrc-mode" ];
      };

      etags = {
        enable = true;
        defer = true;
        # Avoid spamming reload requests of TAGS files.
        config = "(setq tags-revert-without-query t)";
      };

      gcmh = {
        enable = true;
        defer = 1;
        command = [ "gcmh-mode" ];
        config = ''
          (setq gcmh-idle-delay 'auto)
          (gcmh-mode)
        '';
      };

      ggtags = {
        enable = true;
        defer = true;
        command = [ "ggtags-mode" ];
      };

      groovy-mode = {
        enable = true;
        mode = [
          ''"\\.gradle\\'"'' # \
          ''"\\.groovy\\'"'' # \
          ''"Jenkinsfile\\'"'' # \
        ];
      };

      ispell = {
        enable = true;
        defer = 1;
      };

      js = {
        enable = true;
        mode = [
          ''("\\.js\\'" . js-mode)'' # \
          ''("\\.json\\'" . js-mode)'' # \
        ];
        config = ''
          (setq js-indent-level 2)
        '';
      };

      jsonnet-mode = {
        enable = true;
      };

      # See https://github.com/mickeynp/ligature.el
      ligature = {
        enable = true;
        package = epkgs:
          epkgs.trivialBuild {
            pname = "ligature.el";
            src = sources."ligature.el";
            preferLocalBuild = true;
            allowSubstitutes = false;
          };
        command = [ "ligature-set-ligatures" ];
        hook = [
          "(nxml-mode . ligature-mode)" # \
          "(prog-mode . ligature-mode)" # \
        ];
        config = ''
          ;; Prepare Fantasque Sans Mono ligatures in some modes.
          (ligature-set-ligatures 'nxml-mode '("<!--" "-->"))
          (ligature-set-ligatures 'prog-mode '("!=" "!==" "-->" "->" "->>" "-<" "-<<"
                                               "&&" "||" "|>" "==>" "=>" "=>>" "<="
                                               "=<<" "=/=" ">-" ">=" ">=>" ">>" ">>-" ">>="
                                               "<|" "<|>" "<-" "<--" "<->" "<=" "<==" "<=>"
                                               "<=<" "<>" "<<" "<<-" "<<=" "<~" "<~~" "~>"
                                               "~~" "~~>"))
        '';
      };

      mode-line-bell = {
        enable = true;
        config = "(mode-line-bell-mode)";
      };

      notifications = {
        enable = true;
        command = [ "notifications-notify" ];
      };

      notmuch = {
        enable = enableNotMuch;
        command = [
          "notmuch"
          "notmuch-show-tag"
          "notmuch-search-tag"
          "notmuch-tree-tag"
        ];
        functions = [ "notmuch-read-tag-changes" "string-trim" ];
        hook = [ "(notmuch-show . rah-disable-trailing-whitespace-mode)" ];
        bindLocal = {
          notmuch-show-mode-map = {
            "S" = "rah-notmuch-show-tag-spam";
            "d" = "rah-notmuch-show-tag-deleted";
          };
          notmuch-tree-mode-map = {
            "S" = "rah-notmuch-tree-tag-spam";
            "d" = "rah-notmuch-tree-tag-deleted";
          };
          notmuch-search-mode-map = {
            "S" = "rah-notmuch-search-tag-spam";
            "d" = "rah-notmuch-search-tag-deleted";
          };
        };
        config = let
          listTags = ts: "(list ${toString (map (t: ''"${t}"'') ts)})";
          spamTags = listTags [ "+spam" "-inbox" ];
          deletedTags = listTags [ "+deleted" "-inbox" ];
        in ''
          (defun rah-notmuch-show-tag-spam ()
            (interactive)
            (notmuch-show-tag ${spamTags}))

          (defun rah-notmuch-show-tag-deleted ()
            (interactive)
            (notmuch-show-tag ${deletedTags}))

          (defun rah-notmuch-tree-tag-spam ()
            (interactive)
            (notmuch-tree-tag ${spamTags}))

          (defun rah-notmuch-tree-tag-deleted ()
            (interactive)
            (notmuch-tree-tag ${deletedTags}))

          (defun rah-notmuch-search-tag-spam (&optional beg end)
            (interactive)
            (notmuch-search-tag ${spamTags} beg end))

          (defun rah-notmuch-search-tag-deleted (&optional beg end)
            (interactive)
            (notmuch-search-tag ${deletedTags} beg end))

          (setq notmuch-show-logo nil
                notmuch-always-prompt-for-sender t
                notmuch-archive-tags '("-inbox" "+archive"))

          ;; Fix use with consult-completing-read-multiple.
          (advice-add #'notmuch-read-tag-changes
                      :filter-return (lambda (x) (mapcar #'string-trim x)))
        '';
      };

      flyspell = {
        enable = true;
        command = [ "flyspell-mode" "flyspell-prog-mode" ];
        bindLocal = {
          flyspell-mode-map = { "C-;" = "flyspell-auto-correct-word"; };
        };
        hook = [
          # Spell check in text and programming mode.
          "(text-mode . flyspell-mode)"
          "(prog-mode . flyspell-prog-mode)"
        ];
        init = ''
          ;; Completely override flyspell's own keymap.
          (setq flyspell-mode-map (make-sparse-keymap))
        '';
        config = ''
          ;; In flyspell I typically do not want meta-tab expansion
          ;; since it often conflicts with the major mode. Also,
          ;; make it a bit less verbose.
          (setq flyspell-issue-message-flag nil
                flyspell-issue-welcome-flag nil
                flyspell-use-meta-tab nil)
        '';
      };

      # Remember where we where in a previously visited file. Built-in.
      saveplace = {
        enable = true;
        defer = 1;
        config = ''
          (setq-default save-place t)
          (setq save-place-file (locate-user-emacs-file "places"))
        '';
      };

      # More helpful buffer names. Built-in.
      uniquify = {
        enable = true;
        defer = 5;
        config = ''
          (setq uniquify-buffer-name-style 'post-forward)
        '';
      };

      # Hook up hippie expand.
      hippie-exp = {
        enable = true;
        bind = { "M-?" = "hippie-expand"; };
      };

      which-key = {
        enable = true;
        command = [
          "which-key-mode"
          "which-key-add-major-mode-key-based-replacements"
        ];
        defer = 3;
        config = "(which-key-mode)";
      };

      # Enable winner mode. This global minor mode allows you to
      # undo/redo changes to the window configuration. Uses the
      # commands C-c <left> and C-c <right>.
      winner = {
        enable = true;
        defer = 2;
        config = "(winner-mode 1)";
      };

      writeroom-mode = {
        enable = true;
        command = [ "writeroom-mode" ];
        bindLocal = {
          writeroom-mode-map = {
            "M-[" = "writeroom-decrease-width";
            "M-]" = "writeroom-increase-width";
            "M-'" = "writeroom-toggle-mode-line";
          };
        };
        hook = [ "(writeroom-mode . visual-line-mode)" ];
        config = ''
          (setq writeroom-bottom-divider-width 0)
        '';
      };

      buffer-move = {
        enable = true;
        bind = {
          "C-S-<up>" = "buf-move-up";
          "C-S-<down>" = "buf-move-down";
          "C-S-<left>" = "buf-move-left";
          "C-S-<right>" = "buf-move-right";
        };
      };

      nyan-mode = {
        enable = true;
        command = [ "nyan-mode" ];
        config = ''
          (setq nyan-wavy-trail t)
        '';
      };

      string-inflection = {
        enable = true;
        bind = { "C-c C-u" = "string-inflection-all-cycle"; };
      };

      # Configure magit, a nice mode for the git SCM.
      magit = {
        enable = true;
        command = [ "magit-project-status" ];
        bind = { "C-c g" = "magit-status"; };
        hook = [''
          (magit-mode . (lambda ()
            (interactive)
            (transient-append-suffix 'magit-commit "a"
              '("n" "Reshelve commit" magit-commit-reshelve))
            (transient-append-suffix 'magit-rebase "s"
              '("t" "Reshelve since" magit-reshelve-since))
            (transient-append-suffix 'magit-push "-n"
              '("=O" "Set extra push option #1" "--push-option=" read-from-minibuffer))
            (transient-append-suffix 'magit-push "-n"
              '("=P" "Set extra push option #2" "--push-option=" read-from-minibuffer))
            (transient-append-suffix 'magit-push "-n"
              '("-S" "Skip gitlab pipeline creation" "--push-option=ci.skip"))
          ))
        ''];
        init = ''
          (setq magit-git-executable (file-truename (locate-file "git" exec-path)))
        '';
        config = ''
          (add-to-list 'git-commit-style-convention-checks
                       'overlong-summary-line)
        '';
      };

      git-auto-commit-mode = {
        enable = true;
        command = [ "git-auto-commit-mode" ];
        config = ''
          (setq gac-debounce-interval 60)
        '';
      };

      git-messenger = {
        enable = true;
        bind = { "C-x v p" = "git-messenger:popup-message"; };
      };

      marginalia = {
        enable = true;
        command = [ "marginalia-mode" ];
        after = [ "vertico" ];
        defer = 1;
        config = "(marginalia-mode)";
      };

      mml-sec = {
        enable = true;
        defer = true;
        config = ''
          (setq mml-secure-openpgp-encrypt-to-self t
                mml-secure-openpgp-sign-with-sender t)
        '';
      };

      multiple-cursors = {
        enable = true;
        bind = {
          "C-S-c C-S-c" = "mc/edit-lines";
          "C-c m" = "mc/mark-all-like-this";
          "C->" = "mc/mark-next-like-this";
          "C-<" = "mc/mark-previous-like-this";
        };
      };

      nix-sandbox = {
        enable = true;
        command = [ "nix-current-sandbox" "nix-shell-command" ];
      };

      avy = {
        enable = true;
        bind = { "M-j" = "avy-goto-word-or-subword-1"; };
        config = ''
          (setq avy-all-windows t)
        '';
      };

      undo-tree = {
        enable = true;
        defer = 1;
        command = [ "global-undo-tree-mode" ];
        config = ''
          (setq undo-tree-visualizer-relative-timestamps t
                undo-tree-visualizer-timestamps t
                undo-tree-enable-undo-in-region t
                undo-tree-auto-save-history t
                undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo"))
          )
          (global-undo-tree-mode)
        '';
      };

      # Configure AUCTeX.
      latex = {
        enable = true;
        package = epkgs: epkgs.auctex;
        hook = [''
          (LaTeX-mode
           . (lambda ()
               (turn-on-reftex)       ; Hook up AUCTeX with RefTeX.
               (auto-fill-mode)
               (define-key LaTeX-mode-map [adiaeresis] "\\\"a")))
        ''];
        config = ''
          (setq TeX-PDF-mode t
                TeX-auto-save t
                TeX-parse-self t)

          ;; Add Glossaries command. See
          ;; http://tex.stackexchange.com/a/36914
          (eval-after-load "tex"
            '(add-to-list
              'TeX-command-list
              '("Glossaries"
                "makeglossaries %s"
                TeX-run-command
                nil
                t
                :help "Create glossaries file")))
        '';
      };

      lsp-elm = {
        enable = true;
        defer = true;
        hook = [ "(elm-mode . rah-lsp)" ];
        config = ''
          (setq lsp-elm-elm-language-server-path
                  "${pkgs.elmPackages.elm-language-server}/bin/elm-language-server")
        '';
      };

      lsp-haskell = {
        enable = true;
        defer = true;
        hook = [ "(haskell-mode . rah-lsp)" ];
      };

      lsp-purescript = {
        enable = true;
        defer = true;
        hook = [ "(purescript-mode . rah-lsp) " ];
      };

      lsp-ui = {
        enable = true;
        command = [ "lsp-ui-mode" ];
        bindLocal = {
          lsp-mode-map = {
            "C-c r d" = "lsp-ui-doc-glance";
            "C-c f s" = "lsp-ui-find-workspace-symbol";
          };
        };
        config = ''
          (setq lsp-ui-sideline-enable t
                lsp-ui-sideline-show-symbol nil
                lsp-ui-sideline-show-hover nil
                lsp-ui-sideline-show-code-actions nil
                lsp-ui-sideline-update-mode 'point)
          (setq lsp-ui-doc-enable nil
                lsp-ui-doc-position 'at-point
                lsp-ui-doc-max-width 120
                lsp-ui-doc-max-height 15)
        '';
      };

      lsp-ui-flycheck = {
        enable = true;
        after = [ "flycheck" "lsp-ui" ];
      };

      lsp-completion = {
        enable = true;
        after = [ "lsp-mode" ];
        config = ''
          (setq lsp-completion-enable-additional-text-edit nil)
        '';
      };

      lsp-diagnostics = {
        enable = true;
        after = [ "lsp-mode" ];
      };

      lsp-mode = {
        enable = true;
        demand = true;
        command = [
          "lsp"
        ];
        after = [ "company" "flycheck" "which-key" ];
        hook = [
          "(lsp-mode . lsp-enable-which-key-integration)"
          "(scala-mode . lsp)"
          "(lsp-mode . lsp-lens-mode)"
        ];
        bindLocal = {
          lsp-mode-map = {
            "C-c l d" = "dap-hydra";
            "C-c r r" = "lsp-rename";
            "C-c r f" = "lsp-format-buffer";
            "C-c r g" = "lsp-format-region";
            "C-c r a" = "lsp-execute-code-action";
            "C-c f r" = "lsp-find-references";
          };
        };
        init = ''
          (setq lsp-keymap-prefix "C-c l")
          (which-key-add-key-based-replacements "C-c l d" "debugger")
        '';
        config = ''
          (setq lsp-diagnostics-provider :flycheck
                lsp-modeline-workspace-status-enable nil
                lsp-modeline-diagnostics-enable nil
                lsp-modeline-code-actions-enable nil
                lsp-eldoc-render-all nil
                lsp-headerline-breadcrumb-enable nil
          )

          (add-to-list 'lsp-file-watch-ignored-directories "[/\\\\]\\.Trash\\'")
          (add-to-list 'lsp-file-watch-ignored-files "[/\\\\]\\.Trash\\'")

          ;; scala metals suggested properties
          ;; UNCOMMENT the following to tune lsp-mode performance as per
          ;; ;; https://emacs-lsp.github.io/lsp-mode/page/performance/
          ;;       (setq gc-cons-threshold 100000000) ;; 100mb
          ;;       (setq read-process-output-max (* 1024 1024)) ;; 1mb
          ;;       (setq lsp-idle-delay 0.500)
          ;;       (setq lsp-log-io nil)
          ;;       (setq lsp-completion-provider :capf)
          (setq lsp-prefer-flymake nil)

          (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
        '';
        defines = [
          "lsp-prefer-flymake"
        ];
      };

      lsp-java = {
        enable = true;
        defer = true;
        hook = [ "(java-mode . rah-lsp)" ];
        bindLocal = {
          java-mode-map = { "C-c r o" = "lsp-java-organize-imports"; };
        };
        config = ''
          (setq lsp-java-save-actions-organize-imports nil
                lsp-java-completion-favorite-static-members
                    ["org.assertj.core.api.Assertions.*"
                     "org.assertj.core.api.Assumptions.*"
                     "org.hamcrest.Matchers.*"
                     "org.junit.Assert.*"
                     "org.junit.Assume.*"
                     "org.junit.jupiter.api.Assertions.*"
                     "org.junit.jupiter.api.Assumptions.*"
                     "org.junit.jupiter.api.DynamicContainer.*"
                     "org.junit.jupiter.api.DynamicTest.*"
                     "org.mockito.ArgumentMatchers.*"])
        '';
      };

      lsp-metals = {
        enable = true;
        hook = [ "(scala-mode . lsp)" ];
        config = ''
          ;; Metals claims to support range formatting by default, but it supports range
          ;; formatting of multiline strings only. By disabling it emacs can use the
          ;; indendation provided by scala-mode instead.
          ;;(lsp-metals-server-args '("-J-Dmetals.allow-multiline-string-formatting=off"))
        '';
      };

      lsp-python-ms = {
        enable = true;
        defer = true;
        hook = [ "(python-mode . rah-lsp)" ];
        config = ''
          (setq lsp-python-ms-executable (executable-find "python-language-server"))
        '';
      };

      lsp-rust = {
        enable = true;
        defer = true;
        hook = [ "(rust-mode . rah-lsp)" ];
      };

      lsp-treemacs = {
        enable = true;
        after = [ "lsp-mode" "treemacs" ];
        command = [ "lsp-treemacs-errors-list" ];
        config = ''
          (lsp-treemacs-sync-mode 1)
        '';
      };

      dap-mode = {
        enable = true;
        after = [ "lsp-mode" ];
        hook = [
          "(lsp-mode . dap-mode)"
          "(lsp-mode . dap-ui-mode)"
        ];
        # extraConfig = ''
        #   :bind (:map lsp-mode-map
        #    ("<f5>" . dap-debug)
        #    ("C-c l d" . dap-hydra))
        # '';
      };

      dap-mouse = {
        enable = true;
        hook = [ "(dap-mode . dap-tooltip-mode)" ];
      };

      dap-ui = {
        enable = true;
        hook = [ "(dap-mode . dap-ui-mode)" ];
      };

      dap-java = {
        enable = true;
        after = [ "dap-mode" "lsp-java" ];
      };

      # use the Debug Adapter Protocol for running tests and debugging
      posframe = {
        enable = true;
      };

      #  Setup RefTeX.
      reftex = {
        enable = true;
        defer = true;
        config = ''
          (setq reftex-default-bibliography '("~/research/bibliographies/main.bib")
                reftex-cite-format 'natbib
                reftex-plug-into-AUCTeX t)
        '';
      };

      haskell-mode = {
        enable = true;
        mode = [
          ''("\\.hs\\'" . haskell-mode)''
          ''("\\.hsc\\'" . haskell-mode)''
          ''("\\.c2hs\\'" . haskell-mode)''
          ''("\\.cpphs\\'" . haskell-mode)''
          ''("\\.lhs\\'" . haskell-literate-mode)''
        ];
        hook = [ "(haskell-mode . subword-mode)" ];
        bindLocal.haskell-mode-map = {
          "C-c C-l" = "haskell-interactive-bring";
        };
        config = ''
          (setq tab-width 2)

          (setq haskell-process-log t
                haskell-notify-p t)

          (setq haskell-process-args-cabal-repl
                '("--ghc-options=+RTS -M500m -RTS -ferror-spans -fshow-loaded-modules"))
        '';
      };

      haskell-cabal = {
        enable = true;
        mode = [ ''("\\.cabal\\'" . haskell-cabal-mode)'' ];
        bindLocal = {
          haskell-cabal-mode-map = {
            "C-c C-c" = "haskell-process-cabal-build";
            "C-c c" = "haskell-process-cabal";
            "C-c C-b" = "haskell-interactive-bring";
          };
        };
      };

      haskell-doc = {
        enable = true;
        command = [ "haskell-doc-current-info" ];
      };

      markdown-mode = {
        enable = true;
        config = ''
          (setq markdown-command "${pkgs.pandoc}/bin/pandoc")
        '';
      };

      pandoc-mode = {
        enable = true;
        after = [ "markdown-mode" ];
        hook = [ "markdown-mode" ];
        bindLocal = {
          markdown-mode-map = { "C-c C-c" = "pandoc-run-pandoc"; };
        };
      };

      nix-mode = {
        enable = true;
        hook = [ "(nix-mode . subword-mode)" ];
      };

      # Use ripgrep for fast text search in projects. I usually use
      # this through Projectile.
      ripgrep = {
        enable = true;
        command = [ "ripgrep-regexp" ];
      };

      org = {
        enable = true;
        package = epkgs: epkgs.org-contrib;
        bind = {
          "C-c o c" = "org-capture";
          "C-c o a" = "org-agenda";
          "C-c o l" = "org-store-link";
          "C-c o b" = "org-switchb";
        };
        hook = [''
          (org-mode
           . (lambda ()
               (add-hook 'completion-at-point-functions
                         'pcomplete-completions-at-point nil t)))
        ''];
        config = ''
          ;; Some general stuff.
          (setq org-reverse-note-order t
                org-use-fast-todo-selection t
                org-adapt-indentation nil
                org-hide-leading-stars t
                org-hide-emphasis-markers t
                org-ctrl-k-protect-subtree t)

          ;; Add some todo keywords.
          (setq org-todo-keywords
                '((sequence "TODO(t)"
                            "STARTED(s!)"
                            "WAITING(w@/!)"
                            "DELEGATED(@!)"
                            "|"
                            "DONE(d!)"
                            "CANCELED(c@!)")))

          ;; Active Org-babel languages
          (org-babel-do-load-languages 'org-babel-load-languages
                                       '((plantuml . t)
                                         (http . t)
                                         (shell . t)
                                         (sql . t)
                                         (verb . t)))

          ;; Unfortunately org-mode tends to take over keybindings that
          ;; start with C-c.
          (unbind-key "C-c <SPC>" org-mode-map)
          (unbind-key "C-c w" org-mode-map)
          (unbind-key "C-'" org-mode-map)
        '';
      };

      org-agenda = {
        enable = true;
        after = [ "org" ];
        defer = true;
        config = ''
          ;; Set up agenda view.
          (setq org-agenda-files (rah-all-org-files)
                org-agenda-span 5
                org-deadline-warning-days 14
                org-agenda-show-all-dates t
                org-agenda-skip-deadline-if-done t
                org-agenda-skip-scheduled-if-done t
                org-agenda-start-on-weekday nil)
        '';
      };

      ob-http = {
        enable = true;
        after = [ "org" ];
        defer = true;
      };

      ob-plantuml = {
        enable = true;
        after = [ "org" ];
        defer = true;
      };

      ol-notmuch = {
        enable = pcfg.org.enable && enableNotMuch;
        after = [ "notmuch" "org" ];
      };

      org-roam = {
        enable = true;
        command = [ "org-roam-db-autosync-mode" ];
        defines = [ "org-roam-v2-ack" ];
        bind = { "C-' f" = "org-roam-node-find"; };
        bindLocal = {
          org-mode-map = {
            "C-' b" = "org-roam-buffer-toggle";
            "C-' i" = "org-roam-node-insert";
          };
        };
        init = ''
          (setq org-roam-v2-ack t)
        '';
        config = ''
          (setq org-roam-directory "~/roam")
          (org-roam-db-autosync-mode)
        '';
      };

      org-table = {
        enable = true;
        after = [ "org" ];
        command = [ "orgtbl-to-generic" ];
        functions = [ "org-combine-plists" ];
        hook = [
          # For orgtbl mode, add a radio table translator function for
          # taking a table to a psql internal variable.
          ''
            (orgtbl-mode
             . (lambda ()
                 (defun rah-orgtbl-to-psqlvar (table params)
                   "Converts an org table to an SQL list inside a psql internal variable"
                   (let* ((params2
                           (list
                            :tstart (concat "\\set " (plist-get params :var-name) " '(")
                            :tend ")'"
                            :lstart "("
                            :lend "),"
                            :sep ","
                            :hline ""))
                          (res (orgtbl-to-generic table (org-combine-plists params2 params))))
                     (replace-regexp-in-string ",)'$"
                                               ")'"
                                               (replace-regexp-in-string "\n" "" res))))))
          ''
        ];
        config = ''
          (unbind-key "C-c <SPC>" orgtbl-mode-map)
          (unbind-key "C-c w" orgtbl-mode-map)
        '';
      };

      org-capture = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq org-capture-templates rah-org-capture-templates)
        '';
      };

      org-clock = {
        enable = true;
        after = [ "org" ];
        config = ''
          (setq org-clock-rounding-minutes 5
                org-clock-out-remove-zero-time-clocks t)
        '';
      };

      org-duration = {
        enable = true;
        after = [ "org" ];
        config = ''
          ;; I always want clock tables and such to be in hours, not days.
          (setq org-duration-format (quote h:mm))
        '';
      };

      org-refile = {
        enable = true;
        after = [ "org" ];
        config = ''
          ;; Refiling should include not only the current org buffer but
          ;; also the standard org files. Further, set up the refiling to
          ;; be convenient with IDO. Follows norang's setup quite closely.
          (setq org-refile-targets '((nil :maxlevel . 2)
                                     (org-agenda-files :maxlevel . 2))
                org-refile-use-outline-path t
                org-outline-path-complete-in-steps nil
                org-refile-allow-creating-parent-nodes 'confirm)
        '';
      };

      org-superstar = {
        enable = true;
        hook = [ "(org-mode . org-superstar-mode)" ];
      };

      org-tree-slide = {
        enable = true;
        command = [ "org-tree-slide-mode" ];
      };

      org-variable-pitch = {
        enable = false;
        hook = [ "(org-mode . org-variable-pitch-minor-mode)" ];
      };

      orderless = {
        enable = true;
        init = ''
          (setq completion-styles '(orderless)
                read-file-name-completion-ignore-case t)
        '';
      };

      purescript-mode = {
        enable = true;
        hook = [ "(purescript-mode . subword-mode)" ];
      };

      purescript-indentation = {
        enable = true;
        hook = [ "(purescript-mode . purescript-indentation-mode)" ];
      };

      scala-mode = {
        enable = true;
        mode = [
          ''("\\.scala\\'" . scala-mode)''
          ''("\\.sc\\'" . scala-mode)''
        ];
        config = ''
          (setq-local indent-region-function 'indent-for-tab-command-line-by-line)
        '';
      };

      sbt-mode = {
        enable = true;
        command = [ "sbt-start" "sbt-command" ];
        config = ''
          ;; WORKARROUND: https://github.com/ensime/emacs-sbt-mode/issues/31
          ;; allows using SPACE when in the minibuffer
          (substitute-key-definition
          'minibuffer-complete-word
          'self-insert-command
          minibuffer-local-completion-map)

          ;; sbt-supershell kills sbt-mode: https://github.com/hvesalai/emacs-sbt-mode/issues/152
          (setq sbt:program-options '("-Dsbt.supershell=false"))
        '';
      };

      # Set up yasnippet. Defer it for a while since I don't generally
      # need it immediately.
      yasnippet = {
        enable = true;
        defer = 3;
        command = [ "yas-global-mode" "yas-minor-mode" "yas-expand-snippet" ];
        hook = [
          # Yasnippet interferes with tab completion in ansi-term.
          "(term-mode . (lambda () (yas-minor-mode -1)))"
        ];
        config = "(yas-global-mode 1)";
      };

      yasnippet-snippets = {
        enable = true;
        after = [ "yasnippet" ];
      };

      # Setup the cperl-mode, which I prefer over the default Perl
      # mode.
      cperl-mode = {
        enable = true;
        defer = true;
        hook = [ "ggtags-mode" ];
        command = [ "cperl-set-style" ];
        config = ''
          ;; Avoid deep indentation when putting function across several
          ;; lines.
          (setq cperl-indent-parens-as-block t)

          ;; Use cperl-mode instead of the default perl-mode
          (defalias 'perl-mode 'cperl-mode)
          (cperl-set-style "PerlStyle")
        '';
      };

      # Setup ebib, my chosen bibliography manager.
      ebib = {
        enable = false;
        command = [ "ebib" ];
        hook = [
          # Highlighting of trailing whitespace is a bit annoying in ebib.
          "(ebib-index-mode-hook . rah-disable-trailing-whitespace-mode)"
          "(ebib-entry-mode-hook . rah-disable-trailing-whitespace-mode)"
        ];
        config = ''
          (setq ebib-latex-preamble '("\\usepackage{a4}"
                                      "\\bibliographystyle{amsplain}")
                ebib-print-preamble '("\\usepackage{a4}")
                ebib-print-tempfile "/tmp/ebib.tex"
                ebib-extra-fields '(crossref
                                    url
                                    annote
                                    abstract
                                    keywords
                                    file
                                    timestamp
                                    doi))
        '';
      };

      smartparens = {
        enable = true;
        defer = 3;
        command = [ "smartparens-global-mode" "show-smartparens-global-mode" ];
        bindLocal = {
          smartparens-mode-map = {
            "C-M-f" = "sp-forward-sexp";
            "C-M-b" = "sp-backward-sexp";
          };
        };
        config = ''
          (require 'smartparens-config)
          (smartparens-global-mode t)
          (show-smartparens-global-mode t)
        '';
      };

      fill-column-indicator = {
        enable = true;
        command = [ "fci-mode" ];
      };

      flycheck = {
        enable = true;
        command = [ "global-flycheck-mode" ];
        defer = 1;
        bind = {
          "M-n" = "flycheck-next-error";
          "M-p" = "flycheck-previous-error";
        };
        config = ''
          ;; Only check buffer when mode is enabled or buffer is saved.
          (setq flycheck-check-syntax-automatically '(mode-enabled save))

          ;; Enable flycheck in all eligible buffers.
          (global-flycheck-mode)
        '';
      };

      flycheck-plantuml = {
        enable = true;
        hook = [ "(flycheck-mode . flycheck-plantuml-setup)" ];
      };

      project = {
        enable = true;
        command = [ "project-root" ];
        bindKeyMap = { "C-x p" = "project-prefix-map"; };
        bindLocal = {
          project-prefix-map = { "m" = "magit-project-status"; };
        };
        config = ''
          (add-to-list 'project-switch-commands '(magit-project-status "Magit") t)
        '';
      };

      projectile = {
        enable = true;
        command = [ "projectile-mode" ];
        bindKeyMap = { "C-c p" = "projectile-command-map"; };
        config = ''
          (projectile-mode)
          (setq projectile-switch-project-action 'projectile-find-file)
          (projectile-register-project-type 'yarn '("package.json" "yarn.lock")
                                            :compile "yarn install"
                                            :test "yarn test"
                                            :run "yarn start"
                                            :test-suffix ".test")
        '';
      };

      plantuml-mode = {
        enable = true;
        mode = [ ''"\\.puml\\'"'' ];
        init = ''
          (setq plantuml-executable-path (locate-file "plantuml" exec-path))
          (setq plantuml-default-exec-mode 'executable)
        '';
      };

      ace-window = {
        enable = true;
        extraConfig = ''
          :bind* (("C-c w" . ace-window)
                  ("M-o" . ace-window))
        '';
      };

      company = {
        enable = true;
        command = [ "company-mode" "company-doc-buffer" "global-company-mode" ];
        defer = 1;
        extraConfig = ''
          :bind (:map company-mode-map
                      ([remap completion-at-point] . company-complete-common)
                      ([remap complete-symbol] . company-complete-common))
        '';
        config = ''
          (setq company-idle-delay 0.3
                company-show-quick-access t
                company-tooltip-maximum-width 100
                company-tooltip-minimum-width 20
                ; Allow me to keep typing even if company disapproves.
                company-require-match nil)

          (setq lsp-completion-provider :capf)

          (global-company-mode)

          ;; https://www.emacswiki.org/emacs/CompanyMode
          (require 'color)
          (let ((bg (face-attribute 'default :background)))
            (custom-set-faces
              `(company-tooltip ((t (:inherit default :background ,(color-lighten-name bg 2)))))
              `(company-scrollbar-bg ((t (:background ,(color-lighten-name bg 10)))))
              `(company-scrollbar-fg ((t (:background ,(color-lighten-name bg 5)))))
              `(company-tooltip-selection ((t (:inherit font-lock-function-name-face))))
              `(company-tooltip-common ((t (:inherit font-lock-constant-face))))))
        '';
        defines = [
          "lsp-completion-provider"
        ];
      };

      company-box = {
        enable = true;
        hook = [ "(company-mode . company-box-mode)" ];
        config = ''
          (setq company-box-icons-alist 'company-box-icons-all-the-icons)
        '';
      };

      company-yasnippet = {
        enable = true;
        after = [ "company" "yasnippet" ];
        bind = { "M-/" = "company-yasnippet"; };
      };

      company-dabbrev = {
        enable = true;
        after = [ "company" ];
        bind = { "C-M-/" = "company-dabbrev"; };
        config = ''
          (setq company-dabbrev-downcase nil
                company-dabbrev-ignore-case t)
        '';
      };

      company-quickhelp = {
        enable = true;
        after = [ "company" ];
        command = [ "company-quickhelp-mode" ];
        config = ''
          (company-quickhelp-mode 1)
        '';
      };

      company-cabal = {
        enable = true;
        after = [ "company" ];
        command = [ "company-cabal" ];
        config = ''
          (add-to-list 'company-backends 'company-cabal)
        '';
      };

      crux = {
        enable = true;
        bind = {
          "C-S-k" = "crux-smart-kill-line";
          "C-c D" = "crux-delete-file-and-buffer";
          "C-c d" = "crux-duplicate-current-line-or-region";
          "C-c n" = "crux-cleanup-buffer-or-region";
          "C-c r" = "crux-recentf-find-file";
          "C-a" = "crux-move-beginning-of-line";
        };
      };

      editorconfig = {
        enable = true;
        config = ''
          (set-variable 'editorconfig-get-properties-function
                        #'editorconfig-get-properties-from-exec)
          (editorconfig-mode 1)
        '';
      };

      forge = {
        enable = true;
        after = [ "magit" ];
        config = ''
          (setq forge-owned-accounts '())
          (let ((forgeAccounts
                (or
                  (getenv "FORGE_OWNED_ACCOUNTS")
                  (getenv "USER"))))
            (if forgeAccounts
                (let ((accountsList (list forgeAccounts)))
                  (progn
                    (message "Configuring forge-owned-accounts: %s" accountsList)
                    (add-to-list 'forge-owned-accounts accountsList)
                    ))))
        '';
      };

      forge-custom = {
        enable = pathExists (toString ~/.config/custom/forge-custom.el);
        after = [ "forge" ];
      };

      format-all = {
        enable = true;
      };

      php-mode = { hook = [ "ggtags-mode" ]; };

      # Needed by Flycheck.
      pkg-info = {
        enable = true;
        command = [ "pkg-info-version-info" ];
      };

      popper = {
        enable = true;
        bind = {
          "C-`" = "popper-toggle-latest";
          "M-`" = "popper-cycle";
          "C-M-`" = "popper-toggle-type";
        };
        command = [ "popper-mode" "popper-group-by-project" ];
        config = ''
          (setq popper-reference-buffers
                  '("Output\\*$"
                    "\\*Async Shell Command\\*"
                    "\\*Buffer List\\*"
                    "\\*Flycheck errors\\*"
                    "\\*Messages\\*"
                    compilation-mode
                    help-mode)
                popper-group-function #'popper-group-by-project)
          (popper-mode)
        '';
      };

      python = {
        enable = true;
        mode = [ ''("\\.py\\'" . python-mode)'' ];
        hook = [ "ggtags-mode" ];
      };

      transpose-frame = {
        enable = true;
        bind = { "C-c f t" = "transpose-frame"; };
      };

      tt-mode = {
        enable = true;
        mode = [ ''"\\.tt\\'"'' ];
      };

      yaml-mode = {
        enable = true;
        hook = [ "(yaml-mode . rah-prog-mode-setup)" ];
      };

      wc-mode = {
        enable = true;
        command = [ "wc-mode" ];
      };

      web-mode = {
        enable = true;
        mode = [
          ''"\\.html\\'"'' # \
          ''"\\.jsx?\\'"'' # \
        ];
        config = ''
          (setq web-mode-attr-indent-offset 4
                web-mode-code-indent-offset 2
                web-mode-markup-indent-offset 2)

          (add-to-list 'web-mode-content-types '("jsx" . "\\.jsx?\\'"))
        '';
      };

      dired = {
        enable = true;
        command = [ "dired" "dired-jump" ];
        config = ''
          (put 'dired-find-alternate-file 'disabled nil)

          ;; Be smart about choosing file targets.
          (setq dired-dwim-target t)

          ;; Use the system trash can.
          (setq delete-by-moving-to-trash t)
          (setq insert-directory-program "ls" dired-use-ls-dired t)
          (setq dired-listing-switches "-alvh --group-directories-first")
        '';
      };

      dired-filter = {
        enable = true;
        config = ''
          (define-key dired-mode-map (kbd "/") dired-filter-map)
          (define-key dired-mode-map (kbd "M-/") dired-filter-mark-map)
        '';
      };

      all-the-icons = {
        enable = true;
      };

      all-the-icons-dired = {
        enable = true;
        hook = [ "(dired-mode . all-the-icons-dired-mode)" ];
      };

      wdired = {
        enable = true;
        bindLocal = {
          dired-mode-map = { "C-c C-w" = "wdired-change-to-wdired-mode"; };
        };
        config = ''
          ;; I use wdired quite often and this setting allows editing file
          ;; permissions as well.
          (setq wdired-allow-to-change-permissions t)
        '';
      };

      # Hide hidden files when opening a dired buffer. But allow showing them by
      # pressing `.`.
      dired-x = {
        enable = true;
        hook = [ "(dired-mode . dired-omit-mode)" ];
        bindLocal.dired-mode-map = { "." = "dired-omit-mode"; };
        config = ''
          (setq dired-omit-verbose nil
                dired-omit-files (concat dired-omit-files "\\|^\\..+$"))
        '';
      };

      direnv = {
        enable = true;
        config = ''
          (direnv-mode)
        '';
      };

      recentf = {
        enable = true;
        command = [ "recentf-mode" ];
        config = ''
          (setq recentf-save-file (locate-user-emacs-file "recentf")
                recentf-max-menu-items 20
                recentf-max-saved-items 500
                recentf-exclude '("COMMIT_MSG" "COMMIT_EDITMSG"))

          ;; Save the file list every 5 minutes silently.
          ;; https://emacs.stackexchange.com/questions/45697/prevent-emacs-from-messaging-when-it-writes-recentf
          (run-at-time nil (* 5 60)
            (lambda ()
              (let ((save-silently t)
                    (inhibit-message t))
                (recentf-save-list))))

          (recentf-mode)
        '';
      };

      nxml-mode = {
        enable = true;
        mode = [ ''"\\.xml\\'"'' ];
        config = ''
          (setq nxml-child-indent 2
                nxml-attribute-indent 4
                nxml-slash-auto-complete-flag t)
          (add-to-list 'rng-schema-locating-files
                       "~/.emacs.d/nxml-schemas/schemas.xml")
        '';
      };

      rust-mode.enable = true;

      savehist = {
        enable = true;
        init = "(savehist-mode)";
        config = ''
          (setq history-delete-duplicates t
                history-length 100)
        '';
      };

      sendmail = {
        command = [ "mail-mode" "mail-text" ];
        mode = [
          ''("^mutt-" . mail-mode)'' # \
          ''("\\.article" . mail-mode)'' # \
        ];
        bindLocal = {
          mail-mode-map = {
            # Make it easy to include references.
            "C-c [" = "rah-mail-reftex-citation";
          };
        };
        hook = [ "rah-mail-mode-hook" ];
        config = ''
          (defun rah-mail-reftex-citation ()
            (let ((reftex-cite-format 'locally))
              (reftex-citation)))

          (defun rah-mail-flyspell ()
            "Enable flyspell and set dictionary based on To: field."
            (save-excursion
              (goto-char (point-min))
              (when (re-search-forward "^To: .*\\.se\\($\\|,\\|>\\)" nil t)
                (ispell-change-dictionary "swedish"))))

          (defun rah-mail-mode-hook ()
            (auto-fill-mode)     ; Avoid having to M-q all the time.
            (rah-mail-flyspell)  ; I spel funily soemtijms.
            (mail-text))         ; Jump to the actual text.

          (setq sendmail-program "${pkgs.msmtp}/bin/msmtp"
                send-mail-function 'sendmail-send-it
                mail-specify-envelope-from t
                message-sendmail-envelope-from 'header
                mail-envelope-from 'header)
        '';
      };

      shr = {
        enable = true;
        defer = true;
        config = ''
          (setq shr-use-colors nil)
        '';
      };

      sv-kalender = {
        enable = false;
        defer = 5;
      };

      systemd = {
        enable = true;
        defer = true;
      };

      treemacs = {
        enable = true;
        defer = true;
        bind = {
          "C-c t /" = "treemacs";
          "C-c t B" = "treemacs-bookmark";
          "C-c t 0" = "treemacs-select-window";
          "C-c t 1" = "treemacs-delete-other-windows";
          "C-c t d" = "treemacs-select-directory";
          "C-c t f" = "treemacs-find-file";
          "C-c t t" = "treemacs-find-tag";
        };
        config = ''
          (setq treemacs-python-executable "${python3}/bin/python3")
          (setq treemacs-follow-after-init t
                treemacs-project-follow-mode t
                treemacs-follow-mode t
                treemacs-filewatch-mode t
                treemacs-fringe-indicator-mode 'always)
          (treemacs-git-mode 'advanced)
          (add-to-list 'treemacs-pre-file-insert-predicates #'treemacs-is-file-git-ignored?)
        '';
	defines = [
	  "treemacs-project-follow-mode"
	];
      };

      treemacs-icons-dired = {
        hook = [ "(dired-mode . treemacs-icons-dired-enable-once)" ];
        enable = true;
        after = [ "treemacs" ];
        defer = true;
      };

      treemacs-magit = {
        enable = true;
        after = [ "treemacs" "magit" ];
        defer = true;
      };

      verb = {
        enable = true;
        defer = true;
        after = [ "org" ];
        config = ''
          (define-key org-mode-map (kbd "C-c C-r") verb-command-map)
          (setq verb-trim-body-end "[ \t\n\r]+")
        '';
      };

      vertico = {
        enable = true;
        command = [ "vertico-mode" "vertico-next" ];
        init = "(vertico-mode)";
        # config = ''
        #   (setq vertico-cycle t)
        # '';
      };

      visual-fill-column = {
        enable = true;
        command = [ "visual-fill-column-mode" ];
      };

      vterm = {
        enable = true;
        command = [ "vterm" ];
        hook = [ "(vterm-mode . rah-disable-trailing-whitespace-mode)" ];
        config = ''
          (setq vterm-kill-buffer-on-exit t
                vterm-max-scrollback 10000)
        '';
      };

      xterm-color = {
        enable = true;
        defer = 1;
        command = [ "xterm-color-filter" ];
      };
    };
  };
}
