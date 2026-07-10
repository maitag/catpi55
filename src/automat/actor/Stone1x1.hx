package automat.actor;

import automat.Cell.CellType;

import util.Pos;

@:build(automat.actor.Actor.build("
|#|
")) class Stone1x1 implements IActor {

	public var type(get, never):ActorType; inline function get_type() return ActorType.STONE1x1;

	public var name:String;

	

	// TODO: let write this better or also by macrofication!
	// public var blockedCellType:Int = 1<<CellType.METAL;
	public var blockedCellType:Int = 1<<CellType.EARTH | 1<<CellType.METAL;
	// to store one more CellType
	// public var blockedCellType:Int = (1<<(CellType.EARTH-1))|(1<<(CellType.METAL-1));

	public function new(name:String) {
		this.name = name;
		// super();
	}

  
}