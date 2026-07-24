package automat;

import util.Pos;
import util.Pos.xy as P;
import automat.actor.IActor;

class GridView {

	public var grid:Grid = null;
	public var isActive(get, never):Bool;	
	inline function get_isActive():Bool return (grid != null);

	public var leftGrid(get, never):Grid;
	public var rightGrid(get, never):Grid;
	public var topGrid(get, never):Grid;
	public var bottomGrid(get, never):Grid;	
	inline function get_leftGrid():Grid return (grid == null) ? null : grid.left;
	inline function get_rightGrid():Grid return (grid == null) ? null : grid.right;
	inline function get_topGrid():Grid return (grid == null) ? null : grid.top;
	inline function get_bottomGrid():Grid return (grid == null) ? null : grid.bottom;

	// actual range into the connected Grid
	public var xFrom:Int = 0;
	public var xTo:Int = 0;
	public var yFrom:Int = 0;
	public var yTo:Int = 0;

	public var multiGridView:MultiGridView;
	public var index:Int = 0;// index into gridViews of MultiGridView
	public var offsetX:Int = 0;// offset to rootGrid
	public var offsetY:Int = 0;// offset to rootGrid

	// -------------------------------------

	public function new(multiGridView:MultiGridView, index:Int, grid:Grid=null, xFrom:Int=0, xTo:Int=0, yFrom:Int=0, yTo:Int=0) {
		this.multiGridView = multiGridView;
		this.index = index;
		if (grid != null) {
			addToGrid(grid, 0, 0, xFrom, xTo, yFrom, yTo);
			growRight();
		}
	}

	public function addToGrid(grid:Grid, offsetX:Int, offsetY:Int, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int) {
		this.offsetX = offsetX;
		this.offsetY = offsetY;
		this.xFrom = xFrom;
		this.xTo = xTo;
		this.yFrom = yFrom;
		this.yTo = yTo;
		this.grid = grid;
		grid.views.push(this);
		multiGridView.addGridView(index, offsetX, offsetY);
	}

	public function removeFromGrid() {
		if (!isActive) return;
		grid.views.remove(this);
		grid = null;
		multiGridView.removeGridView(index);
	}

	public inline function isInside(x:Int, y:Int):Bool {
		return x >= xFrom && x < xTo && y >= yFrom && y < yTo;
	}



	// ------------------------------------------------------
	// --------------- Actor: add, remove -------------------
	// ------------------------------------------------------
	public function addActor(actor:IActor, actorKey:Int, originPosX:Int) {
		if (isInside(originPosX, actor.pos.y)) {
			multiGridView.switchGridViewIndex(index);
			multiGridView.addActor(actor, actorKey, originPosX);
		}
	}

	public function removeActor(actor:IActor, actorKey:Int, originPosX:Int) {
		if (isInside(originPosX, actor.pos.y)) {
			multiGridView.switchGridViewIndex(index);
			multiGridView.removeActor(actorKey);
		}
	}

	// ------------------------------------------------------
	// ---------------- Actor: MOVEMENT ---------------------
	// ------------------------------------------------------

