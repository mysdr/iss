sudo apt-get install shadowsocks sbcl
cd /tmp/
git clone https://github.com/sgs-site/iss.git
rm -r ~/iss
mkdir ~/iss
cp -r /tmp/iss/* ~/iss
cd ~/iss
/usr/bin/sbcl --load iss.lisp

# auto load Lisp file when Linux boots
# copy this file to /etc/profile.d/
# or copy this to /etc/rc.local
