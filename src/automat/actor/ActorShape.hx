package automat.actor;

import automat.Cell.CellActor;
import util.BitGrid;

import automat.Pos.xy as P;
/*
@:publicFields
class Shape {

	static var shape_01:BitGrid = [
		"##",
		"# ",
	];

	static var bitGrid:BitGrid = [
		"#  #   ##   #   #  ####",
		"#  #  #  #   # #   #   ",
		"####  ####    #    ####",
		"#  #  #  #   # #   #   ",
		"#  #  #  #  #   #  ####",
	];


}

class Shape_01 {
	var s = [
		"##",
		"# ",
	];

}
*/
/*
import automat.ActorShape.ShapeMacro.build as shape
@:build(shape("
| # |
|###|
| # |
") class Cross_3x3 {}
*/
// more shapes !
// ...


class ActorShape {

	static function isFreeLeft(grid:Grid, actor:CellActor, pos:Pos, shape:BitGrid):Bool {
		for (y in 0...shape.height) {
			var x:Int = 0;
			while (x < shape.width && !shape.get(x,y)) x++;
			if (x < shape.width) {
				// if (grid.getActor( P(pos.x + x-1, pos.y + y) ) > 0) return false;
			}
		}
		return true;
	}

	static function moveLeft(grid:Grid, actor:CellActor, pos:Pos, shape:BitGrid) {
		// TODO

		return true;
	}

	
/*
	static inline function CheckUp_1(g:Grid, x:Int, y:Int) {
		if (g.getActor( P(x,y-1) ) == 0) return true;
		else return false;
	}

	static inline function CheckUp_01(g:Grid, x:Int, y:Int) {
		if (g.getActor( P(x+1,y-1) ) == 0) return true;
		else return false;
	}

	static inline function CheckUp_11(g:Grid, x:Int, y:Int) {
		if (g.getActor( P(x,y-1) ) == 0 && g.getActor( P(x+1,y-1) ) == 0) return true;
		else return false;
	}

	static inline function CheckUp_101(g:Grid, x:Int, y:Int) {
		if (g.getActor( P(x,y-1) ) == 0 && g.getActor( P(x+2,y-1) ) == 0) return true;
		else return false;
	}

	static inline function CheckUp_011(g:Grid, x:Int, y:Int) {
		if (g.getActor( P(x+1,y-1) ) == 0 && g.getActor( P(x+2,y-1) ) == 0) return true;
		else return false;
	}

	static inline function CheckUp_111(g:Grid, x:Int, y:Int) {
		if (g.getActor( P(x,y-1) ) == 0 && g.getActor( P(x+1,y-1) ) == 0 && g.getActor( P(x+2,y-1) ) == 0) return true;
		else return false;
	}

	static inline function MoveUp_11(g:Grid, shapeNum:Int, x:Int, y:Int) {
		g.setActor( P(x,y-1), shapeNum ); g.setActor( P(x+1,y-1), shapeNum+1 );
		g.setActor( P(x,y), 0 ); g.setActor( P(x+1,y), 0 );
	}
	static inline function MoveUp_11_11(g:Grid, shapeNum:Int, x:Int, y:Int) {
		g.setActor( P(x,y-1), shapeNum ); g.setActor( P(x+1,y-1), shapeNum+1 );
		g.setActor( P(x,y), shapeNum+2 ); g.setActor( P(x+1,y), shapeNum+3 );
		g.setActor( P(x,y+1),0 ); g.setActor( P(x+1,y+1), 0 );
	}

*/


}