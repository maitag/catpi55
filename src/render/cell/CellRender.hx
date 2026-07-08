package render.cell;

import haxe.ds.Vector;
import lime.graphics.Image;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.TextureConfig;

import asset.Util;
import automat.Cell;

// assets
import asset.generated.cells.Cells;
import asset.generated.cells.Cells.TileID;
// import asset.generated.cells.Cells.AnimID;

@:generic class ElemViewBuffer<T> {
	public var data:Vector<T>;
	public var sizeX:Int;
	public var sizeY:Int;	
	public inline function new(sizeX:Int, sizeY:Int) {	
		this.sizeX = sizeX;	
		this.sizeY = sizeY;
		data = new Vector( sizeX * sizeY );
	}
	inline function modX(x:Int) return (x<0) ? sizeX+x : x % sizeX;
	inline function modY(y:Int) return (y<0) ? sizeY+y : y % sizeY;
	inline function index(x:Int, y:Int) return modY(y) * sizeX + modX(x);
	public inline function get(x:Int, y:Int):T return data.get( index(x, y) );
	public inline function set(x:Int, y:Int, value:T) data.set( index(x, y), value );
}

class CellRender {

	//--------------- STATIC ---------------------------
	public static var peoteView:PeoteView;
	public static var texture:Texture;

	public static function init(peoteView:PeoteView) {
		CellRender.peoteView = peoteView;
		loadTextures();
	}

	public static function loadTextures() {
		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
		};

		texture = Util.loadTextures(Cells.sheets, textureConfig, false)[0];
	}

	//----------------------------------------------------

	public var cellDisplay:CellDisplay;

	var bufferStatic:Buffer<CellElemStatic>;
	var bufferAnim:Buffer<CellElemAnim>;

	var elemViewBuffer:ElemViewBuffer<CellElemStatic>;

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{	
		bufferStatic = new Buffer<CellElemStatic>(1024, 512);
		bufferAnim = new Buffer<CellElemAnim>(1024, 512);

		cellDisplay = new CellDisplay(x, y, width, height, bufferStatic, bufferAnim, texture);
		peoteView.addDisplay(cellDisplay);		
	}

	public function initView(maxWidth:Int, maxHeight:Int) {
		elemViewBuffer = new ElemViewBuffer<CellElemStatic>(maxWidth, maxHeight);
	}
	// public function purgeView() {}
	
	public function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Cell>) {
		var i:Int = 0;
		for (y in yFrom...yTo)
			for (x in xFrom...xTo)
				addCell(x, y, cells[i++].type);
	}

	public function addCellsHorizontal(y:Int, xFrom:Int, xTo:Int, cells:Array<Cell>) {
		for (i in 0...(xTo - xFrom)) addCell(xFrom+i, y, cells[i].type);
	}

	public function addCellsVertical(x:Int, yFrom:Int, yTo:Int, cells:Array<Cell>) {
		for (i in 0...(yTo - yFrom)) addCell(x, yFrom+i, cells[i].type);
	}

	public inline function addCell(x:Int, y:Int, cellType:CellType) {
		var px = x*32 + scrollOffsetX;
		var py = y*32 + scrollOffsetY;
		switch (cellType) {
			// TODO
			case EARTH:
				var tile = Cells.tile(TileID.EARTH);
				var element = new CellElemStatic(tile.anim(tile.animID[0]).start, px, py, 32, 32);
				// var element = new CellElemStatic(TileID.EARTH, px, py, 32, 32);
				elemViewBuffer.set(x, y, element);
				bufferStatic.addElement(element);

			case WOOD:
				var tile = Cells.tile(TileID.WOOD);
				var element = new CellElemStatic(tile.anim(tile.animID[0]).start, px, py, 32, 32);
				// var element = new CellElemStatic(TileID.WOOD, px, py, 32, 32);
				elemViewBuffer.set(x, y, element);
				bufferStatic.addElement(element);

			case ROCK:
				var tile = Cells.tile(TileID.ROCK);
				var element = new CellElemStatic(tile.anim(tile.animID[0]).start, px, py, 32, 32);
				// var element = new CellElemStatic(TileID.ROCK, px, py, 32, 32);
				elemViewBuffer.set(x, y, element);
				bufferStatic.addElement(element);

			case METAL:
				var tile = Cells.tile(TileID.METAL);
				var element = new CellElemStatic(tile.anim(tile.animID[0]).start, px, py, 32, 32);
				// var element = new CellElemStatic(TileID.METAL, px, py, 32, 32);
				elemViewBuffer.set(x, y, element);
				bufferStatic.addElement(element);

			// for fluids and air later maybe different Program and Shader
			case WATER:
				// T O D O

			default: //throw('CellRender - cellType $cellType not implemented yet!');
		}
	}

	public function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) {
		for (y in yFrom...yTo)		
			for (x in xFrom...xTo)
				removeCell(x, y);
	}

	public function removeCellsHorizontal(y:Int, xFrom:Int, xTo:Int) {
		for (x in xFrom...xTo) removeCell(x, y);
	}

	public function removeCellsVertical(x:Int, yFrom:Int, yTo:Int) {
		for (y in yFrom...yTo) removeCell(x, y);
	}

	public inline function removeCell(x:Int, y:Int) {
		var element = elemViewBuffer.get(x, y);
		if (element!=null) {
			bufferStatic.removeElement(element);
			elemViewBuffer.set(x, y, null);
		}
	}


	public function updateCell(x:Int, y:Int) {
		// TODO
	}


	// ------- scrolling ----------

	public var scrollOffsetX:Int = 0;
	public var scrollOffsetY:Int = 0;
	static inline var RESET_AT_OFFSET:Int = 16384;
	
	public function scrollLeft() {
		if (cellDisplay.xOffset >= RESET_AT_OFFSET) {			
			scrollOffsetX += RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.x += RESET_AT_OFFSET;
			}
			bufferStatic.update();
			cellDisplay.xOffset -= RESET_AT_OFFSET;
		}
		cellDisplay.xOffset += 32;		
	}

	public function scrollRight() {
		if (cellDisplay.xOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetX -= RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.x -= RESET_AT_OFFSET;
			}
			bufferStatic.update();
			cellDisplay.xOffset += RESET_AT_OFFSET;
		}
		cellDisplay.xOffset -= 32;	
	}

	public function scrollTop() {
		if (cellDisplay.yOffset >= RESET_AT_OFFSET) {			
			scrollOffsetY += RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.y += RESET_AT_OFFSET;
			}
			bufferStatic.update();
			cellDisplay.yOffset -= RESET_AT_OFFSET;
		}
		cellDisplay.yOffset += 32;		
	}

	public function scrollBottom() {
		if (cellDisplay.yOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetY -= RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.y -= RESET_AT_OFFSET;
			}
			bufferStatic.update();
			cellDisplay.yOffset += RESET_AT_OFFSET;
		}
		cellDisplay.yOffset -= 32;
	}




}