;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Preparation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'package)

;; We keep a modified local copy of ox-rss.el on hand.
(add-to-list 'load-path (expand-file-name "./lisp"))

(setq package-user-dir (expand-file-name "./.packages"))
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(package-install 'htmlize)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Publishing
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(require 'ox-publish)
(require 'ox-rss)

;; Do not create tilde backup files
(setq make-backup-files nil)

(setq kinhung/project-dir "~/spaces/personal/"
      kinhung/org-dir (concat kinhung/project-dir "org/")
      kinhung/www-dir (concat kinhung/project-dir "org/")
      kinhung/blog-org-dir (concat kinhung/org-dir "blog/")
      kinhung/blog-www-dir (concat kinhung/www-dir "blog/"))

(setq org-publish-timestamp-directory
      (concat kinhung/project-dir "cache/"))

(setq kinhung/head
      (concat
       "<meta name=\"twitter:site\" content=\"@twylo\" />\n"
       "<meta name=\"twitter:creator\" content=\"@twylo\" />\n"
       "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\" />\n"
       "<link rel=\"me\" href=\"https://weibo.com/u/2150445074\" />\n"
       "<link rel=\"icon\" type=\"image/png\" href=\"/images/icon/favicon-32x32.png\" />\n"
       "<link rel=\"apple-touch-icon-precomposed\" href=\"/images/icon/apple-touch-icon.png\" />\n"
       "<link rel=\"alternate\" type=\"application/rss+xml\" title=\"Weblog RSS Feed\" href=\"/blog/rss.xml\" />\n"
       "<link rel=\"stylesheet\" type=\"text/css\" href=\"/res/faces.css\">\n"
       "<link rel=\"stylesheet\" type=\"text/css\" href=\"/res/style.css\">\n"))

(setq kinhung/footer
      (concat
       "<div id=\"footer\">\n"
       "Proudly "
       "<a href=\"https://kinhung.me/blog/0110_emacs_blogging_for_fun_and_profit.html\">published</a> with "
       "<a href=\"https://www.gnu.org/software/emacs/\">Emacs</a> and "
       "<a href=\"https://orgmode.org/\">Org Mode</a>. This work is licensed "
       "under a <a rel=\"license\" href=\"http://creativecommons.org/licenses/by-sa/4.0/\">CC "
       "BY-SA 4.0</a> License. "
       "<a href=\"https://kinhung.me/privacy.html\">Privacy Policy</a>"
       "</div>"))

(defvar youtube-iframe-format
  (concat "<iframe width=\"440\""
          " height=\"335\""
          " src=\"https://www.youtube.com/embed/%s\""
          " frameborder=\"0\""
          " allowfullscreen>%s</iframe>"))

(defun kinhung/html-escape-attribute (value)
  "Entity-escape VALUE and wrap it in quotes."
  ;; http://www.w3.org/TR/2009/WD-html5-20090212/serializing-html-fragments.html
  ;;
  ;; "Escaping a string... consists of replacing any occurrences of
  ;; the "&" character by the string "&amp;", any occurrences of the
  ;; U+00A0 NO-BREAK SPACE character by the string "&nbsp;", and, if
  ;; the algorithm was invoked in the attribute mode, any occurrences
  ;; of the """ character by the string "&quot;"..."
  (let* ((value (replace-regexp-in-string "&" "&amp;" value))
         (value (replace-regexp-in-string "\u00a0" "&nbsp;" value))
         (value (replace-regexp-in-string "\"" "&quot;" value)))
    value))

;;
;; Supports [[div:some-class][special text]] syntax to generate
;; <div class="some-class">special text</div> forms.
;;

(org-link-set-parameters
 "div"
 :export (lambda (path desc backend)
           (cl-case backend
             (html (format "<div class=\"%s\">%s</div>"
                           (kinhung/html-escape-attribute path)
                           (or desc "")))
             (_ (or desc "")))))

(org-link-set-parameters
 "youtube"
 :follow (lambda (id)
           (browse-url
            (concat "https://www.youtube.com/embed/" id)))
 :export (lambda (path desc backend)
           (cl-case backend
             (html (format youtube-iframe-format
                           path (or desc "")))
             (latex (format "\href{%s}{%s}"
                            path (or desc "video"))))))

(defun kinhung/header (info)
  "Generate the standard navigation header for all pages."
  (with-temp-buffer
    (insert "<a class=\"skip-nav-link\" href=\"#content\">\n")
    (insert "  Skip navigation\n")
    (insert "</a>\n")
    (insert "<nav>\n")
    (insert "  <div class=\"navitem\"><a href=\"/\">Home</a></div>\n")
    (insert "  <div class=\"navitem\"><a href=\"/blog/\">Weblog</a></div>\n")
    (insert "  <div class=\"navitem\"><a href=\"/portfolio/\">Portfolio</a></div>\n")
    (insert "  <div class=\"navitem\"><a href=\"/resume.html\">Resume</a></div>\n")
    (insert "  <div class=\"navitem\"><a href=\"/contact.html\">Contact</a></div>\n")
    (insert "</nav>\n")
    (buffer-string)))

(defun kinhung/blog-header (info)
  "Generate a specialized header with publish date for blog entries."
  (with-temp-buffer
    (insert (kinhung/header info))
    (when (and (plist-get info :with-date)
               (not (string= "index.org" (plist-get info :input-buffer))))
      (let* ((spec (org-html-format-spec info))
             (date (cdr (assq ?d spec))))
        (progn
          (insert "<div class=\"published\">\n")
          (insert (format "Published %s\n" date))
          (insert "</nav>\n"))))
    (buffer-string)))

(defun kinhung/sitemap (title list)
  "Generate blog sitemap, as a string. TITLE is the title of the
blog. LIST is an internal representation of the files to include,
as returned by `org-list-to-lisp'. PROJECT is the current
project."
  (concat "#+TITLE: " title "\n\n"
          (org-list-to-subtree list nil '(:icount "" :istart ""))))

(defun kinhung/get-preview (entry)
  "Get the preview of a blog entry, and whether a `read more'
link is required to see the entire post. This is returned as a
cons pair of `(needs-more . preview-text)'. ENTRY is the entry to
get the preview for."
  (with-temp-buffer
    (insert-file-contents (concat kinhung/blog-org-dir entry))
    (goto-char (point-min))
    (let* ((len (buffer-size))
           (content-start (or
                           ;; Look for the first non-keyword line
                           (and (re-search-forward "^[^#]" nil t)
                                (match-beginning 0))
                           ;; Failing that, assume we're malformed and have no conent.
                           len))
           (marker (or
                    (and (re-search-forward "^#\\+MORE_LINK:" nil t)
                         (match-beginning 0))
                    len))
           (needs-more (not (= marker len)))
           (preview-text (string-trim (buffer-substring content-start marker))))
      (cons needs-more preview-text))))

(defun kinhung/blog-sitemap-entry (entry style project)
  "Default format for site map ENTRY, as a string.
ENTRY is a file name.  STYLE is the style of the sitemap.
PROJECT is the current project."
  (cond ((not (directory-name-p entry))
         (let* ((file (concat kinhung/blog-org-dir entry))
                (title (org-publish-find-title entry project))
                (date (org-publish-find-date entry project))
                (preview (kinhung/get-preview entry))
                (needs-more (car preview))
                (preview-text (cdr preview)))
           (format (concat
                    "* [[file:%s][%s]]\n"
                    "#+BEGIN_published\n"
                    "%s\n"
                    "#+END_published\n"
                    "%s\n"
                    "--------\n")
                   entry
                   title
                   (format-time-string "%A, %B %_d, %Y at %l:%M %p %Z" date)
                   (if needs-more
                       (format
                        (concat
                         "%s\n\n"
                         "#+BEGIN_morelink\n"
                         "[[file:%s][Read More →]]\n"
                         "#+END_morelink\n")
                        preview-text entry)
                     preview-text))))
        ((eq style 'tree)
         ;; Return only last subdir.
         (file-name-nondirectory (directory-file-name entry)))
        (t entry)))

(defun kinhung/publish-to-rss (plist filename pub-dir)
  "Publish RSS with PLIST, only when FILENAME is `rss.org'.
PUB-DIR is where the output will be placed."
  (if (string= "rss.org" (file-name-nondirectory filename))
      (org-rss-publish-to-rss plist filename pub-dir)))

(defun kinhung/rss-sitemap-entry (entry style project)
  "Return a single sitemap entry for the RSS feed.
ENTRY is the entry to display. STYLE is one of `list' or
`tree'. PROJECT is the current project."
  (cond ((not (directory-name-p entry))
         (let* ((file (org-publish--expand-file-name entry project))
                (email (plist-get (cdr project) :email))
                (author (plist-get (cdr project) :author))
                (title (org-publish-find-title entry project))
                (date (format-time-string "%Y-%m-%d %H:%M:%S" (org-publish-find-date entry project)))
                (preview (kinhung/get-preview entry))
                (needs-more (car preview))
                (preview-text (cdr preview))
                (link (concat (file-name-sans-extension entry) ".html")))
           (with-temp-buffer
             (insert (format "* [[file:%s][%s]]\n" file title))
             (org-set-property "RSS_PERMALINK" link)
             (org-set-property "PUBDATE" date)
             (org-set-property "EMAIL" email)
             (org-set-property "AUTHOR" author)
             (insert preview-text)
             (when needs-more
               (insert (format "\n\n[[file:./blog/%s][Read More →]]" entry)))
             (buffer-string))))
        ((eq style 'tree)
         ;; Return only last subdir.
         (file-name-nondirectory (directory-file-name entry)))
        (t entry)))

;;
;; This is a gross workaround because for the life of me, I cannot
;; figure out how to remove a filter from the filter-alist of an
;; ox-publish backend. The :filter-final-output filter of ox-rss.el
;; enters XML mode, inserts the contents, and then tries to indent it
;; for pretty printing. On my blog, this takes up to two minutes (!!)
;; To work around this, I just replace the function with a no-op.
;;
;; I'd prefer to do this "the right way", if such a way exists.
;;
(fmakunbound 'org-rss-final-function)

(defun org-rss-final-function (contents backend info)
  "Skip filtering backend"
  contents)

(setq org-publish-project-alist
      `(("kinhung"
         :components ("blog" "rss" "pages" "res" "images"))

        ("blog"
         :base-directory ,kinhung/blog-org-dir
         :base-extension "org"
         :publishing-directory ,kinhung/blog-www-dir
         :publishing-function org-html-publish-to-html
         :exclude "rss.*"
         :with-author t
         :author "kinhung lam"
         :email "linjxljx@gmail.com"
         :with-creator nil
         :with-date t
         :section-numbers nil
         :with-title t
         :with-toc nil
         :with-drawers t
         :with-sub-superscript nil
         :html-html5-fancy t
         :html-metadata-timestamp-format "%A, %B %_d, %Y at %l:%M %p"
         :html-doctype "html5"
         :html-link-home "https://kinhung.me/"
         :html-link-use-abs-url nil
         :html-head ,kinhung/head
         :html-head-extra nil
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :html-viewport nil
         :html-link-up ""
         :html-link-home ""
         :html-preamble kinhung/blog-header
         :html-postamble ,kinhung/footer
         :htmlize-output-type: 'inline-css
         :auto-sitemap t
         :sitemap-style list
         :sitemap-format-entry kinhung/blog-sitemap-entry
         :sitemap-function kinhung/sitemap
         :sitemap-filename "index.org"
         :sitemap-title "Kinhung Lam ∴ A Weblog"
         :sitemap-sort-files anti-chronologically)

        ("rss"
         :base-directory ,kinhung/blog-org-dir
         :base-extension "org"
         :author "kinhung lam"
         :email "linjxljx@gmail.com"
         :with-author t
         :with-email t
         :recursive nil
         :publishing-directory ,kinhung/blog-www-dir
         :html-link-home "/blog/"
         :html-link-use-abs-url nil
         :rss-extension "xml"
         :exclude ,(regexp-opt '("rss.org" "index.org" "404.org"))
         :publishing-function kinhung/publish-to-rss
         :filters-alist '() ;; Skip indenting the final output
         :html-link-org-files-as-html t
         :auto-sitemap t
         :sitemap-filename "rss.org"
         :sitemap-title "Kinhung Lam ∴ A Weblog"
         :sitemap-format-entry kinhung/rss-sitemap-entry
         :sitemap-function kinhung/sitemap)

        ("pages"
         :base-directory ,kinhung/org-dir
         :base-extension "org"
         :exclude ".*blog/.*"
         :publishing-directory ,kinhung/www-dir
         :publishing-function org-html-publish-to-html
         :section-numbers nil
         :recursive t
         :with-title t
         :with-toc nil
         :with-drawers t
         :with-sub-superscript nil
         :with-author t
         :author "kinhung lam"
         :email "linjxljx@gmail.com"
         :html-html5-fancy t
         :with-creator nil
         :with-date nil
         :html-link-home "/"
         :html-head nil
         :html-doctype "html5"
         :html-head ,kinhung/head
         :html-head-extra nil
         :html-head-include-default-style nil
         :html-head-include-scripts nil
         :html-link-up ""
         :html-link-home ""
         :html-preamble kinhung/header
         :html-postamble ,kinhung/footer
         :html-viewport nil)

        ("res"
         :base-directory ,kinhung/org-dir
         :base-extension "css\\|js\\|woff2\\|woff\\|ttf"
         :recursive t
         :publishing-directory ,kinhung/www-dir
         :publishing-function org-publish-attachment)

        ("images"
         :base-directory ,kinhung/org-dir
         :base-extension "png\\|jpg\\|gif\\|pdf\\|svg"
         :recursive t
         :publishing-directory ,kinhung/www-dir
         :publishing-function org-publish-attachment)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Publish the site
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(org-publish-all t)

(message "Build Complete")