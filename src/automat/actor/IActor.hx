package automat.actor;

interface IActor {
	public var name:String;
	public var pos:Pos;
	public var grid:Grid;
	public function isFitIntoGrid(grid:Grid, pos:Int):Bool;
	public function isFreeLeft():Bool;
	// public function moveLeft():Bool;
}
