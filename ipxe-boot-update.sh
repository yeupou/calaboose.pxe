#!/bin/bash
#
# Copyright (c) 2012 Mathieu Roy <yeupou--gnu.org>
#           http://yeupou.wordpress.com
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
#   USA

# cd in the directory where this script resides, even if called from a symlink
# in /etc/cron.whatever/
ZERO=$0
if [ -L $0 ]; then ZERO=`readlink $0`; fi
cd `dirname $ZERO`


# basic warning check: does undionly.kpxe exists? 
IPXE_CHAINLOADER=undionly.kpxe
if [ ! -e $IPXE_CHAINLOADER ]; then
    echo "Did you notice that $IPXE_CHAINLOADER was not there?"
    read
    wget http://boot.ipxe.org/$IPXE_CHAINLOADER
fi

# assume each subdirectory in here may contain relevant images
# if an update script exists, run it
for subdir in *; do
    if [ -L $subdir ]; then continue; fi
    if [ -x $subdir/ipxe-boot-update.sh ]; then
	$subdir/ipxe-boot-update.sh
    fi	
done

# now start updating the real boot file, after any other update script
# ended (to avoid having for too long an incomplete main boot file)
echo "#!ipxe" > ipxe-boot
echo "cpuid --ext 29 && set arch x86_64 || set arch i386" >> ipxe-boot

echo "######### CHOICES" >> ipxe-boot
echo ":mainmenu" >> ipxe-boot
echo "menu \${net0/domain} PXE - \${arch} CPU detected" >> ipxe-boot
for subdir in *; do
    if [ -L $subdir ]; then continue; fi
    # if there is a config file for this subdir, strip the menu part of it
    # (any line with item)
    if [ -r $subdir/ipxe-boot ]; then 
	echo "item --gap -- --- $subdir ---" >> ipxe-boot
	grep -E '^item ' $subdir/ipxe-boot >> ipxe-boot
    fi
done

echo "item --gap -- --- Generic options ---" >> ipxe-boot
if [ -e GNULinux/rescue-i386-linux ]; then echo "item --key r rescue Boot rescue i386" >> ipxe-boot; fi
if [ -e GNULinux/rescue-amd64-linux ]; then echo "item --key t rescue-amd64 Boot rescue amd64" >> ipxe-boot; fi
echo "item --key c config Configure iPXE settings" >> ipxe-boot
echo "item --key s shell Drop to iPXE shell" >> ipxe-boot
echo "item --key x exit Exit and continue BIOS boot" >> ipxe-boot

echo "choose target && goto \${target} || goto mainmenu" >> ipxe-boot
echo "shell" >> ipxe-boot


echo "######### BOOTING" >> ipxe-boot
for subdir in *; do
    if [ -L $subdir ]; then continue; fi
    # if there is a config file for this subdir, 
    # add the labels it contains
    if [ -r $subdir/ipxe-boot ]; then
        grep -vE '^item |^menu |^#|^choose ' $subdir/ipxe-boot >> ipxe-boot
    fi
done
echo ":rescue" >> ipxe-boot
echo "# fallback with tftpd" >> ipxe-boot
echo "kernel GNULinux/rescue-i386-linux vga=normal irqpoll rescue/enable=true" >> ipxe-boot
echo "initrd GNULinux/rescue-i386-initrd.gz" >> ipxe-boot
echo "boot"  >> ipxe-boot
echo ":rescue-amd64" >> ipxe-boot
echo "# same for amd64" >> ipxe-boot
echo "kernel GNULinux/rescue-amd64-linux vga=norman irqpoll rescue/enable=true" >> ipxe-boot
echo "initrd GNULinux/rescue-amd64-initrd.gz" >> ipxe-boot
echo "boot" >> ipxe-boot
echo ":config" >> ipxe-boot
echo "config" >> ipxe-boot
echo "goto mainmenu" >> ipxe-boot
echo ":shell" >> ipxe-boot
echo "echo Note, you can run:" >> ipxe-boot
echo "echo    kernel http://URL/vmlinuz" >> ipxe-boot
echo "echo    initrd http://URL/initrd.img" >> ipxe-boot
echo "echo    boot"  >> ipxe-boot
echo "shell" >> ipxe-boot
echo "goto mainmenu" >> ipxe-boot
echo ":exit" >> ipxe-boot
echo "exit" >> ipxe-boot
echo "# EOF" >> ipxe-boot

# EOF
