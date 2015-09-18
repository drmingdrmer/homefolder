function FindProxyForURL(url, host) {
    var local_socks = "SOCKS 127.0.0.1:9001";
    var DEFAULT = "DIRECT";

    if(shExpMatch(host, "*google*")) return local_socks;

    return DEFAULT;
}
