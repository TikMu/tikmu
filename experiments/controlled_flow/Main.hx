import mweb.tools.*;
import neko.Web;
import Type;
using NoTemplate;

class Main {
    static function initDatabases()
    {
        return null;
    }

    public static function main()
    {
        var dbs = initDatabases();
        var ctx = new Context(dbs);

        var res = ctx.dispatch();
        if (!Std.is(res, mweb.tools.HttpResponse.HttpResponseData)) {
            // FIXME allow if internal to the server (filter by localhost?)
            // FIXME should instead fake a 404
            res = new HttpResponse();
            res.setStatus(Forbidden);
            res.setContent("ERROR  /strip/* not allowed client-side".link());
        }
        HttpWriter.fromWeb(Web).writeResponse(res);
    }
}

