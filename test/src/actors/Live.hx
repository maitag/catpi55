package actors;

import catpi.automat.actor.IActor;
import catpi.automat.Cell.CellType;

import catpi.util.Pos;

@:build(catpi.automat.actor.Actor.build("
|#   # #   # ###|
|#   #  # #  ## |
|### #   #   ###|
")) class Live implements IActor {

	public var type(get, never):ActorType; inline function get_type() return LIVE;
	
	public var name:String;


	// TODO: let write this better or also by macrofication!
	// public var blockedCellType:Int = 1<<CellType.METAL;
	public var blockedCellType:Int = 1<<CellType.EARTH | 1<<CellType.METAL;
	// to store one more CellType
	// public var blockedCellType:Int = (1<<(CellType.EARTH-1))|(1<<(CellType.METAL-1));

	public function new(name:String) {
		this.name = name;
	}

  
}