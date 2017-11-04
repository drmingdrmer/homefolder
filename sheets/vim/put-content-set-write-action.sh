CONTENT="$content" vim \
    -c 'put=$CONTENT' \
    -c 'file des3-b64://account' \
    -c 'set buftype=acwrite' \
    -c 'au BufWriteCmd * exec "w !cat | grep . | openssl des3 | base64 > '"$path"'" | q!'
