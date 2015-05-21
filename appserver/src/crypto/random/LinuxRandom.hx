package crypto.random;

import haxe.io.Input;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileSeek;

// TODO check /dev/*random behavior when called from multiple processes/threads
class LinuxRandom {
    static var _random:Input;
    static var _urandom:Input;

    static function safeRead(path, binary:Bool)
    {
        var platform = Sys.systemName();
        if (platform != "Linux")
            throw 'Unsupported platform for LinuxRandom: $platform';
        return File.read(path, binary);
    }

    static function readProcStatus(file:String):Int
    {
        var f = safeRead('/proc/sys/kernel/random/$file', false);
        var a = f.readLine();
        f.close();
        return Std.parseInt(a);
    }

    public static function random():Input
    {
        if (_random == null)
            _random = safeRead("/dev/random", true);
        return _random;
    }

    public static function urandom():Input
    {
        if (_urandom == null)
            _urandom = safeRead("/dev/urandom", true);
        return _urandom;
    }

    public static function availableEntropy():Int
    {
        return readProcStatus("entropy_avail");
    }

    public static function poolSize():Int
    {
        return readProcStatus("poolsize");
    }
}

