package db;
import sys.db.Types;
import sys.db.Object;

class Location extends Object
{
	public var id:SId;
	public var lat:SFloat;
	public var lon:SFloat;
	public var prettyName:SString<255>;

	override public function toString()
	{
		return prettyName;
	}
}
