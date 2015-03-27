package crypto;

#if !windows
import crypto.random.LinuxRandom;
#else
import haxe.io.Bytes;
#end

class Random {
    public static function salt(bytes:Int):String
    {
		#if !windows
        return LinuxRandom.urandom().read(bytes).toHex();
		#else
		var b = Bytes.alloc(bytes);
		for (i in 0...bytes)
			b.set(i, Std.random(255));
		return b.toHex();
		#end
    }

    public static function sid(bytes:Int):String
    {
		#if !windows
        return LinuxRandom.urandom().read(bytes).toHex();
		#else
		var b = Bytes.alloc(bytes);
		for (i in 0...bytes)
			b.set(i, Std.random(256));
		return b.toHex();
		#end
    }
}

