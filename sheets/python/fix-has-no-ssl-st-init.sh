#!/bin/sh

rm -rf /usr/lib/python2.7/dist-packages/OpenSSL
rm -rf /usr/lib/python2.7/dist-packages/pyOpenSSL-0.15.1.egg-info
sudo pip install pyopenssl

# another possible positionn is
#   /usr/local/lib/python2.7/site-packages
