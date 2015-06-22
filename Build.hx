import Sys.*;
import sys.FileSystem;
using StringTools;

enum LibSrc {
    LOfficial(lib:String);
    LGit(lib:String, repo:String, ?ref:String);
}

class Git {
    public static function clone(repo:String, ?ref:String, ?depth:Int, ?path:String)
    {
        var args = ["clone", "--recursive"];
        if (depth != null)
            args.concat(["--depth", Std.string(depth)]);
        if (ref != null)
            args.concat(["--branch", ref]);
        args.push(repo);
        if (path != null)
            args.push(path);
        return command("git", args);
    }
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

    public static function smartInstall(src:LibSrc)
    {
        switch (src) {
        case LOfficial(lib):
            if (install(lib) != 0)
                throw 'Haxelib error while installing official $lib';
        case LGit(lib, repo, ref):
            // don't use `haxelib git` even when it would suffice to avoid local+dependency issues
            var p = './.dev-haxelibs/$lib';
            if (Git.clone(repo, ref, 1, p) != 0)
                throw 'Git error while clonning $repo';
            if (dev(lib, p) != 0)
                throw 'Haxelib error while setting up a dev path for $lib';
        }
    }

}

class Build {

    static var libs = [
        LOfficial("hscript"),  // dep for erazor

        LOfficial("croxit-1"),
        LGit("mongodb", "https://github.com/jonasmalacofilho/mongo-haxe-driver.git", "managers"),
        LGit("mongodb-managers", "https://github.com/jonasmalacofilho/mongo-haxe-managers.git", "master"),
        LGit("geotools", "https://github.com/waneck/geotools.git"),
        LGit("mweb", "https://github.com/jonasmalacofilho/mweb.git"),
        LGit("erazor", "https://github.com/waneck/erazor.git"),
    ];

    static function rmrf(path:String)
    {
        // this is fucking dangerous, considering path errors and escaping
        // issues...
        //
        // don't use this script with this unless you're brave and have nothing
        // to loose!  you have been warned.
        command("rm", ["-rf", path]);
    }

    static function main()
    {
        try {
            var baseDir = getCwd();
            println('Current working dir is $baseDir');

            var branches = args();
            if (branches.length == 0)
                branches = ["master"];
            println('Building branches $branches');

            for (br in branches) {
                var buildDir = '../.build-$br';
                println("Cloning into temp build dir");
                if (FileSystem.exists(buildDir) && FileSystem.isDirectory(buildDir)) {
                    println("Deleting previous build directory");
                    rmrf(buildDir);
                }
                Git.clone(".", "master", 1, buildDir);
                setCwd(buildDir);
                buildDir = getCwd();
                println('Working dir changed to $buildDir');

                println("Fetching haxelibs");
                Haxelib.localSetup();
                for (lib in libs)
                    Haxelib.smartInstall(lib);

                println("Building");
                setCwd("appserver");
                command("haxe", ["build.hxml"]);
                setCwd(buildDir);
                // build more subsystems

                setCwd(baseDir);
            }
        } catch (e:Dynamic) {
            println('Build error: $e');
        }
    }

}

