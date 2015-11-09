import haxe.io.*;

class SimpleProcess extends sys.io.Process {
	static function readBytes(src:haxe.io.Input, dst:BytesBuffer, len:Int):Bool
	{
		var b = Bytes.alloc(len);
		try {
			var n = src.readBytes(b, 0, len);
			if (n > 0)
				dst.addBytes(b, 0, n);
			return false;
		} catch (e:haxe.io.Eof) {}
		return true;
	}

	public function simpleRun(?out, ?err) : { exitCode:Int, stdout:Bytes, stderr:Bytes }
	{
		if (out == null)
			out = new BytesBuffer();
		if (err == null)
			err = new BytesBuffer();

		var outEof = false, errEof = false;
		while (!outEof || !errEof) {
			outEof = readBytes(stdout, out, 4096);
			errEof = readBytes(stderr, err, 1024);
		}

		var exit = exitCode();
		this.close();

		return {
			exitCode : exit,
			stdout : out.getBytes(),
			stderr : err.getBytes()
		}
	}
}

