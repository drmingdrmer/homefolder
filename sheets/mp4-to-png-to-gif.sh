ffmpeg -i WeChatSight969.mp4 -r 10 frames/frame%03d.png

convert -delay 10 -loop 0 frames/frame*.png output.gif

