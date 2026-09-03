package catpi.render.cell;

import haxe.ds.Vector;

import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.TextureConfig;

// TODO: replace by Int or renderCell
import catpi.automat.Cell;

import catpi.render.RenderView;

import catpi.asset.Util;
import catpi.asset.Sheet;

@:generic class ElemViewBuffer<T> {
	public var data:Vector<T>;
	public var sizeX:Int;
	public var sizeY:Int;	
	public inline function new(sizeX:Int, sizeY:Int) {	
		this.sizeX = sizeX;	
		this.sizeY = sizeY;
		data = new Vector( sizeX * sizeY );
	}
	// inline function modX(x:Int) return (x<0) ? sizeX+x : x % sizeX;
	// inline function modY(y:Int) return (y<0) ? sizeY+y : y % sizeY;
	inline function modX(x:Int) return (x<0) ? sizeX + ((x+1) % sizeX) - 1 : x % sizeX;
	inline function modY(y:Int) return (y<0) ? sizeY + ((y+1) % sizeY) - 1 : y % sizeY;

	inline function index(x:Int, y:Int) return modY(y) * sizeX + modX(x);
	public inline function get(x:Int, y:Int):T return data.get( index(x, y) );
	public inline function set(x:Int, y:Int, value:T) data.set( index(x, y), value );
}

class CellRender {

	//--------------- STATIC ---------------------------
	public static var peoteView:PeoteView;
	public static var texture:Texture;

	public static var configStatic:Vector<CellElemConfigStatic>;

	public static function init(peoteView:PeoteView, sheets:Array<Sheet>, configStatic:CellConfigStatic) {
		CellRender.peoteView = peoteView;
		
		loadTextures(sheets);

		CellRender.configStatic = configStatic.toConfigVector();
	}

	public static function loadTextures(sheets:Array<Sheet>) {
		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
		};

		texture = Util.loadTextures(sheets, textureConfig, false)[0]; // only the first one
	}
	// -------------------------------------------------

	var display:CellDisplay;

	var bufferStatic:Buffer<CellElemStatic>;
	var bufferAnim:Buffer<CellElemAnim>;

	var elemViewBuffer:ElemViewBuffer<CellElemStatic>;

	public var zoom(get,set):Float;
	inline function get_zoom():Float return display.zoom;
	inline function set_zoom(z:Float):Float return display.zoom = z;

	// -------------------------------------------------

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{	
		bufferStatic = new Buffer<CellElemStatic>(1024, 512);
		bufferAnim = new Buffer<CellElemAnim>(1024, 512);

		display = new CellDisplay(x, y, width, height, RenderView.cellWidth, RenderView.cellHeight, bufferStatic, bufferAnim, texture);
		peoteView.addDisplay(display);		
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
		var px = x * RenderView.cellWidth + scrollOffsetX;
		var py = y * RenderView.cellHeight + scrollOffsetY;

		// TODO: empty cells
		var config = configStatic.get(cellType);
		// var element = new CellElemStatic(config.tileNr, config.sheetNr, px, py);
		var element = new CellElemStatic(config.tileNr, px, py);
		elemViewBuffer.set(x, y, element);
		bufferStatic.addElement(element);

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
		if (display.xOffset >= RESET_AT_OFFSET) {			
			scrollOffsetX += RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.x += RESET_AT_OFFSET;
			}
			bufferStatic.update();
			display.xOffset -= RESET_AT_OFFSET;
		}
		display.xOffset += RenderView.cellWidth;		
	}

	public function scrollRight() {
		if (display.xOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetX -= RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.x -= RESET_AT_OFFSET;
			}
			bufferStatic.update();
			display.xOffset += RESET_AT_OFFSET;
		}
		display.xOffset -= RenderView.cellWidth;	
	}

	public function scrollTop() {
		if (display.yOffset >= RESET_AT_OFFSET) {			
			scrollOffsetY += RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.y += RESET_AT_OFFSET;
			}
			bufferStatic.update();
			display.yOffset -= RESET_AT_OFFSET;
		}
		display.yOffset += RenderView.cellHeight;		
	}

	public function scrollBottom() {
		if (display.yOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetY -= RESET_AT_OFFSET;
			for (i in 0...elemViewBuffer.data.length) {
				var element = elemViewBuffer.data.get(i);
				if (element!=null) element.y -= RESET_AT_OFFSET;
			}
			bufferStatic.update();
			display.yOffset += RESET_AT_OFFSET;
		}
		display.yOffset -= RenderView.cellHeight;
	}




}