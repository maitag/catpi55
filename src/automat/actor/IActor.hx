package automat.actor;

interface IActor {
	public var name:String;
	public var pos:Pos;
	public var grid:Grid;
	public function addToGrid(grid:Grid, pos:Int):Void;
	public function isFitIntoGrid(grid:Grid, pos:Int):Bool;
	public function isFreeXY(dx:Int, dy:Int):Bool;
	public function isFreeLeft():Bool;
	public function isFreeRight():Bool;
	public function isFreeTop():Bool;
	public function isFreeBottom():Bool;
	// public function moveLeft():Bool;
}
