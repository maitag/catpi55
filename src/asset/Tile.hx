package asset;

class Tile {
	public function new() {}
    public var sheet(get, never):Int; inline function get_sheet() return 0;
    public var animID(get, never):Array<Int>; inline function get_animID() return [];
    public inline function anim(id:Int):Anim return null;
}