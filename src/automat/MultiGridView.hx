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
			addToGrid(xFrom, y, gridView.leftGrid, Grid.WIDTH, Grid.WIDTH, gridView.yFrom, gridView.yTo);
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

	// ------------------- RIGHT -----------------------
	public function canGrowRight():Bool {
		if ( xFrom == xTo ) return false;
		var y = yFrom;
		while (y != yTo ) {
			if ( get(xTo-1, y).rightGrid != null ) return true;
			y = modY(y+1);
		}
		return false;
	}	
	public inline function growRight() {
		var y = yFrom;
		while (y != yTo ) {
			var gridView = get(xTo-1, y);
			addToGrid(xTo, y, gridView.rightGrid, 0, 0, gridView.yFrom, gridView.yTo);
			y = modY(y+1);
		}
		xTo = modX(xTo+1);		
	}
	public inline function shrinkRight() {
		var y = yFrom;		
		xTo = modX(xTo-1);
		while (y != yTo ) {
			removeFromGrid(xTo, y);
			y = modY(y+1);
		}
	}
	// one step for all gridViews at border
	public inline function growRightViews() {	
		var y = yFrom;
		while (y != yTo ) {
			get(xTo-1, y).growRight();
			y = modY(y+1);
		}		
	}
	public inline function shrinkRightViews() {
		var y = yFrom;
		while (y != yTo ) {
			get(xTo-1, y).shrinkRight();
			y = modY(y+1);
		}		
	}

	// -------------------- TOP ------------------------
	public function canGrowTop():Bool {
		if ( yFrom == yTo ) return false;
		var x = xFrom;
		while (x != xTo ) {
			if ( get(x, yFrom).topGrid != null ) return true;
			x = modY(x+1);
		}
		return false;
	}	
	public inline function growTop() {
		var x = xFrom;
		var y = yFrom;
		yFrom = modX(yFrom-1);
		while (x != xTo ) {
			var gridView = get(x, y);
			addToGrid(x, yFrom, gridView.topGrid, gridView.xFrom, gridView.xTo, Grid.HEIGHT, Grid.HEIGHT);
			x = modY(x+1);
		}		
	}
	public inline function shrinkTop() {
		var x = xFrom;		
		while (x != xTo ) {
			removeFromGrid(x, yFrom);
			x = modY(x+1);
		}
		yFrom = modX(yFrom+1);		
	}
	// one step for all gridViews at border
	public inline function growTopViews() {	
		var x = xFrom;
		while (x != xTo ) {
			get(x, yFrom).growTop();
			x = modY(x+1);
		}		
	}
	public inline function shrinkTopViews() {
		var x = xFrom;
		while (x != xTo ) {
			get(x, yFrom).shrinkTop();
			x = modY(x+1);
		}		
	}

	// ------------------- BOTTOM -----------------------
	public function canGrowBottom():Bool {
		if ( yFrom == yTo ) return false;
		var x = xFrom;
		while (x != xTo ) {
			if ( get(x, yTo-1).bottomGrid != null ) return true;
			x = modY(x+1);
		}
		return false;
	}	
	public inline function growBottom() {
		var x = xFrom;
		while (x != xTo ) {
			var gridView = get(x, yTo-1);
			addToGrid(x, yTo, gridView.bottomGrid, gridView.xFrom, gridView.xTo, 0, 0);
			x = modY(x+1);
		}		
		yTo = modX(yTo+1);
	}
	public inline function shrinkBottom() {
		var x = xFrom;
		yTo = modX(yTo-1);
		while (x != xTo ) {
			removeFromGrid(x, yTo);
			x = modY(x+1);
		}		
	}
	// one step for all gridViews at border
	public inline function growBottomViews() {	
		var x = xFrom;
		while (x != xTo ) {
			get(x, yTo-1).growBottom();
			x = modY(x+1);
		}		
	}
	public inline function shrinkBottomViews() {
		var x = xFrom;
		while (x != xTo ) {
			get(x, yTo-1).shrinkBottom();
			x = modY(x+1);
		}		
	}


	


	// ------ debug -------
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

		// grow up to max-sizes
		while ( canGrowLeft() ) growLeft();
		while ( canGrowRight() ) growRight();
		trace("TOOOOOP");
		while ( canGrowTop() ) growTop();
		trace("BOOOOTOM");
		while ( canGrowBottom() ) growBottom();
	}

	// TODO: let travel rootX and rootY !!!

	// ------------------- LEFT -----------------------
	public inline function canGrowLeft():Bool {
		if (leftSize == maxLeftSize) return false;
		if (rootX-leftSize > 0 || (leftSize-rootX) % Grid.WIDTH > 0) return true;
		else return gridViewCache.canGrowLeft();
	}
	public inline function growLeft() {
		if (leftSize >= rootX && (leftSize-rootX) % Grid.WIDTH == 0) gridViewCache.growLeft();
		gridViewCache.growLeftViews();
		leftSize++;
	}
	public inline function canShrinkLeft():Bool return leftSize > 0;
	public inline function shrinkLeft() {
		gridViewCache.shrinkLeftViews();
		leftSize--;
		if ( leftSize >= rootX && (leftSize-rootX) % Grid.WIDTH == 0) gridViewCache.shrinkLeft();
	}

	// ------------------- RIGHT -----------------------
	public inline function canGrowRight():Bool {
		if (rightSize == maxRightSize) return false;
		if ((rootX+rightSize) % Grid.WIDTH > 0) return true;
		else return gridViewCache.canGrowRight();
	}
	public inline function growRight() {
		if ((rootX+rightSize) % Grid.WIDTH == 0) gridViewCache.growRight();
		gridViewCache.growRightViews();
		rightSize++;
	}
	public inline function canShrinkRight():Bool return rightSize > 0;
	public inline function shrinkRight() {
		gridViewCache.shrinkRightViews();
		rightSize--;
		if ((rootX+rightSize) % Grid.WIDTH == 0) gridViewCache.shrinkRight();
	}

	// -------------------- TOP ------------------------
	public inline function canGrowTop():Bool {
		if (topSize == maxTopSize) return false;
		if (rootY-topSize > 0 || (topSize-rootY) % Grid.HEIGHT > 0) return true;
		else return gridViewCache.canGrowTop();
	}
	public inline function growTop() {
		if (topSize >= rootY && (topSize-rootY) % Grid.HEIGHT == 0) gridViewCache.growTop();
		gridViewCache.growTopViews();
		topSize++;
	}
	public inline function canShrinkTop():Bool return topSize > 0;
	public inline function shrinkTop() {
		gridViewCache.shrinkTopViews();
		topSize--;
		if ( topSize >= rootY && (topSize-rootY) % Grid.HEIGHT == 0) gridViewCache.shrinkTop();
	}

	// ------------------- BOTTOM ----------------------
	public inline function canGrowBottom():Bool {
		if (bottomSize == maxBottomSize) return false;
		if ((rootY+bottomSize) % Grid.HEIGHT > 0) return true;
		else return gridViewCache.canGrowBottom();
	}
	public inline function growBottom() {
		if ((rootY+bottomSize) % Grid.HEIGHT == 0) gridViewCache.growBottom();
		gridViewCache.growBottomViews();
		bottomSize++;
	}
	public inline function canShrinkBottom():Bool return bottomSize > 0;
	public inline function shrinkBottom() {
		gridViewCache.shrinkBottomViews();
		bottomSize--;
		if ((rootY+bottomSize) % Grid.HEIGHT == 0) gridViewCache.shrinkBottom();
	}


	// ------------ SCROLLING --------------
	public inline function scrollLeft() {
		if ( !canGrowLeft() ) return;
		shrinkRight();
		growLeft();
	}
	public inline function scrollRight() {
		if ( !canGrowRight() ) return;
		shrinkLeft();
		growRight();
	}
	public inline function scrollTop() {
		if ( !canGrowTop() ) return;
		shrinkBottom();
		growTop();
	}
	public inline function scrollBottom() {
		if ( !canGrowBottom() ) return;
		shrinkTop();
		growBottom();
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