;;;
;;; version
;;;

;; <2017-01-15 Sun 10:34:11>
;; Auto load sh file when Linux boots

;; <2017-01-15 Sun 10:14:36>
;; Rename directory: iss-auto

;; <2017-01-15 Sun 10:11:41>
;; Rename file: iss.lisp

;; <2017-01-15 Sun 10:09:11>
;; On Terminal: auto exit Lisp

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
(rename-package :cl-ppcre :cp)
(with-open-file (out "./ss.json"
                     :direction :output
                     :if-does-not-exist :create
                     :if-exists :supersede)
  (let ((server nil)
        (port nil)
        (password nil))
    (setf server
          (cp:scan-to-strings
           "[^:].*[^<]"
           (cp:scan-to-strings
            ":.*<"
            (cp:scan-to-strings "<div class=\"col-sm-4 text-center\">.*\\s.*"
                                *iss*))))
    (setf port
          (cp:scan-to-strings
           "[^:].*[^<]"
           (cp:scan-to-strings ":.*<"
                               (cp:scan-to-strings "<h4>.*\\s<h4>.*"
                                                   *iss*))))
    (setf password
          (cp:scan-to-strings
           "[^:].*[^<]"
           (cp:scan-to-strings
            ":.*<"
            (cp:scan-to-strings "\\s<h4>.*<"
                                (cp:scan-to-strings "<h4>.*\\s<h4>.*"
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
}
" server port password)))


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

* Help Info 使用说明

** Start Shadowsocks 启动

On SLIME: M-x load-file [this Lisp file]

On SBCL: (load [this Lisp file])

On Terminal: sbcl --load [this Lisp file]

** Configure and Log File of Shadowsocks 配置与日志

Shadowsocks Configure: ./ss.json

Shadowsocks Log: ./log.txt

** Stop Shadowsocks (On Terminal) 关闭

1. netstat -lnp|grep 1080

2. kill -9 [port]

** Show Time of Load this Program 查看耗时

Time of this program: (time-of-this-program)

** Attention 注意事项

1. Shadowsocks Configure and Log file is auto generated. 配置与日志自动生成。

2. Lisp will auto exit after load this file. Lisp 环境会自动退出。

")


;;; Time of this program

;; (time (load "iss-get-account-login-获取网页里的账户并自动连接.lisp"))

(defun time-of-this-program ()
  (time (load "iss-get-account-login-获取网页里的账户并自动连接.lisp")))


;;; exit Lisp

;; (sb-ext:exit)

(sb-ext:exit)


;;; auto load Lisp file when Lisp boots

;; create a sh file: /usr/bin/sbcl --load /home/sgs/Common-Lisp/iss-auto/iss.lisp
;; sudo copy sh file to /etc/profile.d/
