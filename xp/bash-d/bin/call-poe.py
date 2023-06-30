#!/usr/bin/env python
# coding: utf-8

import poe
import logging
import sys
import json

def usage():
    #  pip install poe-api
    #  https://github.com/ading2210/poe-api
    print("Call poe.com")
    print("Usage:")
    print("    echo '<prompt>' | $0 <token>")

    #  Install:
    #   pip install poe-api
    #
    #  Finding Your Token:
    #  https://github.com/ading2210/poe-api#finding-your-token
    #
    #  Log into Poe on any desktop web browser, then open your browser's developer
    #  tools (also known as "inspect") and look for the value of the p-b cookie in the
    #  following menus:
    #    Chromium: Devtools > Application > Cookies > poe.com
    #    Firefox: Devtools > Storage > Cookies
    #    Safari: Devtools > Storage > Cookies

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

#  Find out the engine code name:
#  print(json.dumps(client.bot_names, indent=2))
#  """
#  {
#    "capybara": "Sage",
#    "a2": "Claude-instant",
#    "nutria": "Dragonfly",
#    "a2_100k": "Claude-instant-100k",
#    "beaver": "GPT-4",
#    "chinchilla": "ChatGPT",
#    "a2_2": "Claude+"
#  }

#  poe.logger.setLevel(logging.INFO)

token = sys.argv[1]

input_lines = []
for line in sys.stdin:
    input_lines.append(line.rstrip('\n'))

message = '\n'.join(input_lines)

eprint("prompt start ---")
eprint(message)
eprint("prompt end   ---")

#  socks5 proxy does not work:
#  client = poe.Client(token, proxy="socks5://127.0.0.1:51837")
#  client = poe.Client(token, proxy="socks5h://127.0.0.1:51837")
client = poe.Client(token, proxy="http://127.0.0.1:58591")


for chunk in client.send_message("a2_100k", message, with_chat_break=True, timeout=120):
    print(chunk["text_new"], end="", flush=True)

#  #delete the 3 latest messages, including the chat break
#  client.purge_conversation("capybara", count=3)
