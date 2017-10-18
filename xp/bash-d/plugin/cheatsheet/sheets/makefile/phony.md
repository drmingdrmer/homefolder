
It tells make `clean` is not a file.
Thus do not depends on stat of file `clean` to run task `clean`.

It works as expected:

```make
# cat Makefile
.PHONY: clean

clean:
	rm abc

# ls
abc clean
```


It does not run clean because there is a file `clean` which is always upto
date.

```make
# cat Makefile
clean:
	rm abc

# ls
abc clean
```


