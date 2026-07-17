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
	public function addActor(actor:IActor, actorKey:Int, actor_pos_x:Int) {
		if (isInside(actor_pos_x, actor.pos.y)) {
			multiGridView.switchGridViewIndex(index);
			multiGridView.addActor(actor, actorKey);
		}
	}

	public function removeActor(actor:IActor, actorKey:Int, actor_pos_x:Int) {
		if (isInside(actor_pos_x, actor.pos.y)) {
			multiGridView.switchGridViewIndex(index);
			multiGridView.removeActor(actorKey);
		}
	}

	// ------------------------------------------------------
	// ---------------- Actor: MOVEMENT ---------------------
	// ------------------------------------------------------

	// ------- left -------
	public function actorToLeft(old_actor_pos_x:Int, actor:IActor, actorKey:Int, actor_pos_x:Int, time:Int) {
		if (isInside(old_actor_pos_x, actor.pos.y)) { // inside before
			multiGridView.switchGridViewIndex(index); 
			if (isInside(actor_pos_x, actor.pos.y)) multiGridView.actorGoLeft(actorKey, time); // inside after -> move it
			else multiGridView.removeActor(actorKey); // not inside after -> remove			
		}
		else if (isInside(actor_pos_x, actor.pos.y)) { // not inside before AND inside after -> add
			multiGridView.switchGridViewIndex(index); multiGridView.addActor(actor, actorKey);
		}
	}
	public function actorToLeftOut(newGrid:Grid, oldActorkey:Int, old_actor_pos_x:Int, actor:IActor, actorKey:Int, actor_pos_x:Int, time:Int) {
		var indexLeft = multiGridView.gridViewCache.leftIndex(index);
		var gridViewLeft = multiGridView.gridViewCache.getByIndex(indexLeft);
		if (isInside(old_actor_pos_x, actor.pos.y)) { // inside before		
			multiGridView.switchGridViewIndex(index);
			if (gridViewLeft.grid == newGrid && gridViewLeft.isInside(actor_pos_x, actor.pos.y) ) { // inside after -> move it
				multiGridView.actorToSideGrid(indexLeft, oldActorkey, actorKey);
				multiGridView.switchGridViewIndex(indexLeft);
				multiGridView.actorGoLeft(actorKey, time);
			}
			else multiGridView.removeActor(oldActorkey); // not inside after -> remove	
		}		
	}
	public function actorToLeftIn(oldGrid:Grid, old_actor_pos_x:Int, actor:IActor, actorKey:Int, actor_pos_x:Int, time:Int) {
		var gridViewRight = multiGridView.gridViewCache.getByIndexRight(index);
		if (gridViewRight.grid != oldGrid || !gridViewRight.isInside(old_actor_pos_x, actor.pos.y)) { // not inside before		
			if ( isInside(actor_pos_x, actor.pos.y) ) { // inside after -> add
				multiGridView.switchGridViewIndex(index); multiGridView.addActor(actor, actorKey);				
				// TODO LATER: evtl. add position offset to "move in":
				// multiGridView.actorGoLeft(actorKey, time);
			}
		}	
	}
	// ------- right -------
	public function actorToRight(old_actor_pos_x:Int, actor:IActor, actorKey:Int, actor_pos_x:Int, time:Int) {
		if (isInside(old_actor_pos_x, actor.pos.y)) { // inside before
			multiGridView.switchGridViewIndex(index); 
			if (isInside(actor_pos_x, actor.pos.y)) multiGridView.actorGoRight(actorKey, time); // inside after -> move it
			else multiGridView.removeActor(actorKey); // not inside after -> remove			
		}
		else if (isInside(actor_pos_x, actor.pos.y)) { // not inside before AND inside after -> add
			multiGridView.switchGridViewIndex(index); multiGridView.addActor(actor, actorKey);
		}
	}
	public function actorToRightOut(newGrid:Grid, oldActorkey:Int, old_actor_pos_x:Int, actor:IActor, actorKey:Int, actor_pos_x:Int, time:Int) {
		var indexRight = multiGridView.gridViewCache.rightIndex(index);
		var gridViewRight = multiGridView.gridViewCache.getByIndex(indexRight);
		if (isInside(old_actor_pos_x, actor.pos.y)) { // inside before		
			multiGridView.switchGridViewIndex(index);
			if (gridViewRight.grid == newGrid && gridViewRight.isInside(actor_pos_x, actor.pos.y) ) { // inside after -> move it
				multiGridView.actorToSideGrid(indexRight, oldActorkey, actorKey);
				multiGridView.switchGridViewIndex(indexRight);
				multiGridView.actorGoRight(actorKey, time);
			}
			else multiGridView.removeActor(oldActorkey); // not inside after -> remove	
		}		
	}
	public function actorToRightIn(oldGrid:Grid, old_actor_pos_x:Int, actor:IActor, actorKey:Int, actor_pos_x:Int, time:Int) {
		var gridViewLeft = multiGridView.gridViewCache.getByIndexLeft(index);
		if (gridViewLeft.grid != oldGrid || !gridViewLeft.isInside(old_actor_pos_x, actor.pos.y)) { // not inside before		
			if ( isInside(actor_pos_x, actor.pos.y) ) { // inside after -> add
				multiGridView.switchGridViewIndex(index); multiGridView.addActor(actor, actorKey);				
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
				multiGridView.addActor( actor, actorKey); // actor enters the view
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
				multiGridView.addActor( actor, actorKey); // actor enters the view
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
				multiGridView.addActor( actor, actorKey); // actor enters the view
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
				multiGridView.addActor( actor, actorKey); // actor enters the view
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