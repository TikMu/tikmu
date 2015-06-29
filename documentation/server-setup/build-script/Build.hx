import Sys.*;
import sys.FileSystem;
using StringTools;

enum LibSrc {
    LOfficial(lib:String);
    LGit(lib:String, repo:String, ?ref:String);
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
    {
        return command("git", ["checkout", ref]);
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
            if (Git.clone(repo, p, ref, 1) != 0)
                throw 'Git error while clonning $repo';
            if (dev(lib, p) != 0)
                throw 'Haxelib error while setting up a dev path for $lib';
        }
    }

}

class Build {

    static var libs = [
        LOfficial("hscript"),  // for erazor

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

    public static function build(baseDir:String, commit:String, buildDir:String)
    {
        baseDir = FileSystem.absolutePath(baseDir);
        buildDir = FileSystem.absolutePath(buildDir);

        println('Cloning "$baseDir" into build dir "$buildDir"');
        if (FileSystem.exists(buildDir) && FileSystem.isDirectory(buildDir)) {
            println("Deleting previous build directory");
            rmrf(buildDir);
        }
        Git.clone(baseDir, buildDir);
        println('Changing current working dir to "$buildDir"');
        setCwd(buildDir);
        println('Checking out commit "$commit"');
        Git.checkout(commit);

        println("Fetching haxelibs and other dependencies");
        Haxelib.localSetup();
        for (lib in libs)
            Haxelib.smartInstall(lib);

        println("Building the appserver");
        println('Moving into "./appserver"');
        setCwd("appserver");
        command("haxe", ["build.hxml"]);

        // build other stuff
        // println('Moving back to "$buildDir"');
        // setCwd(buildDir);

        println('Moving back to "$baseDir"');
        setCwd(baseDir);
    }

    static function main()
    {
        try {
            var baseDir = FileSystem.absolutePath("./../../../");
            println('Current working dir is $baseDir');

            var commits = args();
            if (commits.length == 0)
                commits = ["master"];
            println('Building commits $commits');

            for (commit in commits) {
                var buildDir = FileSystem.absolutePath('../.build-$commit');
                build(baseDir, commit, buildDir);
                setCwd(baseDir);
            }
        } catch (e:Dynamic) {
            println('Build error: $e');
        }
    }

}

