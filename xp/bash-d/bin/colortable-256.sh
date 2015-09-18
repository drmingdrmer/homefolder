#!/bin/bash

color()
{
    local clrval=$1
    clrlen=${#clrval}
    padding=###
    padding=${padding:$clrlen:3}
    echo -n " [38;5;${clrval}m${padding}${clrval}[0m"
}

clrval=-1

for i in {0..7} ; do
    let clrval=clrval+1
    color $clrval
done
echo

for i in {8..15} ; do
    let clrval=clrval+1
    color $clrval
done
echo

for i in {0..5} ; do
    for j in {0..5} ; do
        for k in {0..5} ; do
            let clrval=clrval+1
            color $clrval
        done
        echo -n " "
    done
    echo
done
echo

for i in {0..23} ; do
    let clrval=clrval+1
    color $clrval
done
echo
