#!/bin/sh

defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 1 # normal minimum is 2 (30 ms)

# https://apple.stackexchange.com/questions/206351/how-to-enable-key-repeat-on-macbook-pro-with-yosemite?rq=1
