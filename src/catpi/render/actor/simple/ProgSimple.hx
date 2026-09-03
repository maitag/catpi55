package catpi.render.actor.simple;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.Color;

@:forward
abstract ProgSimple(Program) to Program
{
	//inline function getBuffer():Buffer<Elem> return this.buffer;

	public function new(textures:Array<Texture>, bufferMinSize:Int, bufferGrowSize:Int = 0, bufferAutoShrink:Bool = false)
	{
	
		var buffer = new Buffer<ElemSimple>(bufferMinSize, bufferGrowSize, bufferAutoShrink);
		this = new Program(buffer);

		ElemSimple.buffer = buffer;
		
		// this.setMultiTexture(textures);

		// texture.setSmooth(true, false);

		this.blendEnabled = true;
		
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

	}


}