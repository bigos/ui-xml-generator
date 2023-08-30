(asdf:defsystem #:ui-xml-generator
  :description "A system for generation of XML string used by Gtk 4 interfaces"
  :author "Jacek Podkanski"
  :license "MIT License"
  :version "0.0.1"
  :depends-on (:serapeum
               :html-entities)
  :serial T
  :components ((:file "package")
               (:file "ui-xml-generator")))
