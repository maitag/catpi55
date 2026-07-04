package automat;

import haxe.Timer;
import lime.app.Application;

import automat.Cell.CellActor;

import automat.actor.Actor;
import automat.actor.Haxe;
import automat.actor.Live;//<-

import automat.GridTestData;

import util.Pos.xy as P;

class TestAutomat extends Application {


	public function new() {
		super();
		
		// -------- test cell ----------
		/*
		var c0 = new Cell(WATER,42);
		c0.actor = 5;
		trace(c0);
		trace("TYPE:", (c0.type:Int));
		trace("PARAM:",(c0.param:Int));
		trace("cell and type isSolid:", c0.isSolid, c0.type.isSolid);
		trace("cell and type isFluid:",c0.isFluid, c0.type.isFluid);
		trace("cell and type isGas:",c0.isGas, c0.type.isGas);
		*/


		/*
		// -------- test grid ----------
		var grid = new Grid();

		trace(Grid.WIDTH, Grid.HEIGHT);
		
		var c0 = new Cell(WATER,42);
		grid.set(new Pos(0,0), c0);
		grid.set(new Pos(0,1), 42);

		trace(grid.get(new Pos(0,0)));
		trace(grid.get(new Pos(0,1)));
		*/


		/*
		// -------- grid testdata ----------
		var grid = GridTestData.create(GridTestData.TESTGRID);
		// trace(grid.get(new Pos(1,1)));

		grid.setAction(new Action(CELL_MOVE, new Pos(1,1)), 0); // immediadly
		grid.setAction(new Action(CELL_EMPTY, new Pos(3,4)), Grid.MAX_STEPS-1); // max delay time 

		// simmulate 10 timesteps
		for (i in 0...10) {
			trace('step $i');
			grid.step();
		}
		*/


		// -------- add/remove Actors ----------

		var grid = GridTestData.create("
################################
#                              #
#                              #
#                              #
E                              #
#                              #
#                              #
#                              #
#                              #
#                              #
#                              #
#                              #
#                              #
#    E                         #
#            EE              E #
################################
");
		trace("Grid.WIDTH " + Grid.WIDTH,"Grid.HEIGHT " + Grid.HEIGHT);
		trace("CellActor.MAX_ACTORS " + CellActor.MAX_ACTORS,"CellActor.bits " + CellActor.bits);
		/*
		trace("---adding Alice---");
		var alice = new Actor("Alice");
		var p = P(1,1);
		if (alice.isFitIntoGrid(grid, p)) {
			alice.addToGrid(grid, p);
			trace("freeLeft Alice", alice.freeLeft());
			trace("freeRight Alice", alice.freeRight());
			trace("freeUp Alice", alice.freeUp());
			trace("freeDown Alice", alice.freeDown());
		}

		trace("---adding Bob---");
		var bob = new Actor("Bob");
		var p = P(2,3);
		if (bob.isFitIntoGrid(grid, p)) {
			bob.addToGrid(grid, p);
			trace("freeLeft Bob", bob.freeLeft());
			trace("freeRight Bob", bob.freeRight());
			trace("freeUp Bob", bob.freeUp());
			trace("freeDown Bob", bob.freeDown());
		}

		trace("freeRight Alice", alice.freeRight());
		trace("freeDown Alice", alice.freeDown());
		
		trace("freeLeftUp Bob", bob.freeLeftUp());
		trace("freeLeftDown Bob", bob.freeLeftDown());
		trace("freeRightUp Bob", bob.freeRightUp());
		trace("freeRightDown Bob", bob.freeRightDown());
		
		
		traceGrid(grid, 16, 8);

		
		bob.removeFromGrid();
		bob.addToGrid(grid, P(12,0));
		traceGrid(grid, 32, 16);	

		var f;
		f = ()-> {
			if ( bob.freeDown() ) {
				bob.goDown();
				traceGrid(grid, 32, 16, true);
				Timer.delay(f, 1000);
			}
		}		
		f();
		*/
		
		var live = new Live("on shitball around The S u n STAR;)");
		live.addToGrid(grid, P(7,1));
		GridTestData.traceGrid(grid, 32, 16);
		var f;
		f = ()-> {
			if ( live.freeDown() ) {
				live.goDown();
				GridTestData.traceGrid(grid, 32, 16, true);
				Timer.delay(f, 1001); // night ,) 
			}
		}		
		f();


		// TIME for haxe now:
		var haxe = new Haxe("forever! \\o/");
		haxe.addToGrid(grid, P(3,5));
		GridTestData.traceGrid(grid, 32, 16);
		var f;
		f = ()-> {
			if ( haxe.freeDown() ) {
				haxe.goDown();
				GridTestData.traceGrid(grid, 32, 16, true);
				Timer.delay(f, 900);
			}
		}		
		f();





		// -------- benchmarks -------------
		/*var t = haxe.Timer.stamp();
		var i:Int = 0;
		while (i++ < 1000000) {
			bob.removeFromGrid();
			bob.addToGrid(grid, P(9,2));
		}
		trace( (haxe.Timer.stamp() - t) );*/

		
		
		

	}
	
}

