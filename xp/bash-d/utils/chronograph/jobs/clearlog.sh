#!/bin/sh



XJob=clearlog
xstep "-------------"

if [ $(stat -c %s "$XpBase/chronograph/log") -gt 102400 ]; then
  XAct=movelog
  mv "$XpBase/chronograph/log" "$XpBase/chronograph/log.$(date +%F)" \
    && xok || xerr
fi
