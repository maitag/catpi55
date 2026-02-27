package assets;

import haxe.iterators.ArrayIterator;

@:publicFields enum abstract TileID(Int) from Int {
    var haxeLogo;
    var haxeCat;
    public static var names = ["haxeLogo","haxeCat",];
    @:from static public function fromString(s:String):TileID return names.indexOf(s);
    public static function iterator() return new IntIterator(0,2);
}

@:publicFields enum abstract AnimID(Int) from Int {
    var sphereRotate;
    var sphereToCubic;
    var cubicRotate;
    var cubicToHaxe;
    var default;
    public static var names = ["sphereRotate","sphereToCubic","cubicRotate","cubicToHaxe","default",];
    @:from static public function fromString(s:String):AnimID return names.indexOf(s);
    public static function iterator() return new IntIterator(0,5);
}

@:publicFields class Haxelogo implements Tile {
    inline function new () {};
    var sheet(get, never):Int; inline function get_sheet() return 0;
    inline function anim(id:AnimID):Anim {
        return switch(id) {
            case sphereRotate: new Anim(0, 31);
            case sphereToCubic: new Anim(32, 63);
            case cubicRotate: new Anim(64, 95);
            case cubicToHaxe: new Anim(96, 146);
            default: throw("Error, Haxelogo don't have this animation"); null;
        }
    }
    
    var animID:Array<AnimID> = [sphereRotate,sphereToCubic,cubicRotate,cubicToHaxe,];
}
@:publicFields class Haxecat implements Tile {
    inline function new () {};
    var sheet(get, never):Int; inline function get_sheet() return 0;
    inline function anim(id:AnimID):Anim {
        return switch(id) {
            case default: new Anim(147, 147);
            default: throw("Error, Haxecat don't have this animation"); null;
        }
    }
    
    var animID:Array<AnimID> = [default,];
}

class PipelineNew {
    public static var sheets:Array<Sheet> = [
        new Sheet("64x64.png", 64, 64, 0, 16, 10),
    ];

    public inline static function tile(id:TileID):Tile {
        return switch(id) {
            case haxeLogo: new Haxelogo();
            case haxeCat: new Haxecat();
            default:  throw("Error, no tile for this ID"); null;
        }
    }
}

