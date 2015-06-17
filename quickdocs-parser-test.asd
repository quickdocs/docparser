(defsystem quickdocs-parser-test
  :author "Fernando Borretti <eudoxiahp@gmail.com>"
  :license "MIT"
  :depends-on (:quickdocs-parser
               :fiveam)
  :components ((:module "t"
                :serial t
                :components
                ((:file "docparser")))))
