#!/usr/bin/env python2
# coding: utf-8

from twisted.web import proxy, http
from twisted.internet import reactor
from twisted.python import log
import sys

log.startLogging(sys.stdout)

class ProxyFactory(http.HTTPFactory):
    protocol = proxy.Proxy


if __name__ == "__main__":

    port = (sys.argv[1:] + ['8080'])[0]
    port = int(port)
    print 'porxy on port: ', port

    reactor.listenTCP(port, ProxyFactory())
    reactor.run()
