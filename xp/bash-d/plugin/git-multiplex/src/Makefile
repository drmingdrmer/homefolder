# embed sourced file into each

fns = $(shell ls git-*) p8ln

all:
	for f in $(fns); do cat $$f | awk -f preproc.awk > ../bin/$$f && chmod +x ../bin/$$f; done
	for f in $(fns); do test ! -d "../gist/$$f" || cp ../bin/$$f ../gist/$$f/$$f; done
	for f in $(fns); do test ! -d "../repo/$$f" || cp ../bin/$$f ../repo/$$f/$$f; done

