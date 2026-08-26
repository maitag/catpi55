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

	public static function tryFallDown(a:IActor):Bool {
		var delay:Int = 2;
		
		// trace("tryFallDown");

		if ( a.freeDown() ) {			
			a.goDown(delay);
			a.isMove = true;
			var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
			a.grid.setSimEvent(e, delay);
			startNeighborMove(a);
			return true;
		}
		// shuffle:
		if (Math.random() > 0.5) {
			if (a.freeLeftDown(true)) {
				a.goLeftDown(delay);
				a.isMove = true;
				var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
				a.grid.setSimEvent(e, delay);
				startNeighborMove(a);
				return true;
			}
			if (a.freeRightDown(true)) {
				a.goRightDown(delay);
				a.isMove = true;
				var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
				a.grid.setSimEvent(e, delay);
				startNeighborMove(a);
				return true;
			}
		} 
		else {
			if (a.freeRightDown(true)) {
				a.goRightDown(delay);
				a.isMove = true;
				var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
				a.grid.setSimEvent(e, delay);
				startNeighborMove(a);
				return true;
			}
			if (a.freeLeftDown(true)) {
				a.goLeftDown(delay);
				a.isMove = true;
				var e = new SimEvent(SimEventType.ACTOR_AFTER_MOVE, a.gridKey);
				a.grid.setSimEvent(e, delay);
				startNeighborMove(a);
				return true;
			}
		}
		return false;
	}

	// TODO
	public static inline function tryFallDownLeft(a:IActor):Bool {return false;}
	public static inline function tryFallDownRight(a:IActor):Bool {return false;}

	public static inline function startNeighborMove(a:IActor) {

		for (freeCell in a.freeCellsAfterMove) {
			// upper first
			if (Math.random() > 0.5)
				for (dx in [0, -1, 1]) _startNeighborMove(a, freeCell.x+dx, freeCell.y-1);
			else for (dx in [0, 1, -1]) _startNeighborMove(a, freeCell.x+dx, freeCell.y-1);
			if (Math.random() > 0.5)
				for (dx in [-1, 1]) _startNeighborMove(a, freeCell.x+dx, freeCell.y);
			else for (dx in [1, -1]) _startNeighborMove(a, freeCell.x+dx, freeCell.y);
			
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
			neighborActor.grid.setSimEvent(e, 1);
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

		a.tryFallDown();
	}
}