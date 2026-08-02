package automat.actor;

import peote.view.math.Rnd;
import automat.Cell.CellType;
import automat.sim.SimEvent;
import automat.sim.SimEvent.SimEventType;

import util.Pos;

@:build(automat.actor.Actor.build("
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
		addToGrid(grid, pos);

		// start custom moving
		onAfterMove();
	}


	// ----- custom movement ----
	var direction:Int = 1;
	var delay:Int = 3;
	
	
	public function onAfterMove() { // <- overwrite default function
		// trace("onAfterMove",name,gridKey);
		// onAfterMove_SUPER(); // <- call super-function
		
		if (Rnd.int(50)==0) direction = Rnd.intLimit(0,3);
		switch(direction) {
			case 0: if (freeLeft()) goLeft() else direction = Rnd.intLimit(0,3);
			case 1: if (freeRight()) goRight() else direction = Rnd.intLimit(0,3);
			case 2: if (freeUp()) goUp() else direction = Rnd.intLimit(0,3);
			case 3: if (freeDown()) goDown() else direction = Rnd.intLimit(0,3);
			default: 
		}
		
		
		var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, gridKey);
		// trace(name, e);
		grid.setSimEvent(e, delay);
		
	}



}