## Strings

APPEND      Append
BITCOUNT    Count set
            bits
BITOP       Bitwise
            operations
BITPOS      Find first
            set bit
DECR        Decrement
            integer
DECRBY      Subtract from
            integer
GET         Get by key
GETBIT      Get bit by
            index
GETRANGE    Get substring
GETSET      Set,
            returning old
            value
INCR        Increment
            integer
INCRBY      Add to
            integer
INCRBYFLOAT Add to float
MGET        Get multiple
MSET        Set multiple
MSETNX      Set multiple
            if don't
            exist
PSETEX      Set with
            expiry (ms)
SET         Set
SETBIT      Set bit by
            index
SETEX       Set with
            expiry
            (seconds)
SETNX       Set if
            doesn't exist
SETRANGE    Set substring
STRLEN      Get length
            Strings can be used as
            numbers, arrays, bit sets
            and binary data

## Lists

BLPOP      Blocking left
           pop
BRPOP      Blocking right
           pop
BRPOPLPUSH Blocking
           rotate
LINDEX     Access by
           index
LINSERT    Insert next to
LLEN       Get length
LPOP       Pop from start
LPUSH      Push onto
           start
LPUSHX     Push if list
           exists
LRANGE     Access range
LREM       Remove
LSET       Set item by
           index
LTRIM      Remove start
           and/or end
           items
RPOP       Pop from end
RPOPLPUSH  Rotate
RPUSH      Push onto end
RPUSHX     Push onto end
           if list exists

## Client-/Server

AUTH   Request
       authen-tic-ation
ECHO   Return message
PING   Test connection
QUIT   Close connection
SELECT Set current
       database by index

## Sets

SADD        Add item
SCARD       Get size
SDIFF       Get difference
SDIFFSTORE  Store
            difference
SINTER      Inters-ection
SINTERSTORE Store
            inters-ection
SISMEMBER   Check for item
SMEMBERS    Get all
SMOVE       Move item to
            another set
SPOP        Pop random
            item
SRANDMEMBER Get random
            item
SREM        Remove
            matching
SSCAN       Iterate items
SUNION      Union
SUNIONSTORE Store union
[INS::INS]

## Database

DEL       Delete item
DUMP      Serialise item
EXISTS    Check for key
EXPIRE    Set timeout on
          item
EXPIREAT  Set timeout by
          timestamp
KEYS      Get all keys
          matching pattern
MIGRATE   Transfer an item
          between Redis
          instances
MOVE      Transfer an item
          between
          databases
OBJECT    Inspect item
PERSIST   Remove timeout
PEXPIRE   Set timeout (ms)
PEXPIREAT Set timeout (ms
          timestamp)
PTTL      Get item time to
          live (ms)
RANDOMKEY Get random key
RENAME    Change item's
          key
RENAMENX  Change item's
          key if new key
          doesn't exist
RESTORE   Deseri-alise
SCAN      Iterate keys
SORT      Get or store
          sorted copy of
          list, set or
          sorted set
TTL       Get item time to
          live
TYPE      Get type of item

## Scripts

EVAL       Run
EVALSHA    Run cached
SCRIPT     Check by hash
EXISTS
SCRIPT     Clear cache
FLUSH
SCRIPT     Kill running
KILL       script
SCRIPT     Add to cache
LOAD
           Lua scripts access keys
           through the array KEYS and
           additional arguments
           through the array ARGV.

## Hashes

HDEL         Delete item
HEXISTS      Check for item
HGET         Get item
HGETALL      Return all items
HINCRBY      Add to integer value
HINCRBYFLOAT Add to float value
HKEYS        Return all keys
HLEN         Get number of items
HMGET        Get multiple items
HMSET        Set multiple items
HSCAN        Iterate items
HSET         Set item
HSETNX       Set item if doesn't
             exist
HVALS        Return all values

## Sorted sets

ZADD             Add item
ZCARD            Get number of
                 items
ZCOUNT           Number of items
                 within score
                 range
ZINCRBY          Add to score
ZINTERSTORE      Store
                 inters-ection
ZLEXCOUNT        Lexico-gra-phical
                 range count
ZRANGE           Get items within
                 rank range
ZLEXRANGE        Get items within
                 lexico-gra-phical
                 range
ZRANGEBYSCORE    Get items within
                 score range
ZRANK            Get item rank
ZREM             Remove item(s)
ZREMRANGEBYLEX   Remove items
                 within
                 lexico-gra-phical
                 range
ZREMRANGEBYRANK  Remove items
                 within rank range
ZREMRANGEBYSCORE Remove items
                 within score
                 range
ZREVRANGE        ZRANGE in reverse
                 order
ZREVRANGEBYSCORE ZRANGE-BYSCORE in
                 reverse order
ZREVRANK         ZRANK in reverse
                 order
ZSCAN            Iterate items
ZSCORE           Get item score
ZUNIONSTORE      Store union
                 Lexico-gra-phical commands require
                 all items to have the same score

## HyperL-ogLogs

PFADD   Add items
PFCOUNT Get approx-imate size
PFMERGE Merge HyperL-ogLogs
