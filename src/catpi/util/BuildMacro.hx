package catpi.util;

#if macro
import haxe.macro.Compiler;

class BuildMacro {

	// -------- globally adding some metadata --------
	public static function setMetas(packageNames:String, metaNames:String)
	{
		packageNames = ~/ /g.replace(packageNames, "");trace(packageNames);
		metaNames = ~/ /g.replace(metaNames, "");

		var metas:Array<String> = metaNames.split(",");
		var targetPackages:Array<String> = packageNames.split(",");
		
		// loop through and apply metadata to each package
		for (pack in targetPackages) {
			for (meta in metas) {
				meta = "@:" + meta;				
				trace('adding $meta to package: $pack');
				Compiler.addGlobalMetadata(pack, meta, true, true, false);
			}
		}
	}
}
#end