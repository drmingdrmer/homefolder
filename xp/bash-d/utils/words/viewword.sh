#!/bin/bash


while [ 1 ];do
  words=`ls -tr word/`
  i=0
  for w in $words;do
    let i=i+1

    echo ""
    echo $i-----------------------------------------------$w

    read -n1 -p "d:dic v:view r:rename e:erase::" k

    echo ""
    case $k in
      d)
      dict $w
      dic.nopush $w
      ;;

      v)
      w3m -dump "http://dict.cn/search.php?q=$w" | less
      ;;

      r)
      read -p "rename to:" to
      mv word/$w word/$to
      ;;

      e)
      rm word/$w -i
      ;;

      "")
      echo "  passed " $w
      echo 1 >> word/$w
      ;;
    esac

  done

done
