package;

import lime.app.Application;

import catpi.util.BitGrid;
import catpi.util.Pos;
import catpi.util.Maze
;
// import catpi.util.Pos.xy as P;

// import catpi.util.Pos.Pos8x8Neg;

class TestUtil extends Application {


	public function new() {
		super();
				
		// -------- test Pos ----------
		
		trace(Pos.xMax, Pos.yMax);
		var p = new Pos(36,4);
		trace("pos:",p.x,p.y);
		p = Pos.xy(4,5);
		trace("pos:",p.x,p.y);

		var p = new Pos(3,4);
		p.x-=1;
		p.y+=1;
		trace(p);
		
		// negative
		var pNeg = new Pos8x8Neg(-128, 127);
		// var pNeg = Pos8x8Neg.xy(1, 5);
		// pNeg.x = -128; pNeg.y = 128;
		trace("pNeg:", pNeg.x, pNeg.y);
		trace(Pos8x8Neg.xMin, Pos8x8Neg.xMax, Pos8x8Neg.yMin, Pos8x8Neg.yMax);
		
		// -------- test BitGrid ----------
		
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

		// -------- test Maze ----------

		var maze = new Maze(64, 64, 1234567);
		trace( "\n"+maze.toString() );

		var maze = new KruskalCellMerge(65, 65, 100, 1234567);
		trace( "\n"+maze.toString() );

	}
	
}

