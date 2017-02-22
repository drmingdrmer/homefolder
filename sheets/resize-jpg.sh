#!/bin/sh

convert -resize "2048" "$i" "tt/$i"
convert -resize "50%" "$i" "tt/$i"

# resize width to 600, with ratio kept
convert -resize "600" "$i" "tt/$i"


# -size 200x200 tells the jpeg decoder we only need this resolution so it can save memory and read the source image faster
# -thumbnail 100x100^ fast resize making the shortest side 100
# -gravity center center the next operation
#       east
#       west
#       ...
# -extent 100x100 apply the image to a 100x100 canvas
# +profile "*" do not save any metainfo to the jpeg (making the resulting image smaller)
#
#  http://superuser.com/questions/275476/square-thumbnails-with-imagemagick-convert
convert -define jpeg:size=200x200 x.jpg  -thumbnail 400x400^ -gravity center -extent 400x400  t.jpg


# convert t.jpg -font AmplitudeComp-Regular -weight 700  -pointsize 200 -draw "gravity north fill black text 0,700 'IN CENTRAL PARKING BLA BLA' " t.jpg

# draw rectangle
# draw text
convert t.jpg  -weight 700  -pointsize 80  -fill black -draw "rectangle 0,320 400,400" -draw "gravity north fill white text 0,320 'ZK' " u.jpg
