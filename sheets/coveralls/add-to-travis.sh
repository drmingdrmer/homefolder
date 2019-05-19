#!/bin/sh

# gem install travis

# token is here: https://coveralls.io/github/openacid/slim/settings
# in repo dir, this add encrypted token to .travis.yml
travis encrypt  -r openacid/slim COVERALLS_TOKEN="token"  --add
