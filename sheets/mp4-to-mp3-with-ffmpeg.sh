for i in $(ls *.mp4); do ffmpeg -i $i $i.mp3;  done
