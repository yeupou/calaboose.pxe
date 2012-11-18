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

# recreate the ipxe-boot file
echo "#!ipxe" > ipxe-boot

MENU=""

# download images and update the labels
for dist in $DISTS; do
    for arch in $ARCHS; do 
	system=`echo $dist | sed s@dists.*@@`
	system=`basename $system`
	[ ! $NO_WGET ] && wget --quiet $dist/main/installer-$arch/current/images/netboot/$system-installer/$arch/initrd.gz -O `basename $dist`-$arch-initrd.gz
	[ ! $NO_WGET ] && wget --quiet $dist/main/installer-$arch/current/images/netboot/$system-installer/$arch/linux -O `basename $dist`-$arch-linux
	echo ":$system-`basename $dist`-$arch" >> ipxe-boot
	echo "kernel GNULinux/`basename $dist`-$arch-linux $BOOT_OPTS" >> ipxe-boot
	echo "initrd GNULinux/`basename $dist`-$arch-initrd.gz" >> ipxe-boot
	echo "boot" >> ipxe-boot
	MENU="$MENU\nitem $system-`basename $dist`-$arch `echo $system | tr a-z A-Z` `basename $dist` $arch"
    done
done

# add the menu lines
echo "menu GNU/Linux boot images" >> ipxe-boot
echo -e "$MENU" >> ipxe-boot
echo "choose target && goto \${target}" >> ipxe-boot
echo "# EOF" >> ipxe-boot

# EOF
