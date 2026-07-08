package automat.actor;

import automat.Cell.CellType;

import util.Pos;

@:build(automat.actor.Actor.build("
|#|
")) class Stone1x2 implements IActor {

	public var type(get, never):ActorType; inline function get_type() return STONE1x2;

	public var name:String;

	public var pos:Pos;
	// public var type:ActorType;


	public var grid:Grid = null; // not inside any grid at instantiation

	// viktor keys (-1 if not have into grid or neighbours)
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