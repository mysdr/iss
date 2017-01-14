;;;
;;; version
;;;

;; <2017-01-14 Sat 21:25:35>
;; log.txt: send sslocal lot to a file
;; <2017-01-14 Sat 20:37:05>
;; sslocal: auto run sslocal
;; <2017-01-14 Sat 19:57:23>
;; iss: get account and write to a file


;;;
;;; todo
;;;

;; Make it auto run when compute boots
;; Simplify the way of writing to a file
;; Make help info more understardable
;; Make code more independent


;;; iss: get account and write to a file

;; get account

(ql:quickload :drakma)
(defvar *iss*
  (drakma:http-request "http://www.ishadowsocks.me/"))

;; write to a file

(ql:quickload :cl-ppcre)
(with-open-file (out "./ss.json"
                     :direction :output
                     :if-does-not-exist :create
                     :if-exists :supersede)
  (let ((server nil)
        (port nil)
        (password nil))
    (setf server
          (cl-ppcre:scan-to-strings
           "[^:].*[^<]"
           (cl-ppcre:scan-to-strings
            ":.*<"
            (cl-ppcre:scan-to-strings
             "<div class=\"col-sm-4 text-center\">.*
.*"
             *iss*))))
    (setf port
          (cl-ppcre:scan-to-strings
           "[^:].*[^<]"
           (cl-ppcre:scan-to-strings
            ":.*<"
            (cl-ppcre:scan-to-strings "<h4>.*
<h4>.*"
                                      *iss*))))
    (setf password
          (cl-ppcre:scan-to-strings
           "[^:].*[^<]"
           (cl-ppcre:scan-to-strings
            ":.*<"
            (cl-ppcre:scan-to-strings
             "
<h4>.*<"
             (cl-ppcre:scan-to-strings "<h4>.*
<h4>.*"
                                       *iss*)))))
    (format out "{
\"server\":\"~A\",
\"server_port\":~A,
\"local_port\":1080,
\"password\":\"~A\",
\"timeout\":300,
\"method\":\"aes-256-cfb\"
}" server port password)
    (format t "{
\"server\":\"~A\",
\"server_port\":~A,
\"local_port\":1080,
\"password\":\"~A\",
\"timeout\":300,
\"method\":\"aes-256-cfb\"
}" server port password)))


;;; start shadowsocks

;; sslocal -c ./ss.json

(ql:quickload :external-program)
(with-open-file (out "./log.txt"
                     :direction :output
                     :if-does-not-exist :create
                     :if-exists :append)
  (external-program:run "sslocal"
                        ;; directore should be absolute
                        '("-c" "./ss.json" "-v")
                        :output out))


;;; help info

;; load this file

(format t "

==== Help Info ====

On SLIME: C-c C-l [this Lisp file]

Shadowsocks Configure: ./ss.json

Stop Shadowsocks (On Terminal):

1. netstat -lnp|grep 1080
2. kill -9 [port]
")
