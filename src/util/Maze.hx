package util;

import haxe.ds.GenericStack;
import peote.view.math.Random;
import haxe.iterators.StringIterator;
import haxe.ds.Vector;

@:forward(width, height, set, get, fromArrayString, fromString, toArrayString, toString)
abstract Maze(BitGrid) {

	inline public function new(width:Int, height:Int) 
	{
		this = new BitGrid(width, height);
		gimmeMaze(new Random());
	}

	function gimmeMazeRecursive(random:Random, x:Int=1, y:Int=1) {
		this.set(x, y, true);
		var d:Array<Int> = [-2, 0, 0, 2, 2, 0, 0, -2];
		while (d.length > 0) {
			// var i = d.splice( Std.int(Math.random()*d.length) & 0xfffffffe, 2);
			var i = d.splice( random.uint(d.length) & 0xfffffffe, 2);
			var a:Int = x + i[0];
			var b:Int = y + i[1];
			if (a < 0 || b < 0 || a >= this.width || b >= this.height) continue;
			if (this.get(a, b)) continue;
			if (a != x) this.set(x + ((a - x) >> 1), b, true);
			else this.set(a, y + ((b - y) >> 1), true);
			gimmeMazeRecursive(random, a, b);
		}
	}

	function gimmeMaze(random:Random) {
		var param_stack:Array<Dynamic> = [ 1, 1, [-2,0, 0,2, 2,0, 0,-2] ];
		var count:Int = 0;
		// var maxcount:Int = Std.int(this.width*this.height/4);
		var x:Int; var y:Int; var d:Array<Int>; var i:Array<Int>; var a:Int; var b:Int;
		while(param_stack.length > 0)
		{
			d = param_stack.pop();
			y = param_stack.pop();
			x = param_stack.pop();
			if (d.length == 8) {
				this.set(x, y);
				// if (++count >= maxcount) break;
			}
			i = d.splice( random.uint(d.length) & 0xfffffffe, 2);
			a = x + i[0];
			b = y + i[1];
			if (d.length > 0) {
				param_stack.push(x);
				param_stack.push(y);
				param_stack.push(d);
			}
			if (a >= 0 && b >= 0 && a < this.width && b < this.height) {
				if (!this.get(a, b))	{
					if (a != x) this.set(x + ((a - x) >> 1), b, true);
					else this.set(a, y + ((b - y) >> 1), true);
					param_stack.push(a);
					param_stack.push(b);
					param_stack.push([-2,0, 0,2, 2,0, 0,-2]);
				}
			}

		}
	}

}

