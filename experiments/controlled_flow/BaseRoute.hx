import mweb.*;
import mweb.tools.*;

class BaseRoute extends Route<HttpResponse<Dynamic>> {
    public function any()
    {
        return HttpResponse.fromContent(new TemplateLink({ data : "Hello" }, function (x) return x.data));
    }
    
    public function user(id:Int)
    {
    }
}

