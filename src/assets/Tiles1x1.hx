package assets;

enum abstract Tiles1x1(Int) from Int to Int {
	var Brilliant = 5;
	var Cone = 2;
	var Cube = 0;
	var Diamond = 6;
	var Gem = 4;
	var Icosphere = 1;
	var Suzanne = 3;

	public static var fileName:String = "assets/tiles1x1.png";
	public static var width:Int = 128;
	public static var height:Int = 64;
	public static var tilesX:Int = 4;
	public static var tilesY:Int = 2;
	public static var tileWidth:Int = 32;
	public static var tileHeight:Int = 32;
	public static var gap:Int = 0;
}