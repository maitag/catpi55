package automat.actor;

interface IActor {
	public var name:String;
	public var pos:Pos;
	public var grid:Grid;
	public var gridKey:Int;
	public var gridKeyR:Int;
	public var gridKeyB:Int;
	public var gridKeyRB:Int;
	public function addToGrid(grid:Grid, pos:Int):Void;
	public function removeFromGrid():Void;
	public function isFitIntoGrid(grid:Grid, pos:Int):Bool;
	public function isFreeXY(dx:Int, dy:Int):Bool;
	public function isFreeLeft():Bool;
	public function isFreeRight():Bool;
	public function isFreeTop():Bool;
	public function isFreeBottom():Bool;
	// public function moveLeft():Bool;
}
