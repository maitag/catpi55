package util;

import haxe.iterators.StringIterator;
import haxe.ds.Vector;

abstract BitGrid(Vector<Int>) {

	inline public function new(width:Int, height:Int) 
	{
		this = new Vector<Int>(1 + Math.ceil(width * height / 32));
		#if (haxe_ver >= "4.3.7")
		this.fill(0);
		#else
		for (i in 1...this.length) this.set(i, 0);
		#end
		this.set(0, width<<16 | height);
	}

	public var width(get, never):Int;
	inline function get_width():Int return this.get(0)>>16;

	public var height(get, never):Int;
	inline function get_height():Int return this.get(0) & 65535;

	public function set(x:Int, y:Int, value:Bool = true) {
		if (x >= width || y >= height || x < 0 || y < 0 ) throw("BitGrid coors out of bounds.");
		var p:Int = y*width + x;
		var i:Int = 1 + (p>>5);
		var b:Int = p & 31;
		if (value) this.set(i, this.get(i) | (1<<b) );
		else this.set(i, this.get(i) & ~(1<<b) );
	}

	public function get(x:Int, y:Int):Bool {
		if (x >= width || y >= height || x < 0 || y < 0 ) throw("BitGrid coors out of bounds.");
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
		return !(hasLeft && hasRight && hasTop && hasBottom);
	}

	@:from
	public static inline function fromArrayString(shape:Array<String>):BitGrid {
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

	static var parseStringRegExp = ~/\|([^|]+)\|/;
	@:from
	public static inline function fromString(shape:String):BitGrid {
		var a = new Array<String>();
		while (parseStringRegExp.match(shape)) {
			a.push(parseStringRegExp.matched(1));
			shape = parseStringRegExp.matchedRight();
		}
		return fromArrayString(a);
	}
    
	@:to
	public inline function toArrayString():Array<String> {
		var a = new Array<String>();
		for (y in 0...height) {
			var s = "";
			for (x in 0...width) {
				s += get(x,y) ? "#" : " ";
			}
			a.push(s);
		}
		return a;
	}

	@:to
	public inline function toString():String {
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

