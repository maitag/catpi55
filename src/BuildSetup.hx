package;

#if macro
import haxe.macro.Compiler;

class BuildSetup {
    public static function setup() {
        // Define all packages that require the metadata
        var targetPackages = [
            // "asset",
            "automat",
            // "render",
			// "util",
			// "view",
        ];
        
        // Loop through and apply metadata to each package
        for (pack in targetPackages) {
            trace('adding @:unreflective to: $pack');
            Compiler.addGlobalMetadata(pack, "@:unreflective", false, true, false);
        }
    }
}
#end