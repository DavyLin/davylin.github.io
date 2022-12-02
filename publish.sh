#!/bin/bash

emacs -Q --script init-site.el

echo "##############################################################################"
echo "Site build complete."
echo "Server running on localhost:8000 -- press ^C to exit."
echo "##############################################################################"
echo ""

#python3 -m http.server --directory ./org/

#echo -n "OK to publish site? [y/N]: "

#read YN

#if [ "$YN" = "y" -o "$YN" = "Y" ] ; then
 #   rsync -avz --delete --delete-after --progress ./org/ kinhung.me:/var/www/kinhungm/
#fi
