(in-package :cl-user)
(defpackage quickdocs-parser-test
  (:use :cl :fiveam))
(in-package :quickdocs-parser-test)

;;; Utilities

(defmacro with-test-node ((node type name) &body body)
  `(let* ((,node (elt nodes current-node)))
     (is
      (typep ,node ',type))
     (is
      (equal (symbol-name (quickdocs-parser:node-name ,node))
             ,name))
     (is (equal (quickdocs-parser:node-docstring ,node)
                "docstring"))
     ,@body
     (incf current-node)))

;;; Tests

(def-suite tests
  :description "docparser tests.")
(in-suite tests)

(defvar *index* nil)

(test system-parsing
  (let ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system)))
    ;; Test the package
    (is
     (equal (length (quickdocs-parser::index-packages *index*))
            1))
    (let ((package-index (elt (quickdocs-parser::index-packages *index*) 0)))
      (is
       (equal (quickdocs-parser::package-index-name package-index)
              "QUICKDOCS-PARSER-TEST-SYSTEM")))))

(test variable-nodes
  (let* ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system))
         (nodes (quickdocs-parser::package-index-nodes
                 (elt (quickdocs-parser::index-packages *index*) 0)))
         (current-node 0))
    (with-test-node (node quickdocs-parser:variable-node "VAR")
      t)
    (with-test-node (node quickdocs-parser:variable-node "VAR2")
      t)
    (with-test-node (node quickdocs-parser:variable-node "CONST")
      t)))

(test operator-nodes
  (let* ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system))
         (nodes (quickdocs-parser::package-index-nodes
                 (elt (quickdocs-parser::index-packages *index*) 0)))
         (current-node 3))
    ;; The `func` function
    (with-test-node (node quickdocs-parser:function-node "FUNC")
      (is
       (equal (length (quickdocs-parser:operator-lambda-list node))
              5)))
    ;; The `mac` macro
    (with-test-node (node quickdocs-parser:macro-node "MAC")
      (is
       (equal (length (quickdocs-parser:operator-lambda-list node))
              3)))))

(test type-nodes
  (let* ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system))
         (nodes (quickdocs-parser::package-index-nodes
                 (elt (quickdocs-parser::index-packages *index*) 0)))
         (current-node 5))
    ;; The `rec1` struct
    (with-test-node (node quickdocs-parser:struct-node "REC1"))
                                        ; Skip some defstruct-generated stuff
    (incf current-node 9)
    ;; The `rec2` struct
    (with-test-node (node quickdocs-parser:struct-node "REC2"))
                                        ; Skip some defstruct-generated stuff
    (incf current-node 7)
    ;; The `custom-string` type
    (with-test-node (node quickdocs-parser:type-node "CUSTOM-STRING"))
    ;; The `test-class` class
    (with-test-node (node quickdocs-parser:class-node "TEST-CLASS")
      (is (equal (length (quickdocs-parser:record-slots node))
                 3))
      (let ((first-slot (first (quickdocs-parser:record-slots node))))
        (is
         (typep first-slot 'quickdocs-parser:class-slot-node))
        (is
         (equal (symbol-name (quickdocs-parser:node-name first-slot))
                "FIRST-SLOT"))
        (is
         (equal (quickdocs-parser:node-docstring first-slot)
                "docstring"))))))

(test method-nodes
  (let* ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system))
         (nodes (quickdocs-parser::package-index-nodes
                 (elt (quickdocs-parser::index-packages *index*) 0)))
         (current-node 25))
    ;; The `test-method` defgeneric
    (incf current-node)
    ;; The `test-method` method
    (incf current-node)
    ;; The `indirectly-define-function` macro
    (with-test-node (node quickdocs-parser:macro-node "INDIRECTLY-DEFINE-FUNCTION")
      (is
       (equal (length (quickdocs-parser:operator-lambda-list node))
              0)))
    ;; The `hidden-function` function
    (with-test-node (node quickdocs-parser:function-node "HIDDEN-FUNCTION")
      (is
       (equal (length (quickdocs-parser:operator-lambda-list node))
              0)))))

(test cffi-nodes
  (let* ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system))
         (nodes (quickdocs-parser::package-index-nodes
                 (elt (quickdocs-parser::index-packages *index*) 0)))
         (current-node 29))
    ;; The `printf` function
    (incf current-node 2)
    ;; The `size-t` CFFI type
    (with-test-node (node quickdocs-parser:cffi-type "SIZE-T"))
    ;; The `cstruct` struct
    (incf current-node 2)
    ;; The `cunion` union
    (incf current-node 1)
    ;; The `nums` CFFI enum
    (with-test-node (node quickdocs-parser:cffi-enum "NUMS")
      (is (equal (quickdocs-parser:cffi-enum-variants node)
                 (list :a :b :c))))
    ;; The `bits` CFFI bitfield
    (with-test-node (node quickdocs-parser:cffi-bitfield "BITS")
      (is (equal (quickdocs-parser:cffi-bitfield-masks node)
                 (list :a :b :c))))))

(test queries
  (let ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system)))
    (let ((result (quickdocs-parser:query *index* :symbol-name "VAR")))
      (is (equal (length result)
                 1))
      (is (equal (quickdocs-parser:node-docstring (elt result 0))
                 "docstring")))
    (let ((result (quickdocs-parser:query *index* :package-name "QUICKDOCS-PARSER-TEST-SYSTEM"
                                           :symbol-name "VAR")))
      (is (equal (length result)
                 1))
      (is (equal (quickdocs-parser:node-docstring (elt result 0))
                 "docstring")))))

(def-suite load-systems)
(in-suite load-systems)

(test load-all-systems
  (let* ((systems (list :alexandria
                        :cl-conspack
                        :cl-csv))
         (success-count 0)
         (system-count (length systems))
         (failures (list)))
    (loop for system in systems do
      (format t "~%Loading ~S~%" system)
      (finishes
        (let ((index (quickdocs-parser:parse system))
              (node-count 0))
          (quickdocs-parser:do-packages (package index)
            (quickdocs-parser:do-nodes (node package)
              (incf node-count)))
          (if (> node-count 0)
            (progn
              (incf success-count)
              (is-true t))
            (push system failures)))))
    (format t "~&Succeeded ~A/~A systems. Failed: ~A"
            success-count
            system-count
            failures)))

(test printing
  (let ((*index* (quickdocs-parser:parse :quickdocs-parser-test-system)))
    (quickdocs-parser:do-packages (package *index*)
      (quickdocs-parser:do-nodes (node package)
        (print node))
      (quickdocs-parser:dump *index*))))

(test utils
  (is-true (quickdocs-parser:symbol-external-p 'quickdocs-parser:render-humanize))
  (is (equal (quickdocs-parser:render-humanize 'quickdocs-parser:render-humanize)
             "render-humanize")))

(run! 'tests)
(run! 'load-systems)
