package crypto;

import crypto.random.LinuxRandom;

class Random {
    public static function salt(bytes:Int):String
    {
        return LinuxRandom.urandom().read(bytes).toHex();
    }
}

