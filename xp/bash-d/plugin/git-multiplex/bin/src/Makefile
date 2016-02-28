# embed sourced file into each

fns = $(shell ls git-*)

all:
	for f in $(fns); do cat $$f | awk -f preproc.awk > ../$$f && chmod +x $$f; done

