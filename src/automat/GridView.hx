package automat;

import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import automat.Pos.xy as P;

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
		if (grid != null) addToGrid(grid, 0, 0, xFrom, xTo, yFrom, yTo);
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

	public function isInside(pos:Pos):Bool {
		return pos.x >= xFrom && pos.x < xTo && pos.y >= yFrom && pos.y < yTo;
	}


	// ------------------------------------------
	// ---------- SHRINK AND GROW ---------------
	// ------------------------------------------

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
		multiGridView.addCells( xFrom, yFrom, xFrom, yTo, cells );
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
		multiGridView.removeCells( xFrom, yFrom, xFrom, yTo );
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
		multiGridView.addCells( xTo, yFrom, xTo, yTo, cells );
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
		multiGridView.removeCells( xTo, yFrom, xTo, yTo );
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
		multiGridView.addCells( xFrom, yFrom, xTo, yFrom, cells );
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
		multiGridView.removeCells( xFrom, yFrom, xTo, yFrom );
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
		multiGridView.addCells( xFrom, yTo, xTo, yTo, cells );
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
		multiGridView.removeCells( xFrom, yTo, xTo, yTo );
	}


}