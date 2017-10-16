pip list | cut -d" " -f1 | xargs pip show -f | less
