package catpi.automat;

import haxe.ds.Vector;

import catpi.automat.actor.IActor;
import catpi.automat.Cell.CellActor;
import catpi.automat.Cell.CellType;
import catpi.view.View;

import catpi.util.Pos;
// import catpi.util.Pos.xy as P;

/*

Automate Model & Simmulation (Server)       View and Rendering (Client)
-------------------------------------       ------------------------------
grid -> gridView \                                         -> renderCell
grid -> gridView   --> multiGridView  ----> view -> render -> renderActor
grid -> gridView /                                         -> render...
...
*/

// this to sync later by RPC via peote-net!
class MultiGridView {

	// ---- handles the used GridViews -----
	public var gridViewCache:GridViewCache;

	// size of the view
	public var xFrom:Int = 0;
	public var xTo:Int = 0;
	public var yFrom:Int = 0;
	public var yTo:Int = 0;

	public var maxWidth:Int = 32;
	public var maxHeight:Int = 32;

	public var width(get,never):Int;
	inline function get_width():Int return xTo - xFrom;
	public var height(get,never):Int;
	inline function get_height():Int return yTo - yFrom;

	public var view:View; // this will be the client into network later!

	// -------------------------------------
	
	public function new(view:View, rootGrid:Grid, rootX:Int, rootY:Int, maxWidth:Int, maxHeight:Int)
	{
		this.view = view;
		this.maxWidth = maxWidth;
		this.maxHeight = maxHeight;
	
		// calculate the cache size by the max..Sizes!
		var gridViewsSizeX:Int = Math.ceil(maxWidth / Grid.WIDTH) + 1;
		var gridViewsSizeY:Int = Math.ceil(maxHeight / Grid.HEIGHT) + 1;
		
		// initialize the View
		initView(gridViewsSizeX * gridViewsSizeY, maxWidth, maxHeight);
		
		gridViewCache = new GridViewCache( this, rootGrid, rootX, rootY, gridViewsSizeX, gridViewsSizeY );
		// after instancing the cell at root point is already added
		xFrom = rootX; xTo = rootX+1;
		yFrom = rootY; yTo = rootY+1;

		// grow up to max-sizes
		var moreToGrow = true;
		while (moreToGrow) {
			moreToGrow = false;
			if ( canGrowRight() ) { moreToGrow = true; growRight();  }
			if ( canGrowLeft()  ) { moreToGrow = true; growLeft();   }
			if ( canGrowBottom()) { moreToGrow = true; growBottom(); }
			if ( canGrowTop()   ) { moreToGrow = true; growTop();    }
		}

		trace('width:$width, height:$height, xFrom:$xFrom, xTo:$xTo, yFrom:$yFrom, yTo:$yTo');

	}

	// ------------ SCROLLING --------------
	public inline function scrollLeft() {
		if (canShrinkRight()) shrinkRight();
		if (canGrowLeft()) growLeft();
		// trace('width:$width, height:$height, xFrom:$xFrom, xTo:$xTo, yFrom:$yFrom, yTo:$yTo');
	}
	public inline function scrollRight() {
		if (canShrinkLeft()) shrinkLeft();
		if (canGrowRight()) growRight();
		// trace('width:$width, height:$height, xFrom:$xFrom, xTo:$xTo, yFrom:$yFrom, yTo:$yTo');
	}
	public inline function scrollTop() {
		if (canShrinkBottom()) shrinkBottom();
		if (canGrowTop()) growTop();
		// trace('width:$width, height:$height, xFrom:$xFrom, xTo:$xTo, yFrom:$yFrom, yTo:$yTo');
	}
	public inline function scrollBottom() {
		if (canShrinkTop()) shrinkTop();
		if (canGrowBottom()) growBottom();
		// trace('width:$width, height:$height, xFrom:$xFrom, xTo:$xTo, yFrom:$yFrom, yTo:$yTo');
	}

