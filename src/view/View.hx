package view;

import automat.Grid;
import haxe.ds.Vector;
import peote.view.PeoteView;

import automat.Pos;
import automat.Pos.xy as P;
import automat.Cell;
import automat.Cell.CellActor;
import automat.GridView;
import render.Render;


class ViewActor {
	public function new() {
		
	}
	// TODO
}



 // this will be later handled by Remote-Client in peote-net!
class View {

	public var peoteView:PeoteView;
	
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

	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		// var render = new Render(peoteView);

	}


	// ----------------------------------------------
	// --------- Sync from MultiGridView ------------
	// ----------------------------------------------

	public function init(gridViewsSizeX:Int, gridViewsSizeY:Int) {
		trace("init", gridViewsSizeX, gridViewsSizeY);
		// actors = new Vector<Vector<ViewActor>>(maxGridViews);
		gridData = new Vector<Pos>(gridViewsSizeX * gridViewsSizeY);

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

	// ------- add ----------

	public function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Int>) {

		trace("addCells", 'from:${xFrom+gridViewX},${yFrom+gridViewY} -> to ${xTo+gridViewX},${yTo+gridViewY}', [for (cell in cells) (cell:Cell).type.toString()].join(",") );
		// for (cell in cells) trace((cell:Cell).type);
	}

	public function addActor(pos:Pos, actorKey:CellActor, name:String) {
		trace("addActor", pos, actorKey, name);

		// TODO
		// actors.set(actorKey, new ViewActor() ); // CHECK: actorKey have to start by 0 here!
	}

	// ------ remove ---------

	public function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) {
		trace("removeCells", xFrom, yFrom, xTo, yTo);
	}

	public function removeActor(actorKey:CellActor) {
		trace("removeActor", actorKey);
		// actors.set(actorKey, null);
	}

	// ------- update --------

	public function updateCell(pos:Pos, cell:CellType) { // CellParam!
		trace("updateCell", pos, cell);
	}

	public function updateActor(actorKey:CellActor, action:Int) { // TODO: action!
		trace("updateActor", actorKey, action);
	}
	

}