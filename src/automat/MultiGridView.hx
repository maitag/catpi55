package automat;

import haxe.ds.Vector;
import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import view.MultiView;
import automat.Pos.xy as P;


// this will be later handled by Remote-Server in peote-net!
class MultiGridView {

	public var rootGridViewKey:Int = 0;
	// TODO: better topLeft and bottomRight grid

	// position into rootGrid
	public var x:Int = 0;
	public var y:Int = 0;

	// viktor keys to identify the used GridViews
	public var gridViews:Viktor<GridView>;

	// actual size over all GridViews
	public var width:Int = 0;
	public var height:Int = 0;

	public var maxWidth:Int;
	public var maxHeight:Int;
	public var maxGridViewX(get, never):Int;
	public var maxGridViewY(get, never):Int;
	inline function get_maxGridViewX():Int return Math.ceil(maxWidth/Grid.WIDTH) + 1;
	inline function get_maxGridViewY():Int return Math.ceil(maxHeight/Grid.HEIGHT) + 1;

	public var multiView:MultiView; // this will be the client into network later!

	// -------------------------------------

	public function new(rootGrid:Grid, x:Int, y:Int, maxWidth:Int, maxHeight:Int) {
		this.x = x;
		this.y = y;
		this.maxWidth = maxWidth;
		this.maxHeight = maxHeight;

		// TODO: create first rootGridView
		var rootGridView = new GridView(rootGrid, x, x, y, y, false, false);
		gridViews = new Viktor<GridView>(maxGridViewX * maxGridViewY);
		rootGridViewKey = gridViews.add(rootGridView);
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



	// public function goLeft() { extendLeft(); shrinkRight(); }


}