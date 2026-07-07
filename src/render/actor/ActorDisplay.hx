package render.actor;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;

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

	public function new(x:Int, y:Int, w:Int, h:Int, bufferStatic:Buffer<ActorElemStatic>, bufferAnim:Buffer<ActorElemAnim>, textures:Array<Texture>)
	{
		this = new Display(x, y, w, h);

		//----------------------------------------------------
		
		var programStatic = new Program(bufferStatic);
		// programAnim = new Program(bufferAnim);

		// programStatic.setTexture(texture);
		programStatic.setMultiTexture(textures);
		// texture.setSmooth(true, false);

		programStatic.blendEnabled = true;
		
		/*
		// to reduce visual gap while zooming, not need whitout texture-interpolation (smooth) or by using framebuffer-way
		var zoomFix = 0.0;
		// var zoomFix = 0.37;
		programStatic.setFormula("texSizeX", '${Util.toFloatString(
			zoomFix + Tiles.tileWidth+Tiles.gap+Tiles.gap
		)}');
		programStatic.setFormula("texSizeY", '${Util.toFloatString(
			zoomFix + Tiles.tileHeight+Tiles.gap+Tiles.gap
		)}');
		*/

		// TODO: extra programs for animated elements etc.
		// programAnim = new Program(bufferAnim);

		this.addProgram(programStatic);
		// this.addProgram(programAnim);
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