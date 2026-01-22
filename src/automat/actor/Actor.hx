package automat.actor;

import automat.Cell.CellType;
import util.BitGrid;

@:build(automat.actor.Shape.ShapeMacro.build("
| # |
|###|
| # |
")) class Actor implements IActor {

	public var name:String;

	public var pos:Pos;
	// public var type:ActorType;


	public var grid:Grid = null; // not inside any grid at instantiation
	public var gridKey:Int = -1;
	public var gridKeyR:Int = -1;
	public var gridKeyB:Int = -1;
	public var gridKeyRB:Int = -1;
	

	// TODO: let write this better or also by macrofication!
	// public var blockedCellType:Int = 1<<CellType.METAL;
	public var blockedCellType:Int = 1<<CellType.EARTH | 1<<CellType.METAL;
	// to store one more CellType
	// public var blockedCellType:Int = (1<<(CellType.EARTH-1))|(1<<(CellType.METAL-1));

	public function new(name:String) {
		this.name = name;
	}

  
}