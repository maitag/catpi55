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
		// send all to the view, row by row
		
	}

	// ------- add ----------

	inline function syncAddCells(posFrom:Pos, posTo:Pos, cells:Array<Int>) {
		trace("syncAddCells", posFrom, posTo);
	}

	inline function syncAddActor(pos:Pos, actorKey:CellActor, actor:IActor) {
		trace("syncAddActor", pos, actorKey, actor.name);
	}

	// ------ remove ---------

	inline function syncRemoveCells(posFrom:Pos, posTo:Pos) {
		trace("syncViewRemove", posFrom, posTo);
	}

	inline function syncRemoveActor(actorKey:CellActor) {
		trace("syncRemoveActor", actorKey);
	}

	// ------- update --------

	inline function syncUpdateCell(pos:Pos, cell:CellType) { // CellParam!
		trace("syncViewUpdate", pos, cell);
	}

	inline function syncUpdateActor(actorKey:CellActor, action:Int) { // TODO: action!
		trace("syncUpdateActor", actorKey, action);
	}


	// ------------------------------------------
	// ------------------------------------------
	// ------------------------------------------
	
	public function extendLeft() {
		if (xFrom == 0) return;
		xFrom--;
		var cells = new Array<Int>();
		var actorKey:CellActor = CellActor.EMPTY;
		var alreadyAdded = new Array<CellActor>();
		for (y in yFrom...yTo)
		{
			var cell:Cell = grid.get(P(xFrom, y));
			cells.push(cell); // TODO: CellType + CellParam!
			if (cell.actor != actorKey)
			{ 
				if(cell.actor != CellActor.EMPTY && alreadyAdded.indexOf(cell.actor) == -1 )
				{
					actorKey = cell.actor;
					var actor:IActor = grid.actors.get(actorKey);
					if (actor.grid == grid && // only if inside the SAME grid
						actor.pos.x + actor.width - 1 == xFrom) // and left actor-side comes in
					{
						syncAddActor( P(xFrom, y), actorKey, actor); // actor enters the view
						alreadyAdded.push(actorKey); // to not add it again
					}
				}
			}
		}
		syncAddCells( P(xFrom, yFrom), P(xFrom, yTo), cells );
	}

	public function extendRight() {
		if (xTo == Grid.WIDTH) return;
		xTo++;
		
	}

	public function shrinkLeft() {
		var actorKey:CellActor = 0;

		for (y in yFrom...yTo) {
			var actorKey = grid.get(P(xFrom, y)).actor;
			// TODO: only if actor goes out of view:
			// syncRemoveActor( 0 );
		}		
		xFrom++;
		syncRemoveCells( P(xFrom, yFrom), P(xFrom, yTo) );
	}

	public function shrinkRight() {
		
	}

	public function goLeft() { extendLeft(); shrinkRight(); }


}