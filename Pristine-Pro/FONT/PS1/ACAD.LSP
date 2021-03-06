
;   AutoLisp utilities to test translated PostScript fonts

(setq fontdir "shapes/")              ; Directory containing .shp and .shx files

(defun testfont (where stylename / c1 c2 c3 c4 c5 c6 c7 i f s)
    (setq c1 "" c2 "" c3 "" c4 "" c5 "" c6 "" c7"")
    (setq i 32)
    (while (< i 64)
        (setq c1 (strcat c1 (chr i))
              c2 (strcat c2 (chr (+ i 32)))
              c3 (strcat c3 (chr (+ i 64)))
              c4 (strcat c4 (chr (+ i 96)))
              c5 (strcat c5 (chr (+ i 128)))
              c6 (strcat c6 (chr (+ i 160)))
              c7 (strcat c7 (chr (+ i 192))))
        (setq i (1+ i))
    )

    (if (setq f (open (findfile (strcat
        (cdr (assoc 3 (tblsearch "style" stylename))) ".shp")) "r"))
        (progn
            (setq s (read-line f))
            (close f)
        )
        (setq s "")
    )
    (command "text" "Style" "Standard" where "" ""
        (strcat stylename " (" (substr s 6) ")"))
    (command "text" "Style" stylename (list (car where) (- (cadr where) 0.35))
         "" "" c1)
    (command "text" "" c2)
    (command "text" "" c3)
    (command "text" "" c4)
    (command "text" "" c5)
    (command "text" "" c6)
    (command "text" "" c7)
)

;   TESTFONTS  --  Test all fonts defined as styles in drawing

(defun C:testfonts ()
    (setvar "CMDECHO" 0)
    (setvar "HIGHLIGHT" 0)
    (setq first t)
    (setq p '(1 2))
    (while (setq s (tblnext "style" first))
        (print (setq style (cdr (assoc 2 s))))
        (testfont p style)
        (if (>= (car p) 29)
            (setq p (list 1 (- (cadr p) 4)))
            (setq p (list (+ (car p) 8) (cadr p)))
        )
        (setq first nil)
    )
    (setvar "CMDECHO" 1)
    (setvar "HIGHLIGHT" 1)
)

;   TRYFONT  --  Test a single font, automatically defining a new
;                style to load it.

(defun C:tryfont ()
    (setq a (getstring "\nFont name: "))
    (setvar "CMDECHO" 0)
    (setvar "HIGHLIGHT" 0)
    (command "style" a (strcat fontdir a) "" "" "" "n" "n" "n")
    (testfont '(2 4) a)
    (command "text" "style" "standard")
    (command)
    (setvar "HIGHLIGHT" 1)
    (setvar "CMDECHO" 1)
)

;   LISTFONT  --  List the characters in a font by code

(defun C:listfont ()
    (setq a (getstring "\nFont name: "))
    (setvar "CMDECHO" 0)
    (setvar "HIGHLIGHT" 0)
    (command "text" '(7.5 8.5) "" "" a)
    (command "style" a (strcat fontdir a) "" "" "" "n" "n" "n")
    (setq i 32 p 8)
    (while (< i 64)
        (command "text" "style" "standard" (list 2 p) "" "" (strcat (itoa i) " " (chr i)))
        (command "text" "style" a (list 3 p) "" "" (chr i))
        (command "text" "style" "standard" (list 4 p) "" "" (strcat (itoa (+ i 32)) " " (chr (+ i 32))))
        (command "text" "style" a (list 5 p) "" "" (chr (+ i 32)))
        (command "text" "style" "standard" (list 6 p) "" "" (strcat (itoa (+ i 64)) " " (chr (+ i 64))))
        (command "text" "style" a (list 7 p) "" "" (chr (+ i 64)))
        (command "text" "style" "standard" (list 8 p) "" "" (strcat (itoa (+ i 96)) " " (chr (+ i 96))))
        (command "text" "style" a (list 9 p) "" "" (chr (+ i 96)))
        (command "text" "style" "standard" (list 10 p) "" "" (strcat (itoa (+ i 128))))
        (command "text" "style" a (list 11 p) "" "" (chr (+ i 128)))
        (command "text" "style" "standard" (list 12 p) "" "" (strcat (itoa (+ i 160))))
        (command "text" "style" a (list 13 p) "" "" (chr (+ i 160)))
        (command "text" "style" "standard" (list 14 p) "" "" (strcat (itoa (+ i 192))))
        (command "text" "style" a (list 15 p) "" "" (chr (+ i 192)))
        (setq i (1+ i))
        (setq p (- p 0.4))
    )
    (command "text" "style" "standard")
    (command)
    (setvar "HIGHLIGHT" 1)
    (setvar "CMDECHO" 1)
)

;   FONTSPEC  --  Produce specimen output from all fonts

(defun C:fontspec ()
    (setvar "CMDECHO" 0)
    (setvar "HIGHLIGHT" 0)
    (setq first t)
    (setq p 9)
    (while (setq s (tblnext "style" first))
        (if (setq f (open (findfile (strcat
            (cdr (assoc 3 s)) ".shp")) "r"))
            (progn
                (setq n (read-line f))
                (close f)
            )
            (setq n "")
        )
        (print (setq style (cdr (assoc 2 s))))
        (command "text" "style" "standard" (list 0.5 p) "" "" style)
        (command "text" (list 2.5 p) "" "" (substr n 6))
        (command "text" "style" style (list 10 p) "" "" "ABCZYZabcxyz123456789+-?!*&#")
        (setq p (- p 0.35))
        (setq first nil)
    )
    (setvar "CMDECHO" 1)
    (setvar "HIGHLIGHT" 1)
)
