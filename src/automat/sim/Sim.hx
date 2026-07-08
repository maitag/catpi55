package automat.sim;

class Sim {
	public static inline function init() {			
	}

	public static inline function step(grid:Grid, event:SimEvent) {

		switch (event.type) {

			case CELL_MOVE: trace(event);

			case CELL_EMPTY: {
				trace(event);

				// trigger the above Actor and give position:
				// grid.getActor(above!!!).simEmptyBelow(position)
				// if (is not null-actor) 

			}

			case ACTOR_AFTER_MOVE: {
				trace(event);
			}

			// TODO
			default: throw("unknown SIM event");

		};
		
	}



}