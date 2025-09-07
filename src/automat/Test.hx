package automat;

import lime.app.Application;

class Test extends Application {


	public function new() {
		super();
		
		// -------- test Pos ----------
		trace(Pos.xMax, Pos.yMax);
		

		// -------- test cell ----------
		var c0 = new Cell(WATER);
		trace(c0);
		trace(c0.type);
		trace(c0.isSolid);
		trace(c0.isFluid);
		trace(c0.isGas);

		// -------- test grid ----------
		var grid = new Grid();

		trace(Grid.WIDTH, Grid.HEIGHT);
		
		grid.set(new Pos(0,0), c0);
		grid.set(new Pos(0,1), 42);

		trace(grid.get(new Pos(0,0)));
		trace(grid.get(new Pos(0,1)));


		grid.step();
		
	}
}
