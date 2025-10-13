package automat;

class BaseActor {

	static inline function CheckUp_1(g:Grid, x:Int, y:Int) {
		if (g.get( new Pos(x,y-1) ).actor == 0) return true;
		else return false;
	}

	static inline function CheckUp_01(g:Grid, x:Int, y:Int) {
		if (g.get( new Pos(x+1,y-1) ).actor == 0) return true;
		else return false;
	}

	static inline function CheckUp_11(g:Grid, x:Int, y:Int) {
		if (g.get( new Pos(x,y-1) ).actor == 0 && g.get( new Pos(x+1,y-1) ).actor == 0) return true;
		else return false;
	}

	static inline function CheckUp_101(g:Grid, x:Int, y:Int) {
		if (g.get( new Pos(x,y-1) ).actor == 0 && g.get( new Pos(x+2,y-1) ).actor == 0) return true;
		else return false;
	}

	static inline function CheckUp_011(g:Grid, x:Int, y:Int) {
		if (g.get( new Pos(x+1,y-1) ).actor == 0 && g.get( new Pos(x+2,y-1) ).actor == 0) return true;
		else return false;
	}

	static inline function CheckUp_111(g:Grid, x:Int, y:Int) {
		if (g.get( new Pos(x,y-1) ).actor == 0 && g.get( new Pos(x+1,y-1) ).actor == 0 && g.get( new Pos(x+2,y-1) ).actor == 0) return true;
		else return false;
	}



	static inline function MoveUp_11(g:Grid, shapeNum:Int, x:Int, y:Int) {
		g.setActor( new Pos(x,y-1) , shapeNum ); g.setActor( new Pos(x+1,y-1) , shapeNum+1 );
		g.setActor( new Pos(x,y) , 0 ); g.setActor( new Pos(x+1,y) , 0 );
	}
	static inline function MoveUp_11_11(g:Grid, shapeNum:Int, x:Int, y:Int) {
		g.setActor( new Pos(x,y-1) , shapeNum ); g.setActor( new Pos(x+1,y-1) , shapeNum+1 );
		g.setActor( new Pos(x,y) , shapeNum+2 ); g.setActor( new Pos(x+1,y) , shapeNum+3 );
		g.setActor( new Pos(x,y+1) , 0 ); g.setActor( new Pos(x+1,y+1) , 0 );
	}


	static inline var zweierPos:Int = 20;
	static inline var zweierTiles_11:Int = 4;
	static inline var zweierTiles_1_1:Int = 3;

	static inline var dreierPos:Int = 2 * (zweierTiles_11 + zweierTiles_1_1);
	static inline var dreierTiles_111:Int = 1;
	static inline var dreierTiles_1_1_1:Int = 1;
	static inline var dreierTiles_11_10:Int = 1;
	static inline var dreierTiles_11_01:Int = 1;
	static inline var dreierTiles_01_11:Int = 1;
	static inline var dreierTiles_10_11:Int = 1;

	static inline var viererPos:Int = 3 * (dreierTiles_111 + dreierTiles_1_1_1 + dreierTiles_11_10 + dreierTiles_11_01 + dreierTiles_01_11 + dreierTiles_10_11);
	static inline var viererTiles_11_11:Int = 5;

	static function moveDown(grid:Grid, pos:Pos, shapeNum:Int):Bool {
		// ...

		if (shapeNum>=dreierPos)
		{

		}

		return true;
	}
}