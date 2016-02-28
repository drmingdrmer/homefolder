# embed sourced file into each

all:
	for f in $(ls git-*); do cat $$f | awk -f preproc.awk > ../$$f && chmod +x $$f; done

