package automat;

class Sim {


	public static inline function init() {
			
	}


	public static inline function step(grid:Grid, action:Action) {

		switch (action.type) {

			case CELL_MOVE: trace("move");

			case CELL_EMPTY: trace("gets empty");


			// TODO

		};
		
	}



}