package automat;

import lime.app.Application;

class Test extends Application {


	public function new() {
		super();
		
		
		// -------- test cell ----------

		trace(Pos.xMax, Pos.yMax);

		var c0 = new Cell();
		trace(c0);
		c0.type= EARTH;
		trace(c0.isSolid);
		c0.type= WATER;
		trace(c0.isSolid);
		trace(c0.isFluid);

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
