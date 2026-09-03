package catpi.render.actor.simple;

import peote.view.Buffer;
import catpi.render.actor.ActorElem;

class ElemSimple implements peote.view.Element implements ActorElem
{
	public static var buffer:Buffer<ElemSimple>;

	public var x(get, set):Int;
	inline function get_x():Int {
		return _xEnd;
	}
	inline function set_x(v:Int):Int {
		_xStart = _xEnd;
		return _xEnd = v;
	}

	public var y(get, set):Int;
	inline function get_y():Int {
		return _yEnd;
	}
	inline function set_y(v:Int):Int {
		_yStart = _yEnd;
		return _yEnd = v;
	}

	// position in pixel (relative to upper left corner of Display)
	@anim @posX public var _x:Int = 0;
	@anim @posY public var _y:Int = 0;
		
	// size in pixel
	@sizeX public var w:Int = 32;
	@sizeY public var h:Int = 32;
	
	// tile number
	@texTile public var tile:Int = 0;

	// texture unit (sheet index!)
	@texUnit public var sheet:Int=0;

	// scale out the gap;
	// @const @texSizeX var texSizeX:Float;
	// @const @texSizeY var texSizeY:Float;
	// var OPTIONS = { texRepeatX:false, texRepeatY:false };

	// --------------------------------------------------------------------------
	
	public function new(tile:Int, sheet:Int, x:Int, y:Int, w:Int, h:Int)
	{
		this.tile = tile;
		this.sheet = sheet;
		
		_xStart = _xEnd = x;
		_yStart = _yEnd = y;

		// time(0,0);
		
		this.w = w;
		this.h = h;
	}
	
	public function add() {
		buffer.addElement(this);
	}
	public function update() {
		buffer.updateElement(this);
	}
	public function remove() {
		buffer.removeElement(this);
	}

	inline function goX(dx:Int, startTime:Float, duration:Float) {
		_xStart = _xEnd; _xEnd += dx;
		_yStart = _yEnd;
		time(startTime, duration);
		buffer.updateElement(this);
	}
	inline function goY(dy:Int, startTime:Float, duration:Float) {
		_xStart = _xEnd;
		_yStart = _yEnd; _yEnd += dy;
		time(startTime, duration);
		buffer.updateElement(this);
	}
	inline function goXY(dx:Int, dy:Int, startTime:Float, duration:Float) {
		_xStart = _xEnd; _xEnd += dx;
		_yStart = _yEnd; _yEnd += dy;
		time(startTime, duration);
		buffer.updateElement(this);
	}
	
	public function goLeft (startTime:Float, duration:Float) goX(-RenderView.cellWidth, startTime, duration);
	public function goRight(startTime:Float, duration:Float) goX( RenderView.cellWidth, startTime, duration);
	public function goUp   (startTime:Float, duration:Float) goY(-RenderView.cellWidth, startTime, duration);
	public function goDown (startTime:Float, duration:Float) goY( RenderView.cellWidth, startTime, duration);
	
	public function goLeftUp   (startTime:Float, duration:Float) goXY(-RenderView.cellWidth, -RenderView.cellWidth, startTime, duration);
	public function goLeftDown (startTime:Float, duration:Float) goXY(-RenderView.cellWidth,  RenderView.cellWidth, startTime, duration);
	public function goRightUp  (startTime:Float, duration:Float) goXY( RenderView.cellWidth, -RenderView.cellWidth, startTime, duration);
	public function goRightDown(startTime:Float, duration:Float) goXY( RenderView.cellWidth,  RenderView.cellWidth, startTime, duration);
}
