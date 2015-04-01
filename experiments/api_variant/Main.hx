/*
   Some subdispatching and API experimentation with mweb.
*/

typedef DefaultData = {
    msg : String
}

typedef NowData = {
    date : Date
}

@:template("<body>@msg</body>")
class DefaultView extends erazor.macro.SimpleTemplate<DefaultData> {}

@:template("<body>Now is @date</body>")
class NowView extends erazor.macro.SimpleTemplate<NowData> {}

typedef RouteContext = {
    isHtml : Bool
}

typedef RouteReturn = mweb.tools.HttpResponse<Dynamic>;

class TopLevel extends mweb.Route<RouteReturn> {
    @html
    public function any():RouteReturn
    {
        var res = new mweb.tools.HttpResponse();

        var data = {
            msg : "Welcome!"
        };

        res.setContent(new mweb.tools.TemplateLink(data, new DefaultView()));
        return res;
    }

    @html @api
    public function anyNow():RouteReturn
    {
        var res = new mweb.tools.HttpResponse();

        var data = {
            date : Date.now()
        };

        res.setContent(new mweb.tools.TemplateLink(data, new NowView()));
        return res;
    }
}

class Root extends mweb.Route<RouteReturn> {
    public function any(d:mweb.Dispatcher<RouteReturn>):RouteReturn
    {
        // TODO support and enforce @html
        return d.dispatch(new TopLevel());
    }

    public function anyApi(d:mweb.Dispatcher<RouteReturn>):RouteReturn
    {
        // TODO support and enforce @api
        var res = d.dispatch(new TopLevel());
        // TODO handle some @apiReady (indicates that somehow the method has
        //      already generated a API compatible response)
        switch (res.response) {
        case Content(data):
            // TODO support for serialization options
            var json = haxe.Json.stringify.bind(_, null, null);
            res.replaceContent(new mweb.tools.TemplateLink(data.data, json));
        case _:
            // NOOP
        }
        return res;
    }
}

class Main {
    public static function main()
    {
        haxe.Log.trace = function (msg, ?pos) Sys.stderr().writeString('${pos.fileName}:${pos.lineNumber}: $msg\n');
        var d = new mweb.Dispatcher<RouteReturn>(neko.Web);
        var res = d.dispatch(new Root());
        mweb.tools.HttpWriter.fromWeb(neko.Web).writeResponse(res);
    }
}

