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

# do `export NO_WGET=1` if you want it do skip downloading files.

BOOT_OPTS="vga=normal"
[ $NO_WGET ] && echo "NO_WGET is exported so we won't download required files."

# cd in the directory where this script resides, even if called from a symlink
# in /etc/cron.whatever/
ZERO=$0
if [ -L $0 ]; then ZERO=`readlink $0`; fi
cd `dirname $ZERO`

# list of distros we want to provide
# (yes, this is debian-specific, feel free to modify/improve)
DISTS="ftp://ftp.fr.debian.org/debian/dists/stable ftp://ftp.fr.debian.org/debian/dists/testing http://archive.ubuntu.com/ubuntu/dists/precise"
ARCHS="i386 amd64"
PXELINUX0="ftp://ftp.fr.debian.org/debian/dists/testing/main/installer-i386/current/images/netboot/pxelinux.0"

# recreate from scratch the conffile
# (always one x86 rescue option with debian stable first)
CONFFILE="../pxelinux.cfg/default"
echo "DISPLAY pxelinux.cfg/boot.txt" > $CONFFILE
echo "DEFAULT rescue-x86 " >> $CONFFILE
echo >> $CONFFILE
echo "LABEL rescue-x86" >> $CONFFILE
echo "      kernel gnulinux/stable-i386-linux" >> $CONFFILE
echo "      append $BOOT_OPTS irqpoll initrd=gnulinux/stable-i386-initrd.gz rescue/enable=true  --" >> $CONFFILE

# download images and update the conffile
for dist in $DISTS; do
    for arch in $ARCHS; do 
	system=`echo $dist | sed s@dists.*@@`
	system=`basename $system`
	[ ! $NO_WGET ] && wget --quiet $dist/main/installer-$arch/current/images/netboot/$system-installer/$arch/initrd.gz -O `basename $dist`-$arch-initrd.gz
	[ ! $NO_WGET ] && wget --quiet $dist/main/installer-$arch/current/images/netboot/$system-installer/$arch/linux -O `basename $dist`-$arch-linux
	echo >> $CONFFILE
	echo "LABEL $system-`basename $dist`-$arch" >> $CONFFILE
	echo "      kernel gnulinux/`basename $dist`-$arch-linux" >> $CONFFILE
	echo "      append $BOOT_OPTS initrd=gnulinux/`basename $dist`-$arch-initrd.gz --" >> $CONFFILE
    done
done

echo >> $CONFFILE
echo "PROMPT 1" >> $CONFFILE
echo "TIMEOUT 0" >> $CONFFILE

# finaly, make sure we have the latest bootstrap program we can get
[ ! $NO_WGET ] && wget --quiet $PXELINUX0 -O ../pxelinux.0

# EOF
