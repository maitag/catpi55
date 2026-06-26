package automat;

import haxe.ds.Vector;
import automat.actor.IActor;
import automat.Cell.CellActor;
import automat.Cell.CellType;
import view.View;
import automat.Pos.xy as P;

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

	// -------------------------------------
	// first position inside rootGrid (middle from where it grows)
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

	// TODO:
	// public var xFrom:Int = 0;
	// public var xTo:Int = 0;
	// public var yFrom:Int = 0;
	// public var yTo:Int = 0;

	// public var maxWidth:Int = 32;
	// public var maxHeight:Int = 32;

	// public var width(get,never):Int;
	// inline function get_width():Int return xTo - xFrom;
	// public var height(get,never):Int;
	// inline function get_height():Int return yTo - yFrom;

	public var view:View; // this will be the client into network later!

	// -------------------------------------
	
	public function new(view:View, rootGrid:Grid, rootX:Int, rootY:Int,
		maxLeftSize:Int, maxRightSize:Int, maxTopSize:Int, maxBottomSize:Int,
		gridViewsSizeX:Int, gridViewsSizeY:Int)
	{
		this.view = view;
		this.rootX = rootX;
		this.rootY = rootY;
		this.maxLeftSize = maxLeftSize;
		this.maxRightSize = maxRightSize;
		this.maxTopSize = maxTopSize;
		this.maxBottomSize = maxBottomSize;
	
		// TODO:
		// xFrom = xTo = rootX;
		// yFrom = yTo = rootY;
		// this.maxWidth = maxWidth;
		// this.maxHeight = maxHeight;
		
		
		// initialize the View
		// TODO: elementCache can be smaller also (maxWidth and maxHeight?)
		initView(gridViewsSizeX, gridViewsSizeY);
		
		// TODO: calculate the cache size by the max..Sizes!
		gridViewCache = new GridViewCache( this, rootGrid, rootX, rootY, gridViewsSizeX, gridViewsSizeY );

		// grow up to max-sizes
		trace("grow left");
		while ( canGrowLeft() ) growLeft();
		trace("grow right");
		while ( canGrowRight() ) growRight();
		trace("grow top");
		while ( canGrowTop() ) growTop();
		trace("grow bottom");
		while ( canGrowBottom() ) growBottom();

		// TODO:
		/*
		var moreToGrow = true;
		while (moreToGrow) {
			moreToGrow = false;
			if ( canGrowLeft()  ) { moreToGrow = true; growLeft();   }
			if ( canGrowRight() ) { moreToGrow = true; growRight();  }
			if ( canGrowTop()   ) { moreToGrow = true; growTop();    }
			if ( canGrowBottom()) { moreToGrow = true; growBottom(); }
		}
		*/

	}

	// ------------ SCROLLING --------------

	// TODO: still buggy here!
	// BETTER:
	// "grow-point" rootX/Y only for initialisation
	// xFrom/xTo and yFrom/yTo instead of leftSize/rightSize/...
	// width/height-getters (in depend of from/to)
	// and maxWidth/maxHeight then

	/*public inline function scrollLeft() {
		rootX--; leftSize--; rightSize++;
		if ( !canGrowLeft() ) {rootX++;leftSize++;rightSize--;return;}
		shrinkRight();
		growLeft();
	}
	public inline function scrollRight() {
		rootX++;leftSize++;rightSize--;
		if ( !canGrowRight() ) {rootX--; leftSize--; rightSize++;return;}
		shrinkLeft();
		growRight();
	}*/
	public inline function scrollLeft() {
		shrinkRight();
		growLeft();
		rootX--;leftSize--;rightSize++;
	}
	public inline function scrollRight() {
		shrinkLeft();
		growRight();
		rootX++;leftSize++;rightSize--;
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

	// ------------------- LEFT -----------------------
	// TODO
	/*
	public inline function canGrowLeft():Bool {
		if (width == maxWidth) return false;
		if (xFrom % Grid.WIDTH > 0) return true;
		else return gridViewCache.canGrowLeft();
	}
	public inline function growLeft() {
		if (xFrom % Grid.WIDTH == 0) gridViewCache.growLeft();
		gridViewCache.growLeftViews();
		xFrom--;
	}
	public inline function canShrinkLeft():Bool return width > 0;
	public inline function shrinkLeft() {
		gridViewCache.shrinkLeftViews();
		xFrom++;
		if (xFrom % Grid.WIDTH == 0) gridViewCache.shrinkLeft();
	}*/
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



	// ------------------------------------------
	// ------------ Sync to View ----------------
	// ------------------------------------------

	public var lastGridViewIndex:Int = -1;

	public inline function initView(gridViewsSizeX:Int, gridViewsSizeY:Int) {
		view.init(gridViewsSizeX, gridViewsSizeY);
	}

	public inline function addGridView(index:Int, offsetX:Int, offsetY:Int) {
		view.addGridView(index, offsetX, offsetY);
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

	public inline function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Int>) {
		view.addCells(xFrom, yFrom, xTo, yTo, cells);
	}

	public inline function addCellsHorizontal(y:Int, xFrom:Int, xTo:Int, cells:Array<Int>) {
		view.addCellsHorizontal(y, xFrom, xTo, cells);
	}

	public inline function addCellsVertical(x:Int, yFrom:Int, yTo:Int, cells:Array<Int>) {
		view.addCellsVertical(x, yFrom, yTo, cells);
	}

	// ------ remove cells ---------

	public inline function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) {
		view.removeCells(xFrom, yFrom, xTo, yTo);
	}

	public inline function removeCellsHorizontal(y:Int, xFrom:Int, xTo:Int) {
		view.removeCellsHorizontal(y, xFrom, xTo);
	}

	public inline function removeCellsVertical(x:Int, yFrom:Int, yTo:Int) {
		view.removeCellsVertical(x, yFrom, yTo);
	}


	// ------- actor ---------


	public inline function addActor(actor:IActor, actorKey:CellActor) {
		view.addActor(actor.pos, actorKey, actor.name);
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