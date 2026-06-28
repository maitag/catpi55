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

	public function initView(maxWidth:Int, maxHeight:Int)
	{
		cellRender.initView(maxWidth, maxHeight);
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
	public function scrollTop() {
		cellRender.scrollTop();
		// actorRenderer.scrollTop();
	}
	public function scrollBottom() {
		cellRender.scrollBottom();
		// actorRenderer.scrollBottom();
	}
	
}