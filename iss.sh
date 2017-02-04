# 优化 强制删除文件 <2017-02-04 六 09:54:44>
# 新增 crontab 定时更新 <2017-02-04 六 09:50:59>
# 新增 删除文件 <2017-02-03 Fri 16:32:22>
# 新增 删除相关文件夹 <2017-02-03 Fri 16:30:13>
sudo apt-get install shadowsocks sbcl
cd /tmp/
rm iss.sh
rm -rf /tmp/iss
git clone https://github.com/sgs-site/iss.git
rm -rf ~/iss
mkdir ~/iss
cp -rf /tmp/iss/* ~/iss
cd ~/iss
/usr/bin/sbcl --load iss.lisp

# auto load Lisp file when Linux boots
# copy this file to /etc/profile.d/
# or copy this to /etc/rc.local

crontab ~/iss/iss-crontab
