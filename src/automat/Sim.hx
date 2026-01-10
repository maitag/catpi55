package automat;

class Sim {


	public static inline function init() {
			
	}


	public static inline function step(grid:Grid, action:Action) {

		switch (action.type) {

			case CELL_MOVE: trace(action);

			case CELL_EMPTY: {
				trace(action);

				// trigger the above Actor and give position:
				// grid.getActor(above!!!).simEmptyBelow(position)
				// if (is not null-actor) 

			}

			// TODO

		};
		
	}



}