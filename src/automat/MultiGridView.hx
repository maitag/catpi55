package automat;

import haxe.ds.Vector;
import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import view.View;
import automat.Pos.xy as P;

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

		// initialize all other with index but without grid-connection
		for (i in 1...data.length) data.set( i, new GridView(multiGridView, i) );

		// initialize the root gridView .. TODO: init !
		data.set( 0, new GridView(multiGridView, 0, rootGrid, rootX, rootX, rootY, rootY+1) ); // y+1 to get started somewhere while initialization-grow
	}

	inline function modX(x:Int) return (x<0) ? sizeX+x : x % sizeX;
	inline function modY(y:Int) return (y<0) ? sizeY+y : y % sizeY;
	inline function index(x:Int, y:Int) return modY(y) * sizeX + modX(x);

	public inline function get(x:Int, y:Int):GridView {
		return data.get( index(x, y) );
	}

	public inline function addToGrid(x:Int, y:Int, grid:Grid, xFrom:Int, xTo:Int, yFrom:Int, yTo:Int) {
		if (grid != null) get(x, y).addToGrid( grid, xFrom, xTo, yFrom, yTo);
	}

	public inline function removeFromGrid(x:Int, y:Int) {
		get(x, y).removeFromGrid();
	}

	// TODO: for larger grid-graph-topology (what is also out of "convex") it needs deeper->neighbour-traversing

	// ------------------- LEFT -----------------------
	public function canGrowLeft():Bool {
		if ( xFrom == xTo ) return false;
		var y = yFrom;
		while (y != yTo ) {
			if ( get(xFrom, y).leftGrid != null ) return true;
			y = modY(y+1);
		}
		return false;
	}	
	public inline function growLeft() {
		var x = xFrom;
		var y = yFrom;
		xFrom = modX(xFrom-1);
		while (y != yTo ) {
			var gridView = get(x, y);
			addToGrid(xFrom, y, gridView.leftGrid, Grid.WIDTH-1, Grid.WIDTH, gridView.yFrom, gridView.yTo);
			y = modY(y+1);
		}		
	}
	public inline function shrinkLeft() {
		var y = yFrom;		
		while (y != yTo ) {
			removeFromGrid(xFrom, y);
			y = modY(y+1);
		}
		xFrom = modX(xFrom+1);		
	}
	// one step for all gridViews at border
	public inline function growLeftViews() {	
		var y = yFrom;
		while (y != yTo ) {
			get(xFrom, y).growLeft();
			y = modY(y+1);
		}		
	}
	public inline function shrinkLeftViews() {
		var y = yFrom;
		while (y != yTo ) {
			get(xFrom, y).shrinkLeft();
			y = modY(y+1);
		}		
	}

	// TODO: right, top, bottom
	
	// debug
	public function toString():String {
		var s = "\n";
		for (y in 0...sizeY) {
			for (x in 0...sizeX) {
				var gridView = data.get( index(x, y) );
				var index = "null";
				if (gridView.grid != null) index = '[${gridView.index},${gridView.xFrom},${gridView.xTo},${gridView.yFrom},${gridView.yTo}]'; 
				s += index + ",";
			}
			s+="\n";
		}
		return s;
	}
}


// this to sync later by RPC via peote-net!
class MultiGridView {

	// ---- handles the used GridViews -----
	public var gridViewCache:GridViewCache;

	// -------------------------------------
	// first position inside rootGrid (middle from where it grows?)
	public var rootX:Int;
	public var rootY:Int;
	
	// size of the view relative to root-point
	public var leftSize:Int = 0;
	public var rightSize:Int = 0;
	public var topSize:Int = 0;
	public var bottomSize:Int = 0;
	// max size to grow
	public var maxLeftSize:Int = 5;
	public var maxRightSize:Int = 6;
	public var maxTopSize:Int = 3;
	public var maxBottomSize:Int = 4;


	public var view:View; // this will be the client into network later!

	// -------------------------------------
	
	public function new(view:View, rootGrid:Grid, rootX:Int, rootY:Int, gridViewsSizeX:Int, gridViewsSizeY:Int) {
		this.view = view;
		this.rootX = rootX;
		this.rootY = rootY;

		// TODO: calculate the cache size by the max..Sizes! 

		gridViewCache = new GridViewCache( this, rootGrid, rootX, rootY, gridViewsSizeX, gridViewsSizeY );

		var i:Int=0;
		while ( i++ < maxLeftSize && canGrowLeft() ) growLeft();
		// i=0; while ( i++ < maxRightSize && canGrowRight() ) growRight();
		// i=0; while ( i++ < maxTopSize && canGrowTop() ) growTop();
		// i=0; while ( i++ < maxBottomSize && canGrowBottom() ) growBottom();
	}

/*
	public function init(view:View) {
		this.view = view;
		syncInit();
	}
*/

/*	inline function syncInit() {
	}
*/

	// ------------------- LEFT -----------------------
	public inline function canGrowLeft():Bool {
		if (rootX-leftSize > 0 || (leftSize-rootX) % Grid.WIDTH > 0) return true;
		else return gridViewCache.canGrowLeft();
	}
	public inline function growLeft() {
		if (rootX-leftSize > 0 || (leftSize-rootX) % Grid.WIDTH > 0) gridViewCache.growLeftViews();
		else gridViewCache.growLeft();
		leftSize++;
	}
	public inline function canShrinkLeft():Bool return leftSize > 0;
	public inline function shrinkLeft() {
		if (rootX-leftSize > 0 || (leftSize-rootX) % Grid.WIDTH < Grid.WIDTH) gridViewCache.shrinkLeftViews();
		else gridViewCache.shrinkLeft();
		leftSize--;
	}

	// TODO: right, top, bottom


	// TODO:
	public inline function goLeft() {
		if ( !canGrowLeft() ) return;
		// shrinkRight();
		growLeft();
	}

	// ------------------------------------------
	// ------------ Sync to View ----------------
	// ------------------------------------------

	public var lastGridViewIndex:Int = -1;

	public inline function addGridView(index:Int) {
		view.addGridView(index);
	}

	public inline function removeGridView(index:Int) {
		view.removeGridView(index);
	}
	
	public inline function switchGridViewIndex(index:Int) {
		if (index == lastGridViewIndex) return;
		view.switchGridViewIndex(index);
		lastGridViewIndex = index;
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