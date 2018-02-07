#!/bin/sh

git ls | while read fn; do
    git blame "$fn" \
        | grep "韩晓攀" \
        | grep -v "2139d78\|5b3afe1\|b3e1560\|d782232\|f292b9e\|1462e53"
done | wc
