package render.cell;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;

@:forward(width, height, xOffset, yOffset, fbTexture)
abstract CellDisplay(Display) to Display
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

	public function new(x:Int, y:Int, w:Int, h:Int, bufferStatic:Buffer<CellElemStatic>, bufferAnim:Buffer<CellElemAnim>, texture:Texture)
	{
		this = new Display(x, y, w, h, Color.BLUE1);

		//----------------------------------------------------
		
		var programStatic = new Program(bufferStatic);

		programStatic.setTexture(texture);
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


}