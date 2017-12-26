
# show all net connection
ss -tan

# show all TIME_WAIT tcp
ss -tan state time-wait


# -l: listening
# -t: tcp
# -a: all
# -n: no host resolve

# STATE-FILTER

STATE-FILTER allows to construct arbitrary set of states to match. Its syntax is sequence of keywords state and exclude followed by identifier of state.

Available identifiers are:

      All standard TCP states:
          established
          syn-sent
          syn-recv
          fin-wait-1
          fin-wait-2
          time-wait
          closed
          close-wait
          last-ack
          listen
          closing

      all - for all the states

      connected - all the states except for listen and closed

      synchronized - all the connected states except for syn-sent

      bucket - states, which are maintained as minisockets, i.e.  time-wait and syn-recv

      big - opposite to bucket

# USAGE EXAMPLES

ss -t -a
      Display all TCP sockets.

ss -t -a -Z
      Display all TCP sockets with process SELinux security contexts.

ss -u -a
      Display all UDP sockets.

ss -o state established '( dport = :ssh or sport = :ssh )'
      Display all established ssh connections.

ss -x src /tmp/.X11-unix/*
      Find all local processes connected to X server.

ss -o state fin-wait-1 '( sport = :http or sport = :https )' dst 193.233.7/24
      List all the tcp sockets in state FIN-WAIT-1 for our apache to network 193.233.7/24 and look at their timers.

