#!/usr/bin/env python
# coding: utf-8

import socket
import threading
import os

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

sock.setsockopt(socket.SOL_SOCKET,  socket.SO_REUSEADDR,  1)

sock.bind(('0.0.0.0', 80))
sock.listen(100)

def work(sock, addr):
    try:
        while True:
            buf = sock.recv(1024)
            os.write(1, buf)
    except Exception as e:
        print repr(e)

while True:
    cli_sock, addr = sock.accept()
    th = threading.Thread(target=work, args=(cli_sock, addr))
    th.daemon = True
    th.start()



