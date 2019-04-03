(defsystem quickdocs-parser
  :author "Fernando Borretti <eudoxiahp@gmail.com>, Eitaro Fukamachi <e.arrows@gmail.com>"
  :maintainer "Eitaro Fukamachi <e.arrows@gmail.com>"
  :license "MIT"
  :version "0.1"
  :homepage ""
  :bug-tracker ""
  :source-control (:git "")
  :depends-on (:optima :trivia)
  :components ((:module "src"
                :serial t
                :components
                ((:file "package")
                 (:file "nodes")
                 (:file "core")
                 (:file "parsers")
                 (:file "print"))))
  :description "Parse documentation from Common Lisp systems."
  :long-description
  #.(uiop:read-file-string
     (uiop:subpathname *load-pathname* "README.md"))
  :in-order-to ((test-op (test-op quickdocs-parser-test))))
