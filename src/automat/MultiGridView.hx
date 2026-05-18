package automat;

import haxe.ds.Vector;
import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import view.View;
import automat.Pos.xy as P;


// TODO: store all used GridViews for easy scrolling and "re-usage"
class GridViewCache {

	var data:Vector<GridView>;
	public var sizeX:Int;
	public var sizeY:Int;

	// actual range of used GridViews
	public var xFrom:Int = 0;
	public var xTo:Int = 1;
	public var yFrom:Int = 0;
	public var yTo:Int = 1;
	
	public inline function new(multiGridView:MultiGridView, rootGrid:Grid, rootX:Int, rootY:Int, sizeX:Int, sizeY:Int)
	{	
		this.sizeX = sizeX;	
		this.sizeY = sizeY;

		data = new Vector<GridView>( sizeX * sizeY );

		// initialize the root gridView
		data.set( 0, new GridView(multiGridView, 0, rootGrid, rootX, rootX+1, rootY, rootY+1) );

		// initialize all other with index but without grid-connection
		for (i in 1...data.length) data.set( i, new GridView(multiGridView, i) );
	}

	inline function modX(x:Int) return (x<0) ? sizeX+x : x % sizeX;
	inline function modY(y:Int) return (y<0) ? sizeY+y : y % sizeY;
	inline function index(x:Int, y:Int) return modY(y) * sizeX + modX(x);

	public inline function get(x:Int, y:Int):GridView {
		return data.get( index(x, y) );
	}

	public inline function addToGrid(x:Int, y:Int, grid:Grid, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int) {
		data.get( index(x, y) ).addToGrid( grid, xFrom, xTo, yFrom, yTo);
	}

	public inline function removeFromGrid(x:Int, y:Int) {
		data.get( index(x, y) ).removeFromGrid();
	}

	public function canGrowLeft():Bool {
		if ( xFrom == xTo ) return false;
		var y = yFrom;
		while (y != yTo ) {
			var grid = get(xFrom, y).grid;
			if ( grid != null && grid.left != null  ) return true;
			y = modY(y+1);
		}
		return false;
	}
	// public function canGrowRight():Bool 
	
	// TODO: growLeft()

}


// this to sync later by RPC via peote-net!
class MultiGridView {

	// ---- handles the used GridViews -----
	public var gridViewCache:GridViewCache;

	// -------------------------------------
	// first position inside rootGrid (middle from where it grows?)
	public var rootX:Int;
	public var rootY:Int;

	public var view:View; // this will be the client into network later!

	// -------------------------------------
	
	public function new(rootGrid:Grid, rootX:Int, rootY:Int, gridViewsSizeX:Int, gridViewsSizeY:Int) {
		this.rootX = rootX;
		this.rootY = rootY;

		gridViewCache = new GridViewCache( this, rootGrid, rootX, rootY, gridViewsSizeX, gridViewsSizeY );


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

	public function extendLeft() {
		// if (x==0) {
		// 	x = Grid.WIDTH-1;
		//  gridViews.extendLeft();
		// }
		// else x--;
		// for (y in 0...gridViews.height) gridViews.getLeft(y).extendLeft();
	}
	public function shrinkRight() {
		// for (y in 0...gridViews.height) gridViews.getRight(y).shrinkRight();
	}

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