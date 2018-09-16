#!/bin/sh


{
cat <<-END
a 1
c 3
b 2
END
} | awk '{
    a[$1] = $2
}
END {
    n = asorti(a, keys)
    for (i=1; i<=n; i++) {
        k = keys[i]
        print k " " a[k]
    }
}'
