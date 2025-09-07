package automat;

import lime.app.Application;

class Test extends Application {


	public function new() {
		super();
		
		/*
		// -------- test Pos ----------
		trace(Pos.xMax, Pos.yMax);
		*/



		// -------- test cell ----------
		var c0 = new Cell(AIR,42);
		trace(c0);
		trace("TYPE:", c0.type);
		trace("PARAM:",c0.param);
		trace("cell and type isSolid:", c0.isSolid, c0.type.isSolid);
		trace("cell and type isFluid:",c0.isFluid, c0.type.isFluid);
		trace("cell and type isGas:",c0.isGas, c0.type.isGas);


		/*
		// -------- test grid ----------
		var grid = new Grid();

		trace(Grid.WIDTH, Grid.HEIGHT);
		
		grid.set(new Pos(0,0), c0);
		grid.set(new Pos(0,1), 42);

		trace(grid.get(new Pos(0,0)));
		trace(grid.get(new Pos(0,1)));


		grid.step();
		*/
	}
}
