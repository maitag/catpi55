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