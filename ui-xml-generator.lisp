(in-package #:ui-xml-generator)

(defun xml-intro (&key (version "1.0") (encoding "UTF-8"))
  (format nil "<?xml version=~S encoding=~S?>" version encoding))

(defparameter *indent-by* 2)

(defun add-indentation (indent string)
  (let ((indented (make-string (* indent *indent-by*) :initial-element #\Space)))
    (format nil "~A~A" indented string)))

(defun attributes-string (tag attrs)
  (reduce
   (lambda (acc pair)
     (concatenate 'string
                  acc
                  " "
                  (format nil "~A=~S"
                          (string-downcase (format nil "~A" (car pair)))
                          (cdr pair))))
   (serapeum/bundle:plist-alist attrs)
   :initial-value (format nil "~A" tag)))

(defun read-tags (tree &optional (indent 0))
  "Read tags from the TREE and produce xml string"
  (destructuring-bind (tag attrs next &rest cx) tree
    (assert (typep tag 'keyword))
    (assert (or (typep attrs 'null)
                (typep attrs 'cons)))
    (assert (not (eq (first attrs)
                     'quote))
            ()
            "attrs ~s should not be quoted" attrs)
    (assert (evenp (length attrs)))

    (ecase next
      (:content
       (assert (eq 1 (length cx)))
       (assert (or (eq (first cx)
                       :none)
                   (typep (first cx)
                          'string)))
       (format nil "~A"
               (add-indentation indent
                                (if (eq (first cx) :none)
                                    (format nil "<~A/>"
                                            (attributes-string
                                             (string-downcase tag)
                                             attrs))
                                    (format nil "<~A>~A</~A>"
                                            (attributes-string
                                             (string-downcase tag)
                                             attrs)
                                            (html-entities:encode-entities (first cx))
                                            (string-downcase tag))))))
      (:children
       (assert (typep (first cx)
                      'cons))
       (format nil "~&~A~&~A~&~A"
               (add-indentation indent
                                (format nil "<~A>"
                                        (attributes-string
                                         (string-downcase tag)
                                         attrs)))
               (serapeum:string-join
                (loop for c in cx
                      collect (read-tags c (1+ indent)))
                (string #\Newline))

               (format nil "~A"
                       (add-indentation indent
                                        (format nil "</~A>" (string-downcase tag)))))))))

(defun xml-string (tree)
  (serapeum:string-join (list (xml-intro)
                              (read-tags tree))
                        (string #\Newline)))
