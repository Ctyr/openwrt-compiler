#openwrt one-key compiler shell script

**description:** This shell script automatically install openwrt compile environment,clone various branch source code,add feeds like shadowsocks,chinaDNS,rygel etc, and add compile support for **Huawei HG255D**.

**usage:** ./openwrt-compiler.sh

The program is interactive,when you are running,you will get:

	#please choose which branch you want to download:
	#branch                                  code  
	trunk (main development tree)             A     
	14.07 branch 'Barrier Breaker'            B         
	12.09 branch 'Attitude Adjustment'        C
	10.03 branch 'Backfire'                   D
	8.09 branch  'Kamikaze'                   E
	7.09 branch  'Kamikaze'                   F
	Tagged                                    G
	openwrt-pandorabox                        H
	#ps:this shell's function of feeds add&update&install&alter,customed settings,HG255D compile support only implement in trunk branchother branch not support yet.
	choose which one(input the code right side):


