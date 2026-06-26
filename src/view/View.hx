package view;

import haxe.ds.Vector;

import peote.view.PeoteView;

import automat.Pos;
import automat.Pos.xy as P;
import automat.Grid;
import automat.Cell;
import automat.Cell.CellActor;

import render.RenderView;


class ViewActor {
	public function new() {
		
	}
	// TODO
}



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
		
	
	// TODO
	// public var actors = new Vector<ViewActor>(CellActor.MAX_ACTORS);

	public function new(peoteView:PeoteView, x:Int, y:Int, width:Int, height:Int)
	{
		this.peoteView = peoteView;

		renderView = new RenderView(x, y, width, height);

	}


	// ----------------------------------------------
	// --------- Sync from MultiGridView ------------
	// ----------------------------------------------

	public function init(gridViewsSizeX:Int, gridViewsSizeY:Int) {

		trace("init", gridViewsSizeX, gridViewsSizeY);

		// actors = new Vector<Vector<ViewActor>>(maxGridViews);


		gridData = new Vector<Pos>(gridViewsSizeX * gridViewsSizeY);

		renderView.initView(gridViewsSizeX, gridViewsSizeY);

		// TODO: init the RenderView -> ElementCache with same size

	}

	public inline function addGridView(index:Int, offsetX:Int, offsetY:Int) {
		trace("addGridView", index, offsetX, offsetY);
		gridData.set(index, P(offsetX, offsetY));
	}

	public inline function removeGridView(index:Int) {
		trace("removeGridView", index);
	}

	// sync functions what called from automat->GridView->to here
	var gridViewIndex:Int = -1;
	var gridViewX:Int = 0;
	var gridViewY:Int = 0;

	public inline function switchGridViewIndex(index:Int) {
		trace("switchGridViewIndex", index);
		gridViewIndex = index;
		var offset = gridData.get(index);
		gridViewX = offset.x * Grid.WIDTH;
		gridViewY = offset.y * Grid.HEIGHT;
	}

	// ------- add cells ----------

	public function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Cell>) {
		trace("addCells", 'from:${xFrom+gridViewX},${yFrom+gridViewY} -> to ${xTo+gridViewX},${yTo+gridViewY}', [for (cell in cells) cell.type.toString()].join(",") );		
		renderView.cellRender.addCells(xFrom+gridViewX, yFrom+gridViewY, xTo+gridViewX, yTo+gridViewY, cells);
	}

	public function addCellsHorizontal(y:Int, xFrom:Int, xTo:Int, cells:Array<Cell>) {
		trace("addCellsHorizontal", 'y:${y+gridViewY}, xFrom:${xFrom+gridViewX} -> xTo:${xTo+gridViewX}', [for (cell in cells) cell.type.toString()].join(",") );
		renderView.cellRender.addCellsHorizontal(y+gridViewY, xFrom+gridViewX, xTo+gridViewX, cells);
	}

	public function addCellsVertical(x:Int, yFrom:Int, yTo:Int, cells:Array<Cell>) {
		trace("addCellsVertical", 'x:${x+gridViewX}, yFrom:${yFrom+gridViewY} -> yTo:${yTo+gridViewY}', [for (cell in cells) cell.type.toString()].join(",") );
		renderView.cellRender.addCellsVertical(x+gridViewX, yFrom+gridViewY, yTo+gridViewY, cells);
	}

	// ------ remove cells ---------

	public function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) {
		trace("removeCells", 'from:${xFrom+gridViewX},${yFrom+gridViewY} -> to ${xTo+gridViewX},${yTo+gridViewY}');
		renderView.cellRender.removeCells(xFrom+gridViewX, yFrom+gridViewY, xTo+gridViewX, yTo+gridViewY);
	}

	public function removeCellsHorizontal(y:Int, xFrom:Int, xTo:Int) {
		trace("removeCellsHorizontal", 'y:{$y+gridViewY}, xFrom:${xFrom+gridViewX} -> xTo:${xTo+gridViewX}');
		renderView.cellRender.removeCellsHorizontal(y+gridViewY, xFrom+gridViewX, xTo+gridViewX);
	}

	public function removeCellsVertical(x:Int, yFrom:Int, yTo:Int) {
		trace("removeCellsVertical", 'x:${x+gridViewX}, yFrom:${yFrom+gridViewY} -> yTo:${yTo+gridViewY}');
		renderView.cellRender.removeCellsVertical(x+gridViewX, yFrom+gridViewY, yTo+gridViewY);
	}


	// ------ actor --------

	public function addActor(pos:Pos, actorKey:CellActor, name:String) {

		var mapkey = ( gridViewIndex << (CellActor.bits-1)) & actorKey;

		trace("addActor", pos, mapkey, name);

		// TODO
		// actors.set(actorKey, new ViewActor() ); // CHECK: actorKey have to start by 0 here!
	}

	public function removeActor(actorKey:CellActor) {

		var mapkey = ( gridViewIndex << (CellActor.bits-1)) & actorKey;

		trace("removeActor", mapkey);
		// actors.set(actorKey, null);
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

}