#!/bin/sh

while read nm; do
    url="https://www.w3schools.com/charsets/ref_utf_$nm.asp"
    fn=$nm.txt
    echo $nm: $url
    # w3m -dump $url > $fn

    # filter out junks
    cat $fn | awk '
    /Char *Dec *Hex *Entity/,!/./ {
        print $0
    }
    ' >t

    mv t $fn

done <<-END
arrows
block
box
currency
cyrillic
cyrillic_supplement
diacritical
dingbats
geometric
greek
latin1_supplement
latin_extended_a
latin_extended_b
letterlike
math
modifiers
punctuation
symbols
END

