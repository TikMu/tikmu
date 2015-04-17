import mweb.*;
import mweb.tools.*;
import neko.Web;

class Context {
    var toJson:HttpResponse<Dynamic>->HttpResponse<Dynamic>;
    var toHaxe:HttpResponse<Dynamic>->HttpResponse<Dynamic>;

    var route:Route<Dynamic>;
    var request:HttpRequest;
    var dispatcher:Dispatcher<Dynamic>;

    function serialize(res:HttpResponse<Dynamic>, serializer)
    {
        switch (res.response) {
        case Content(data):
            res.replaceContent(new TemplateLink(data.data, serializer));
        case _:
            // NOOP
        }
        return res;
    }

    function strip(res:HttpResponse<Dynamic>)
    {
        return switch (res.response) {
        case Content(data):
            return data.data;
        case _:
            null;
        }
    }

    public function dispatch()
    {
        return dispatcher.dispatch(route);
    }

    public function new(databases)
    {
        toJson = serialize.bind(_, haxe.Json.stringify.bind(_, null, null));
        toHaxe = serialize.bind(_, haxe.Serializer.run);

        var baseRoute = new BaseRoute();
        route = Route.anon({
            any : baseRoute,
            api : Route.anon({
                v1 : Route.anon({
                    any : baseRoute.map(toJson),
                    json : baseRoute.map(toJson),  
                    haxe : baseRoute.map(toHaxe)
                }),
                "1" : Route.anon({
                    any : baseRoute.map(toJson),
                    json : baseRoute.map(toJson),  
                    haxe : baseRoute.map(toHaxe)
                })
            }),
            strip : baseRoute.map(strip)
        });

        request = Web;
        dispatcher = new Dispatcher(request);
    }
}

