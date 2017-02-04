;;;; 获取在线 shadowsocks 账号并自动连接


;;;
;;; version
;;;

;; 优化 更好地 readme <2017-02-04 Sat 22:38:16>

;; 优化 Some Info Dont't Print <2017-02-04 Sat 22:30:26>
;; format

;; 修复 slime character decode error <2017-02-04 Sat 22:24:29>
;; http://stackoverflow.com/questions/10866478/how-do-i-get-quicklisp-to-load-rfc2388-in-slime
;; 解决方法：新增 Emacs 全局 UTF-8 编码 <2017-02-04 Sat 22:20:09>
;; (setenv "LANG" "en_US.UTF-8")

;; 修复 中文在纯英文系统下不兼容的问题 <2017-02-03 Fri 16:21:16>

;; <2017-01-27 Fri 22:45:48>
;; Restart: Use start, not run

;; <2017-01-15 Sun 13:47:20>
;; Make code more independent

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

;; DONE：Character decoding error in a ;-comment at position 1079 reading source stream #<FORM-TRACKING-STREAM for "file /root/iss/iss.lisp" {B90A661}>, resyncing.
;; 无法访问网址
;; DONE：Restart bug: when start after stop.先停止后启动，不能正常退出 Lisp 环境.
;; DONE：Some Info Dont't Print
;; Manage help info
;; DONE: Make it auto run when compute boots
;; Simplify the way of writing to a file
;; DONE: Make help info more understardable
;; DONE: Make code more independent


;;;
;;; Auto Login Shadowsocks 自动登录 SS
;;;


;;; iss: get account and write to a file

;; get account

(ql:quickload :drakma)
(defvar *iss*
  (drakma:http-request "http://www.ishadowsocks.com/"))
;; (drakma:http-request "http://iss.pm/")
;; 有时网址无法访问。

;; write to a file

(ql:quickload :cl-ppcre)
(defun get-ss-json ()
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
               "<div class=\"col-sm-4 text-center\">.*\\s.*"
               *iss*))))
      (setf port
            (cl-ppcre:scan-to-strings
             "[^:].*[^<]"
             (cl-ppcre:scan-to-strings
              ":.*<"
              (cl-ppcre:scan-to-strings "<h4>.*\\s<h4>.*"
                                        *iss*))))
      (setf password
            (cl-ppcre:scan-to-strings
             "[^:].*[^<]"
             (cl-ppcre:scan-to-strings
              ":.*<"
              (cl-ppcre:scan-to-strings
               "\\s<h4>.*<"
               (cl-ppcre:scan-to-strings "<h4>.*\\s<h4>.*"
                                         *iss*)))))
      (format out "{
\"server\":\"~A\",
\"server_port\":~A,
\"local_port\":1080,
\"password\":\"~A\",
\"timeout\":300,
\"method\":\"aes-256-cfb\"
}" server port password)
      (format t "
==== Shadowsocks Configure Info ====

{
\"server\":\"~A\",
\"server_port\":~A,
\"local_port\":1080,
\"password\":\"~A\",
\"timeout\":300,
\"method\":\"aes-256-cfb\"
}
" server port password))))


;;; start shadowsocks

;; get shadowsocks's pid

(ql:quickload :external-program)
(defun get-program-pid (program-name)
  (cl-ppcre:scan-to-strings
   "\\d*"
   (with-output-to-string (out)
     (external-program:run "pgrep"
                           `("-l" ,program-name)
                           :output out))))
;; (get-program-pid "sslocal")

(defun shadowsocks-running-info ()
  (format nil "
==== Shadowsocks Running Info ====

Shadowsocks's PID: ~A.
On Terminal: kill -9 ~A.
On SBCL: (stop-ss)
" (get-program-pid "sslocal") (get-program-pid "sslocal")))

;; sslocal -c ./ss.json

(ql:quickload :external-program)
(defun start-ss ()
  (if (> (length (get-program-pid "sslocal"))
         0)
      "Shadowsocks is already Started."
      (with-open-file (out "./log.txt"
                           :direction :output
                           :if-does-not-exist :create
                           :if-exists :append)
        ;; Can't exit SBCL: <2017-01-15 Sun 15:53:30>
        ;; 将 run 修改为 start 能正常的退出 SBCL：<2017-01-27 Fri 12:09:23>
        (external-program:start "sslocal"
                                ;; directore should be absolute
                                '("-c" "./ss.json" "-v")
                                :output out)
        "Shadowsocks is Started.")))
;; (start-ss)


;;; stop shadowsocks

;; kill shadowsocks's pd

(defun stop-ss ()
  (if (> (length (get-program-pid "sslocal"))
         0)
      (progn
        (external-program:run "kill"
                              `("-9" ,(get-program-pid "sslocal")))
        "Shadowsocks is Stoped.")
      "Shadowsocks is not Started."))
;; (stop-ss)


;;; restart shadowsocks

;; stop then start


(defun restart-ss ()
  (stop-ss)
  (start-ss)
  (format t "~A"
          (shadowsocks-running-info)))
;; (restart-ss)


;;; help info

;; auto save help info to readme.org

(defvar *help-info*
  "* Help Info 使用说明

** Install Shadowsocks 安装
#+BEGIN_SRC shell
cd /tmp
rm iss.sh
wget https://raw.githubusercontent.com/sgs-site/iss/master/iss.sh
sh iss.sh
#+END_SRC
Or
#+BEGIN_SRC shell
sudo apt-get install shadowsocks

cd /tmp/

git clone https://github.com/sgs-site/iss.git

cp -r /tmp/iss/ ~/iss/

cd ~/iss/

/usr/bin/sbcl --load iss.lisp
#+END_SRC
** Start Shadowsocks 启动

On SLIME: M-x load-file [this Lisp file]

On SBCL: (load [this Lisp file])

On Terminal: sbcl --load [this Lisp file]

** Configure and Log File of Shadowsocks 配置与日志

Shadowsocks Configure: ./ss.json

Shadowsocks Log: ./log.txt

** Stop Shadowsocks 关闭

*** On Terminal

1. pgrep -l sslocal

2. kill -9 [pid]

*** On SBCL

(stop-ss)

** Restart Shadowsocks 重启

(restart-ss)

** Show Time of Load this Program 查看耗时

Time of this program: (time-of-this-program)

** Attention 注意事项

1. Shadowsocks Configure and Log file is auto generated. 配置与日志自动生成。

2. Lisp will auto exit after load this file. Lisp 环境会自动退出。

3. Readme is auto generated.

")

;; save readme

(defun save-readme ()
  (with-open-file (out "./readme.org"
                       :direction :output
                       :if-does-not-exist :create
                       :if-exists :supersede)
    (format out "~A" *help-info*)
    (format nil "~A" *help-info*)))


;;; Time of this program

;; (time (load "iss-get-account-login-获取网页里的账户并自动连接.lisp"))

;; (defun time-of-this-program ()
;;   (time (load "iss-get-account-login-获取网页里的账户并自动连接.lisp")))


;;; exit Lisp

;; (sb-ext:exit)

(defun exit-lisp ()
  (sb-ext:exit))


;;; auto load Lisp file when Lisp boots

;; create a sh file: /usr/bin/sbcl --load /home/sgs/Common-Lisp/iss-auto/iss.lisp
;; sudo copy sh file to /etc/profile.d/


;;; Configure Lisp Program

;; Start Shadowsocks, then Exit Lisp

(get-ss-json)
(restart-ss)
(save-readme)
;; (format t "~A" *help-info*)

(exit-lisp)
