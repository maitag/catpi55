package automat;

import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import view.View;
import automat.Pos.xy as P;

// this will be later handled by Remote-Server in peote-net!
class GridView {

	public var grid:Grid = null;

	public var xFrom:Int = 0;
	public var xTo:Int = 0;
	public var yFrom:Int = 0;
	public var yTo:Int = 0;

	public var view:View; // this will be the client into network!
	// TODO: viktor keys to identify the gridView per client!

	// -------------------------------------

	public function new(grid:Grid, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int) {
		this.grid = grid;
		this.xFrom = xFrom;
		this.xTo = xTo;
		this.yFrom = yFrom;
		this.yTo = yTo;
	}

	public function isInside(pos:Pos):Bool {
		return pos.x >= xFrom && pos.x < xTo && pos.y >= yFrom && pos.y < yTo;
	}


	public function init(view:View) {
		this.view = view;
		syncInit();
	}


	// ------------------------------------------
	// -------- Sync Cells to View --------------
	// ------------------------------------------
	inline function syncInit() {
		// send all to the view
		// TODO: start values
		xFrom = xTo = 0;
		yFrom = 0;
		yTo = Grid.HEIGHT;
		extendRight(true);
		for (x in 1...Grid.WIDTH) {
			extendRight();
		}
		
	}

	// ------- add ----------

	inline function syncAddCells(posFrom:Pos, posTo:Pos, cells:Array<Int>) {
		view.addCells(posFrom, posTo, cells);
	}

	inline function syncAddActor(pos:Pos, actorKey:CellActor, actor:IActor) {
		view.addActor(pos, actorKey, actor.name);
	}

	// ------ remove ---------

	inline function syncRemoveCells(posFrom:Pos, posTo:Pos) {
		view.removeCells(posFrom, posTo);
	}

	inline function syncRemoveActor(actorKey:CellActor) {
		view.removeActor(actorKey);
	}

	// ------- update --------

	inline function syncUpdateCell(pos:Pos, cell:CellType) { // CellParam!
		view.updateCell(pos, cell);
	}

	inline function syncUpdateActor(actorKey:CellActor, action:Int) { // TODO: action!
		view.updateActor(actorKey, action);
	}


	// ------------------------------------------
	// ------------------------------------------
	// ------------------------------------------
	
	public function extendLeft(first = false) {
		if (xFrom == 0) return;
		xFrom--;
		var cells = new Array<Int>();
		var actorKey:CellActor = CellActor.EMPTY;
		var alreadyAdded = new Array<CellActor>();
		for (y in yFrom...yTo) {
			var cell:Cell = grid.get(P(xFrom, y));
			cells.push(cell); // TODO: CellType + CellParam!
			if (cell.actor != actorKey) { 
				if(cell.actor != CellActor.EMPTY && alreadyAdded.indexOf(cell.actor) == -1 ) {
					actorKey = cell.actor;
					var actor:IActor = grid.actors.get(actorKey);
					// only if inside the SAME grid and left actor-side comes in
					if (actor.grid == grid && (actor.pos.x + actor.width - 1 == xFrom || first)) {
						syncAddActor( P(xFrom, y), actorKey, actor); // actor enters the view
						alreadyAdded.push(actorKey); // to not add it again
					}
				}
			}
		}
		syncAddCells( P(xFrom, yFrom), P(xFrom, yTo), cells );
	}

	public function extendRight(first = false) {
		if (xTo == Grid.WIDTH) return;
		var cells = new Array<Int>();
		var actorKey:CellActor = CellActor.EMPTY;
		var alreadyAdded = new Array<CellActor>();
		for (y in yFrom...yTo) {
			var cell:Cell = grid.get(P(xTo, y));
			cells.push(cell); // TODO: CellType + CellParam!
			if (cell.actor != actorKey) { 
				if(cell.actor != CellActor.EMPTY && alreadyAdded.indexOf(cell.actor) == -1 ) {
					actorKey = cell.actor;
					var actor:IActor = grid.actors.get(actorKey);
					// only if inside the SAME grid and left actor-side comes in
					if (actor.grid == grid && (actor.pos.x == xTo || first)) {
						syncAddActor( P(xTo, y), actorKey, actor); // actor enters the view
						alreadyAdded.push(actorKey); // to not add it again
					}
				}
			}
		}
		syncAddCells( P(xTo, yFrom), P(xTo, yTo), cells );
		xTo++;
	}

	public function shrinkLeft(last = false) {
		if (xFrom == xTo) return;
		var actorKey:CellActor = CellActor.EMPTY;
		var alreadyRemoved = new Array<CellActor>();
		for (y in yFrom...yTo) {
			var cell:Cell = grid.get(P(xFrom, y));
			if (cell.actor != actorKey) { 
				if(cell.actor != CellActor.EMPTY && alreadyRemoved.indexOf(cell.actor) == -1 ) {
					actorKey = cell.actor;
					var actor:IActor = grid.actors.get(actorKey);
					// only if inside the SAME grid and left actor-side goes out
					if (actor.grid == grid && (actor.pos.x + actor.width - 1 == xFrom || last)) {
						syncRemoveActor( actorKey); // actor leaves the view
						alreadyRemoved.push(actorKey); // to not remove it again
					}
				}
			}
		}
		syncRemoveCells( P(xFrom, yFrom), P(xFrom, yTo) );
		xFrom++;
	}

	public function shrinkRight(last = false) {
		if (xFrom == xTo) return;
		xTo--;
		var actorKey:CellActor = CellActor.EMPTY;
		var alreadyRemoved = new Array<CellActor>();
		for (y in yFrom...yTo) {
			var cell:Cell = grid.get(P(xTo, y));
			if (cell.actor != actorKey) { 
				if(cell.actor != CellActor.EMPTY && alreadyRemoved.indexOf(cell.actor) == -1 ) {
					actorKey = cell.actor;
					var actor:IActor = grid.actors.get(actorKey);
					// only if inside the SAME grid and left actor-side goes out
					if (actor.grid == grid && (actor.pos.x == xTo || last)) {
						syncRemoveActor( actorKey); // actor leaves the view
						alreadyRemoved.push(actorKey); // to not remove it again
					}
				}
			}
		}
		syncRemoveCells( P(xTo, yFrom), P(xTo, yTo) );
	}

	public function goLeft() { extendLeft(); shrinkRight(); }


}