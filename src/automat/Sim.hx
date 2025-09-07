package automat;

class Sim {


	public static inline function init() {
			
	}


	public static inline function step(grid:Grid, action:Action) {

		switch (action.type) {

			case CELL_MOVE: trace("move", action.pos);

			case CELL_EMPTY: trace("gets empty", action.pos);


			// TODO

		};
		
	}



}