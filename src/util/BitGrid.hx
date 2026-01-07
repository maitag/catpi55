package util;

import haxe.iterators.StringIterator;
import haxe.ds.Vector;

abstract BitGrid(Vector<Int>) {

	inline public function new(width:Int, height:Int) 
	{
		this = new Vector<Int>(1 + Math.ceil(width * height / 32));
		this.fill(0);
		this.set(0, width<<16 | height);
	}

	public var width(get, never):Int;
	inline function get_width():Int return this.get(0)>>16;

	public var height(get, never):Int;
	inline function get_height():Int return this.get(0) & 65535;

	public function set(x:Int, y:Int, value:Bool = true) {
		var p:Int = y*width + x;
		var i:Int = 1 + (p>>5);
		var b:Int = p & 31;
		if (value) this.set(i, this.get(i) | (1<<b) );
		else this.set(i, this.get(i) & ~(1<<b) );
	}

	public function get(x:Int, y:Int):Bool {
		var p:Int = y*width + x;
		var i:Int = 1 + (p>>5);
		var b:Int = p & 31;
		return (this.get(i) & (1<<b)) != 0;
	}

	public function hasGap():Bool {
		var hasLeft = false;
		var hasRight = false;
		var hasTop = false;
		var hasBottom = false;
		for (y in 0...height) {
			for (x in 0...width) {
				if (get(x,y)) {
					if (x==0) hasLeft = true;
					if (x==width-1) hasRight = true;
					if (y==0) hasTop = true;
					if (y==height-1) hasBottom = true;
				}
			}
		}
		return (hasLeft && hasRight && hasTop && hasBottom);
	}

	@:from
	static inline function fromArrayString(shape:Array<String>) {
		if (shape == null || shape.length==0) return new BitGrid(0, 0);
		
		var width = shape[0].length;
		var bitGrid = new BitGrid(width, shape.length);

		var x:Int = 0; var y:Int = 0;
		for (s in shape) {
			if (s==null || s.length==0) throw("The String to init a new BitGrid instance is invalid.");
			if (width != s.length) throw("The Strings to init a new BitGrid have not the same length.");
			for (c in new StringIterator(s)) {
				if (c!=32) bitGrid.set(x, y);
				x++;
			}
			x=0; y++;
		}

		return bitGrid;
	}
    
	@:to
	inline function toString():String {
		var s = "";
		for (y in 0...height) {
			for (x in 0...width) {
				s += get(x,y) ? "#" : " ";
			}
			if (y<height-1) s+="\n";
		}
		return s;
	}

}

