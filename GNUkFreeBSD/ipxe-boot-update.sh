#!/bin/bash
#
# Copyright (c) 2013 Mathieu Roy <yeupou--gnu.org>
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

# Use the following if you want to provide access to these over http
# instead of tftp or any other relevant protocol, assuming you set up
# the relevant server to serve these
#PREFIX=http://URL/pxe/

[ $NO_WGET ] && echo "NO_WGET is exported so we won't download required files."

# cd in the directory where this script resides, even if called from a symlink
# in /etc/cron.whatever/
ZERO=$0
if [ -L $0 ]; then ZERO=`readlink $0`; fi
cd `dirname $ZERO`

# for this, we'll use grub2pxe as provided by debian. This one is set to use
# debian-installer as main directory. Create the symlink now if missing
if [ ! -e ../debian-installer ]; then ln -s GNUkFreeBSD ../debian-installer; fi

ARCHS="kfreebsd-i386 kfreebsd-amd64"

# recreate the ipxe-boot file
echo "#!ipxe" > ipxe-boot

MENU=""

# download images and update the labels
system=debian
for arch in $ARCHS; do 
    mkdir -p $arch
    url=http://ftp.fr.debian.org/debian/dists/stable/main/installer-$arch/current/images/netboot/debian-installer/$arch
    [ ! $NO_WGET ] && wget --quiet  $url/initrd.gz -O $arch/initrd.gz
    [ ! $NO_WGET ] && wget --quiet $url/kfreebsd.gz -O $arch/kfreebsd.gz
    [ ! $NO_WGET ] && wget --quiet $url/grub2pxe -O $arch/grub2pxe
    [ ! $NO_WGET ] && wget --quiet $url/grub.cfg -O $arch/grub.cfg
    echo ":$system-$arch" >> ipxe-boot
    echo chain $PREFIX"GNUkFreeBSD/$arch/grub2pxe" >> ipxe-boot
    echo "boot" >> ipxe-boot
    MENU="$MENU\nitem $system-$arch Install `echo $system | tr a-z A-Z` $arch"
done


# add the menu lines
echo "menu GNU/kFreeBSD boot images" >> ipxe-boot
echo -e "$MENU" >> ipxe-boot
echo "choose target && goto \${target}" >> ipxe-boot
echo "# EOF" >> ipxe-boot

# EOF
