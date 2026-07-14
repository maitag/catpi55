package automat.actor;

class ActorSim {

	public static inline function tryFallDown(a:IActor):Bool {
		trace("tryFallDown");
		if ( a.freeDown() ) {
			// TODO: update View !
			a.goDown();
			// isMove = true;
			// TODO: set Sim Event -> ACTOR_AFTER_MOVE

			return true;
		}

		return false;

	}
	public static inline function tryFallDownLeft(a:IActor):Bool {return false;}
	public static inline function tryFallDownRight(a:IActor):Bool {return false;}

	// TODO: grid-swapping -> gridView index-swapping to !



	public static inline function onAddToGrid(a:IActor) {
		trace("onAddToGrid");
		// TODO: add actor to View !
		// tryFallDown(a);
	}

	public static inline function onAfterMove(a:IActor) {
		trace("onAfterMove");
		// isMove = false;

		// TODO: check the cells that was getting empty after move
		// loop throught them and check:
		//    a) if cell is empty (no other still get into that place while iterating)
		//    b) trigger an actor not twice
		//          by check actors "isMoving"-flag AND
		//          by store the already-checked in a map to not trigger double (.clear afterwards) 
		// 1) the upper ones
		// 2) the left and right upper outsides
	}
}