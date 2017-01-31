cd /tmp/iss/
cp -r /tmp/iss/ ~/iss/
cd ~/iss/
/usr/bin/sbcl --load iss.lisp
# auto load Lisp file when Linux boots
# copy this file to /etc/profile.d/
# or copy this to /etc/rc.local
