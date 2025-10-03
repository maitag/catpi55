package render;

import lime.graphics.Image;

import peote.view.intern.Util;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;
import peote.view.Load;

import assets.Tiles1x1 as Tiles;

class Render {

	var peoteView:PeoteView;
	var display:Display;

	var bufferStatic:Buffer<ElemStatic>;
	var bufferAnim:Buffer<ElemAnim>;

	var programStatic:Program;
	var programAnim:Program;

 	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		var textureStatic = new Texture(Tiles.width, Tiles.height, 1, {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false
		});

		textureStatic.tilesX = Tiles.tilesX;
		textureStatic.tilesY = Tiles.tilesY;
		
		Load.imageArray([
			Tiles.fileName
			],
			true,
			function (image:Array<Image>) {

				textureStatic.setData(image[0]);
				
			}
		);


		
		//----------------------------------------------------
		

		display = new Display(0, 0, 512, 512, Color.BLUE1);
		peoteView.addDisplay(display);
	
		bufferStatic = new Buffer<ElemStatic>(1024, 512);
		// bufferAnim = new Buffer<ElemAnim>(1024, 512);

		programStatic = new Program(bufferStatic);
		// programAnim = new Program(bufferAnim);

		programStatic.setTexture(textureStatic);
		
		// to reduce visual gap while zooming, not need whitout texture-interpolation (smooth) or by using framebuffer-way
		var zoomFix = 0.0;
		// var zoomFix = 0.37;
		
		programStatic.setFormula("texSizeX", '${Util.toFloatString(
			zoomFix + Tiles.tileWidth+Tiles.gap+Tiles.gap
		)}');
		programStatic.setFormula("texSizeY", '${Util.toFloatString(
			zoomFix + Tiles.tileHeight+Tiles.gap+Tiles.gap
		)}');
		
		programStatic.blendEnabled = true;

		display.addProgram(programStatic);
		// display.addProgram(programAnim);

		// ----------------------------------------

		var e0 = new ElemStatic(Tiles.Cube, 0, 0, Tiles.tileWidth, Tiles.tileHeight);
		bufferStatic.addElement(e0);
	
		var e1 = new ElemStatic(Tiles.Cube, Tiles.tileWidth*1, 0, Tiles.tileWidth, Tiles.tileHeight);
		bufferStatic.addElement(e1);
	
		var e2 = new ElemStatic(Tiles.Brilliant, Tiles.tileWidth*2, 0, Tiles.tileWidth, Tiles.tileHeight);
		bufferStatic.addElement(e2);

		var e4 = new ElemStatic(Tiles.Cube, 0, Tiles.tileHeight*1, Tiles.tileWidth, Tiles.tileHeight);
		bufferStatic.addElement(e4);
	
		var e5 = new ElemStatic(Tiles.Icosphere, Tiles.tileWidth*1, Tiles.tileHeight*1, Tiles.tileWidth, Tiles.tileHeight);
		bufferStatic.addElement(e5);
	
		var e6 = new ElemStatic(Tiles.Suzanne, Tiles.tileWidth*2, Tiles.tileHeight*1, Tiles.tileWidth, Tiles.tileHeight);
		bufferStatic.addElement(e6);
	
	

		

	}


}