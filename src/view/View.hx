package view;

import haxe.ds.Vector;
import peote.view.PeoteView;

import automat.Pos;
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

	// each added grid will store its offset to grid where its started the view
	public var gridOffsets:Vector<Pos>;

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

	public function init(maxViews:Int) {
		// actors = new Vector<Vector<ViewActor>>(maxViews);
	}

	// sync functions what called from automat->GridView->to here
	public var gridViewIndex:Int = -1;

	public inline function addGridView(index:Int) {
		trace("addGridView", index);

	}

	public inline function removeGridView(index:Int) {
		trace("removeGridView", index);
	}

	public inline function switchGridViewIndex(index:Int) {
		trace("switchGridViewIndex", index);
		gridViewIndex = index;
		
	}

	// ------- add ----------

	public function addCells(posFrom:Pos, posTo:Pos, cells:Array<Int>) {

		trace("addCells", 'from:$posFrom -> to $posTo', [for (cell in cells) (cell:Cell).type.toString()].join(",") );
		// for (cell in cells) trace((cell:Cell).type);
	}

	public function addActor(pos:Pos, actorKey:CellActor, name:String) {
		trace("addActor", pos, actorKey, name);

		// TODO
		// actors.set(actorKey, new ViewActor() ); // CHECK: actorKey have to start by 0 here!
	}

	// ------ remove ---------

	public function removeCells(posFrom:Pos, posTo:Pos) {
		trace("removeCells", posFrom, posTo);
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