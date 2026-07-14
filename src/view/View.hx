package view;

import automat.actor.ActorType;
import haxe.ds.Vector;

import peote.view.PeoteView;

import util.Pos;
import util.Pos.xy as P;

import automat.Grid;
import automat.Cell;
import automat.Cell.CellActor;
import render.RenderView;


// this will be later handled by Remote-Client in peote-net!
class View {

	public var peoteView:PeoteView;
	public var renderView:RenderView;
	
	// todo: setter of xFrom ...
	// public var width:Int = 0;
	// public var height:Int = 0;

	// each added grid will store its data here (at now only the offset!)
	public var gridData:Vector<Pos>;

	// from here it grows into all directions (set on first root-grid initialization)
	public var rootX:Int = 0;
	public var rootY:Int = 0;

	// actual range into global position values over multigridviews from where it starts
	public var xFrom:Int = 0;
	public var xTo:Int = 0;
	public var yFrom:Int = 0;
	public var yTo:Int = 0;

	public var zoom(get,set):Float;
	inline function get_zoom():Float return (renderView==null) ? 0.0 : renderView.zoom;
	inline function set_zoom(z:Float):Float return (renderView==null) ? 0.0 : renderView.zoom = z;

	// ----------------------------------------------

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int)
	{
		this.peoteView = peoteView;
		renderView = new RenderView(x, y, width, height);
	}

	// ----------------------------------------------
	// --------- Sync from MultiGridView ------------
	// ----------------------------------------------

	public function init(maxGrids:Int, maxWidth:Int, maxHeight:Int) {
		trace("init", maxGrids, maxWidth, maxHeight);
		gridData = new Vector<Pos>(maxGrids);
		renderView.initView(maxWidth, maxHeight);
	}

	public inline function addGridView(index:Int, offsetX:Int, offsetY:Int) {
		trace("addGridView", index, offsetX, offsetY);
		gridData.set(index, P(offsetX, offsetY));
	}

	public inline function removeGridView(index:Int) {
		trace("removeGridView", index);
	}

	// current gridViewIndex and position-offsets
	var gridViewIndex:Int = -1;
	var gridViewX:Int = 0;
	var gridViewY:Int = 0;

	public inline function switchGridViewIndex(index:Int) {
		// trace("switchGridViewIndex", index);
		gridViewIndex = index;
		var offset = gridData.get(index);
		gridViewX = offset.x * Grid.WIDTH;
		gridViewY = offset.y * Grid.HEIGHT;
	}

	// ------- add cells ----------

	public function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Cell>) {
		// trace("addCells", 'from:${xFrom+gridViewX},${yFrom+gridViewY} -> to ${xTo+gridViewX},${yTo+gridViewY}', [for (cell in cells) cell.type.toString()].join(",") );		
		renderView.cellRender.addCells(xFrom+gridViewX, yFrom+gridViewY, xTo+gridViewX, yTo+gridViewY, cells);
	}

	public function addCellsHorizontal(y:Int, xFrom:Int, xTo:Int, cells:Array<Cell>) {
		// trace("addCellsHorizontal", 'y:${y+gridViewY}, xFrom:${xFrom+gridViewX} -> xTo:${xTo+gridViewX}', [for (cell in cells) cell.type.toString()].join(",") );
		renderView.cellRender.addCellsHorizontal(y+gridViewY, xFrom+gridViewX, xTo+gridViewX, cells);
	}

	public function addCellsVertical(x:Int, yFrom:Int, yTo:Int, cells:Array<Cell>) {
		// trace("addCellsVertical", 'x:${x+gridViewX}, yFrom:${yFrom+gridViewY} -> yTo:${yTo+gridViewY}', [for (cell in cells) cell.type.toString()].join(",") );
		renderView.cellRender.addCellsVertical(x+gridViewX, yFrom+gridViewY, yTo+gridViewY, cells);
	}

	// ------ remove cells ---------

	public function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) {
		// trace("removeCells", 'from:${xFrom+gridViewX},${yFrom+gridViewY} -> to ${xTo+gridViewX},${yTo+gridViewY}');
		renderView.cellRender.removeCells(xFrom+gridViewX, yFrom+gridViewY, xTo+gridViewX, yTo+gridViewY);
	}

	public function removeCellsHorizontal(y:Int, xFrom:Int, xTo:Int) {
		// trace("removeCellsHorizontal", 'y:{$y+gridViewY}, xFrom:${xFrom+gridViewX} -> xTo:${xTo+gridViewX}');
		renderView.cellRender.removeCellsHorizontal(y+gridViewY, xFrom+gridViewX, xTo+gridViewX);
	}

	public function removeCellsVertical(x:Int, yFrom:Int, yTo:Int) {
		// trace("removeCellsVertical", 'x:${x+gridViewX}, yFrom:${yFrom+gridViewY} -> yTo:${yTo+gridViewY}');
		renderView.cellRender.removeCellsVertical(x+gridViewX, yFrom+gridViewY, yTo+gridViewY);
	}


	// ------ actor --------

	public function addActor(pos:Pos, actorKey:CellActor, actorType:ActorType) {
		var mapkey = ( gridViewIndex << (CellActor.bits-1)) | actorKey;
		trace("addActor", 'x:${pos.x+gridViewX} y:${pos.y+gridViewY}, actorKey:$actorKey, actorType:$actorType, mapkey:$mapkey');		
		renderView.actorRender.addActor(pos.x+gridViewX, pos.y+gridViewY, mapkey, actorType);
	}

	public function removeActor(actorKey:CellActor) {
		var mapkey = ( gridViewIndex << (CellActor.bits-1)) | actorKey;
		trace("removeActor", mapkey);
		renderView.actorRender.removeActor(mapkey);
	}

	// if actors origin moved to a side-grid
	public inline function actorSwitchGrid(oldGridViewIndex:Int, oldoldActorKey:CellActor, newGridViewIndex:Int, newActorKey:CellActor) {
		var oldMapkey = ( oldGridViewIndex << (CellActor.bits-1)) | oldoldActorKey;
		var newMapkey = ( newGridViewIndex << (CellActor.bits-1)) | newActorKey;
		// renderView.actorRender.actorSwitchGrid(oldMapkey, newMapkey);
	}
	
	// ------- update --------

	public function updateCell(pos:Pos, cell:CellType) { // CellParam!
		trace("updateCell", pos, cell);
	}

	public function updateActor(actorKey:CellActor, action:Int) { // TODO: action!
		trace("updateActor", actorKey, action);
	}
	

	// ------- scrolling ----------
	public function scrollLeft() {
		renderView.scrollLeft();
	}
	public function scrollRight() {
		renderView.scrollRight();
	}
	public function scrollTop() {
		renderView.scrollTop();
	}
	public function scrollBottom() {
		renderView.scrollBottom();
	}

}