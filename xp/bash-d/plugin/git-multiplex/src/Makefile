# embed sourced file into each

fns = $(shell ls git-*)

all:
	for f in $(fns); do cat $$f | awk -f preproc.awk > ../bin/$$f && chmod +x ../bin/$$f; test ! -d "../gist/$$f" || cp ../bin/$$f ../gist/$$f/$$f; done

