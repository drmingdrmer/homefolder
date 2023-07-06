#!/bin/sh

{
    echo '```rust'
    cat
    echo '```'
} | general-text-proc-gpt-poe.sh "refine the document comment"
