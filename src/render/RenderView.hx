package render;

import peote.view.PeoteView;
import render.cell.CellRender;

class RenderView {

	public var cellRender:CellRender;

	//----------------------------------------------------

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		cellRender = new CellRender(x, y, width, height);
		
	}

	public function initView(gridViewsSizeX:Int, gridViewsSizeY:Int)
	{
		cellRender.initView(gridViewsSizeX, gridViewsSizeY);
	}

	// ------- scrolling ----------
	
	public function scrollLeft() {
		cellRender.scrollLeft();
		// actorRenderer.scrollLeft();
	}
	public function scrollRight() {
		cellRender.scrollRight();
		// actorRenderer.scrollRight();
	}
	
}