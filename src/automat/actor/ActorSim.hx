package automat.actor;

import automat.sim.SimEvent;
import automat.sim.SimEvent.SimEventType;

class ActorSim {

	public static inline function tryFallDown(a:IActor):Bool {
		// trace("tryFallDown");
		if ( a.freeDown() ) {			
			a.goDown();
			a.isMove = true;
			var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
			a.grid.setSimEvent(e, 4);
			return true;
		}
		else if (a.freeLeftDown(true)) {
			a.goLeftDown();
			a.isMove = true;
			var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
			a.grid.setSimEvent(e, 4);
			return true;
		}
		else if (a.freeRightDown(true)) {
			a.goRightDown();
			a.isMove = true;
			var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
			a.grid.setSimEvent(e, 4);
			return true;
		}
		else return false;
	}
	public static inline function tryFallDownLeft(a:IActor):Bool {return false;}
	public static inline function tryFallDownRight(a:IActor):Bool {return false;}


	// TODO: also for some of "init-event"
	public static inline function onAddToGrid(a:IActor) {
		trace("onAddToGrid");
		// tryFallDown(a);
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