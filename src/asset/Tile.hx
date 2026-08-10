package asset;

@:publicFields class Tile {
	function new() {}
    var sheet(get, never):Int; inline function get_sheet() return 0;
    var animID(get, never):Array<Int>; inline function get_animID() return [];
    inline function anim(id:Int):Anim return null;
}