#!/bin/sh

# issues like:
# find_spec_for_exe': can't find gem bundler (>= 0.a) (Gem::GemNotFoundException)
# find_spec_for_exe': can't find gem jekyll (>= 0.a) with executable jekyll (Gem::GemNotFoundException)

# just reinstall it
sudo gem install jekyll
