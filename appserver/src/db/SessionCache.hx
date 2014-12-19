package db;

import org.mongodb.*;

class SessionCache {

    public var limit : Int;  // TODO not enforced yet
    public var size = 0;

    var manager:Manager<Session>;
    var cache = new Map<String, Session>();

    // TODO queue of sessions to be removed from the cache

    function keep(s:Session)
    {
        if (!cache.exists(s._id)) {
            cache.set(s._id, s);
            size++;
        }
    }

    function discard(id)
    {
        if (cache.remove(id)) {
            // TODO also remove from the queue
            size--;
            return true;
        }
        return false;
    }

    function fetch(id):Null<Session>
    {
        var s = manager.findOne({ _id : id });
        if (s != null)
            keep(s);
        return s;
    }

    public function new(manager, ?limit=0)
    {
        this.limit = limit;
        this.manager = manager;
    }

    // Return if the session `id` exists,
    // but don't attempt to verify that it is valid
    public function exists(id:String):Bool
    {
        if (cache.exists(id))
            return true;
        return fetch(id) != null;
    }

    // Return null or the session `id`
    public function get(id:String):Null<Session>
    {
        var s = cache.get(id);
        if (s == null)
            s = fetch(id);
        return s;
    }

    // Add `session` to the db or update it
    public function save(session:Session):Void
    {
        if (exists(session._id)) {
            manager.update({ _id : session._id }, session);
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

