package catpi.render.actor;

class ActorElemStatic implements peote.view.Element
{
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

}
