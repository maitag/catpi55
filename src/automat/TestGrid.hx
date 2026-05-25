package automat;

import automat.Pos.xy as P;

class TestGrid
{
	public static function createTestGrid(testGrid:String):Grid {
		var grid = new Grid();

		testGrid = ~/^\r?\n+/g.replace(~/\r?\n+$/g.replace(testGrid, ""), "");
		var a = ~/\r?\n/g.split(testGrid);
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

	public static function traceGrid(grid:Grid, w:Int=Grid.WIDTH, h:Int=Grid.HEIGHT, clear=false) {
		var s = "\n";
		for (y in 0...h) {
			for (x in 0...w) {
				var cell = grid.get(P(x,y));
				if (cell.hasActor) {
					if (cell.isOrigin) s += "O";
					else s += cell.actor;
				}
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
		#if html5
		//js.html.Console.clear();
		#else
		if (clear) Sys.command("clear");
		#end


		trace(s);
	}
	
	public static function createTestGrid3x3():Grid {
		var grid11 = createTestGrid(TESTGRID_1);
		var grid12 = createTestGrid(TESTGRID_2);
		var grid13 = createTestGrid(TESTGRID_3);

		var grid21 = createTestGrid(TESTGRID_1);
		var grid22 = createTestGrid(TESTGRID_2);
		var grid23 = createTestGrid(TESTGRID_3);

		var grid31 = createTestGrid(TESTGRID_1);
		var grid32 = createTestGrid(TESTGRID_2);
		var grid33 = createTestGrid(TESTGRID_3);

		knotGridsLeftRight([grid11, grid12, grid13]);
		knotGridsLeftRight([grid21, grid22, grid23]);
		knotGridsLeftRight([grid31, grid32, grid33]);

		knotGridsTopBottom([grid11, grid21, grid31]);
		knotGridsTopBottom([grid12, grid22, grid32]);
		knotGridsTopBottom([grid13, grid23, grid33]);

		return grid11;
	}

	public static function knotGridsLeftRight(grids:Array<Grid>) {
		for (i in 0...grids.length) {
			if (i!=0) grids[i].left = grids[i-1];
			if (i!=grids.length-1) grids[i].right = grids[i+1];
		}
	}
	public static function knotGridsTopBottom(grids:Array<Grid>) {
		for (i in 0...grids.length) {
			if (i!=0) grids[i].top = grids[i-1];
			if (i!=grids.length-1) grids[i].bottom = grids[i+1];
		}
	}


	public static inline var TESTGRID64x64:String = "
################################################################
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#..EEEE....EEEEEE..............................................#
#...................................E^^^^E.....................#
#.................RR................E^^^^E.....................#
#..................RR...............E^^^^E.....................#
#...................R...............E^^^^E.....................#
#...................RRR.............E^^^^E.....................#
#...................RRRRREEEEEEEEEEEEEEEEE.....................#
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
################################################################
";

public static inline var TESTGRID_1:String = "
################################################################
#                                                              #
#         EEEE                                                 #
#       EEEEEE                                                 #
#      EEE EEE .m                                              #
#          EEE                                                 #
#          EEE                                                 #
#          EEE                                                 #
#        EEEEEEE                                               #
#        EEEEEEE                                               #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
################################################################
";

public static inline var TESTGRID_2:String = "
################################################################
#                                                              #
#         EEEEE                                                #
#       EEEEEEEE                                               #
#      EEE    EEE                                              #
#            EEE                                               #
#           EEE                                                #
#         EEEE                                                 #
#       EEEEEEEEE                                              #
#       EEEEEEEEE                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
################################################################
";
public static inline var TESTGRID_3:String = "
################################################################
#                                                              #
#         EEEE                                                 #
#       EEEEEEEE                                               #
#      EEE    EEE                                              #
#             EEE                                              #
#          EEEEE                                               #
#          EEEEE                                               #
#             EEE                                              #
#      EEE   EEE                                               #
#       EEEEEEE                                                #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
#                                                              #
################################################################
";

}