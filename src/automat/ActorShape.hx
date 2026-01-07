package automat;

import automat.Cell.CellActor;
import util.BitGrid;

import automat.Pos.xy as P;


class ActorShape {

	static function moveDown(grid:Grid, actor:CellActor, pos:Pos):Bool {
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