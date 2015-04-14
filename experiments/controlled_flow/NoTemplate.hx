import mweb.tools.TemplateLink;

abstract NoTemplate(String) {
    inline static function self(s:String)
    {
        return s;
    }

    @:to public static inline function link(t)
    {
        return new TemplateLink(t, self);
    }

    public inline function new(s:String)
    {
        this = s;
    }
}

