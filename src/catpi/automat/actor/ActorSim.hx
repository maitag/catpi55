package catpi.automat.actor;

import catpi.automat.sim.SimEvent;
import catpi.automat.sim.SimEventType;
import catpi.util.Pos;

@:access(catpi.automat.actor)
class ActorSim {

	// TODO: also for some of "init-event"
	public static inline function onAddToGrid(a:IActor) {
		trace("onAddToGrid");
		// tryFallDown(a);
	}

	public static inline function tryFallDown(a:IActor):Bool {
		var delay:Int = 4;
		
		// trace("tryFallDown");
		if ( a.freeDown() ) {			
			a.goDown(delay);
			a.isMove = true;
			var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
			a.grid.setSimEvent(e, delay);
			startNeighborMove(a);
			return true;
		}
		else if (a.freeLeftDown(true)) {
			a.goLeftDown(delay);
			a.isMove = true;
			var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
			a.grid.setSimEvent(e, delay);
			startNeighborMove(a);
			return true;
		}
		else if (a.freeRightDown(true)) {
			a.goRightDown(delay);
			a.isMove = true;
			var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
			a.grid.setSimEvent(e, delay);
			startNeighborMove(a);
			return true;
		}
		else return false;
	}

	// TODO
	public static inline function tryFallDownLeft(a:IActor):Bool {return false;}
	public static inline function tryFallDownRight(a:IActor):Bool {return false;}

	public static inline function startNeighborMove(a:IActor) {

		for (freeCell in a.freeCellsAfterMove) {
			// trace(freeCell);
			// upper first
			for (dx in [0, -1, 1]) _startNeighborMove(a, freeCell.x+dx, freeCell.y-1);
			for (dx in [-1, 1]) _startNeighborMove(a, freeCell.x+dx, freeCell.y);
			
		}
		a.freeCellsAfterMove = [];

	}
	public static inline function _startNeighborMove(a:IActor, x:Int, y:Int) {
		var neighborActor = a.grid.getActorAtOffset(x, y);
		if (neighborActor != null && neighborActor != a && neighborActor.reactOnFreeNeighbor
			&& !neighborActor.isStartMove && !neighborActor.isMove) {
			// trace("trigger onStartMove:", neighborActor.name);
			var e = new SimEvent(SimEventType.ACTOR_START_MOVE, neighborActor.gridKey);
			neighborActor.isStartMove = true;
			neighborActor.grid.setSimEvent(e, 2);
		}
	}

	public static inline function onStartMove(a:IActor) {
		// trace("onStartMove");
		a.isStartMove = false;
		a.tryFallDown();
		
	}

	public static inline function onAfterMove(a:IActor) {
		// trace("onAfterMove");
		a.isMove = false;

		// TODO: check the cells that was getting empty after move
		// loop throught and check:
		//    a) if cell is empty (no other still get into that place while iterating)
		//    b) trigger an actor not twice
		//          by check actors "isMoving"-flag AND
		//          by store the already-checked in a map to not trigger double (.clear afterwards) 
		// 1) the upper ones
		// 2) the left and right upper outsides
		// UNLOCK them if no one is movin inside(that will lock it again into future optimization)!

		// -> needs a shape-function-helper at first what gives all "shape-offsets" from one direction!!!!!!

		// some SIMPLE at FIRST :)
		a.tryFallDown();
	}
}