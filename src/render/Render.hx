package render;

import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;
import peote.view.Load;

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

		var textureStatic = new Texture(128, 128, 1, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
		textureStatic.tilesX = 4;
		textureStatic.tilesY = 4;
		
		Load.imageArray([
			"assets/test.png"
			],
			true,
			function (image:Array<Image>) {

				textureStatic.setData(image[0]);
				
			}
		);


		
		//----------------------------------------------------
		

		display = new Display(0, 0, 512, 512);
		peoteView.addDisplay(display);

	
		bufferStatic = new Buffer<ElemStatic>(1024, 512);
		// bufferAnim = new Buffer<ElemAnim>(1024, 512);

		programStatic = new Program(bufferStatic);
		// programAnim = new Program(bufferAnim);

		programStatic.setTexture(textureStatic);

		display.addProgram(programStatic);
		// display.addProgram(programAnim);

		// ----------------------------------------

		var e0 = new ElemStatic(7, 10);
		bufferStatic.addElement(e0);
	
	

		

	}


}