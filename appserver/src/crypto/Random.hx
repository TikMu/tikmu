package crypto;

import crypto.random.LinuxRandom;
import haxe.io.Bytes;

class Random {
	static function fake(bytes):String
	{
		var b = Bytes.alloc(bytes);
		for (i in 0...bytes)
			b.set(i, Std.random(256));
		return b.toHex();
	}

	public static function salt(bytes:Int):String
	{
#if tikmu_fake_random
		return fake(bytes);
#else
		return LinuxRandom.urandom().read(bytes).toHex();
#end
	}

	public static function sid(bytes:Int):String
	{
#if tikmu_fake_random
		return fake(bytes);
#else
		return LinuxRandom.urandom().read(bytes).toHex();
#end
	}
}

