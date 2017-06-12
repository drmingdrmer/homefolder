#!/bin/sh

brew install homebrew/nginx/openresty

sudo cpan Test::Nginx

$PATH:/usr/local/Cellar/openresty/1.11.2.3/nginx/sbin

prove -r t
