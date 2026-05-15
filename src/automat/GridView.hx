package automat;

import haxe.ds.Vector;
import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import view.View;
import automat.Pos.xy as P;


class GridView {

	public var grid:Grid = null;

	// actual range into ONE Grid
	public var xFrom:Int = 0;
	public var xTo:Int = 0;
	public var yFrom:Int = 0;
	public var yTo:Int = 0;

	public var multiGridView:MultiGridView;
	public var id:Int = 0;// vikto key to identify

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

	public function init(multiGridView:MultiGridView) {
		this.multiGridView = multiGridView;
		syncInit();
	}


	// ------------------------------------------
	// -------- Sync Cells to View --------------
	// ------------------------------------------
	inline function syncInit() {
		// send all to the view
		var _xTo = xTo; 
		xTo = xFrom;
		for (x in xFrom..._xTo) {
			extendRight();
		} 
		
	}

	// ------- add ----------



	// ------------------------------------------
	// ------------------------------------------
	// ------------------------------------------
/*	
	public function extendLeft(first = false) {
		if (xFrom == 0) return;
		xFrom--;
		var cells = new Array<Int>();
		var actorKey:CellActor = CellActor.EMPTY;
		var alreadyAdded = new Array<CellActor>();
		for (y in yFrom...yTo) {
			// cell
			var cell:Cell = grid.get(P(xFrom, y));
			cells.push(cell); // TODO: CellType + CellParam!

			// actor
			if (cell.actor != actorKey) { 
				if(cell.actor != CellActor.EMPTY && alreadyAdded.indexOf(cell.actor) == -1 ) {
					actorKey = cell.actor;
					var actor:IActor = grid.actors.get(actorKey);
					// only if inside the SAME grid and left actor-side comes in
					if (actor.grid == grid && (actor.pos.x + actor.width - 1 == xFrom || first)) {
						syncAddActor( actor, actorKey); // actor enters the view
						alreadyAdded.push(actorKey); // to not add it again
					}
				}
			}
		}
		syncAddCells( P(xFrom, yFrom), P(xFrom, yTo), cells );
	}
*/
	public function extendRight() {
		if (xTo == Grid.WIDTH) return;
		var cells = new Array<Int>();
		var actorKey:CellActor = CellActor.EMPTY;
		
		for (y in yFrom...yTo) {
			// cell
			var cell:Cell = grid.get(P(xTo, y));
			cells.push(cell); // TODO: CellType + CellParam!

			// actor
			actorKey = cell.actor;
			if (actorKey != CellActor.EMPTY) {
				var actor:IActor = grid.actors.get(actorKey);
				// check if it have to use actors from left, top or leftTop neighbor-grid
				if ( actor.grid == grid)
				{
					multiGridView.addActor( actor, actorKey); // actor enters the view
				}
			}
		}
		multiGridView.addCells( P(xTo, yFrom), P(xTo, yTo), cells );
		xTo++;
	}
/*	public function extendRight(first = false) {
		if (xTo == Grid.WIDTH) return;
		var cells = new Array<Int>();
		var actorKey:CellActor = CellActor.EMPTY;
		var alreadyAdded = new Array<CellActor>();

		// TODO: also a "getOutsiderActorsTop" flag if the view should or should NOT add the actors wich pos is from grid above
		for (y in yFrom...yTo) {

			// cell
			var cell:Cell = grid.get(P(xTo, y));
			cells.push(cell); // TODO: CellType + CellParam!

			// actor
			if (cell.actor != actorKey) { 
				if(cell.actor != CellActor.EMPTY && alreadyAdded.indexOf(cell.actor) == -1 ) {
					actorKey = cell.actor;
					var actor:IActor = grid.actors.get(actorKey);
					// only if inside the SAME grid and right actor-side comes in
					if (actor.grid == grid && (actor.pos.x == xTo || first)) {
						syncAddActor( actor, actorKey); // actor enters the view
						alreadyAdded.push(actorKey); // to not add it again
					}
				}
			}
		}
		syncAddCells( P(xTo, yFrom), P(xTo, yTo), cells );
		xTo++;
	}
*/
/*
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
*/
	// public function goLeft() { extendLeft(); shrinkRight(); }


}