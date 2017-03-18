;;;
;;; 项目描述
;;;


;; http://www.ishadowsocks.org/
;; <2017-03-18 Sat 17:53:56>
;; 能自动获取相关数据
;; 旧网站方案在iss-old.lisp中


;;;
;;; 获取相关数据
;;;

(ql:quickload '(sundawn.html-selector))
(use-package :sundawn.html-selector)

(defun page-tables (&optional (uri "http://www.ishadowsocks.org/"))
  "获取未处理的html字符串"
  (rest
   (same-selector
    (unique-selector
     (drakma:http-request :user-agent :firefox)
     "<div class=\"portfolio-items\">"
     "<div class=\"row text-center center\">")
    ;; 居然按地区分开
    "<div class=\"col-sm-6 col-md-4 col-lg-4"
    "<div class=\"col-sm-6 col-md-4 col-lg-4")))

(defun ippm ()
  "ippm: ip address, port, password, method"
  (mapcar
   #'(lambda (i)
       (list
        ;; IP Address
        (unique-selector (unique-selector i "<h4>" "</span>") ">" "\"")
        ;; 这里应该是编码的问题，留意
        ;; Port
        (unique-selector i "<h4>Portï¼" "</h4>")
        ;; Password
        (unique-selector (unique-selector i "<h4>Password" "</span>")
                         ">" "\"")
        ;; Method
        (unique-selector i "<h4>Method:" "</h4>")))
   (page-tables)))

(defun test ()
  (unique-selector (unique-selector (first (page-tables))
                                    "<h4>Method:" "</h4>")
                   ">" "\""))

;; ;; >>> Note
;; (ippm)
;; ;; =>
;; (("a.usip.pro" "443" "01082172" "aes-256-cfb")
;;  ("b.usip.pro" "8388" "98267266" "rc4-md5")
;;  ("c.usip.pro" "23456" "21669613" "chacha20")
;;  ("a.jpip.pro" "443" "39531342" "aes-256-cfb")
;;  ("b.jpip.pro" "8388" "07254546" "rc4-md5")
;;  ("c.jpip.pro" "23456" "61524873" "chacha20")
;;  ("a.sgip.pro" "443" "08295878" "aes-256-cfb")
;;  ("b.sgip.pro" "8388" "70611114" "rc4-md5")
;;  ("c.sgip.pro" "23456" "39484182" "chacha20")
;;  ("c.usip.pro" "23456" "21669613" "chacha20")
;;  ("b.jpip.pro" "8388" "07254546" "rc4-md5")
;;  ("a.sgip.pro" "443" "08295878" "aes-256-cfb"))
;; ;; <<< Note

(defun remove-nil ()
  (remove "" (ippm) :key #'third :test #'string=))

(defun nil-string? (lst)
  "查找纯字符串的列表中是否有空字符串"
  (stringp (find "" lst :test #'string=)))

(defun ippm->json (&optional (ippm (first (remove-nil))))
  (with-open-file (out "ss.json"
                       :direction :output
                       :if-does-not-exist :create
                       :if-exists :supersede)
    (format out "{
\"server\":\"~A\",
\"server_port\":~A,
\"local_port\":1080,
\"password\":\"~A\",
\"timeout\":300,
\"method\":\"~A\"
}" (first ippm) (second ippm) (third ippm) (fourth ippm))
    (format t "
==== Shadowsocks Configure Info ====

{
\"server\":\"~A\",
\"server_port\":~A,
\"local_port\":1080,
\"password\":\"~A\",
\"timeout\":300,
\"method\":\"~A\"
}" (first ippm) (second ippm) (third ippm) (fourth ippm))))


;;;
;;; 管理shadowsocks
;;;


;;; start shadowsocks

(ql:quickload :external-program)

(defun get-program-pid (program-name)
  ;; get shadowsocks's pid
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

(defun start-ss ()
  ;; sslocal -c ./ss.json
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


;;; stop shadowsocks

(defun stop-ss ()
  ;; kill shadowsocks's pd
  (if (> (length (get-program-pid "sslocal"))
         0)
      (progn
        (external-program:run "kill"
                              `("-9" ,(get-program-pid "sslocal")))
        "Shadowsocks is Stoped.")
      "Shadowsocks is not Started."))


;;; restart shadowsocks

(defun restart-ss ()
  ;; stop then start
  (stop-ss)
  (start-ss)
  (format t "~A"
          (shadowsocks-running-info)))
;; (restart-ss)


;;; 启动程序及退出程序

(ippm->json)
(restart-ss)
;; (sb-ext:exit)
