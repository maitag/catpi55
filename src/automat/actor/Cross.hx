package automat.actor;

import automat.Cell.CellType;
import peote.view.math.Rnd;
import automat.sim.SimEvent;

import util.Pos;

@:build(automat.actor.Actor.build("
| # |
|###|
| # |
")) class Cross implements IActor {

	public var type(get, never):ActorType; inline function get_type() return ActorType.CROSS;

	public var name:String;
	

	// TODO: let write this better or also by macrofication!
	// public var blockedCellType:Int = 1<<CellType.METAL;
	public var blockedCellType:Int = 1<<CellType.EARTH | 1<<CellType.METAL;
	// to store one more CellType
	// public var blockedCellType:Int = (1<<(CellType.EARTH-1))|(1<<(CellType.METAL-1));

	public function new(name:String="",grid:Grid, pos:Pos) {
		this.name = name;
		addToGrid(grid, pos);

		// start custom moving
		onAfterMove();
	}

	// ----- custom movement ----
	var direction:Int = 10;
	var delay:Int = 2;

	public function onAfterMove() { // <- overwrite default function
		// trace("onAfterMove",name,gridKey);
		// onAfterMove_SUPER(); // <- call super-function
		
		var i:Int = 7;
		switch(direction) {
			case 0: if (freeLeft()) goLeft() else direction = Rnd.intLimit(0,i);
			case 1: if (freeRight()) goRight() else direction = Rnd.intLimit(0,i);
			case 2: if (freeUp()) goUp() else direction = Rnd.intLimit(0,i);
			case 3: if (freeDown()) goDown() else direction = Rnd.intLimit(0,i);
			case 4: if (freeLeftUp()) goLeftUp() else direction = Rnd.intLimit(0,i);
			case 5: if (freeLeftDown()) goLeftDown() else direction = Rnd.intLimit(0,i);
			case 6: if (freeRightUp()) goRightUp() else direction = Rnd.intLimit(0,i);
			case 7: if (freeRightDown()) goRightDown() else direction = Rnd.intLimit(0,i);
			default: direction = Rnd.intLimit(0,i);
		}
		
		
		var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, gridKey);
		// trace(name, e);
		grid.setSimEvent(e, delay);
		
	}
  
}