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

	public function freeLeft():Bool;
	public function freeRight():Bool;
	public function freeUp():Bool;
	public function freeDown():Bool;

	public function freeLeftUp():Bool;
	public function freeLeftDown():Bool;
	public function freeRightUp():Bool;
	public function freeRightDown():Bool;

	public function goLeft():Void;
	public function goRight():Void;
	public function goUp():Void;
	public function goDown():Void;

	public function goLeftUp():Void;
	public function goLeftDown():Void;
	public function goRightUp():Void;
	public function goRightDown():Void;

}
