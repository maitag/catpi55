package view;

import peote.view.PeoteView;

import automat.Pos;
import automat.Cell;
import automat.Cell.CellActor;
import automat.GridView;
import render.Render;

 // this will be later handled by Remote-Client in peote-net!
class View {

	public var peoteView:PeoteView;
	
	public var width:Int = 0;
	public var height:Int = 0;

	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		// TODO: disable testrenderings!
		// var render = new Render(peoteView);

	}


	// sync functions from automat->GridView

	// ------- add ----------

	public function addCells(posFrom:Pos, posTo:Pos, cells:Array<Int>) {
		trace("addCells", posFrom, posTo);
	}

	public function addActor(pos:Pos, actorKey:CellActor, name:String) {
		trace("addActor", pos, actorKey, name);
	}

	// ------ remove ---------

	public function removeCells(posFrom:Pos, posTo:Pos) {
		trace("removeCells", posFrom, posTo);
	}

	public function removeActor(actorKey:CellActor) {
		trace("removeActor", actorKey);
	}

	// ------- update --------

	public function updateCell(pos:Pos, cell:CellType) { // CellParam!
		trace("updateCell", pos, cell);
	}

	public function updateActor(actorKey:CellActor, action:Int) { // TODO: action!
		trace("updateActor", actorKey, action);
	}
	

}