package assets;

import haxe.iterators.ArrayIterator;

@:publicFields enum abstract TileID(Int) from Int {
    <!--(for tile in tmpl_tiles)-->
    var $!tile["name"]!$;
    <!--(end)-->
    public static var names = [<!--(for tile in tmpl_tiles)-->"$!tile['name']!$",<!--(end)-->];
    @:from static public function fromString(s:String):TileID return names.indexOf(s);
    public static function iterator() return new IntIterator(0,$!len(tmpl_tiles)!$);
}

@:publicFields enum abstract AnimID(Int) from Int {
    <!--(for anim in tmpl_all_anims)-->
    var $!anim!$;
    <!--(end)-->
    public static var names = [<!--(for anim in tmpl_all_anims)-->"$!anim!$",<!--(end)-->];
    @:from static public function fromString(s:String):AnimID return names.indexOf(s);
    public static function iterator() return new IntIterator(0,$!len(tmpl_all_anims)!$);
}

<!--(for tile in tmpl_tiles)-->
@:publicFields class $!tile["name"].capitalize()!$ implements Tile {
    inline function new () {};
    var sheet(get, never):Int; inline function get_sheet() return $!tile["sheetIndex"]!$;
    inline function anim(id:AnimID):Anim {
        return switch(id) {
            <!--(for anim in tile["tmpl_anims"])-->
            case $!anim["name"]!$: new Anim($!anim["start"]!$, $!anim["end"]!$);
            <!--(end)-->
            default: throw("Error, $!tile['name'].capitalize()!$ don't have this animation"); null;
        }
    }
    #! THIS COULD BE BETTER WITHOUT A FOR LOOP i am think (^_^) !#
    var animID:Array<AnimID> = [<!--(for anim in tile["tmpl_anims"])-->$!anim["name"]!$,<!--(end)-->];
}
<!--(end)-->

class $!haxeClass!$ {
    public static var sheets:Array<Sheet> = [
        <!--(for sheet in tmpl_sheets)-->
        new Sheet("$!sheet['pathName']!$", $!sheet['width']!$, $!sheet['height']!$, $!sheet['gap']!$, $!sheet['tilesX']!$, $!sheet['tilesY']!$),
        <!--(end)-->
    ];

    public inline static function tile(id:TileID):Tile {
        return switch(id) {
            <!--(for tile in tmpl_tiles)-->
            case $!tile["name"]!$: new $!tile["name"].capitalize()!$();
            <!--(end)-->
            default:  throw("Error, no tile for this ID"); null;
        }
    }
}

