function regExpMatch(url, pattern) {
    try { return new RegExp(pattern).test(url); } catch(ex) { return false; }
}

function FindProxyForURL(url, host) {
    if ( regExpMatch( host, "facebook.com" )
        || regExpMatch( host, /google.com/ )
    ) {
        return 'SOCKS5 127.0.0.1:9000';
    }
    else {
        return 'DIRECT';
    }

}
