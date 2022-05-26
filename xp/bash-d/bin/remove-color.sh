#!/bin/sh
# on mac use gsed instead of sed
gsed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"
