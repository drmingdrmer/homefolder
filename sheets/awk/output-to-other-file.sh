#!/bin/sh

awk '{print $1 > "a.txt"}' <<-END
1
2
3
END
