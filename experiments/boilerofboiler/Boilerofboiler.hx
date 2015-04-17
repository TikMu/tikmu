class Test
{
	public static function takeOffBoiler(_this : { ctx:Context })
	{
		_this.ctx.dispatcher.getRoute(User).takeOffBoiler().unwrap();
	}
}
