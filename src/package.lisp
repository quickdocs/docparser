(in-package :cl-user)
(defpackage quickdocs-parser
  (:use :cl)
  ;; Classes
  (:export :name-node
           :documentation-node
           :operator-node
           :function-node
           :macro-node
           :generic-function-node
           :method-node
           :variable-node
           :struct-slot-node
           :class-slot-node
           :record-node
           :struct-node
           :class-node
           :condition-node
           :type-node
           :optima-pattern-node
           :trivia-pattern-node)
  ;; CFFI classes
  (:export :cffi-node
           :cffi-function
           :cffi-type
           :cffi-slot
           :cffi-struct
           :cffi-union
           :cffi-enum
           :cffi-bitfield)
  ;; Accessors
  (:export ;; names and docstrings
           :node-form
           :node-name
           :node-docstring
           ;; Operators
           :operator-lambda-list
           :operator-setf-p
           ;; Slots
           :slot-accessors
           :slot-readers
           :slot-writers
           :slot-type
           :slot-allocation
           ;; Records and classes
           :record-slots
           :class-node-superclasses)
  ;; CFFI accessors
  (:export :cffi-function-return-type
           :cffi-type-base-type
           :cffi-slot-type
           :cffi-struct-slots
           :cffi-union-variants
           :cffi-enum-variants
           :cffi-bitfield-masks)
  ;; Methods
  (:export :symbol-external-p
           :symbol-package-name
           :render-full-symbol
           :render-humanize)
  ;; Parsers
  (:export :define-parser
           :define-cffi-parser)
  ;; Indices
  (:export :package-index
           :index
           :package-index-name
           :package-index-docstring)
  ;; Interface
  (:export :parse
           :do-packages
           :do-nodes
           :query
           :dump
           :*store-form*)
  (:documentation "Parse documentation from ASDF systems."))
