package actors;

import peote.view.math.Rnd;

import catpi.automat.Grid;
import catpi.automat.actor.IActor;
import catpi.automat.Cell.CellType;
import catpi.automat.sim.SimEvent;
import catpi.automat.sim.SimEventType;

import catpi.util.Pos;

@:build(catpi.automat.actor.Actor.build("
|##|
|##|
")) class Flixel implements IActor {

	public var type(get, never):ActorType; inline function get_type() return ActorType.FLIXEL;

	public var name:String;

	
	// TODO: let write this better or also by macrofication!
	// public var blockedCellType:Int = 1<<CellType.METAL;
	public var blockedCellType:Int = 1<<CellType.EARTH | 1<<CellType.METAL;
	// to store one more CellType
	// public var blockedCellType:Int = (1<<(CellType.EARTH-1))|(1<<(CellType.METAL-1));

	public function new(name:String="",grid:Grid, pos:Pos) {
		this.name=name;
		reactOnFreeNeighbor = false;
		addToGrid(grid, pos);

		// start custom moving
		onAfterMove();
	}


	// ----- custom movement ----
	var direction:Int = 1;
	var delay:Int = 1;
	
	
	public function onAfterMove() { // <- overwrite default function
		// trace("onAfterMove",name,gridKey);
		// onAfterMove_SUPER(); // <- call super-function
		
		var i:Int = 7;
		if (Rnd.int(50)==0) direction = Rnd.intLimit(0,i);
		switch(direction) {
			case 0: if (freeLeft()) goLeft(delay) else direction = Rnd.intLimit(0,i);
			case 1: if (freeRight()) goRight(delay) else direction = Rnd.intLimit(0,i);
			case 2: if (freeUp()) goUp(delay) else direction = Rnd.intLimit(0,i);
			case 3: if (freeDown()) goDown(delay) else direction = Rnd.intLimit(0,i);
			case 4: if (freeLeftUp()) goLeftUp(delay) else direction = Rnd.intLimit(0,i);
			case 5: if (freeLeftDown()) goLeftDown(delay) else direction = Rnd.intLimit(0,i);
			case 6: if (freeRightUp()) goRightUp(delay) else direction = Rnd.intLimit(0,i);
			case 7: if (freeRightDown()) goRightDown(delay) else direction = Rnd.intLimit(0,i);
			default: 
		}
					
		
		var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, gridKey);
		// trace(name, e);
		grid.setSimEvent(e, delay);
		
	}



}