	// ------------------- LEFT -----------------------
	public inline function canGrowLeft(checkMaxSize=true):Bool {
		if (checkMaxSize && width == maxWidth) return false;
		// if (xFrom % Grid.WIDTH > 0) return true;
		if (xFrom % Grid.WIDTH != 0) return true;
		else return gridViewCache.canGrowLeft();
	}
	public inline function growLeft() {
		if (xFrom % Grid.WIDTH == 0) gridViewCache.growLeft();
		gridViewCache.growLeftViews(); xFrom--;
	}
	public inline function canShrinkLeft():Bool return width > 1;
	public inline function shrinkLeft() {
		gridViewCache.shrinkLeftViews(); xFrom++;
		if (xFrom % Grid.WIDTH == 0) gridViewCache.shrinkLeft();
	}
	// ------------------- RIGHT -----------------------
	public inline function canGrowRight(checkMaxSize=true):Bool {
		if (checkMaxSize && width == maxWidth) return false;
		// if (xTo % Grid.WIDTH > 0) return true;
		if (xTo % Grid.WIDTH != 0) return true;
		else return gridViewCache.canGrowRight();
	}
	public inline function growRight() {
		if (xTo % Grid.WIDTH == 0) gridViewCache.growRight();
		gridViewCache.growRightViews(); xTo++;
	}
	public inline function canShrinkRight():Bool return width > 1;
	public inline function shrinkRight() {
		gridViewCache.shrinkRightViews(); xTo--;
		if (xTo % Grid.WIDTH == 0) gridViewCache.shrinkRight();
	}
	// -------------------- TOP ------------------------
	public inline function canGrowTop(checkMaxSize=true):Bool {
		if (checkMaxSize && height == maxHeight) return false;
		// if (yFrom % Grid.HEIGHT > 0) return true;
		if (yFrom % Grid.HEIGHT != 0) return true;
		else return gridViewCache.canGrowTop();
	}
	public inline function growTop() {
		if (yFrom % Grid.HEIGHT == 0) gridViewCache.growTop();
		gridViewCache.growTopViews(); yFrom--;
	}
	public inline function canShrinkTop():Bool return height > 1;
	public inline function shrinkTop() {
		gridViewCache.shrinkTopViews(); yFrom++;
		if (yFrom % Grid.HEIGHT == 0) gridViewCache.shrinkTop();
	}
	// ------------------- BOTTOM ----------------------
	public inline function canGrowBottom(checkMaxSize=true):Bool {
		if (checkMaxSize && height == maxHeight) return false;
		// if (yTo % Grid.HEIGHT > 0) return true;
		if (yTo % Grid.HEIGHT != 0) return true;
		else return gridViewCache.canGrowBottom();
	}
	public inline function growBottom() {
		if (yTo % Grid.HEIGHT == 0) gridViewCache.growBottom();
		gridViewCache.growBottomViews(); yTo++;
	}
	public inline function canShrinkBottom():Bool return height > 1;
	public inline function shrinkBottom() {
		gridViewCache.shrinkBottomViews(); yTo--;
		if (yTo % Grid.HEIGHT == 0) gridViewCache.shrinkBottom();
	}

	// ------------------------------------------
	// ------------ Sync to View ----------------
	// ------------------------------------------

	public var lastGridViewIndex:Int = -1;

	public inline function initView(maxGrids:Int, maxWidth:Int, maxHeight:Int) {
		view.init(maxGrids, maxWidth, maxHeight);
	}

	public inline function addGridView(index:Int, offsetX:Int, offsetY:Int) {
		view.addGridView(index, Pos8x8Neg.xy(offsetX, offsetY));
	}

	public inline function removeGridView(index:Int) {
		view.removeGridView(index);
	}
	
	public inline function switchGridViewIndex(index:Int) {
		if (index == lastGridViewIndex) return;
		view.switchGridViewIndex(index);
		lastGridViewIndex = index;
	}

	// ------ add cells ---------

	public inline function addCells(xF:Int, yF:Int, xT:Int, yT:Int, cells:Array<Int>) {
		view.addCells(xF, yF, xT, yT, cells);
	}

	public inline function addCellsHorizontal(y:Int, xF:Int, xT:Int, cells:Array<Int>) {
		view.addCellsHorizontal(y, xF, xT, cells);
	}

	public inline function addCellsVertical(x:Int, yF:Int, yT:Int, cells:Array<Int>) {
		view.addCellsVertical(x, yF, yT, cells);
	}

	// ------ remove cells ---------

	public inline function removeCells(xF:Int, yF:Int, xT:Int, yT:Int) {
		view.removeCells(xF, yF, xT, yT);
	}

	public inline function removeCellsHorizontal(y:Int, xF:Int, xT:Int) {
		view.removeCellsHorizontal(y, xF, xT);
	}

	public inline function removeCellsVertical(x:Int, yF:Int, yT:Int) {
		view.removeCellsVertical(x, yF, yT);
	}


	// ------- actor ---------

	public inline function addActor(actor:IActor, actorKey:CellActor, originPosX:Int) {
		var x:Int = actor.pos.x;
		if (x > originPosX) x -= Grid.WIDTH;
		view.addActor(x, actor.pos.y, actorKey, actor.type);
	}

	public inline function removeActor(actorKey:CellActor) {
		view.removeActor(actorKey);
	}

	// if actors origin moved to a side-grid it is need a key-exchange at view-side
	public inline function actorToSideGrid(newIndex:Int, oldKey:CellActor, newKey:CellActor) {
		view.actorToSideGrid(newIndex, oldKey, newKey);
	}

	// actor MOVES
	public inline function actorGoLeft(actorKey:Int, time:Int) view.actorGoLeft(actorKey, time);
	public inline function actorGoRight(actorKey:Int, time:Int) view.actorGoRight(actorKey, time);
	public inline function actorGoUp(actorKey:Int, time:Int) view.actorGoUp(actorKey, time);
	public inline function actorGoDown(actorKey:Int, time:Int) view.actorGoDown(actorKey, time);	
	public inline function actorGoLeftUp(actorKey:Int, time:Int) view.actorGoLeftUp(actorKey, time);
	public inline function actorGoLeftDown(actorKey:Int, time:Int) view.actorGoLeftDown(actorKey, time);
	public inline function actorGoRightUp(actorKey:Int, time:Int) view.actorGoRightUp(actorKey, time);
	public inline function actorGoRightDown(actorKey:Int, time:Int) view.actorGoRightDown(actorKey, time);


	// ------- update --------
	// TODO:
	public inline function updateCell(pos:Pos, cell:CellType) { // CellParam!
		view.updateCell(pos, cell);
	}

	public inline function updateActor(actorKey:CellActor, action:Int) { // TODO: action!
		view.updateActor(actorKey, action);
	}

}