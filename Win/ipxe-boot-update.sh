#
# FILE DISCONTINUED HERE
# UPDATED VERSION AT
#         https://gitlab.com/yeupou/calaboose.pxe/raw/master/Win/ipxe-boot-update.sh
#
#                                 |     |
#                                 \_V_//
#                                 \/=|=\/
#                                  [=v=]
#                                __\___/_____
#                               /..[  _____  ]
#                              /_  [ [  M /] ]
#                             /../.[ [ M /@] ]
#                            <-->[_[ [M /@/] ]
#                           /../ [.[ [ /@/ ] ]
#      _________________]\ /__/  [_[ [/@/ C] ]
#     <_________________>>0---]  [=\ \@/ C / /
#        ___      ___   ]/000o   /__\ \ C / /
#           \    /              /....\ \_/ /
#        ....\||/....           [___/=\___/
#       .    .  .    .          [...] [...]
#      .      ..      .         [___/ \___]
#      .    0 .. 0    .         <---> <--->
#   /\/\.    .  .    ./\/\      [..]   [..]
#
#
# FILE DISCONTINUED H
#         https://gitlab.com/yeupou/bada/raw/master/Win/ipxe-boot-update.sh
#
#                                 |     |
#                                 \_V_//
#                                 \/=|=\/
#                                  [=v=]
#                                __\___/_____
#                               /..[  _____  ]
#                              /_  [ [  M /] ]
#                             /../.[ [ M /@] ]
#                            <-->[_[ [M /@/] ]
#                           /../ [.[ [ /@/ ] ]
#      _________________]\ /__/  [_[ [/@/ C] ]
#     <_________________>>0---]  [=\ \@/ C / /
#        ___      ___   ]/000o   /__\ \ C / /
#           \    /              /....\ \_/ /
#        ....\||/....           [___/=\___/
#       .    .  .    .          [...] [...]
#      .      ..      .         [___/ \___]
#      .    0 .. 0    .         <---> <--->
#   /\/\.    .  .    ./\/\      [..]   [..]
#  / / / .../|  |\... \ \ \    _[__]   [__]_
# / / /       \/       \ \ \  [____>   <____]
#
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


# This use wimboot http://ipxe.org/wimboot
# As such, tftpd is not enough, an http server must serve this directory
# so $PREFIX must be defined. Silently exits if unset.
#PREFIX=http://URL/pxe/
[ ! $PREFIX ] && exit

# cd in the directory where this script resides, even if called from a symlink
# in /etc/cron.whatever/
ZERO=$0
if [ -L $0 ]; then ZERO=`readlink $0`; fi
cd `dirname $ZERO`

# check if required files exists
REQUIRED_FILES="wimboot 7/bootmgr 7/boot/bcd 7/boot/boot.sdi 7/sources/boot.wim"
for file in $REQUIRED_FILES; do
    if [ ! -e $file ]; then 
	echo "$file is missing. Please read http://ipxe.org/wimboot"
	exit
    fi
done

# recreate the ipxe-boot file
echo "#!ipxe
menu Win 
item win7 Win 7
choose target && goto \${target}
:win7
kernel "$PREFIX"Win/wimboot
initrd "$PREFIX"Win/7/bootmgr          bootmgr
initrd "$PREFIX"Win/7/boot/bcd         BCD
initrd "$PREFIX"Win/7/boot/boot.sdi    boot.sdi
initrd "$PREFIX"Win/7/sources/boot.wim boot.wim
boot
# EOF" > ipxe-boot

# EOF
