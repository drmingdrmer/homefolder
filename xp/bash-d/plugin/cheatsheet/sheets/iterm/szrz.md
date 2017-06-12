
Install lrzsz on OSX: brew install lrzsz

Save the iterm2-send-zmodem.sh and iterm2-recv-zmodem.sh scripts in /usr/local/bin/
Set up Triggers in iTerm 2 like so:

    Regular expression: rz waiting to receive.\*\*B0100
    Action: Run Silent Coprocess
    Parameters: /usr/local/bin/iterm2-send-zmodem.sh
    Instant: checked

    Regular expression: \*\*B00000000000000
    Action: Run Silent Coprocess
    Parameters: /usr/local/bin/iterm2-recv-zmodem.sh
    Instant: checked

https://github.com/mmastrac/iterm2-zmodem
