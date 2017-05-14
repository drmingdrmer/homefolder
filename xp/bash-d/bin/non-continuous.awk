#!/usr/bin/env awk -f

{
    i=$0
    if (prev + 1 != i) {
        print prev " " i
    }
    prev = i
}
