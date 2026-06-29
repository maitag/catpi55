package automat;

import haxe.ds.Vector;
import automat.Pos.xy as P;

class GridViewCache {

	var data:Vector<GridView>;
	
	public var sizeX(default, null):Int;
	public var sizeY(default, null):Int;

	// actual range of used GridViews
	var xFrom:Int = 0;
	var xTo:Int = 1;
	var yFrom:Int = 0;
	var yTo:Int = 1;
	
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

	public inline function addToGrid(x:Int, y:Int, grid:Grid, offsetX:Int, offsetY:Int, _xFrom:Int, _xTo:Int, _yFrom:Int, _yTo:Int) {
		if (grid != null) get(x, y).addToGrid( grid, offsetX, offsetY, _xFrom, _xTo, _yFrom, _yTo);
	}

	public inline function removeFromGrid(x:Int, y:Int) {
		get(x, y).removeFromGrid();
	}

	// TODO: for larger grid-graph-topology (what is also out of "convex") it needs deeper->neighbour-traversing
	// ------------------- LEFT -----------------------
	public function canGrowLeft():Bool {
		for (y in yFrom...yTo) if ( get(xFrom, y).leftGrid != null ) return true;
		return false;
	}	
	public inline function growLeft() {
		for (y in yFrom...yTo) {
			var gridView = get(xFrom, y);
			// TODO: no need gridView.offsetX/Y if using xFrom-1 and xTo instead
			// trace("always equal X ?",xFrom-1, gridView.offsetX-1);
			// trace("always equal Y ?",y, gridView.offsetY);
			addToGrid(xFrom-1, y, gridView.leftGrid, gridView.offsetX-1, gridView.offsetY, Grid.WIDTH, Grid.WIDTH, gridView.yFrom, gridView.yTo);
		}
		xFrom--;
	}
	public inline function shrinkLeft() {
		for (y in yFrom...yTo) removeFromGrid(xFrom, y);
		xFrom++;
	}
	public inline function growLeftViews() for (y in yFrom...yTo) get(xFrom, y).growLeft();
	public inline function shrinkLeftViews() for (y in yFrom...yTo) get(xFrom, y).shrinkLeft();	

	// ------------------- RIGHT -----------------------
	public function canGrowRight():Bool {
		for (y in yFrom...yTo) if ( get(xTo-1, y).rightGrid != null ) return true;
		return false;
	}	
	public inline function growRight() {
		for (y in yFrom...yTo) {
			var gridView = get(xTo-1, y);
			addToGrid(xTo, y, gridView.rightGrid, gridView.offsetX+1, gridView.offsetY, 0, 0, gridView.yFrom, gridView.yTo);
		}
		xTo++;
	}
	public inline function shrinkRight() {
		xTo--;
		for (y in yFrom...yTo) removeFromGrid(xTo, y);
	}
	public inline function growRightViews() for (y in yFrom...yTo) get(xTo-1, y).growRight();
	public inline function shrinkRightViews() for (y in yFrom...yTo) get(xTo-1, y).shrinkRight();

	// -------------------- TOP ------------------------
	public function canGrowTop():Bool {
		for (x in xFrom...xTo) if ( get(x, yFrom).topGrid != null ) return true;
		return false;
	}	
	public inline function growTop() {
		for (x in xFrom...xTo) {
			var gridView = get(x, yFrom);
			addToGrid(x, yFrom-1, gridView.topGrid, gridView.offsetX, gridView.offsetY-1, gridView.xFrom, gridView.xTo, Grid.HEIGHT, Grid.HEIGHT);
		}
		yFrom--;
	}
	public inline function shrinkTop() {
		for (x in xFrom...xTo) removeFromGrid(x, yFrom);
		yFrom++;		
	}
	public inline function growTopViews() for (x in xFrom...xTo) get(x, yFrom).growTop();
	public inline function shrinkTopViews() for (x in xFrom...xTo) get(x, yFrom).shrinkTop();

	// ------------------- BOTTOM -----------------------
	public function canGrowBottom():Bool {
		for (x in xFrom...xTo) if ( get(x, yTo-1).bottomGrid != null ) return true;
		return false;
	}	
	public inline function growBottom() {
		for (x in xFrom...xTo) {
			var gridView = get(x, yTo-1);
			addToGrid(x, yTo, gridView.bottomGrid, gridView.offsetX, gridView.offsetY+1, gridView.xFrom, gridView.xTo, 0, 0);
		}
		yTo++;
	}
	public inline function shrinkBottom() {
		yTo--;
		for (x in xFrom...xTo) removeFromGrid(x, yTo);	
	}
	public inline function growBottomViews() for (x in xFrom...xTo) get(x, yTo-1).growBottom();	
	public inline function shrinkBottomViews() for (x in xFrom...xTo) get(x, yTo-1).shrinkBottom();	


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

