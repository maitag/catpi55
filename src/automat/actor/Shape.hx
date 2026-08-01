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
		// trace('ADD: shapeX:$xFrom-$xTo, shapeY:$yFrom-$yTo - x:${pos.x + xFrom - xOff}-${pos.x + xTo - xOff}, y:${pos.y + yFrom - yOff}-${pos.y + yTo - yOff}');
		var originXOffset:Int = shape.originXOffset;
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				if (shape.get(x,y)) grid.setCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff), actorKey, y == 0 && x == originXOffset);
	}

	public static inline function addToGrid(a:IActor, grid:Grid, pos:Pos, shape:BitGrid, syncToView:Bool, setKey:Int=-1, setKeyR:Int=-1, setKeyB:Int=-1, setKeyRB:Int=-1) {
		a.grid = grid;
		a.pos = pos;
		a.gridKey = (setKey==-1) ? grid.actors.add(a) : setKey;
		if ( pos.x + shape.width <= Grid.WIDTH ) {
			if ( pos.y + shape.height <= Grid.HEIGHT) {
				_addToGridFromTo(pos, 0, 0, 0, shape.width, 0, shape.height, a.grid, a.gridKey, shape); // root grid
			}
			else {
				_addToGridFromTo(pos, 0, 0, 0, shape.width, 0, Grid.HEIGHT - pos.y, a.grid, a.gridKey, shape); // root grid
				a.gridKeyB = (setKeyB==-1) ? a.grid.bottom.actors.add(a) : setKeyB;
				_addToGridFromTo(pos, 0, Grid.HEIGHT, 0, shape.width, Grid.HEIGHT - pos.y, shape.height, a.grid.bottom, a.gridKeyB, shape); // bottom
			}
		}
		else {
			a.gridKeyR = (setKeyR==-1) ? a.grid.right.actors.add(a) : setKeyR;
			if ( pos.y + shape.height <= Grid.HEIGHT ) {
				_addToGridFromTo(pos, 0, 0, 0, Grid.WIDTH - pos.x, 0, shape.height, a.grid, a.gridKey, shape); // root grid
				_addToGridFromTo(pos, Grid.WIDTH, 0, Grid.WIDTH - pos.x, shape.width, 0, shape.height, a.grid.right, a.gridKeyR, shape); // right
			}
			else {
				_addToGridFromTo(pos, 0, 0, 0, Grid.WIDTH - pos.x, 0, Grid.HEIGHT - pos.y, a.grid, a.gridKey, shape); // root grid
				_addToGridFromTo(pos, Grid.WIDTH, 0, Grid.WIDTH - pos.x, shape.width, 0, Grid.HEIGHT - pos.y, a.grid.right, a.gridKeyR, shape); // right
				a.gridKeyB = (setKeyB==-1) ? a.grid.bottom.actors.add(a) : setKeyB;
				_addToGridFromTo(pos, 0, Grid.HEIGHT, 0, Grid.WIDTH - pos.x, Grid.HEIGHT - pos.y, shape.height, a.grid.bottom, a.gridKeyB, shape); // bottom
				a.gridKeyRB = (setKeyRB==-1) ? a.grid.rightBottom.actors.add(a) : setKeyRB;
				_addToGridFromTo(pos, Grid.WIDTH, Grid.HEIGHT, Grid.WIDTH - pos.x, shape.width, Grid.HEIGHT - pos.y, shape.height, a.grid.rightBottom, a.gridKeyRB, shape); // rightBottom
			}
		}

		// trigger actor-add to the origin corresponding grid and its views
		if (syncToView) {
			if (pos.x + shape.originXOffset < Grid.WIDTH) grid.viewsActorAdd(a, a.gridKey, a.pos.x + shape.originXOffset);
			else grid.right.viewsActorAdd(a, a.gridKeyR, (a.pos.x + shape.originXOffset) % Grid.WIDTH);
		}
	}

	static inline function _removeFromGrid(pos:Pos, xOff:Int, yOff:Int, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int, grid:Grid, shape:BitGrid) {
		// trace('REMOVE: shapeX:$xFrom-$xTo, shapeY:$yFrom-$yTo - x:${pos.x + xFrom - xOff}-${pos.x + xTo - xOff}, y:${pos.y + yFrom - yOff}-${pos.y + yTo - yOff}');
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				if (shape.get(x,y)) grid.delCellActorAt(P(pos.x + x - xOff, pos.y + y - yOff));
	}

	public static inline function removeFromGrid(a:IActor, shape:BitGrid, syncToView:Bool, delKey:Bool=true, delKeyR:Bool=true, delKeyB:Bool=true, delKeyRB:Bool=true) {
		if ( a.pos.x + shape.width <= Grid.WIDTH ) {
			if ( a.pos.y + shape.height <= Grid.HEIGHT) {
				_removeFromGrid(a.pos, 0, 0, 0, shape.width, 0, shape.height, a.grid, shape); // root grid
			}
			else {
				_removeFromGrid(a.pos, 0, 0, 0, shape.width, 0, Grid.HEIGHT - a.pos.y, a.grid, shape); // root grid
				_removeFromGrid(a.pos, 0, Grid.HEIGHT, 0, shape.width, Grid.HEIGHT - a.pos.y, shape.height, a.grid.bottom, shape); // bottom
				if (delKeyB) {a.grid.bottom.actors.del(a.gridKeyB); a.gridKeyB = -1;}
			}
		}
		else {
			if ( a.pos.y + shape.height <= Grid.HEIGHT ) {
				_removeFromGrid(a.pos, 0, 0, 0, Grid.WIDTH - a.pos.x, 0, shape.height, a.grid, shape); // root grid
				_removeFromGrid(a.pos, Grid.WIDTH, 0, Grid.WIDTH - a.pos.x, shape.width, 0, shape.height, a.grid.right, shape); // right
			}
			else {
				_removeFromGrid(a.pos, 0, 0, 0, Grid.WIDTH - a.pos.x, 0, Grid.HEIGHT - a.pos.y, a.grid, shape); // root grid
				_removeFromGrid(a.pos, Grid.WIDTH, 0, Grid.WIDTH - a.pos.x, shape.width, 0, Grid.HEIGHT - a.pos.y, a.grid.right, shape); // right
				_removeFromGrid(a.pos, 0, Grid.HEIGHT, 0, Grid.WIDTH - a.pos.x, Grid.HEIGHT - a.pos.y, shape.height, a.grid.bottom, shape); // bottom
				_removeFromGrid(a.pos, Grid.WIDTH, Grid.HEIGHT, Grid.WIDTH - a.pos.x, shape.width, Grid.HEIGHT - a.pos.y, shape.height, a.grid.rightBottom, shape); // rightBottom
				if (delKeyB) {a.grid.bottom.actors.del(a.gridKeyB); a.gridKeyB = -1;}
				if (delKeyRB) {a.grid.rightBottom.actors.del(a.gridKeyRB); a.gridKeyRB = -1;}
			}
			if (delKeyR) a.grid.right.actors.del(a.gridKeyR); //a.gridKeyR = -1;
		}
		if (delKey) a.grid.actors.del(a.gridKey);

		// trigger actor-remove to the origin corresponding grid and its views
		if (syncToView) {
			if (a.pos.x + shape.originXOffset < Grid.WIDTH) a.grid.viewsActorRemove(a, a.gridKey, a.pos.x + shape.originXOffset);
			else a.grid.right.viewsActorRemove(a, a.gridKeyR, (a.pos.x + shape.originXOffset) % Grid.WIDTH);
		}
		// clean up after view-sync
		if (delKey) a.gridKey = -1;
		if (delKeyR) a.gridKeyR = -1;
		a.grid = null;
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
		return _isFreeSide(-1, 0, grid, pos, blockedCellType, shape);
	}
	public static function freeRight(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 1, 0, grid, pos, blockedCellType, shape);
	}
	public static function freeUp(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 0,-1, grid, pos, blockedCellType, shape);
	}
	public static function freeDown(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid):Bool {
		return _isFreeSide( 0, 1, grid, pos, blockedCellType, shape);
	}

	public static function freeLeftUp(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid, checkSide:Bool=false):Bool {
		if (checkSide) return _isFreeSide(-1, 0, grid, pos, blockedCellType, shape) && _isFreeSide(-1,-1, grid, pos, blockedCellType, shape);
		else return _isFreeSide(-1,-1, grid, pos, blockedCellType, shape);
	}
	public static function freeLeftDown(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid, checkSide:Bool=false):Bool {
		if (checkSide) return _isFreeSide(-1, 0, grid, pos, blockedCellType, shape) && _isFreeSide(-1, 1, grid, pos, blockedCellType, shape);
		else return _isFreeSide(-1, 1, grid, pos, blockedCellType, shape);
	}
	public static function freeRightUp(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid, checkSide:Bool=false):Bool {
		if (checkSide) return _isFreeSide(1, 0, grid, pos, blockedCellType, shape) && _isFreeSide( 1,-1, grid, pos, blockedCellType, shape);
		else return _isFreeSide( 1,-1, grid, pos, blockedCellType, shape);
	}
	public static function freeRightDown(grid:Grid, pos:Int, blockedCellType:Int, shape:BitGrid, checkSide:Bool=false):Bool {
		if (checkSide) return _isFreeSide(1, 0, grid, pos, blockedCellType, shape) && _isFreeSide( 1, 1, grid, pos, blockedCellType, shape);
		else return _isFreeSide( 1, 1, grid, pos, blockedCellType, shape);
	}



	// TODO: refactor constant arguments for view-sync out!

	// ------- left -------
	public static function goLeft(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g:Grid = a.grid;
		// store old values to sync the views afterwards
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }
		
		/*removeFromGrid(a, shape, false);		
		if (a.pos.x == 0) addToGrid(a, g.left, P(Grid.WIDTH - 1, a.pos.y), shape, false);
		else addToGrid(a, g, P(a.pos.x-1, a.pos.y), shape, false);*/
		if (a.pos.x == 0) {
			removeFromGrid(a, shape, false,                                   (shape.width == 1), true, (shape.width == 1), true);		
			addToGrid(a, g.left, P(Grid.WIDTH - 1, a.pos.y), shape, false,    -1, a.gridKey, -1, a.gridKeyB   );
		}
		else {
			removeFromGrid(a, shape, false,                         false, (a.pos.x + shape.width == Grid.WIDTH+1), false, (a.pos.x + shape.width == Grid.WIDTH+1));		
			addToGrid(a, g, P(a.pos.x-1, a.pos.y), shape, false,    a.gridKey, a.gridKeyR, a.gridKeyB, a.gridKeyRB );
		}

		if (syncToView) { // sync views
			if (oldX > 0) oldGrid.viewsActorToLeft(a, oldKey, oldX, oldX-1, time);
			else {
				var newX:Int = Grid.WIDTH-1;
				var newGrid:Grid = oldGrid.left;
				var newKey:Int = a.gridKey;
				oldGrid.viewsActorToLeftOut(a, newGrid, oldKey, newKey, oldX, newX, time);
				newGrid.viewsActorToLeftIn(a, oldGrid, newKey, oldX, newX, time);
			}
		}	
	}
	// ------- right -------
	public static function goRight(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g:Grid = a.grid;
		// store old values to sync the views afterwards
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }
		
		/*removeFromGrid(a, shape, false);
		if (a.pos.x == Grid.WIDTH - 1) addToGrid(a, g.right, P(0, a.pos.y), shape, false);
		else addToGrid(a, g, P(a.pos.x+1, a.pos.y), shape, false);*/
		if (a.pos.x == Grid.WIDTH - 1) {
			removeFromGrid(a, shape, false,                      true, false, true, false);
			addToGrid(a, g.right, P(0, a.pos.y), shape, false,   a.gridKeyR, -1, a.gridKeyRB, -1);
			a.gridKeyR = -1; a.gridKeyB = -1;
		}
		else {
			removeFromGrid(a, shape, false,                      false, false, false, false);
			addToGrid(a, g, P(a.pos.x+1, a.pos.y), shape, false,    a.gridKey, a.gridKeyR, a.gridKeyB, a.gridKeyRB);
		}

		if (syncToView) { // sync views
			if (oldX < Grid.WIDTH-1) oldGrid.viewsActorToRight(a, oldKey, oldX, oldX+1, time);
			else {
				var newX:Int = 0;
				var newGrid:Grid = oldGrid.right;
				var newKey:Int = (shape.originXOffset == 0) ? a.gridKey : a.gridKeyR;
				oldGrid.viewsActorToRightOut(a, newGrid, oldKey, newKey, oldX, newX, time);
				newGrid.viewsActorToRightIn(a, oldGrid, newKey, oldX, newX, time);
			}
		}
	}
	// ------- up -------
	public static function goUp(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g:Grid = a.grid;
		// store old values to sync the views afterwards
		var oldY:Int = a.pos.y;
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }
		
		removeFromGrid(a, shape, false);
		if (a.pos.y == 0) addToGrid(a, g.top, P(a.pos.x, Grid.HEIGHT - 1), shape, false);
		else addToGrid(a, g, P(a.pos.x, a.pos.y-1), shape, false);
		
		if (syncToView) { // sync views
			if (oldY > 0) oldGrid.viewsActorToUp(a, oldKey, oldX, oldY, oldY-1, time);
			else {
				var newY:Int = Grid.HEIGHT-1;
				var newGrid:Grid = oldGrid.top;
				var newKey:Int = (a.pos.x + shape.originXOffset < Grid.WIDTH) ? a.gridKey : a.gridKeyR;
				oldGrid.viewsActorToUpOut(a, newGrid, oldKey, newKey, oldX, oldY, newY, time);
				newGrid.viewsActorToUpIn(a, oldGrid, newKey, oldX, oldY, newY, time);
			}
		}
	}
	// ------- down -------
	public static function goDown(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g:Grid = a.grid;
		// store old values to sync the views afterwards
		var oldY:Int = a.pos.y;
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }
		
		removeFromGrid(a, shape, false);
		if (a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.bottom, P(a.pos.x, 0), shape, false);
		else addToGrid(a, g, P(a.pos.x, a.pos.y+1), shape, false);

		if (syncToView) { // sync views
			if (oldY < Grid.HEIGHT-1) oldGrid.viewsActorToDown(a, oldKey, oldX, oldY, oldY+1, time);
			else {
				var newY:Int = 0;
				var newGrid:Grid = oldGrid.bottom;
				var newKey:Int = (a.pos.x + shape.originXOffset < Grid.WIDTH) ? a.gridKey : a.gridKeyR;
				oldGrid.viewsActorToDownOut(a, newGrid, oldKey, newKey, oldX, oldY, newY, time);
				newGrid.viewsActorToDownIn(a, oldGrid, newKey, oldX, oldY, newY, time);
			}
		}
	}

	// ------- leftUp -------
	public static function goLeftUp(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g = a.grid; 
		// store old values to sync the views afterwards
		var oldY:Int = a.pos.y;
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }

		removeFromGrid(a, shape, false);
		if (a.pos.x == 0 && a.pos.y == 0) addToGrid(a, g.leftTop, P(Grid.WIDTH - 1, Grid.HEIGHT - 1), shape, false);
		else if (a.pos.x == 0) addToGrid(a, g.left, P(Grid.WIDTH - 1, a.pos.y-1), shape, false);
		else if (a.pos.y == 0) addToGrid(a, g.top, P(a.pos.x-1, Grid.HEIGHT - 1), shape, false);
		else addToGrid(a, g, P(a.pos.x-1, a.pos.y-1), shape, false);
		
		if (syncToView) { // sync views
			if (oldX > 0 && oldY > 0) oldGrid.viewsActorToLeftUp(a, oldKey, oldX, oldX-1, oldY, oldY-1, time);
			else {			
				var newX:Int = (oldX > 0) ? oldX-1 : Grid.WIDTH-1;
				var newY:Int = (oldY > 0) ? oldY-1 : Grid.HEIGHT-1;
				var newGrid:Grid = (oldX == 0 && oldY == 0) ? oldGrid.leftTop  :  ((oldX == 0) ? oldGrid.left : oldGrid.top);
				var newKey:Int = (a.pos.x + shape.originXOffset < Grid.WIDTH) ? a.gridKey : a.gridKeyR;
				oldGrid.viewsActorToLeftUpOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
				newGrid.viewsActorToLeftUpIn(a, oldGrid, newKey, oldX, newX, oldY, newY, time);				
			}
		}
	}
	// ------- leftDown -------
	public static function goLeftDown(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g = a.grid; 
		// store old values to sync the views afterwards
		var oldY:Int = a.pos.y;
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }
		
		removeFromGrid(a, shape, false);
		if (a.pos.x == 0 && a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.leftBottom, P(Grid.WIDTH - 1, 0), shape, false);
		else if (a.pos.x == 0) addToGrid(a, g.left, P(Grid.WIDTH - 1, a.pos.y+1), shape, false);
		else if (a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.bottom, P(a.pos.x-1, 0), shape, false);
		else addToGrid(a, g, P(a.pos.x-1, a.pos.y+1), shape, false);
		
		if (syncToView) { // sync views
			if (oldX > 0 && oldY < Grid.HEIGHT-1) oldGrid.viewsActorToLeftDown(a, oldKey, oldX, oldX-1, oldY, oldY+1, time);
			else {			
				var newX:Int = (oldX > 0) ? oldX-1 : Grid.WIDTH-1;
				var newY:Int = (oldY < Grid.HEIGHT-1) ? oldY+1 : 0;
				var newGrid:Grid = (oldX == 0 && oldY == Grid.HEIGHT-1) ? oldGrid.leftBottom  :  ((oldX == 0) ? oldGrid.left : oldGrid.bottom);
				var newKey:Int = (a.pos.x + shape.originXOffset < Grid.WIDTH) ? a.gridKey : a.gridKeyR;
				oldGrid.viewsActorToLeftDownOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
				newGrid.viewsActorToLeftDownIn(a, oldGrid, newKey, oldX, newX, oldY, newY, time);				
			}
		}
	}
	// ------- rightUp -------
	public static function goRightUp(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g = a.grid;
		// store old values to sync the views afterwards
		var oldY:Int = a.pos.y;
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }
		
		removeFromGrid(a, shape, false);
		if (a.pos.x == Grid.WIDTH - 1 && a.pos.y == 0) addToGrid(a, g.rightTop, P(0, Grid.HEIGHT - 1), shape, false);
		else if (a.pos.x == Grid.WIDTH - 1) addToGrid(a, g.right, P(0, a.pos.y-1), shape, false);
		else if (a.pos.y == 0) addToGrid(a, g.top, P(a.pos.x+1, Grid.HEIGHT - 1), shape, false);
		else addToGrid(a, g, P(a.pos.x+1, a.pos.y-1), shape, false);
		
		if (syncToView) { // sync views
			if (oldX < Grid.WIDTH-1 && oldY > 0) oldGrid.viewsActorToRightUp(a, oldKey, oldX, oldX+1, oldY, oldY-1, time);
			else {			
				var newX:Int = (oldX < Grid.WIDTH-1) ? oldX+1 : 0;
				var newY:Int = (oldY > 0) ? oldY-1 : Grid.HEIGHT-1;
				var newGrid:Grid = (oldX == Grid.WIDTH-1 && oldY == 0) ? oldGrid.rightTop  :  ((oldX == Grid.WIDTH-1) ? oldGrid.right : oldGrid.top);
				var newKey:Int = (a.pos.x + shape.originXOffset < Grid.WIDTH) ? a.gridKey : a.gridKeyR;
				oldGrid.viewsActorToRightUpOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
				newGrid.viewsActorToRightUpIn(a, oldGrid, newKey, oldX, newX, oldY, newY, time);				
			}
		}		
	}
	// ------- rightDown -------
	public static function goRightDown(a:IActor, shape:BitGrid, time:Int, syncToView:Bool) {
		var g = a.grid;
		// store old values to sync the views afterwards
		var oldY:Int = a.pos.y;
		var oldGrid:Grid = g; var oldKey:Int = a.gridKey; var oldX:Int = a.pos.x + shape.originXOffset;
		if (syncToView && oldX >= Grid.WIDTH) {	oldGrid = oldGrid.right; oldKey = a.gridKeyR; oldX -= Grid.WIDTH; }
		
		removeFromGrid(a, shape, false);
		if (a.pos.x == Grid.WIDTH - 1 && a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.rightBottom, P(0, 0), shape, false);
		else if (a.pos.x == Grid.WIDTH - 1) addToGrid(a, g.right, P(0, a.pos.y+1), shape, false);
		else if (a.pos.y == Grid.HEIGHT - 1) addToGrid(a, g.bottom, P(a.pos.x+1, 0), shape, false);
		else addToGrid(a, g, P(a.pos.x+1, a.pos.y+1), shape, false);
		
		if (syncToView) { // sync views
			if (oldX < Grid.WIDTH-1 && oldY < Grid.HEIGHT-1) oldGrid.viewsActorToRightDown(a, oldKey, oldX, oldX+1, oldY, oldY+1, time);
			else {			
				var newX:Int = (oldX < Grid.WIDTH-1) ? oldX+1 : 0;
				var newY:Int = (oldY < Grid.HEIGHT-1) ? oldY+1 : 0;
				var newGrid:Grid = (oldX == Grid.WIDTH-1 && oldY == Grid.HEIGHT-1) ? oldGrid.rightBottom  :  ((oldX == Grid.WIDTH-1) ? oldGrid.right : oldGrid.bottom);
				var newKey:Int = (a.pos.x + shape.originXOffset < Grid.WIDTH) ? a.gridKey : a.gridKeyR;
				oldGrid.viewsActorToRightDownOut(a, newGrid, oldKey, newKey, oldX, newX, oldY, newY, time);
				newGrid.viewsActorToRightDownIn(a, oldGrid, newKey, oldX, newX, oldY, newY, time);				
			}
		}
	}


	// TODO: function to get the cell-offsets to one side
		// or to let iterate about them by a given function !
}
