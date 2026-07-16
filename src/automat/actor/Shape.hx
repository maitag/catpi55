package automat.actor;

import automat.Cell;
import automat.Cell.CellActor;

import util.BitGrid;
import util.Pos;
import util.Pos.xy as P;


// optimized shapes without macro:
// class ShapeRect {
	// TODO
// }
// class Shape1x1 {
	// TODO
// }

class Shape {

	static inline function _addToGridFromTo(pos:Pos, xOff:Int, yOff:Int, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int, grid:Grid, actorKey:CellActor, shape:BitGrid)	{
		var originXOffset:Int = shape.originXOffset;
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				if (shape.get(x,y)) grid.setCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff), actorKey, y == 0 && x == originXOffset);
	}

	public static inline function addToGrid(a:IActor, grid:Grid, pos:Pos, shape:BitGrid, syncToView:Bool = true) {
		a.grid = grid;
		a.pos = pos;
		a.gridKey = grid.actors.add(a);
		if ( pos.x + shape.width < Grid.WIDTH ) {
			if ( pos.y + shape.height < Grid.HEIGHT) {
				_addToGridFromTo(pos, 0, 0, 0, shape.width, 0, shape.height, a.grid, a.gridKey, shape); // root grid
			}
			else {
				_addToGridFromTo(pos, 0, 0, 0, shape.width, 0, pos.y + shape.height - Grid.HEIGHT, a.grid, a.gridKey, shape); // root grid
				a.gridKeyB = a.grid.bottom.actors.add(a);
				_addToGridFromTo(pos, 0, Grid.HEIGHT, 0, shape.width, pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, a.gridKeyB, shape); // bottom
			}
		}
		else {
			a.gridKeyR = a.grid.right.actors.add(a);
			if ( pos.y + shape.height < Grid.HEIGHT ) {
				_addToGridFromTo(pos, 0, 0, 0, pos.x + shape.width - Grid.WIDTH, 0, shape.height, a.grid, a.gridKey, shape); // root grid
				_addToGridFromTo(pos, Grid.WIDTH, 0, pos.x + shape.width - Grid.WIDTH, shape.width, 0, shape.height, a.grid.right, a.gridKeyR, shape); // right
			}
			else {
				_addToGridFromTo(pos, 0, 0, 0, pos.x + shape.width - Grid.WIDTH, 0, pos.y + shape.height - Grid.HEIGHT, a.grid, a.gridKey, shape); // root grid
				_addToGridFromTo(pos, Grid.WIDTH, 0, pos.x + shape.width - Grid.WIDTH, shape.width, 0, pos.y + shape.height - Grid.HEIGHT, a.grid.right, a.gridKeyR, shape); // right
				a.gridKeyB = a.grid.bottom.actors.add(a);
				_addToGridFromTo(pos, 0, Grid.HEIGHT, 0, pos.x + shape.width - Grid.WIDTH, pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, a.gridKeyB, shape); // bottom
				a.gridKeyRB = a.grid.rightBottom.actors.add(a);
				_addToGridFromTo(pos, Grid.WIDTH, Grid.HEIGHT, pos.x + shape.width - Grid.WIDTH, shape.width, pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.rightBottom, a.gridKeyRB, shape); // rightBottom
			}
		}

		// trigger actor-add to the origin corresponding grid and its views
		if (syncToView) {
			if (pos.x + shape.originXOffset < Grid.WIDTH) grid.viewsActorAdd(a, a.gridKey, a.pos.x + shape.originXOffset);
			else grid.right.viewsActorAdd(a, a.gridKeyR, (a.pos.x + shape.originXOffset) % Grid.WIDTH);
		}
	}

	static inline function _removeFromGrid(pos:Pos, xOff:Int, yOff:Int, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int, grid:Grid, shape:BitGrid) {
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				if (shape.get(x,y)) grid.delCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff));
	}

	public static inline function removeFromGrid(a:IActor, shape:BitGrid, syncToView:Bool = true) {
		if ( a.pos.x + shape.width < Grid.WIDTH ) {
			if ( a.pos.y + shape.height < Grid.HEIGHT) {
				_removeFromGrid(a.pos, 0, 0, 0, shape.width, 0, shape.height, a.grid, shape); // root grid
			}
			else {
				_removeFromGrid(a.pos, 0, 0, 0, shape.width, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid, shape); // root grid
				_removeFromGrid(a.pos, 0, Grid.HEIGHT, 0, shape.width, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, shape); // bottom
				a.grid.bottom.actors.del(a.gridKeyB); a.gridKeyB = -1;
			}
		}
		else {
			if ( a.pos.y + shape.height < Grid.HEIGHT ) {
				_removeFromGrid(a.pos, 0, 0, 0, a.pos.x + shape.width - Grid.WIDTH, 0, shape.height, a.grid, shape); // root grid
				_removeFromGrid(a.pos, Grid.WIDTH, 0, a.pos.x + shape.width - Grid.WIDTH, shape.width, 0, shape.height, a.grid.right, shape); // right
			}
			else {
				_removeFromGrid(a.pos, 0, 0, 0, a.pos.x + shape.width - Grid.WIDTH, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid, shape); // root grid
				_removeFromGrid(a.pos, Grid.WIDTH, 0, a.pos.x + shape.width - Grid.WIDTH, shape.width, 0, a.pos.y + shape.height - Grid.HEIGHT, a.grid.right, shape); // right
				_removeFromGrid(a.pos, 0, Grid.HEIGHT, 0, a.pos.x + shape.width - Grid.WIDTH, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.bottom, shape); // bottom
				_removeFromGrid(a.pos, Grid.WIDTH, Grid.HEIGHT, a.pos.x + shape.width - Grid.WIDTH, shape.width, a.pos.y + shape.height - Grid.HEIGHT, shape.height, a.grid.rightBottom, shape); // rightBottom
				a.grid.bottom.actors.del(a.gridKeyB); a.gridKeyB = -1;
				a.grid.rightBottom.actors.del(a.gridKeyRB); a.gridKeyRB = -1;
			}
			a.grid.right.actors.del(a.gridKeyR); a.gridKeyR = -1;
		}
		a.grid.actors.del(a.gridKey); a.gridKey = -1;
		a.grid = null;

		// trigger actor-remove to the origin corresponding grid and its views
		if (syncToView) {
			if (a.pos.x + shape.originXOffset < Grid.WIDTH) a.grid.viewsActorRemove(a, a.gridKey, a.pos.x + shape.originXOffset);
			else a.grid.right.viewsActorRemove(a, a.gridKeyR, (a.pos.x + shape.originXOffset) % Grid.WIDTH);
		}
	}

	public static function isFitIntoGrid(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		for (y in 0...shape.height)
			for (x in 0...shape.width)
				if (shape.get(x,y) && _blocked(grid.getCellAtOffset( pos, x, y ), blockedCellType)) return false;
		return true;
	}

	static inline function _blocked(cell:Cell, blockedCellType:Int):Bool {
		return (1<<cell.type & blockedCellType > 0 || cell.hasActor || cell.isTabu); // to store one more CellType: return (1<<(cell.type-1) & blockedCellType > 0 || cell.isTabu || cell.hasActor);
	}
	
	public static function _isFreeSide(xOff:Int, yOff:Int, grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid) {
		for (y in 0...shape.height)
			for (x in 0...shape.width)
				if ( shape.get(x,y) && ((x+xOff)<0 || (x+xOff)>=shape.width || (y+yOff)<0 || (y+yOff)>=shape.height || !shape.get(x+xOff,y+yOff)) && _blocked(grid.getCellAtOffset( pos, x+xOff, y+yOff), blockedCellType)) return false;
		return true;
	}

	public static function freeLeft(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide(-1, 0, grid, pos, blockedCellType, shape );
	}
	public static function freeRight(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 1, 0, grid, pos, blockedCellType, shape );
	}
	public static function freeUp(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 0,-1, grid, pos, blockedCellType, shape );
	}
	public static function freeDown(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 0, 1, grid, pos, blockedCellType, shape );
	}
	public static function freeLeftUp(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide(-1,-1, grid, pos, blockedCellType, shape );
	}
	public static function freeLeftDown(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide(-1, 1, grid, pos, blockedCellType, shape );
	}
	public static function freeRightUp(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 1,-1, grid, pos, blockedCellType, shape );
	}
	public static function freeRightDown(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 1, 1, grid, pos, blockedCellType, shape );
	}


	// Optimization: keep the actor key while remove and adding again
	public static function goLeft(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.x == 0) addToGrid(a, g.left, P(Grid.WIDTH - 1, a.pos.y), shape, false);
		else addToGrid(a, g, P(a.pos.x-1, a.pos.y), shape, false);

		// sync to view after move
		// TODO: only if actor is "inside", so handle this case (or if it "goes in/out") into GridView.hx
		if (a.pos.x + shape.originXOffset == Grid.WIDTH) g.viewsActorToGridLeft(a.gridKeyR, a.gridKey);
		g.viewsActorGoLeft(a.gridKey);
		
	}
	public static function goRight(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.x == Grid.WIDTH - 1) addToGrid(a, g.right, P(0, a.pos.y), shape, false);
		else addToGrid(a, g, P(a.pos.x+1, a.pos.y), shape, false);
	}
	public static function goUp(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.y == 0) addToGrid(a, g.top, P(a.pos.x, Grid.HEIGHT - 1), shape, false);
		else addToGrid(a, g, P(a.pos.x, a.pos.y-1), shape, false);
	}
	public static function goDown(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.bottom, P(a.pos.x, 0), shape, false);
		else addToGrid(a, g, P(a.pos.x, a.pos.y+1), shape, false);
	}
	public static function goLeftUp(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.x == 0 && a.pos.y == 0) addToGrid(a, g.leftTop, P(Grid.WIDTH - 1, Grid.HEIGHT - 1), shape, false);
		else if (a.pos.x == 0) addToGrid(a, g.left, P(Grid.WIDTH - 1, a.pos.y-1), shape, false);
		else if (a.pos.y == 0) addToGrid(a, g.top, P(a.pos.x-1, Grid.HEIGHT - 1), shape, false);
		else addToGrid(a, g, P(a.pos.x-1, a.pos.y-1), shape, false);
	}
	public static function goLeftDown(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.x == 0 && a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.leftBottom, P(Grid.WIDTH - 1, 0), shape, false);
		else if (a.pos.x == 0) addToGrid(a, g.left, P(Grid.WIDTH - 1, a.pos.y+1), shape, false);
		else if (a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.bottom, P(a.pos.x-1, 0), shape, false);
		else addToGrid(a, g, P(a.pos.x-1, a.pos.y+1), shape, false);
	}
	public static function goRightUp(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.x == Grid.WIDTH - 1 && a.pos.y == 0) addToGrid(a, g.rightTop, P(0, Grid.HEIGHT - 1), shape, false);
		else if (a.pos.x == Grid.WIDTH - 1) addToGrid(a, g.right, P(0, a.pos.y-1), shape, false);
		else if (a.pos.y == 0) addToGrid(a, g.bottom, P(a.pos.x+1, Grid.HEIGHT - 1), shape, false);
		else addToGrid(a, g, P(a.pos.x+1, a.pos.y-1), shape, false);
	}
	public static function goRightDown(a:IActor, shape:BitGrid) {
		var g = a.grid; removeFromGrid(a, shape, false);
		if (a.pos.x == Grid.WIDTH - 1 && a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.rightBottom, P(0, 0), shape, false);
		else if (a.pos.x == Grid.WIDTH - 1) addToGrid(a, g.left, P(0, a.pos.y+1), shape, false);
		else if (a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.bottom, P(a.pos.x+1, 0), shape, false);
		else addToGrid(a, g, P(a.pos.x+1, a.pos.y+1), shape, false);
	}


	// TODO: function to get the cell-offsets to one side
		// or to let iterate about them by a given function !
}
