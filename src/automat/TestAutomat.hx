package automat;

import haxe.Timer;
import automat.Cell.CellActor;
import util.BitUtil;
import lime.app.Application;

import util.BitGrid;

import automat.actor.Actor;
import automat.actor.Shape;


import automat.Pos.xy as P;

class TestAutomat extends Application {


	public function new() {
		super();
		
		
		// -------- test Pos ----------
		/*
		trace(Pos.xMax, Pos.yMax);
		var p = new Pos(36,4);
		trace("pos:",p.x,p.y);
		p = Pos.xy(4,5);
		trace("pos:",p.x,p.y);
		
		trace("pos:", P(23, 42) );
		*/

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

		// -------- test BitGrid ----------
		/*
		var bitGrid:BitGrid = [
			"#  #  #   #",
			"#  #   # # ",
			"####    #  ",
			"#  #   # # ",
			"#  #  #   #",
		];		
		// bitGrid.set(0,0, false);
		// bitGrid.set(1,0);
		trace("\n"+bitGrid, bitGrid.width, bitGrid.height, bitGrid.hasGap());

		var bitGrid:BitGrid = "
			|                             |
			|   #  #   ##   #   #  ####   |
			|   #  #  #  #   # #   #      |
			|   ####  ####    #    ####   |
			|   #  #  #  #   # #   #      |
			|   #  #  #  #  #   #  ####   |
			|                             |
		";
		trace("\n"+bitGrid, bitGrid.width, bitGrid.height, bitGrid.hasGap());
		*/


		/*
		// -------- grid testdata ----------
		var grid = createTestGrid(TESTGRID);
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

		var grid = createTestGrid("
##############
#            #
E            #
#            #
#            #
#            #
##############
");
		trace("Grid.WIDTH " + Grid.WIDTH,"Grid.HEIGHT " + Grid.HEIGHT);
		trace("CellActor.MAX_ACTORS " + CellActor.MAX_ACTORS,"CellActor.bits " + CellActor.bits);
		
		trace("---adding Alice---");
		var alice = new Actor("Alice");
		var p = P(1,1);
		if (alice.isFitIntoGrid(grid, p)) {
			alice.addToGrid(grid, p);
			trace("isFreeLeft Alice", alice.isFreeLeft());
			trace("isFreeRight Alice", alice.isFreeRight());
			trace("isFreeTop Alice", alice.isFreeTop());
			trace("isFreeBottom Alice", alice.isFreeBottom());
		}

		trace("---adding Bob---");
		var bob = new Actor("Bob");
		var p = P(2,3);
		if (bob.isFitIntoGrid(grid, p)) {
			bob.addToGrid(grid, p);
			trace("isFreeLeft Bob", bob.isFreeLeft());
			trace("isFreeRight Bob", bob.isFreeRight());
			trace("isFreeTop Bob", bob.isFreeTop());
			trace("isFreeBottom Bob", bob.isFreeBottom());
		}

		trace("isFreeRight Alice", alice.isFreeRight());
		trace("isFreeBottom Alice", alice.isFreeBottom());
		
		trace("isFreeLeftTop Bob", bob.isFreeLeftTop());
		trace("isFreeLeftBottom Bob", bob.isFreeLeftBottom());
		trace("isFreeRightTop Bob", bob.isFreeRightTop());
		trace("isFreeRightBottom Bob", bob.isFreeRightBottom());
		
		
		traceGrid(grid, 16, 8);
		
		bob.removeFromGrid();
		bob.addToGrid(grid, P(10,3));
		

		traceGrid(grid, 16, 8);
		if (bob.isFreeLeft()) bob.moveLeft();
		traceGrid(grid, 16, 8);
		
		var f;
		f = ()-> {
			var p = bob.pos;
			p.x -= 1;
			if ( bob.isFreeLeft() ) {
				bob.moveLeft();
				traceGrid(grid, 16, 8, true);
				Timer.delay(f, 1000);
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


	// ----------------------------------------------------------------
	// ----------------------------------------------------------------
	// ----------------------------------------------------------------

	public static function traceGrid(grid:Grid, w:Int=Grid.WIDTH, h:Int=Grid.HEIGHT, clear=false) {
		var s = "\n";
		for (y in 0...h) {
			for (x in 0...w) {
				var cell = grid.get(P(x,y));
				if (cell.hasActor) s += cell.actor;
				else {
					s += switch(cell.type) {
						case TABU: "X";
						case AIR: " ";
						case WOOD: ".";
						case METAL: "#";
						case EARTH: "E";
						case ROCK: "R";
						case WATER: "^";
						case MILK: "m";
						case PISS: "p";
						default: " ";
					}
				}
			}
			s += "\n";
		}
		if (clear) Sys.command("clear");
		trace(s);
	}
	
	public static function createTestGrid(testGrid:String):Grid {
		var grid = new Grid();

		testGrid = ~/^\n+/g.replace(~/\n+$/g.replace(testGrid, ""), "");
		var a = ~/\n/g.split(testGrid);
		var longestLine:Int = 0;
		for (s in a) if (s.length>longestLine) longestLine = s.length;
		
		for (y in 0...a.length) {
			for (x in 0...a[y].length) {
				var c = a[y].charAt(x);
				switch (c) {
					case "X": grid.set( P(x,y), new Cell(TABU) );
					case " ": grid.set( P(x,y), new Cell(AIR) );
					case ".": grid.set( P(x,y), new Cell(WOOD) );
					case "#": grid.set( P(x,y), new Cell(METAL) );
					case "E": grid.set( P(x,y), new Cell(EARTH) );
					case "R": grid.set( P(x,y), new Cell(ROCK) );
					case "^": grid.set( P(x,y), new Cell(WATER)  );
					case "m": grid.set( P(x,y), new Cell(MILK)  );
					case "p": grid.set( P(x,y), new Cell(PISS)  );
					
					default: throw('unknown "$c" in TESTGRID');
				}
			}
			for (x in a[y].length...longestLine) grid.set( P(x,y), new Cell(AIR) );
			for (x in longestLine...Grid.WIDTH) grid.set( P(x,y), new Cell(TABU) );
		}
		for (y in a.length...Grid.HEIGHT)
			for (x in 0...Grid.WIDTH) grid.set( P(x,y), new Cell(TABU) );

		return grid;
	}


	public static inline var TESTGRID64x64:String = "
################################################################
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..EEEE....EEEEEE..............................................#
#...................................E^^^^E.....................#
#.................RR................E^^^^E.....................#
#..................RR...............E^^^^E.....................#
#...................R...............E^^^^E.....................#
#...................RRR.............E^^^^E.....................#
#...................RRRRREEEEEEEEEEEEEEEEE.....................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
#..............................................................#
################################################################
";

}
