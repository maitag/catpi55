package view;

import haxe.ds.Vector;
import peote.view.PeoteView;

import automat.Pos;
import automat.Cell;
import automat.Cell.CellActor;
import automat.GridView;
import render.Render;



 // this will be later handled by Remote-Client in peote-net!
class MultiView {

	public var peoteView:PeoteView;
	
	public var width:Int = 0;
	public var height:Int = 0;

	// viktor keys to identify the used Views
	public var views:Viktor<View>;

	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		// TODO: disable testrenderings!
		// var render = new Render(peoteView);

	}

	public function init(maxViews:Int) {
		views = new Viktor<View>(maxViews);
	}

	// sync functions what called from automat->GridView->to here

	// ------- add ----------
/*
	public function addCells(posFrom:Pos, posTo:Pos, cells:Array<Int>) {
		trace("addCells", posFrom, posTo);
		for (cell in cells) trace((cell:Cell));
	}

	public function addActor(pos:Pos, actorKey:CellActor, name:String) {
		trace("addActor", pos, actorKey, name);

		// TODO
		actors.set(actorKey, new ViewActor() ); // CHECK: actorKey have to start by 0 here!
	}

	// ------ remove ---------

	public function removeCells(posFrom:Pos, posTo:Pos) {
		trace("removeCells", posFrom, posTo);
	}

	public function removeActor(actorKey:CellActor) {
		trace("removeActor", actorKey);
		actors.set(actorKey, null);
	}

	// ------- update --------

	public function updateCell(pos:Pos, cell:CellType) { // CellParam!
		trace("updateCell", pos, cell);
	}

	public function updateActor(actorKey:CellActor, action:Int) { // TODO: action!
		trace("updateActor", actorKey, action);
	}
	
*/
}