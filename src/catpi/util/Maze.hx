package catpi.util;

import haxe.ds.GenericStack;
import haxe.iterators.StringIterator;
import haxe.ds.Vector;

import peote.view.math.Random;

@:forward(width, height, set, get, fromArrayString, fromString, toArrayString, toString)
abstract Maze(BitGrid) {

	inline public function new(width:Int, height:Int, ?seed:Null<Int>) 
	{
		this = new BitGrid(width, height);
		gimmeMaze(new Random(seed));
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

// ---------------------- Kruskal with cell merging -------------------------

@:forward(width, height, set, get, fromArrayString, fromString, toArrayString, toString)
abstract KruskalCellMerge(BitGrid) {

	inline public function new(width:Int, height:Int, roomCount:Int, ?seed:Null<Int>) 
	{
		this = new BitGrid(width, height, 0xffffffff);
		gimmeKruskalCellMerge(new Random(seed), roomCount);
	}

	// recursive path compression
	function find(parent:Vector<Int>, i:Int):Int {
		if (parent[i] == i) return i;
		return parent[i] = find(parent, parent[i]);
	}

	inline function union(parent:Vector<Int>, i:Int, j:Int):Bool {
		var rootI = find(parent, i);
		var rootJ = find(parent, j);
		if (rootI != rootJ) {
			parent[rootI] = rootJ;
			return true;
		}
		return false;
	}

	function gimmeKruskalCellMerge(random:Random, roomCount:Int) {
		
		// init
		var w:Int = (this.width & 1) == 0 ? this.width - 1 : this.width;
		var h:Int = (this.height & 1) == 0 ? this.height - 1 : this.height;
		
		var parent = new Vector<Int>(w * h);
		for (i in 0...parent.length) parent[i] = i;		

		var numCellsX:Int = (w - 1) >> 1;
		var numCellsY:Int = (h - 1) >> 1;
		
		// 1. Alle Standard-Basis-Zellen aktivieren (ungerade Koordinaten)
		// TODO: this can be also optimized while initialization
		var x:Int = 1;
		while (x < w - 1) {
			var y:Int = 1;
			while (y < h - 1) {
				this.set(x, y, false);
				y += 2;
			}
			x += 2;
		}

		// 2. Cell-Merging: Zufällige größere Räume/Gänge vorab verschmelzen		
		for (_ in 0...roomCount) {
			// Directly calculate random odd coordinates without array lookup
			// var cx:Int = Std.int(Math.random() * numCellsX);
			// var cy:Int = Std.int(Math.random() * numCellsY);
			var cx:Int = random.uint(numCellsX);
			var cy:Int = random.uint(numCellsY);
			var startX:Int = (cx << 1) + 1;
			var startY:Int = (cy << 1) + 1;
			
			// Zufällige Ausdehnung (Schritte in 2er-Schritten für gültige Zellen)
			// var roomW:Int = (Std.int(Math.random() * 2) + 1) << 1;
			// var roomH:Int = (Std.int(Math.random() * 2) + 1) << 1;
			var roomW:Int = random.uintLimit(1, 2) << 1;
			var roomH:Int = random.uintLimit(1, 2) << 1;

			// Prüfen, ob der Raum in die Map passt
			if (startX + roomW < w - 1 && startY + roomH < h - 1) {
				var baseId:Int = startX * h + startY;
				var endX:Int = startX + roomW;
				var endY:Int = startY + roomH;
				
				// TODO: merge both loops

				// Alle Wände innerhalb dieses Bereichs einreißen
				for (tx in startX...endX + 1) {
					for (ty in startY...endY + 1) {
						this.set(tx, ty, false);
					}
				}
				
				// Logische Zellen mit der Basis-Zelle verschmelzen (nur ungerade Koordinaten)
				for (tx in startX...endX + 1) {
					if ((tx & 1) == 1) {
						var txBase:Int = tx * h;
						for (ty in startY...endY + 1) {
							if ((ty & 1) == 1) {
								union(parent, baseId, txBase + ty);
							}
						}
					}
				}
			}
		}

		// 3. Alle potenziellen Trennwände zwischen logischen Zellen sammeln
		// pack coordinates into a single 32-bit Int (8 bits per coordinate) for optimization
		var edges = new Array<Int>();
		var ex:Int = 1;
		while (ex < w - 1) {
			var ey = 1;
			while (ey < h - 1) {
				if (ex + 2 < w - 1) {
					edges.push(ex | (ey << 8) | ((ex + 2) << 16) | (ey << 24));
				}
				if (ey + 2 < h - 1) {
					edges.push(ex | (ey << 8) | (ex << 16) | ((ey + 2) << 24));
				}
				ey += 2;
			}
			ex += 2;
		}

		// Wände zufällig mischen: Fisher-Yates Shuffle (O(N) instead of O(N log N) sort)
		var i:Int = edges.length;
		while (i > 1) {
			// var j:Int = Std.int(Math.random() * i);
			var j:Int = random.uint(i);
			i--;
			var temp:Int = edges[i];
			edges[i] = edges[j];
			edges[j] = temp;
		}
		
		// 4. Kruskal-Logik: Wände entfernen, wenn die Zellen nicht im selben Set sind
		for (edge in edges) {
			var x1:Int = edge & 0xFF;
			var y1:Int = (edge >> 8) & 0xFF;
			var x2:Int = (edge >> 16) & 0xFF;
			var y2:Int = (edge >> 24) & 0xFF; // & 0xFF ensures safety even if sign-extended

			var id1:Int = x1 * h + y1;
			var id2:Int = x2 * h + y2;

			var root1:Int = find(parent, id1);
			var root2:Int = find(parent, id2);

			if (root1 != root2) {
				parent[root1] = root2;
				this.set((x1 + x2) >> 1, (y1 + y2) >> 1, false);
			}
		}


	}



}
