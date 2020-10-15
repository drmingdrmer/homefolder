#!/bin/sh

usage()
{
    cat <<-END
convert mp4 to pngs:
$0 x.mp4 to

convert pngs to gif:
$0 x.mp4 gif
END
}
fn=$1
action=$2
tmpdir="$fn-frames/"
outfn="$fn.gif"
mkdir -p "$tmpdir"

if [ "$action" = "to" ]; then
    ffmpeg -i "$fn" -r 10 "$tmpdir/%03d.png"
else
    convert -delay 10 -loop 0 "$tmpdir/*.png" "$outfn"
fi

