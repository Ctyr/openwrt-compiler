#!/bin/bash
#description:one-key install openwrt SDK environment.add some packages feeds include shadowsocks chinaDNS etc.
#2015-1-30  ver 1.0
#Tyr Chen @ http://www.chenhd.com
set -e
if [ "$UID" -eq "0" ];then
    echo "please do not run this shell as root.exit."
    exit 1
fi
read -p "please input the dir where you want to install:" opdir
if [ -d $opdir -a -w $opdir ];then
        echo "select $opdir"
else
        echo "$opdir not exists,try create"
        mkdir -p $opdir &&echo "create success" || echo "create failure"
fi
#install prerequisites and their corresponding packages
sudo apt-get update
sudo apt-get install gcc g++ binutils patch bzip2 flex bison make autoconf \
gettext texinfo unzip sharutils subversion libncurses5-dev ncurses-term \
zlib1g-dev git gawk libssl-dev -y
cd $opdir
go() #function of alter feeds,add packages,customed settings,add HG255D compile support etc.only implement to trunk.
{
#svn checkout svn://svn.openwrt.org/openwrt/trunk
#git clone git://git.openwrt.org/openwrt.git
#cd trunk
#cd openwrt
################# add feeds and packages ####################
# include rygel,shadowsocks,chinaDNS,shadownVPN,redsocks2,etc.
echo "
src-git luci2 git://git.openwrt.org/project/luci2/ui.git
src-git ramod git://github.com/ravageralpha/my_openwrt_mod.git
src-git ChinaDNS https://github.com/clowwindy/ChinaDNS.git " >> feeds.conf.default
sed -i '1i src-git rygel https://github.com/aandyl/openwrt-packages.git;rygel' feeds.conf.default
git clone https://github.com/aa65535/openwrt-dist-luci.git package/openwrt-dist-luci
git clone https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
################ update and install feeds ###################
./scripts/feeds update -a
./scripts/feeds install -a
###############  add Huawei HG255D support ##################
sed -i '/HG255D/s/#//g' target/linux/ramips/image/Makefile
#support HG255D LED
sed -i '/ramips_board_name/a \
        hg255d)\
                status_led="hg255d:power" \
                ;;' target/linux/ramips/base-files/etc/diag.sh
############## customed setting #############################
#wifi-encryption & password
sed -i -e 's/none/psk2/' -e '/encryption/a    option key 11223344'  package/kernel/mac80211/files/lib/wifi/mac80211.sh
#language & themes
sed -i 's/auto/zh_cn/;s/openwrt.org/bootstrap/' feeds/luci/modules/luci-base/root/etc/config/luci
sed -i '/internal languages/a  \
    option zh_cn chinese \
    option en English ' feeds/luci/modules/luci-base/root/etc/config/luci
sed -i '/internal themes/a  \
    option Bootstrap /luci-static/bootstrap' feeds/luci/modules/luci-base/root/etc/config/luci
#alter net.netfilter.nf_conntrack_max from 16384 to 65535
sed -i 's/16384/65535/' package/base-files/files/etc/sysctl.conf
#timezone
sed -i -e '/UTC/a option zonename Asia/Shanghai' -e 's/UTC/CST-8/' package/base-files/files/etc/config/system
read -p "add HG255D led configuration to package/base-files/files/etc/config/system ?
if yes, answer yes,otherwise leave blank:" ANS
if [ $ANS = 'yes' ];then
echo "
config led 'usb_led'
    option name 'USB'
    option sysfs 'hg255d:usb'
    option trigger 'usbdev'
    option dev '1-1'
    option interval '50'
config led 'wlan_led'
    option name 'WLAN'
    option sysfs 'hg255d:wlan'
    option trigger 'netdev'
    option dev 'ra0'
    option mode 'link tx'
config led 'internet_led'
    option name 'INTERNET'
    option sysfs 'hg255d:internet'
    option trigger 'netdev'
    option dev 'eth0.2'
    option mode 'tx rx'
" >> package/base-files/files/etc/config/system
fi
echo "done.Bye"
exit 0
}
read -p "please choose which branch you want to download:
branch                                  code  
trunk (main development tree)             A     
14.07 branch 'Barrier Breaker'            B         
12.09 branch 'Attitude Adjustment'        C
10.03 branch 'Backfire'                   D
8.09 branch  'Kamikaze'                   E
7.09 branch  'Kamikaze'                   F
Tagged                                    G
openwrt-pandorabox                        H
ps:this shell's function of feeds add&update&install&alter,customed settings,
HG255D support only implement in trunk branchother branch not support yet.
choose which one(input the code right side):"  CODE
case $CODE in
    "A")
            echo "start clone ..."
            svn co svn://svn.openwrt.org/openwrt/trunk/
            cd trunk
            go
            ;;
    "B")
            echo "start clone ..."
            svn co svn://svn.openwrt.org/openwrt/branches/barrier_breaker
            ;;
    "C")
            echo "start clone ..."
            svn co svn://svn.openwrt.org/openwrt/branches/attitude_adjustment
            ;;
    "D")
            echo "start clone ..."
            svn co svn://svn.openwrt.org/openwrt/branches/backfire
            ;;
    "E")
            echo "start clone ..."
            svn co svn://svn.openwrt.org/openwrt/branches/8.09
            ;;
    "F")
            echo "start clone ..."
            svn co svn://svn.openwrt.org/openwrt/tags/kamikaze_7.09
            ;;
    "G")
            echo "start clone ..."
            svn co svn://svn.openwrt.org/openwrt/tags/backfire_10.03
            ;;
    "H")
            echo "start clone ..."
            svn co svn://svn.openwrt.org.cn/dreambox/trunk openwrt-pandorabox
            ;;
    *)
            echo "start clone ..."
            echo "error code"
            exit 2
    esac
echo "download ok.Bye"
exit 0
