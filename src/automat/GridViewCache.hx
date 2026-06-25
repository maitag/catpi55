package automat;

import haxe.ds.Vector;
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

