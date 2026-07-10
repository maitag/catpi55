package automat.actor;

class ActorSim {

	public static inline function tryFallDown(a:IActor):Bool {
		trace("tryFallDown");
		if ( a.freeDown() ) {
			// TODO: update View !
			a.goDown();

			// TODO: set Sim Event with cells that gets empty afterwards

			return true;
		}

		return false;

	}




	public static inline function onAddToGrid(a:IActor) {
		trace("onAddToGrid");
	}

	public static inline function onAfterMove(a:IActor) {
		trace("onAfterMove");
	}
}