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

	var data:Vector<T>;
	public var sizeX:Int;
	public var sizeY:Int;

	/*
	// actual range of used elements
	public var xFrom:Int = 0;
	public var xTo:Int = 0;
	public var yFrom:Int = 0;
	public var yTo:Int = 0;
*/	
	public inline function new(sizeX:Int, sizeY:Int)
	{	
		this.sizeX = sizeX;	
		this.sizeY = sizeY;
		data = new Vector( sizeX * sizeY );
	}

	inline function modX(x:Int) return (x<0) ? sizeX+x : x % sizeX;
	inline function modY(y:Int) return (y<0) ? sizeY+y : y % sizeY;
	// inline function index(x:Int, y:Int) return modY(yFrom+y) * sizeX + modX(xFrom+x);
	inline function index(x:Int, y:Int) return modY(y) * sizeX + modX(x);

	public inline function get(x:Int, y:Int):T {
		return data.get( index(x, y) );
	}
	public inline function set(x:Int, y:Int, value:T) {
		data.set( index(x, y), value );
	}
/*
	public inline function extendLeft(values:Array<T>, init = false) {
		if (!init && xFrom == xTo) throw("Error extendLeft: out of bounds");
		xFrom = modX(xFrom-1);
	}
	public inline function shrinkLeft() {
		if (xFrom == xTo) throw("Error shrinkLeft: out of bounds");
		xFrom = modX(xFrom+1);
	}
	public inline function scrollLeft() {
		xFrom = modX(xFrom+1);
		xTo = modX(xTo+1);
	}
*/

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

	public function initView(gridViewsSizeX:Int, gridViewsSizeY:Int)
	{
		elemViewCache = new ElemViewCache<CellElemStatic>(gridViewsSizeX * Grid.WIDTH, gridViewsSizeY * Grid.HEIGHT);
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
		switch (cellType) {
			case EARTH:trace("render EARTH");
				var element = new CellElemStatic(TileID.EARTH, x*32, y*32, 32, 32);
				elemViewCache.set(x, y, element);
				cellBufferStatic.addElement(element);

			case ROCK:
				var element = new CellElemStatic(TileID.ROCK, x*32, y*32, 32, 32);
				elemViewCache.set(x, y, element);
				cellBufferStatic.addElement(element);

			// for fluids and air later maybe different Program and Shader
			case WATER:
				// T O D O

			default:
		}

	}

	public function delCell(x:Int, y:Int) {}

	public function updateCell(x:Int, y:Int) {}

/*
	// ----------------------------------------
	// not sure yet how to delegate them from MultiGridView->View down to here

	public function extendLeft(values:Array<Cell> , init = false) {
		for (value in values) {

			switch (value.type) {
				case EARTH:
					var element = new CellElemStatic(TileID.EARTH, 0, 0, 32, 32);
					elemViewCache.extendLeft([element], init);
					cellBufferStatic.addElement(element);

				case ROCK:
					var element = new CellElemStatic(TileID.ROCK, 0, 0, 32, 32);
					elemViewCache.extendLeft([element], init);
					cellBufferStatic.addElement(element);

				// for fluids and air later maybe different Program and Shader
				case WATER:
					// T O D O

				default:
			}
			
		}
	}

	public inline function shrinkLeft() {
		elemViewCache.shrinkLeft();
	}

	public function scrollLeft(values:Array<Cell>) {
		elemViewCache.scrollLeft();
		// TODO: set new values on the right side by using old ones from left side

		// TODO: scroll the Display
	}
*/
}