	// ------- left -------
	public function actorToLeft(a:IActor, key:Int, oldX:Int, newX:Int, time:Int) {
		if (isInside(oldX, a.pos.y)) { // inside before
			multiGridView.switchGridViewIndex(index); 
			if (isInside(newX, a.pos.y)) multiGridView.actorGoLeft(key, time); // inside after -> move it
			else multiGridView.removeActor(key); // not inside after -> remove			
		}
		else if (isInside(newX, a.pos.y)) { // not inside before AND inside after -> add
			multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, newX);
		}
	}
	public function actorToLeftOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, time:Int) {
		var indexLeft = multiGridView.gridViewCache.leftIndex(index);
		var gridViewLeft = multiGridView.gridViewCache.getByIndex(indexLeft);
		if (isInside(oldX, a.pos.y)) { // inside before		
			multiGridView.switchGridViewIndex(index);
			if (gridViewLeft.grid == newGrid && gridViewLeft.isInside(newX, a.pos.y) ) { // inside after -> move it
				multiGridView.actorToSideGrid(indexLeft, oldKey, newKey);
				multiGridView.switchGridViewIndex(indexLeft);
				multiGridView.actorGoLeft(newKey, time);
			}
			else multiGridView.removeActor(oldKey); // not inside after -> remove	
		}		
	}
	public function actorToLeftIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, time:Int) {
		var gridViewRight = multiGridView.gridViewCache.getByIndexRight(index);
		if (gridViewRight.grid != oldGrid || !gridViewRight.isInside(oldX, a.pos.y)) { // not inside before		
			if ( isInside(newX, a.pos.y) ) { // inside after -> add
				multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, newX);				
				// TODO LATER: evtl. add position offset to "move in":
				// multiGridView.actorGoLeft(key, time);
			}
		}	
	}
	// ------- right -------
	public function actorToRight(a:IActor, key:Int, oldX:Int, newX:Int, time:Int) {
		if (isInside(oldX, a.pos.y)) { // inside before
			multiGridView.switchGridViewIndex(index); 
			if (isInside(newX, a.pos.y)) multiGridView.actorGoRight(key, time); // inside after -> move it
			else multiGridView.removeActor(key); // not inside after -> remove			
		}
		else if (isInside(newX, a.pos.y)) { // not inside before AND inside after -> add
			multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, newX);
		}
	}
	public function actorToRightOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, time:Int) {
		var indexRight = multiGridView.gridViewCache.rightIndex(index);
		var gridViewRight = multiGridView.gridViewCache.getByIndex(indexRight);
		if (isInside(oldX, a.pos.y)) { // inside before		
			multiGridView.switchGridViewIndex(index);
			if (gridViewRight.grid == newGrid && gridViewRight.isInside(newX, a.pos.y) ) { // inside after -> move it
				multiGridView.actorToSideGrid(indexRight, oldKey, newKey);
				multiGridView.switchGridViewIndex(indexRight);
				multiGridView.actorGoRight(newKey, time);
			}
			else multiGridView.removeActor(oldKey); // not inside after -> remove	
		}		
	}
	public function actorToRightIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, time:Int) {
		var gridViewLeft = multiGridView.gridViewCache.getByIndexLeft(index);
		if (gridViewLeft.grid != oldGrid || !gridViewLeft.isInside(oldX, a.pos.y)) { // not inside before		
			if ( isInside(newX, a.pos.y) ) { // inside after -> add
				multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, newX);
			}
		}	
	}
	// ------- up -------
	public function actorToUp(a:IActor, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		if (isInside(x, oldY)) { // inside before
			multiGridView.switchGridViewIndex(index); 
			if (isInside(x, newY)) multiGridView.actorGoUp(key, time); // inside after -> move it
			else multiGridView.removeActor(key); // not inside after -> remove			
		}
		else if (isInside(x, newY)) { // not inside before AND inside after -> add
			multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, x);
		}
	}
	public function actorToUpOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		var indexTop = multiGridView.gridViewCache.topIndex(index);
		var gridViewTop = multiGridView.gridViewCache.getByIndex(indexTop);
		if (isInside(x, oldY)) { // inside before		
			multiGridView.switchGridViewIndex(index);
			if (gridViewTop.grid == newGrid && gridViewTop.isInside(x, newY) ) { // inside after -> move it
				multiGridView.actorToSideGrid(indexTop, oldKey, newKey);
				multiGridView.switchGridViewIndex(indexTop);
				multiGridView.actorGoUp(newKey, time);
			}
			else multiGridView.removeActor(oldKey); // not inside after -> remove
		}		
	}
	public function actorToUpIn(a:IActor, oldGrid:Grid, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		var gridViewBottom = multiGridView.gridViewCache.getByIndexBottom(index);
		if (gridViewBottom.grid != oldGrid || !gridViewBottom.isInside(x, oldY)) { // not inside before		
			if ( isInside(x, newY) ) { // inside after -> add
				multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, x);
			}
		}	
	}
	// ------- down -------
	public function actorToDown(a:IActor, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		if (isInside(x, oldY)) { // inside before
			multiGridView.switchGridViewIndex(index); 
			if (isInside(x, newY)) multiGridView.actorGoDown(key, time); // inside after -> move it
			else multiGridView.removeActor(key); // not inside after -> remove			
		}
		else if (isInside(x, newY)) { // not inside before AND inside after -> add
			multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, x);
		}
	}
	public function actorToDownOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		var indexBottom = multiGridView.gridViewCache.topIndex(index);
		var gridViewBottom = multiGridView.gridViewCache.getByIndex(indexBottom);
		if (isInside(x, oldY)) { // inside before		
			multiGridView.switchGridViewIndex(index);
			if (gridViewBottom.grid == newGrid && gridViewBottom.isInside(x, newY) ) { // inside after -> move it
				multiGridView.actorToSideGrid(indexBottom, oldKey, newKey);
				multiGridView.switchGridViewIndex(indexBottom);
				multiGridView.actorGoDown(newKey, time);
			}
			else multiGridView.removeActor(oldKey); // not inside after -> remove
		}		
	}
	public function actorToDownIn(a:IActor, oldGrid:Grid, key:Int, x:Int, oldY:Int, newY:Int, time:Int) {
		var gridViewTop = multiGridView.gridViewCache.getByIndexTop(index);
		if (gridViewTop.grid != oldGrid || !gridViewTop.isInside(x, oldY)) { // not inside before		
			if ( isInside(x, newY) ) { // inside after -> add
				multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, x);
			}
		}	
	}

	// ------- leftUp -------
	public function actorToLeftUp(a:IActor, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		if (isInside(oldX, oldY)) { // inside before
			multiGridView.switchGridViewIndex(index); 
			if (isInside(newX, newY)) multiGridView.actorGoLeftUp(key, time); // inside after -> move it
			else multiGridView.removeActor(key); // not inside after -> remove			
		}
		else if (isInside(newX, newY)) { // not inside before AND inside after -> add
			multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, newX);
		}
	}
	public function actorToLeftUpOut(a:IActor, newGrid:Grid, oldKey:Int, newKey:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		var indexSide = (oldX == 0 && oldY == 0) ? multiGridView.gridViewCache.leftTopIndex(index)  :  ((oldX == 0) ? multiGridView.gridViewCache.leftIndex(index) : multiGridView.gridViewCache.topIndex(index));
		var gridViewSide = multiGridView.gridViewCache.getByIndex(indexSide);
		if (isInside(oldX, oldY)) { // inside before		
			multiGridView.switchGridViewIndex(index);
			if (gridViewSide.grid == newGrid && gridViewSide.isInside(newX, newY) ) { // inside after -> move it
				multiGridView.actorToSideGrid(indexSide, oldKey, newKey);
				multiGridView.switchGridViewIndex(indexSide);
				multiGridView.actorGoLeftUp(newKey, time);
			}
			else multiGridView.removeActor(oldKey); // not inside after -> remove	
		}
	}
	public function actorToLeftUpIn(a:IActor, oldGrid:Grid, key:Int, oldX:Int, newX:Int, oldY:Int, newY:Int, time:Int) {
		var gridViewSide = (oldX == 0 && oldY == 0) ? multiGridView.gridViewCache.getByIndexRightBottom(index)  :  ((oldX == 0) ? multiGridView.gridViewCache.getByIndexRight(index) : multiGridView.gridViewCache.getByIndexBottom(index));
		if (gridViewSide.grid != oldGrid || !gridViewSide.isInside(oldX, oldY)) { // not inside before		
			if ( isInside(newX, newY) ) { // inside after -> add
				multiGridView.switchGridViewIndex(index); multiGridView.addActor(a, key, newX);				
			}
		}
	}




	// ----------------------------------------------
	// ---------- SHRINK AND GROW THE VIEW ----------
	// ----------------------------------------------

	// TODO: optimize it without cell arrays !

	// ------------------- LEFT -----------------------
	public function growLeft() {
		if (!isActive) return;
		// if (xFrom == 0) return;
		xFrom--;
		var cells = new Array<Int>();
		var actorKey:Int;
		multiGridView.switchGridViewIndex(index);
		for (y in yFrom...yTo) {
			var cell:Cell = grid.get(P(xFrom, y));
			cells.push(cell); // TODO: CellType + CellParam!
			if (cell.isOrigin) {
				actorKey = cell.actor;
				var actor:IActor = grid.actors.get(actorKey);
				multiGridView.addActor( actor, actorKey, xFrom); // actor enters the view
			}
		}
		multiGridView.addCellsVertical( xFrom, yFrom, yTo, cells );
	}

	public function shrinkLeft() {
		if (!isActive) return;
		// if (xFrom == xTo) return;
		multiGridView.switchGridViewIndex(index);
		for (y in yFrom...yTo) {
			var cell:Cell = grid.get(P(xFrom, y));
			if (cell.isOrigin) { 
				multiGridView.removeActor( cell.actor ); // actor leaves the view
			}
		}
		multiGridView.removeCellsVertical( xFrom, yFrom, yTo );
		xFrom++;
	}

	// ------------------- RIGHT -----------------------
	public function growRight() {
		if (!isActive) return;
		// if (xTo == Grid.WIDTH) return;
		var cells = new Array<Int>();
		var actorKey:Int;
		multiGridView.switchGridViewIndex(index);
		for (y in yFrom...yTo) {
			// cell
			var cell:Cell = grid.get(P(xTo, y));
			cells.push(cell); // TODO: CellType + CellParam!
			if (cell.isOrigin) {
				actorKey = cell.actor;
				var actor:IActor = grid.actors.get(actorKey);
				multiGridView.addActor( actor, actorKey, xTo); // actor enters the view
			}
		}
		multiGridView.addCellsVertical( xTo, yFrom, yTo, cells );
		xTo++;
	}

	public function shrinkRight(last = false) {
		if (!isActive) return;
		// if (xFrom == xTo) return;
		xTo--;
		multiGridView.switchGridViewIndex(index);
		for (y in yFrom...yTo) {
			var cell:Cell = grid.get(P(xTo, y));
			if (cell.isOrigin) { 
				multiGridView.removeActor( cell.actor ); // actor leaves the view
			}
		}
		multiGridView.removeCellsVertical( xTo, yFrom, yTo );
	}

	// -------------------- TOP ------------------------
	public function growTop() {
		if (!isActive) return;
		// if (yFrom == 0) return;
		yFrom--;
		var cells = new Array<Int>();
		var actorKey:Int;
		multiGridView.switchGridViewIndex(index);
		for (x in xFrom...xTo) {
			var cell:Cell = grid.get(P(x, yFrom));
			cells.push(cell); // TODO: CellType + CellParam!
			if (cell.isOrigin) {
				actorKey = cell.actor;
				var actor:IActor = grid.actors.get(actorKey);
				multiGridView.addActor( actor, actorKey, x); // actor enters the view
			}
		}
		multiGridView.addCellsHorizontal( yFrom, xFrom, xTo, cells );
	}

	public function shrinkTop() {
		if (!isActive) return;
		// if (yFrom == yTo) return;
		multiGridView.switchGridViewIndex(index);
		for (x in xFrom...xTo) {
			var cell:Cell = grid.get(P(x, yFrom));
			if (cell.isOrigin) { 
				multiGridView.removeActor( cell.actor ); // actor leaves the view
			}
		}
		multiGridView.removeCellsHorizontal( yFrom, xFrom,  xTo );
		yFrom++;
	}

	// ------------------- BOTTOM ----------------------
	public function growBottom() {
		if (!isActive) return;
		// if (yTo == Grid.HEIGHT) return;
		var cells = new Array<Int>();
		var actorKey:Int;
		multiGridView.switchGridViewIndex(index);
		for (x in xFrom...xTo) {
			// cell
			var cell:Cell = grid.get(P(x, yTo));
			cells.push(cell); // TODO: CellType + CellParam!
			if (cell.isOrigin) {
				actorKey = cell.actor;
				var actor:IActor = grid.actors.get(actorKey);
				multiGridView.addActor( actor, actorKey, x); // actor enters the view
			}
		}
		multiGridView.addCellsHorizontal( yTo, xFrom, xTo, cells );
		yTo++;
	}

	public function shrinkBottom(last = false) {
		if (!isActive) return;
		// if (yFrom == yTo) return;
		yTo--;
		multiGridView.switchGridViewIndex(index);
		for (x in xFrom...xTo) {
			var cell:Cell = grid.get(P(x, yTo));
			if (cell.isOrigin) { 
				multiGridView.removeActor( cell.actor ); // actor leaves the view
			}
		}
		multiGridView.removeCellsHorizontal( yTo, xFrom, xTo );
	}


}