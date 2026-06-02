package render.cell;

import haxe.ds.Vector;
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

import render.cell.CellDisplay;
import render.cell.CellElemAnim;
import render.cell.CellElemStatic;

// import asset.generated.Cells;

class CellRender {

	var peoteView:PeoteView;
	var cellDisplay:CellDisplay;

	var cellBufferStatic:Buffer<CellElemStatic>;
	var cellBufferAnim:Buffer<CellElemAnim>;

	public static function loadTextures() {
		/*
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
		*/
	}

	//----------------------------------------------------

	var elements:Vector<CellElem>;

 	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;
	
		cellBufferStatic = new Buffer<CellElemStatic>(1024, 512);
		cellBufferAnim = new Buffer<CellElemAnim>(1024, 512);

		// ----------------------------------------

		cellDisplay = new CellDisplay(0, 0, 512, 512, cellBufferStatic, cellBufferAnim);
		peoteView.addDisplay(cellDisplay);
		
	}

	public function initView(width:Int, height:Int, viewWidth:Int, viewHeight:Int, viewMaxWidth:Int, viewMaxHeight:Int) {
		elements = new Vector<CellElem>(viewMaxWidth * viewMaxHeight);
	}
	// public function purgeView()

	public function addCell(x:Int, y:Int, cellType:Int) {
		
	}
	public function delCell(x:Int, y:Int) {

	}

	public function scrollLeft() {
		
	}

}