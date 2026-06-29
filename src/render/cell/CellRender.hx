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
import peote.view.TextureConfig;
import peote.view.Color;
import peote.view.Load;

import automat.Grid;
import automat.Cell;

import render.cell.CellDisplay;
import render.cell.CellElemAnim;
import render.cell.CellElemStatic;

import asset.generated.Cells as CellAsset;
import asset.generated.Cells.TileID as TileID;
// import asset.generated.Cells.AnimID as AnimID;

class ElemViewCache<T> {

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

	public inline function get(x:Int, y:Int):T {
		return data.get( index(x, y) );
	}
	public inline function set(x:Int, y:Int, value:T) {
		data.set( index(x, y), value );
	}
}

class CellRender {

	//--------------- STATIC ---------------------------

	public static var peoteView:PeoteView;

	public static var texture:Texture;

	public static function init(peoteView:PeoteView)
	{
		CellRender.peoteView = peoteView;
		loadTextures();
	}

	public static function loadTextures()
	{
		var sheet = CellAsset.sheets[0];

		var textureConfig:TextureConfig = {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false,
			tilesX: sheet.tilesX,
			tilesY: sheet.tilesY
		};

		texture = new Texture(sheet.width*sheet.tilesX, sheet.height*sheet.tilesY, 1, textureConfig);
		
		Load.image( "assets/" + sheet.name,
			true,
			function (image:Image) {
				texture.setData(image);				
			}
		);
		
	}

	//----------------------------------------------------

	var cellDisplay:CellDisplay;

	var cellBufferStatic:Buffer<CellElemStatic>;
	var cellBufferAnim:Buffer<CellElemAnim>;

	var elemViewCache:ElemViewCache<CellElemStatic>;

 	public function new(x:Int, y:Int, width:Int, height:Int)
	{	
		cellBufferStatic = new Buffer<CellElemStatic>(1024, 512);
		cellBufferAnim = new Buffer<CellElemAnim>(1024, 512);

		// ----------------------------------------

		cellDisplay = new CellDisplay(x, y, width, height, cellBufferStatic, cellBufferAnim, texture);
		peoteView.addDisplay(cellDisplay);
		
	}

	public function initView(maxWidth:Int, maxHeight:Int)
	{
		// TODO: size here in depend of maximum-Left/Right sizes in MultiGridView!
		elemViewCache = new ElemViewCache<CellElemStatic>(maxWidth, maxHeight);
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
			case EARTH:
				var element = new CellElemStatic(TileID.EARTH, px, py, 32, 32);
				elemViewCache.set(x, y, element);
				cellBufferStatic.addElement(element);

			case WOOD:
				var element = new CellElemStatic(TileID.WOOD, px, py, 32, 32);
				elemViewCache.set(x, y, element);
				cellBufferStatic.addElement(element);

			case ROCK:
				var element = new CellElemStatic(TileID.ROCK, px, py, 32, 32);
				elemViewCache.set(x, y, element);
				cellBufferStatic.addElement(element);

			case METAL:
				var element = new CellElemStatic(TileID.METAL, px, py, 32, 32);
				elemViewCache.set(x, y, element);
				cellBufferStatic.addElement(element);

			// for fluids and air later maybe different Program and Shader
			case WATER:
				// T O D O

			default:
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
		var element = elemViewCache.get(x, y);
		if (element!=null) {
			cellBufferStatic.removeElement(element);
			elemViewCache.set(x, y, null);
		}
	}



	public function updateCell(x:Int, y:Int) {

	}


	// ------- scrolling ----------

	public var scrollOffsetX:Int = 0;
	public var scrollOffsetY:Int = 0;
	static inline var RESET_AT_OFFSET:Int = 16384;
	
	public function scrollLeft() {
		if (cellDisplay.xOffset >= RESET_AT_OFFSET) {			
			scrollOffsetX += RESET_AT_OFFSET;
			for (i in 0...(elemViewCache.sizeX * elemViewCache.sizeY)) {
				var element = elemViewCache.data.get(i);
				if (element!=null) element.x += RESET_AT_OFFSET;
			}
			cellBufferStatic.update();
			cellDisplay.xOffset -= RESET_AT_OFFSET;
		}

		cellDisplay.xOffset += 32;		
	}

	public function scrollRight() {
		if (cellDisplay.xOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetX -= RESET_AT_OFFSET;
			for (i in 0...(elemViewCache.sizeX * elemViewCache.sizeY)) {
				var element = elemViewCache.data.get(i);
				if (element!=null) element.x -= RESET_AT_OFFSET;
			}
			cellBufferStatic.update();
			cellDisplay.xOffset += RESET_AT_OFFSET;
		}

		cellDisplay.xOffset -= 32;	
	}

	public function scrollTop() {
		if (cellDisplay.yOffset >= RESET_AT_OFFSET) {			
			scrollOffsetY += RESET_AT_OFFSET;
			for (i in 0...elemViewCache.data.length) {
				var element = elemViewCache.data.get(i);
				if (element!=null) element.y += RESET_AT_OFFSET;
			}
			cellBufferStatic.update();
			cellDisplay.yOffset -= RESET_AT_OFFSET;
		}

		cellDisplay.yOffset += 32;		
	}

	public function scrollBottom() {
		if (cellDisplay.yOffset <= -RESET_AT_OFFSET) {			
			scrollOffsetY -= RESET_AT_OFFSET;
			for (i in 0...elemViewCache.data.length) {
				var element = elemViewCache.data.get(i);
				if (element!=null) element.y -= RESET_AT_OFFSET;
			}
			cellBufferStatic.update();
			cellDisplay.yOffset += RESET_AT_OFFSET;
		}

		cellDisplay.yOffset -= 32;
	}




}