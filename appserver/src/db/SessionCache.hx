package db;

import haxe.ds.Vector;
import org.mongodb.*;

class SessionCache {

    public var size (default,null) : Int;
    public var used = 0;

    var manager : Manager<Session>;
    var items : Vector<Session>;

    // CACHE INTERNAL IMPLEMENTATION

    // Fowler–Noll–Vo alternate function (FNV-1a/32bits)
    // http://www.isthe.com/chongo/tech/comp/fnv/index.html#FNV-1a
    // http://programmers.stackexchange.com/questions/49550/which-hashing-algorithm-is-best-for-uniqueness-and-speed/145633#145633
    static inline var FNV_OFFSET_BASIS = 0x811C9DC5;
    static inline var FNV_PRIME = 16777619;
    function cache_sessionHash(id)
    {
        var h = FNV_OFFSET_BASIS;
        for (i in 0...id.length)
            h = (h ^ id.charCodeAt(i))*FNV_PRIME;
        return h;
    }

    function cache_sessionPos(id)
    {
        var h = cache_sessionHash(id);
        var p = h % size;
        return p > 0 ? p : (-p);
    }

    function cache_equalSessions(id1, id2) {
        return id1 == id2;
    }

    function cache_has(id)
    {
        return cache_get(id) != null;
    }

    function cache_get(id)
    {
        var pos = cache_sessionPos(id);
        var s = items.get(pos);
        return (s != null && cache_equalSessions(id, s._id)) ? s : null;
    }

    function cache_set(id, s)
    {
        var pos = cache_sessionPos(id);
        var add = items.get(pos) == null;
        items.set(pos, s);
        if (add)
            used++;
        return s;
    }

    function cache_remove(id)
    {
        var pos = cache_sessionPos(id);
        var rem = items.get(pos) != null;
        items.set(pos, null);
        if (rem)
            used--;
        return rem;
    }

    // PRIVATE API

    inline function keep(s:Session)
    {
        cache_set(s._id, s);
    }

    inline function discard(id)
    {
        return cache_remove(id);
    }

    function fetch(id):Null<Session>
    {
        var s = manager.findOne({ _id : id });
        if (s != null)
            keep(s);
        return s;
    }

    public function new(manager, ?size=1000)
    {
        this.manager = manager;
        this.size = size;
        items = new Vector(size);
    }

    // Return if the session `id` exists,
    // but don't attempt to verify that it is valid
    public function exists(id:String):Bool
    {
        if (cache_has(id))
            return true;
        return fetch(id) != null;
    }

    // Return null or the session `id`
    public function get(id:String):Null<Session>
    {
        var s = cache_get(id);
        if (s == null)
            s = fetch(id);
        return s;
    }

    // Add `session` to the db or update it
    public function save(session:Session):Void
    {
        if (exists(session._id)) {
            manager.update({ _id : session._id }, session);
            // exists already places the session in the cache, if necessary
        }
        else {
            manager.insert(session);
            keep(session);
        }
    }

    // Terminate `session` saving its current state on the db
    public function terminate(session:Session):Bool
    {
        session.closedAt = Date.now();
        save(session);
        discard(session._id);
        return true;
    }

}

