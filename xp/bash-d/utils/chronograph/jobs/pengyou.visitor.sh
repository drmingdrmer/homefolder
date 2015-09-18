#!/bin/bash


datetime=`date +%s`
url="http://pengyou.sina.com.cn/friend/profile/aj_visitor.php?uid=1539471463&rnd="
url=$url$datetime


coo='vjuids=-14778c9c8.11a2305ec69.0.8185ad5a89fb28; vjlast=1244186140; SINA_BBS_MYSHOW=3-56-5; SINAPUID=10.218.20.141.110491220928080806; SINA_NEWS_CUSTOMIZE_city=%u5317%u4EAC; SINAGLOBAL=10.218.26.98.67771216635434399; platform_tray_tips=true; __utma=269849203.1444441516.1242034254.1242034254.1242034254.1; __utmz=269849203.1242034254.1.1.utmccn=(direct)|utmcsr=(direct)|utmcmd=(none); sl=drdr.xp%40gmail.com; SPHPSESSID=luicg083v1ocjl5dreqm1lft90; islogin=1; chatid=20mvj2e82g5bc18u; Apache=10.209.3.154.37621244081482910; _s_upa=6; remberloginname=%25u91D1%25u51EF%25u5E73; SE=C6E779FF4FBBAF3B5473FC34765A79190372330A67933A57174EFB9EFF6765E272A69D2A6414439F626C8343E9EAB6E28D5FF8CF37BCF34A9CF0C64000FB604AAB1F643BD0511AD6CAACDED24E069A0E; PS=; SU=drdr.xp%40gmail.com:4:1539471463:xper:1244186082:1:::; SINAPRO=MeDZZDC%26X9yE%26UXXBEC.J%21%26JZEZ%3DH%3DE%3DYfEf.ppi8%3DEEzi0YlzEili8pHE%25zEjBqX0E0; UNIPROU=4:drdr.xp%40gmail.com:0::1:; nick=xper(1539471463); gender=1; UNIPROTM=1244186082; SUE=es%3D60d345ebed02a2c9d08dee45faaedcae%26ev%3Dv0; SUP=cv%3D1%26bt%3D1244186082%26et%3D1244272482%26uid%3D1539471463%26user%3Ddrdr.xp%2540gmail.com%26ag%3D4%26nick%3Dxper%26sex%3D1%26ps%3D0; ALF=1244790882; SSOLoginState=1244186078'

echo load visitors
curl $url -H "Cookie: $coo" >.file

# cat .file

cat .file \
| sed 's/<\w\+/\n/g' \
| grep "href" | grep -v "title\|javascript"  | grep "CP_avt_a" \
| awk -F/ '{print $2}' \
| awk -F\\ '{print $1}' > .tmp


cat .tmp

for i in `cat .tmp`;do
  # curl http://pengyou.sina.com.cn/$i -H "Cookie: $coo" 2>&1 | grep "<title"
  echo visit $i
  curl "http://pengyou.sina.com.cn/friend/aj_addvisitor.php?ownerid=$i" -H "Cookie: $coo" 2>/dev/null
done

# vjuids=-14778c9c8.11a2305ec69.0.8185ad5a89fb28; vjlast=1244186140; SINA_BBS_MYSHOW=3-56-5; SINAPUID=10.218.20.141.110491220928080806; SINA_NEWS_CUSTOMIZE_city=%u5317%u4EAC; SINAGLOBAL=10.218.26.98.67771216635434399; platform_tray_tips=true; __utma=269849203.1444441516.1242034254.1242034254.1242034254.1; __utmz=269849203.1242034254.1.1.utmccn=(direct)|utmcsr=(direct)|utmcmd=(none); sl=drdr.xp%40gmail.com; SPHPSESSID=luicg083v1ocjl5dreqm1lft90; islogin=1; chatid=20mvj2e82g5bc18u; Apache=10.209.3.154.37621244081482910; _s_upa=6; remberloginname=%25u91D1%25u51EF%25u5E73; SE=C6E779FF4FBBAF3B5473FC34765A79190372330A67933A57174EFB9EFF6765E272A69D2A6414439F626C8343E9EAB6E28D5FF8CF37BCF34A9CF0C64000FB604AAB1F643BD0511AD6CAACDED24E069A0E; PS=; SU=drdr.xp%40gmail.com:4:1539471463:xper:1244186082:1:::; SINAPRO=MeDZZDC%26X9yE%26UXXBEC.J%21%26JZEZ%3DH%3DE%3DYfEf.ppi8%3DEEzi0YlzEili8pHE%25zEjBqX0E0; UNIPROU=4:drdr.xp%40gmail.com:0::1:; nick=xper(1539471463); gender=1; UNIPROTM=1244186082; SUE=es%3D60d345ebed02a2c9d08dee45faaedcae%26ev%3Dv0; SUP=cv%3D1%26bt%3D1244186082%26et%3D1244272482%26uid%3D1539471463%26user%3Ddrdr.xp%2540gmail.com%26ag%3D4%26nick%3Dxper%26sex%3D1%26ps%3D0; ALF=1244790882; SSOLoginState=1244186078







rm .tmp .file
