package automat;

import haxe.ds.Vector;
import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import view.View;
import automat.Pos.xy as P;


// TODO: store all used GridViews for easy scrolling and "re-usage"
class GridViewRingMatrix {
	public var x:Int = 0;
	public var y:Int = 0;
	public var w:Int;
	public var h:Int;
	public var data:Vector<GridView>;

	public function new(sizeX:Int, sizeY:Int) {
		data = new Vector<GridView>(sizeX * sizeY);
		for (i in 0...data.length) data.set(i, null);
	}

	// T
	// O
	// D
	// O
}


// this to sync later by RPC via peote-net!
class MultiGridView {

	public var rootGridViewKey:Int = 0;
	// TODO: better topLeft and bottomRight grid

	// position into rootGrid
	public var x:Int;
	public var y:Int;

	// viktor keys to identify the used GridViews
	public var gridViews:GridViewRingMatrix;

	// actual size over all GridViews
	public var width:Int;
	public var height:Int;

	public var maxWidth:Int;
	public var maxHeight:Int;

	public var maxGridViewX(get, never):Int;
	public var maxGridViewY(get, never):Int;
	inline function get_maxGridViewX():Int return Math.ceil(maxWidth/Grid.WIDTH);
	inline function get_maxGridViewY():Int return Math.ceil(maxHeight/Grid.HEIGHT);


	public var view:View; // this will be the client into network later!

	// -------------------------------------

	public function new(rootGrid:Grid, x:Int, y:Int, width:Int, height:Int, maxWidth:Int, maxHeight:Int) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		this.maxWidth = maxWidth;
		this.maxHeight = maxHeight;

		// HOW TO BOOT is easy up???

		// TODO: create first rootGridView
		// var rootGridView = new GridView(rootGrid, x, x, y, y);

		gridViews = new GridViewRingMatrix(maxGridViewX, maxGridViewY);


	}

/*
	public function isInside(pos:Pos):Bool {
		return pos.x >= xFrom && pos.x < xTo && pos.y >= yFrom && pos.y < yTo;
	}
*/
/*
	public function init(view:View) {
		this.view = view;
		syncInit();
	}
*/

	// ------------------------------------------
	// -------- Sync Cells to View --------------
	// ------------------------------------------
/*	inline function syncInit() {
		// send all to the MultiView
		var _xTo = xTo; 
		xTo = xFrom;
		for (x in xFrom..._xTo) {
			extendRight();
		} 
		
	}
*/

	public inline function addCells(posFrom:Pos, posTo:Pos, cells:Array<Int>) {
		view.addCells(posFrom, posTo, cells);
	}

	public inline function addActor(actor:IActor, actorKey:CellActor) {
		view.addActor(actor.pos, actorKey, actor.name);
	}

	// ------ remove ---------

	public inline function removeCells(posFrom:Pos, posTo:Pos) {
		view.removeCells(posFrom, posTo);
	}

	public inline function removeActor(actorKey:CellActor) {
		view.removeActor(actorKey);
	}

	// ------- update --------

	public inline function updateCell(pos:Pos, cell:CellType) { // CellParam!
		view.updateCell(pos, cell);
	}

	public inline function updateActor(actorKey:CellActor, action:Int) { // TODO: action!
		view.updateActor(actorKey, action);
	}


	// public function goLeft() { extendLeft(); shrinkRight(); }


}