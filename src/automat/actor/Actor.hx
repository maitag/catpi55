package automat.actor;

import util.BitGrid;

@:build(automat.actor.Shape.ShapeMacro.build("
| # |
|###|
| # |
")) class Actor implements Shape.IActorShape {

	// manually shaping (same what macro generates into "delegate" mode)
	/*
	public var width:Int = 3;
	public var height:Int = 3;
	public var shapeBitGrid:BitGrid = [
		" # ",
		"###",
		" #",
	];
	public function isFreeLeft():Bool return Shape.isFreeLeft(grid, pos, shapeBitGrid);
	public function moveLeft() Shape.moveLeft(this, shapeBitGrid);
	//...
	*/


	public var pos:Pos;
	// public var type:ActorType;

	public var name:String;

	public var grid:Grid = null; // not inside any grid at instantiation
	
	public function new(name:String) {
		this.name = name;
	}

  
}