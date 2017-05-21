https://lists.freebsd.org/pipermail/freebsd-stable/2006-November/030886.html

    "UseDNS no" only prevents sshd from performing a validation
    of the client's reverse lookup.  That is, if you connect
    with a client whose hostname resolves to a different IP
    address than the one with which it connects, the server
    will reject it if UseDNS is "yes", but allow it if "no".

    But "UseDNS no" does _not_ prevent the sshd server from
    performing any DNS lookups at all.  That's not the purpose
    of that directive.

    If you specify the -u0 option when starting sshd, it means
    that it will not put hostnames into the utmp structure
    (i.e. what you see when you type "w" at the shell prompt),
    which means that sshd will not perform DNS lookups for that
    purpose.  _However_ there are still cases where a lookup
    has to be performed when a user has "from=<hostname>"
    entries in his authorized_keys file, or when authentication
    methods or configuration directives are used that involve
    hostnames.


https://lists.freebsd.org/pipermail/freebsd-stable/2006-November/030890.html
