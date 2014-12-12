package db.helper;
import haxe.macro.Expr;
import haxe.macro.Context;
import haxe.macro.Context.*;
import haxe.macro.Type;

import sys.FileSystem.*;

using haxe.macro.ExprTools;
using StringTools;

class ManagersBuild
{
	public static function build():Array<Field>
	{
		var cls = Context.getLocalClass().get();
		var pack = cls.pack.join('.');
		var managers = [];
		var dir = pack.replace('.','/');
		for (cp in getClassPath())
		{
			var dir = cp + '/' + dir;
			if (exists(dir) && isDirectory(dir))
			{
				for (file in readDirectory(dir))
				{
					if (file.endsWith('.hx') && file != 'Managers.hx')
					{
						var name = file.substr(0,file.length-3);
						managers.push({ name:name.toLowerCase(), path:TPath({ pack: pack.split('.'), name:name }) });
					}
				}
			}
		}

		var pos = Context.currentPos();
		var fields = [ for (man in managers) {
			name: man.name,
			access:[APublic],
			kind: FieldType.FVar({ var path = man.path; macro : org.mongodb.Manager<$path>; }),
			pos: pos
		} ];
		fields.push({ name: 'new', access:[APublic], kind: FFun({
			args: [{ name:'mongo', type: macro : org.mongodb.Database }],
			ret: null,
			expr: { expr: EBlock([for (man in managers) {
				var name = man.name,
						type = man.path;
				macro this.$name = new org.mongodb.Manager<$type>(mongo.$name);
			}]), pos: pos }
		}), pos: pos });
		return fields;
	}
}
