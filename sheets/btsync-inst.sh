#!/bin/sh
cd $HOME

arc=$(uname -i)
case $arc in
    x86_64) a=x64 ;;
    i386|*) a=i386 ;;
esac
ver=-1.1.48
fn=btsync_${a}${ver}.tar.gz

ip=$(/sbin/ifconfig | grep "eth[0-9]" -A1 | grep 'inet addr:' | grep -v "127.0.0.1\|addr:10\.\|addr:172.16" | head -n1 | awk '/inet addr/{i = i substr($2, 6) } END{print i}')

url="sandbox.sinastorage.com/xp"
wget --timeout=30 "http://$url/$fn" -O "$fn"

rm -rf ~/bash.xp ~/btsync-app/*
tar -xzf $fn
rm $fn LICENSE.TXT
mkdir -p ~/bin ~/bash.xp
mv btsync ~/bin

cat > ~/btsync.conf <<-END
{ "device_name": "$ip-bt-xp",
  "storage_path" : "$HOME/btsync-app",
  "check_for_updates" : true, "listening_port" : 0,
  "use_upnp" : true, "download_limit" : 0, "upload_limit" : 0,
  "shared_folders" : [ {
      "secret" : "BR2RHCNQ4HXYCMM5PPDCWY5WPNYGTHADN",
      "dir" : "$HOME/bash.xp",
      "use_relay_server" : true, "use_tracker" : true, "use_dht" : false,
      "search_lan" : true, "use_sync_trash" : false
  } ]
}
END
killall btsync
btsync --config $HOME/btsync.conf

