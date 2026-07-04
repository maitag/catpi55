package util;

import lime.app.Application;

import util.Pos;
// import Pos.xy as P;

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


	}
	
}

