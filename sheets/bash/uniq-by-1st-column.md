```sh
# -u uniq
# -t seperator
# -k<from_column>,<to_column>

sort -u -t " " -k1,1
```

or 

```sh
awk -F"," '!_[$1]++' file
# -F sets the field separator.
# $1 is the first field.
# _[val] looks up val in the hash _(a regular variable).
# ++ increment, and return old value.
# ! returns logical not.
# there is an implicit print at the end.
```

http://stackoverflow.com/questions/1915636/is-there-a-way-to-uniq-by-column
