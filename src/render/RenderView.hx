package render;

import render.cell.CellRender;
import render.actor.ActorRender;

class RenderView {

	public var cellRender:CellRender;
	public var actorRender:ActorRender;

	public var zoom(get,set):Float;
	inline function get_zoom():Float return cellRender.zoom;
	inline function set_zoom(z:Float):Float return cellRender.zoom = actorRender.zoom = z;
	
	//----------------------------------------------------

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{
		cellRender = new CellRender(x, y, width, height);
		actorRender = new ActorRender(x, y, width, height);
	}

	public function initView(maxWidth:Int, maxHeight:Int)
	{
		cellRender.initView(maxWidth, maxHeight);
		actorRender.initView(maxWidth, maxHeight);
	}

	// ------- scrolling ----------
	
	public function scrollLeft() {
		cellRender.scrollLeft();
		actorRender.scrollLeft();
	}
	public function scrollRight() {
		cellRender.scrollRight();
		actorRender.scrollRight();
	}
	public function scrollTop() {
		cellRender.scrollTop();
		actorRender.scrollTop();
	}
	public function scrollBottom() {
		cellRender.scrollBottom();
		actorRender.scrollBottom();
	}
	
}