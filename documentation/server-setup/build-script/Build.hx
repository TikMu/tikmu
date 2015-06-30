/**
  Automated build recipe.

  Usage: haxe --run Build [commit] ...

  For each commit, this will create a .build-$commit directory above this git
  tree, install all dependencies locally and compile the appserver.

  A commit can be defined by any valid git reference, such as a partial hash, a
  tag or a branch; if no commit is specified, a reference to 'master' is
  assumed.
**/

import Sys.*;
import sys.FileSystem;
using StringTools;

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

class Build {

    static var libs = [
        LOfficial("hscript"),  // for erazor

        LOfficial("croxit-1"),
        LGit("mongodb", "https://github.com/jonasmalacofilho/mongo-haxe-driver.git", "managers"),
        LGit("mongodb-managers", "https://github.com/jonasmalacofilho/mongo-haxe-managers.git", "master", "lib"),
        LGit("geotools", "https://github.com/waneck/geotools.git"),
        LGit("mweb", "https://github.com/jonasmalacofilho/mweb.git", null, "src"),
        LGit("erazor", "https://github.com/waneck/erazor.git"),
    ];

    static function rmrf(path:String)
    {
        // this is fucking dangerous, considering path errors and escaping
        // issues...
        //
        // don't use this script with this unless you're brave and have nothing
        // to loose!  you have been warned.
        return command("rm", ["-rf", path]);
    }

    public static function build(baseDir:String, commit:String, buildDir:String)
    {
        baseDir = FileSystem.absolutePath(baseDir);
        buildDir = FileSystem.absolutePath(buildDir);

        setCwd(baseDir);  // make sure we start at someplace safe, otherwise git might fail

        println('Cloning "$baseDir" into build dir "$buildDir"');
        if (FileSystem.exists(buildDir) && FileSystem.isDirectory(buildDir)) {
            println("Deleting previous build directory");
            if (rmrf(buildDir) != 0)
                throw "Possibly dangerous rm error";
        }
        if (Git.clone(baseDir, buildDir) != 0)
            throw 'Git error while cloning';
        println('Changing current working dir to "$buildDir"');
        setCwd(buildDir);
        println('Checking out commit "$commit"');
        if (Git.checkout(commit) != 0)
            throw 'Git error while checking out';

        println("Fetching haxelibs and other dependencies");
        if (Haxelib.localSetup() != 0)
            throw "Haxelib error while setting up locally";
        for (lib in libs) {
            switch (lib) {
            case LOfficial(lib):
                println('Installing official "$lib" haxelib');
            case LGit(lib, repo, ref, _):
                println('Installing "$lib" from ' + (ref != null ? '"$repo@$ref"' : '"$repo"'));
            }
            Haxelib.smartInstall(lib);
        }

        println("Building the appserver");
        println('Moving into "./appserver"');
        setCwd("appserver");
        if (Haxelib.linkLocalSetup("..") != 0)  // can't use local haxelib from a subdirectory
            throw "Error while linking to another local haxelib setup";
        println('Running haxe');
        if (command("haxe", ["build.hxml"]) != 0)
            throw 'Compilation failed';

        // build other stuff
        // println('Moving back to "$buildDir"');
        // setCwd(buildDir);

        println('Moving back to "$baseDir"');
        setCwd(baseDir);
    }

    static function main()
    {
        // TODO make this usable from any directory in the current git repo

        var baseDir = FileSystem.absolutePath("./../../../");
        println('Current working dir is $baseDir');

        var commits = args();
        if (commits.length == 0)
            commits = ["master"];
        println('Building commits $commits');

        for (commit in commits) {
            var buildDir = FileSystem.absolutePath(baseDir + '/../.build-$commit');
            build(baseDir, commit, buildDir);
            setCwd(baseDir);
        }
    }

}

