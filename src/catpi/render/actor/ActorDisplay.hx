package catpi.render.actor;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Program;

@:forward(width, height, fbTexture)
abstract ActorDisplay(Display) to Display
{
	/*
	public inline function addToPeoteView(peoteView:PeoteView, ?atDisplay:Display, addBefore:Bool=false)
	{
		this.addToPeoteView(peoteView, atDisplay, addBefore);
	}
	
	public inline function removeFromPeoteView(peoteView:PeoteView) {
		this.removeFromPeoteView(peoteView);
	}
	*/

	public function new(x:Int, y:Int, w:Int, h:Int, programs:Array<Program>)
	{
		this = new Display(x, y, w, h);
		for (program in programs) this.addProgram(program);
	}

	public var zoom(get,set):Float;
	inline function get_zoom() return this.zoom;
	inline function set_zoom(z:Float) {
		var old_xOffset = xOffset; var old_yOffset = yOffset;
		xOffset = 0; yOffset = 0;
		this.zoom = z;
		xOffset = old_xOffset; yOffset = old_yOffset;
		return this.zoom = z;
	}

	public var xOffset(get,set):Float;
	inline function get_xOffset() return this.xOffset/this.zoom;
	inline function set_xOffset(offset:Float) {
		return this.xOffset = offset*this.zoom;
	}

	public var yOffset(get,set):Float;
	inline function get_yOffset() return this.yOffset/this.zoom;
	inline function set_yOffset(offset:Float) {
		return this.yOffset = offset*this.zoom;
	}
}