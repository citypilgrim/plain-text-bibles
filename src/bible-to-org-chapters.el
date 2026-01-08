;;; bible-to-org-chapters.el --- Generate Bible chapters into Org files

(require 'cl-lib)
(require 's)
(require 'org-id)
(require 'sword-to-org)

;;;; User configuration

(defvar bible-org-module "ESV"
  "Sword module abbreviation (e.g. \"ESV\", \"WEB\", \"NASB\").")

(defvar bible-org-output-directory "~/bible/"
  "Directory where Bible Org files will be written.")

;;;; Book metadata
;; (ORDER ABBREV FILE-CODE FULL-NAME CHAPTERS)

(defconst bible-org-books
  '((1  "Gen"  "GEN" "Genesis"        50)
    (2  "Exod" "EXO" "Exodus"         40)
    (3  "Lev"  "LEV" "Leviticus"      27)
    (4  "Num"  "NUM" "Numbers"        36)
    (5  "Deut" "DEU" "Deuteronomy"    34)
    (6  "Josh" "JOS" "Joshua"         24)
    (7  "Judg" "JDG" "Judges"         21)
    (8  "Ruth" "RUT" "Ruth"            4)
    (9  "1Sam" "1SA" "1 Samuel"       31)
    (10 "2Sam" "2SA" "2 Samuel"       24)
    (11 "1Kgs" "1KI" "1 Kings"        22)
    (12 "2Kgs" "2KI" "2 Kings"        25)
    (13 "1Chr" "1CH" "1 Chronicles"   29)
    (14 "2Chr" "2CH" "2 Chronicles"   36)
    (15 "Ezra" "EZR" "Ezra"            10)
    (16 "Neh"  "NEH" "Nehemiah"       13)
    (17 "Esth" "EST" "Esther"         10)
    (18 "Job"  "JOB" "Job"             42)
    (19 "Ps"   "PSA" "Psalms"         150)
    (20 "Prov" "PRO" "Proverbs"       31)
    (21 "Eccl" "ECC" "Ecclesiastes"   12)
    (22 "Song" "SNG" "Song of Solomon" 8)
    (23 "Isa"  "ISA" "Isaiah"         66)
    (24 "Jer"  "JER" "Jeremiah"       52)
    (25 "Lam"  "LAM" "Lamentations"    5)
    (26 "Ezek" "EZK" "Ezekiel"        48)
    (27 "Dan"  "DAN" "Daniel"         12)
    (28 "Hos"  "HOS" "Hosea"          14)
    (29 "Joel" "JOL" "Joel"            3)
    (30 "Amos" "AMO" "Amos"            9)
    (31 "Obad" "OBA" "Obadiah"         1)
    (32 "Jonah""JON" "Jonah"           4)
    (33 "Mic"  "MIC" "Micah"           7)
    (34 "Nah"  "NAM" "Nahum"           3)
    (35 "Hab"  "HAB" "Habakkuk"        3)
    (36 "Zeph" "ZEP" "Zephaniah"       3)
    (37 "Hag"  "HAG" "Haggai"          2)
    (38 "Zech" "ZEC" "Zechariah"      14)
    (39 "Mal"  "MAL" "Malachi"         4)
    (40 "Matt" "MAT" "Matthew"        28)
    (41 "Mark" "MRK" "Mark"           16)
    (42 "Luke" "LUK" "Luke"           24)
    (43 "John" "JHN" "John"           21)
    (44 "Acts" "ACT" "Acts"           28)
    (45 "Rom"  "ROM" "Romans"         16)
    (46 "1Cor" "1CO" "1 Corinthians"  16)
    (47 "2Cor" "2CO" "2 Corinthians"  13)
    (48 "Gal"  "GAL" "Galatians"       6)
    (49 "Eph"  "EPH" "Ephesians"       6)
    (50 "Phil" "PHP" "Philippians"     4)
    (51 "Col"  "COL" "Colossians"      4)
    (52 "1Thess" "1TH" "1 Thessalonians" 5)
    (53 "2Thess" "2TH" "2 Thessalonians" 3)
    (54 "1Tim" "1TI" "1 Timothy"       6)
    (55 "2Tim" "2TI" "2 Timothy"       4)
    (56 "Titus" "TIT" "Titus"          3)
    (57 "Phlm" "PHM" "Philemon"        1)
    (58 "Heb"  "HEB" "Hebrews"        13)
    (59 "Jas"  "JAS" "James"           5)
    (60 "1Pet" "1PE" "1 Peter"         5)
    (61 "2Pet" "2PE" "2 Peter"         3)
    (62 "1John""1JN" "1 John"          5)
    (63 "2John""2JN" "2 John"          1)
    (64 "3John""3JN" "3 John"          1)
    (65 "Jude" "JUD" "Jude"            1)
    (66 "Rev"  "REV" "Revelation"     22)))

;;;; Internals

(defun bible-org--chapter-file-name (module book-num file-code chapter book-name)
  (format "%s%02d-%s%02d %s %d.org"
          module
          book-num
          file-code
          chapter
          book-name
          chapter))

(defun bible-org--write-chapter (book-num abbrev file-code book-name chapter)
  (let* ((default-directory bible-org-output-directory)
         (file (bible-org--chapter-file-name
                bible-org-module book-num file-code chapter book-name))
         (title (format "%s %d" abbrev chapter))
         (passage (format "%s %d" book-name chapter)))
    (with-temp-file file
      (org-mode)
      (setq buffer-file-name file)

      (org-id-get-create)
      (goto-char (point-max))

      (insert "#+title: " title "\n")
      (insert "#+date: " (format-time-string "[%Y-%m-%d]") "\n")
      (insert "#+hugo_lastmod: " (format-time-string "[%Y-%m-%d]") "\n")
      (insert "#+filetags: :bible:" (downcase bible-org-module) ":faith:\n")
      (insert "\n")

      (dolist (verse
               (sword-to-org--diatheke-parse-text
                (sword-to-org--diatheke-get-text
                 bible-org-module passage)))
        (insert (format "%d. %s\n"
                        (plist-get verse :verse)
                        (plist-get verse :text))))

      (set-buffer-modified-p nil))))

;;;###autoload
(defun bible-org-generate-all ()
  "Generate Bible Org files (one file per chapter) for the configured module."
  (interactive)
  (make-directory bible-org-output-directory t)
  (dolist (book bible-org-books)
    (cl-destructuring-bind (num abbrev file-code name chapters) book
      (dotimes (i chapters)
        (bible-org--write-chapter
         num abbrev file-code name (1+ i))))))

(provide 'bible-to-org-chapters)
