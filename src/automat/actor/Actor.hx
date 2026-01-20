package automat.actor;

import automat.Cell.CellType;
import util.BitGrid;

@:build(automat.actor.Shape.ShapeMacro.build("
| # |
|###|
| # |
")) class Actor implements IActor {

	// manually shaping (same what macro generates into "delegate" mode)
	/*
	public var width:Int = 3;
	public var height:Int = 3;
	public var shapeBitGrid:BitGrid = [
		" # ",
		"###",
		" #",
	];
	public function addToGrid(grid:Grid, pos:Int) return Shape.addToGrid(this, grid, pos, shapeBitGrid);
	public function isFitIntoGrid(grid:Grid, pos:Int):Bool return Shape.isFitIntoGrid(this, grid, pos, blockedCellType, shapeBitGrid);
	public function isFreeLeft():Bool return Shape.isFreeLeft(this, grid, pos, blockedCellType, shapeBitGrid);
	//...
	public function moveLeft() Shape.moveLeft(this, shapeBitGrid);
	//...
	*/

	public var name:String;

	public var pos:Pos;
	// public var type:ActorType;


	public var grid:Grid = null; // not inside any grid at instantiation
	

	// TODO: let write this better or also by macrofication!
	// public var blockedCellType:Int = 1<<CellType.METAL;
	public var blockedCellType:Int = 1<<CellType.EARTH | 1<<CellType.METAL;
	// to store one more CellType
	// public var blockedCellType:Int = (1<<(CellType.EARTH-1))|(1<<(CellType.METAL-1));

	public function new(name:String) {
		this.name = name;
	}

  
}