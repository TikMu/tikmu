/**
  Automated build recipe.

  Usage: haxe --run Build [haxe extra arguments]

  This will install all dependencies locally and compile the appserver.
**/

import Sys.*;
import haxe.io.*;
import sys.FileSystem;
import sys.io.File;
using StringTools;

typedef Define = {
	name : String,
	?value : String
}

enum LibSrc {
	LOfficial(lib:String);
	LGit(lib:String, repo:String, ?ref:String, ?src:String);
}

class Git {
	public static function clone(repo:String, ?path:String, ?branch:String, ?depth:Int)
	{
		var args = ["clone", "--recursive"];
		if (depth != null)
			args.concat(["--depth", Std.string(depth)]);
		if (branch != null)
			args.concat(["--branch", branch]);
		args.push(repo);
		if (path != null)
			args.push(path);
		return command("git", args);
	}

	public static function checkout(ref:String)
		return command("git", ["checkout", ref]);
}

class Haxelib {
	public static function install(lib:String)
		return command("haxelib", ["install", lib]);

	public static function dev(lib:String, path:String)
		return command("haxelib", ["dev", lib, path]);

	public static function git(lib:String, repo:String)
		return command("haxelib", ["git", lib, repo]);

	public static function localSetup()
		return command("haxelib", ["newrepo"]);

	public static function linkLocalSetup(path:String)
		return command("ln", ["--symbolic", '$path/.haxelib', "."]);

	public static function smartInstall(src:LibSrc)
	{
		switch (src) {
		case LOfficial(lib):
			if (install(lib) != 0)
				throw 'Haxelib error while installing';
		case LGit(lib, repo, ref, src):
			// don't use `haxelib git` even when it would suffice to avoid local+dependency issues
			var cwd = getCwd();
			var p = './.dev-haxelibs/$lib';
			if (Git.clone(repo, p) != 0)
				throw 'Git error while clonning "$repo"';
			setCwd(p);
			if (ref != null && Git.checkout(ref) != 0)
				throw 'Git error while checking out "$ref"';
			setCwd(cwd);  // can't use local haxelib from a subdirectory
			var ps = src != null ? p + "/" + src : p;
			if (dev(lib, ps) != 0)
				throw 'Haxelib error while setting up a dev path';
		}
	}

}

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

	public function simpleRun() : { exitCode:Int, stdout:Bytes, stderr:Bytes }
	{
		var out = new BytesBuffer();
		var err = new BytesBuffer();

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

class Build {

	static var libs = [
		LOfficial("hscript"),  // for erazor

		LOfficial("croxit-1"),
		LOfficial("tink_core"), // for mweb
		LGit("mongodb", "https://github.com/jonasmalacofilho/mongo-haxe-driver.git", "managers"),
		LGit("mongodb-managers", "https://github.com/jonasmalacofilho/mongo-haxe-managers.git", "master", "lib"),
		LGit("geotools", "https://github.com/waneck/geotools.git"),
		LGit("mweb", "https://github.com/waneck/mweb.git"),
		LGit("erazor", "https://github.com/waneck/erazor.git"),
	];

	static function customTrace(msg:String, ?p:haxe.PosInfos) {
		if (p.customParams != null)
			msg = msg + ',' + p.customParams.join(',');
		var s = '${p.fileName}:${p.lineNumber}:  $msg\n';
		Sys.stderr().writeString(s);
	}

	static function rmrf(path:String)
	{
		// this is fucking dangerous, considering path errors and escaping
		// issues...
		//
		// don't use this script with this unless you're brave and have nothing
		// to loose!  you have been warned.
		return command("rm", ["-rf", path]);
	}

	static function build(haxeArgs:Array<String>)
	{
		trace("Fetching haxelibs and other dependencies");
		if (Haxelib.localSetup() != 0)
			throw "Haxelib error while setting up locally";
		for (lib in libs) {
			switch (lib) {
			case LOfficial(lib):
				trace('Installing official "$lib" haxelib');
			case LGit(lib, repo, ref, _):
				trace('Installing "$lib" from ' + (ref != null ? '"$repo@$ref"' : '"$repo"'));
			}
			Haxelib.smartInstall(lib);
		}

		trace("Building the appserver");
		trace('Moving into "./appserver"');
		setCwd("appserver");
		if (Haxelib.linkLocalSetup("..") != 0)	// can't use local haxelib from a subdirectory
			throw "Error while linking to another local haxelib setup";
		trace("Running haxe");
		var args = haxeArgs.concat(["build.hxml"]);
		var haxe = new SimpleProcess("haxe", args);
		var res = haxe.simpleRun();
		File.saveContent(".haxe.stdout", res.stdout.toString());
		File.saveContent(".haxe.stderr", res.stderr.toString());
		if (res.exitCode != 0)
			throw "Failed compilation";
	}

	public static function begin(baseDir:String, commit:String, buildDir:String, haxeArgs:Array<String>)
	{
		baseDir = FileSystem.absolutePath(baseDir);
		buildDir = FileSystem.absolutePath(buildDir);

		setCwd(baseDir);  // make sure we start at someplace safe, otherwise git might fail

		trace('Cloning "$baseDir" into build dir "$buildDir"');
		if (FileSystem.exists(buildDir) && FileSystem.isDirectory(buildDir)) {
			trace("Deleting previous build directory");
			if (rmrf(buildDir) != 0)
				throw "Possibly dangerous rm error";
		}
		if (Git.clone(baseDir, buildDir) != 0)
			throw 'Git error while cloning';
		trace('Changing current working dir to "$buildDir"');
		setCwd(buildDir);
		trace('Checking out commit "$commit"');
		if (Git.checkout(commit) != 0)
			throw 'Git error while checking out';

		trace("Running the checkout build recipe");
		if (command("haxe", ["--run", "Build"].concat(haxeArgs)) != 0)
			throw "Failed compilation";

		trace('Moving back to "$baseDir"');
		setCwd(baseDir);
	}

	static function main()
	{
		try {
			build(Sys.args());
		} catch (e:Dynamic) {
			trace('ERROR: $e');
			exit(-1);
		}
	}

}

