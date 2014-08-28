import croxit.geo.Location;
import croxit.geo.LocationError;

class Geo
{
	static var needsInit = false;
	static var hasData:Bool;

	public static function init(precisionMagnitude=-1)
	{
		Location.update.bindVoid(onData);
		Location.error.bind(onError);

		//Location.distanceFilterMeters = 0.0;
		Location.precisionMagnitudeMeters = precisionMagnitude;
		Location.startMonitoring();
	}

	private static function onData()
	{
		hasData = true;
		trace('hasData',Location.getLatest());
	}

	private static function onError(err:LocationError)
	{
		switch(err)
		{
			case ECustom(e):
				needsInit = true;
				if (hasData)
					throw ("Erro de GPS: " + e);
			case EDeniedByUser:
				needsInit = true;
				throw ("Você precisa autorizar este aplicativo para usar o GPS!");
			case ELocationUnknown:
				//if (hasData)
					//Routes.alert("Localização não encon");
			default:
		}
		hasData = false;
	}

	public static function check():Void
	{
		if (needsInit)
		{
			needsInit = false;
			Location.startMonitoring();
		}
	}
}
