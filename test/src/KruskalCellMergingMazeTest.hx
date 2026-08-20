package;

import haxe.ds.Vector;

// this will be BIT on or off
enum TileType {
	Wall;
	Floor;
}
/*
enum abstract -> NO NO NO -> ON LY B I Ts <- 0 or 1 .)
*/

// at first -> could that not be a "@:struct" also ?)
class WallEdge {
	public var x1:Int;
	public var y1:Int;
	public var x2:Int;
	public var y2:Int;

	public function new(x1:Int, y1:Int, x2:Int, y2:Int) {
		this.x1 = x1;
		this.y1 = y1;
		this.x2 = x2;
		this.y2 = y2;
	}
}

class KruskalCellMergingMazeTest {
	private var width:Int;
	private var height:Int;
	private var grid:Vector<Vector<TileType>>; // <- BIT GRID
	
	// Union-Find Datenstruktur für die Zellen-Sets
	private var parent:Vector<Int>;

	public function new(width:Int, height:Int) {
		// Breite und Höhe sollten ungerade sein, damit Wände und Gänge sauber trennbar sind
		this.width = width % 2 == 0 ? width + 1 : width;
		this.height = height % 2 == 0 ? height + 1 : height;
		
		initGrid();
	}

	private function initGrid() {
		grid = new Vector(this.width);
		for (x in 0...this.width) {
			grid[x] = new Vector(this.height);
			for (y in 0...this.height) {
				grid[x][y] = TileType.Wall;
			}
		}

		// Die mathematischen Zellen liegen nur auf ungeraden Koordinaten
		// Eine Zelle bei (x,y) entspricht dem Index im Union-Find: (x * height + y)
		parent = new Vector(this.width * this.height);
		for (i in 0...parent.length) {
			parent[i] = i;
		}
	}

	// Union-Find: Find-Operation mit Pfadkompression
	private function find(i:Int):Int {
		if (parent[i] == i) return i;
		parent[i] = find(parent[i]);
		return parent[i];
	}

	// Union-Find: Union-Operation
	private function union(i:Int, j:Int):Bool {
		var rootI = find(i);
		var rootJ = find(j);
		if (rootI != rootJ) {
			parent[rootI] = rootJ;
			return true;
		}
		return false;
	}

	private function getCellId(x:Int, y:Int):Int {
		return x * this.height + y;
	}

	public function generate(roomCount:Int):Vector<Vector<TileType>> {
		// 1. Alle Standard-Basis-Zellen aktivieren (ungerade Koordinaten)
		var cellCoords:Array<{x:Int, y:Int}> = [];
		var x = 1;
		while (x < width - 1) {
			var y = 1;
			while (y < height - 1) {
				grid[x][y] = TileType.Floor;
				cellCoords.push({x: x, y: y});
				y += 2;
			}
			x += 2;
		}

		// 2. Cell-Merging: Zufällige größere Räume/Gänge vorab verschmelzen
		for (_ in 0...roomCount) {
			var start = cellCoords[Math.floor(Math.random() * cellCoords.length)];
			
			// Zufällige Ausdehnung (Schritte in 2er-Schritten für gültige Zellen)
			var roomW = (Math.floor(Math.random() * 2) + 1) * 2; // z.B. 2 oder 4 Zellen breit
			var roomH = (Math.floor(Math.random() * 2) + 1) * 2; // z.B. 2 oder 4 Zellen hoch

			// Prüfen, ob der Raum in die Map passt
			if (start.x + roomW < width - 1 && start.y + roomH < height - 1) {
				var baseId = getCellId(start.x, start.y);
				
				var rx = 0;
				while (rx <= roomW) {
					var ry = 0;
					while (ry <= roomH) {
						var targetX = start.x + rx;
						var targetY = start.y + ry;
						
						// Alle Wände innerhalb dieses Bereichs einreißen
						grid[targetX][targetY] = TileType.Floor;
						
						// Wenn es eine gültige logische Zelle ist, mit der Basis-Zelle verschmelzen
						if (targetX % 2 != 0 && targetY % 2 != 0) {
							union(baseId, getCellId(targetX, targetY));
						}
						ry++;
					}
					rx++;
				}
			}
		}

		// 3. Alle potenziellen Trennwände zwischen logischen Zellen sammeln
		var edges:Array<WallEdge> = [];
		var x = 1;
		while (x < width - 1) {
			var y = 1;
			while (y < height - 1) {
				// Wand nach rechts prüfen
				if (x + 2 < width - 1) {
					edges.push(new WallEdge(x, y, x + 2, y));
				}
				// Wand nach unten prüfen
				if (y + 2 < height - 1) {
					edges.push(new WallEdge(x, y, x, y + 2));
				}
				y += 2;
			}
			x += 2;
		}

		// Wände zufällig mischen (Kruskal-Mischung)
		haxe.ds.ArraySort.sort(edges, function(a, b) return Math.random() > 0.5 ? 1 : -1);

		// 4. Kruskal-Logik: Wände entfernen, wenn die Zellen nicht im selben Set sind
		for (edge in edges) {
			var id1 = getCellId(edge.x1, edge.y1);
			var id2 = getCellId(edge.x2, edge.y2);

			if (find(id1) != find(id2)) {
				union(id1, id2);
				
				// Berechne die Wand-Koordinate genau zwischen den beiden Zellen
				var wallX = Math.floor((edge.x1 + edge.x2) / 2);
				var wallY = Math.floor((edge.y1 + edge.y2) / 2);
				grid[wallX][wallY] = TileType.Floor;
			}
		}

		return grid;
	}

	// Konsolen-Vorschau zum Testen
	public function printGrid() {
		for (y in 0...height) {
			var row = "";
			for (x in 0...width) {
				row += grid[x][y] == TileType.Wall ? "##" : "  ";
			}
			trace(row);
		}
	}
}

// ----------------- optimized version by benzoyl and "qwen 3.7 plus" ---------------

class KruskalCellMergingMazeTestOpt {
	private var width:Int;
	private var height:Int;
	private var grid:Vector<Vector<TileType>>;
	private var parent:Vector<Int>;

	public function new(width:Int, height:Int) {
		// Bitwise check for odd/even is faster than modulo
		this.width = (width & 1) == 0 ? width + 1 : width;
		this.height = (height & 1) == 0 ? height + 1 : height;
		initGrid();
	}

	private function initGrid() {
		grid = new Vector(this.width);
		for (x in 0...this.width) {
			var col = new Vector<TileType>(this.height);
			for (y in 0...this.height) {
				col[y] = TileType.Wall;
			}
			grid[x] = col;
		}

		parent = new Vector(this.width * this.height);
		for (i in 0...parent.length) {
			parent[i] = i;
		}
	}

	private function find(i:Int):Int {
		// Recursive path compression is highly efficient and JIT-friendly
		if (parent[i] == i) return i;
		return parent[i] = find(parent[i]);
	}

	private inline function union(i:Int, j:Int):Bool {
		var rootI = find(i);
		var rootJ = find(j);
		if (rootI != rootJ) {
			parent[rootI] = rootJ;
			return true;
		}
		return false;
	}

	public function generate(roomCount:Int):Vector<Vector<TileType>> {
		var numCellsX = (this.width - 1) >> 1;
		var numCellsY = (this.height - 1) >> 1;

		// 1. Alle Standard-Basis-Zellen aktivieren
		var x = 1;
		while (x < this.width - 1) {
			var gridX = grid[x]; // Cache vector reference
			var y = 1;
			while (y < this.height - 1) {
				gridX[y] = TileType.Floor;
				y += 2;
			}
			x += 2;
		}

		// 2. Cell-Merging: Zufällige größere Räume/Gänge vorab verschmelzen
		for (_ in 0...roomCount) {
			// Directly calculate random odd coordinates without array lookup
			var cx = Std.int(Math.random() * numCellsX);
			var cy = Std.int(Math.random() * numCellsY);
			var startX = (cx << 1) + 1;
			var startY = (cy << 1) + 1;
			
			// Bitwise equivalent of (Math.floor(Math.random() * 2) + 1) * 2
			var roomW = (Std.int(Math.random() * 2) + 1) << 1;
			var roomH = (Std.int(Math.random() * 2) + 1) << 1;

			if (startX + roomW < this.width - 1 && startY + roomH < this.height - 1) {
				var baseId = startX * this.height + startY;
				var endX = startX + roomW;
				var endY = startY + roomH;
				
				// Alle Wände und Böden innerhalb dieses Bereichs einreißen
				for (tx in startX...endX + 1) {
					var gridTx = grid[tx];
					for (ty in startY...endY + 1) {
						gridTx[ty] = TileType.Floor;
					}
				}
				
				// Logische Zellen mit der Basis-Zelle verschmelzen (nur ungerade Koordinaten)
				for (tx in startX...endX + 1) {
					if ((tx & 1) == 1) {
						var txBase = tx * this.height;
						for (ty in startY...endY + 1) {
							if ((ty & 1) == 1) {
								union(baseId, txBase + ty);
							}
						}
					}
				}
			}
		}

		// 3. Alle potenziellen Trennwände zwischen logischen Zellen sammeln
		// OPTIMIZATION: Pack coordinates into a single 32-bit Int (8 bits per coordinate)
		var edges = new Array<Int>();
		var ex = 1;
		while (ex < this.width - 1) {
			var ey = 1;
			while (ey < this.height - 1) {
				if (ex + 2 < this.width - 1) {
					edges.push(ex | (ey << 8) | ((ex + 2) << 16) | (ey << 24));
				}
				if (ey + 2 < this.height - 1) {
					edges.push(ex | (ey << 8) | (ex << 16) | ((ey + 2) << 24));
				}
				ey += 2;
			}
			ex += 2;
		}

		// Wände zufällig mischen: Fisher-Yates Shuffle (O(N) instead of O(N log N) sort)
		var i = edges.length;
		while (i > 1) {
			var j = Std.int(Math.random() * i);
			i--;
			var temp = edges[i];
			edges[i] = edges[j];
			edges[j] = temp;
		}

		// 4. Kruskal-Logik: Wände entfernen, wenn die Zellen nicht im selben Set sind
		for (edge in edges) {
			var x1 = edge & 0xFF;
			var y1 = (edge >> 8) & 0xFF;
			var x2 = (edge >> 16) & 0xFF;
			var y2 = (edge >> 24) & 0xFF; // & 0xFF ensures safety even if sign-extended

			var id1 = x1 * this.height + y1;
			var id2 = x2 * this.height + y2;

			var root1 = find(id1);
			var root2 = find(id2);

			if (root1 != root2) {
				parent[root1] = root2;
				
				var wallX = (x1 + x2) >> 1;
				var wallY = (y1 + y2) >> 1;
				grid[wallX][wallY] = TileType.Floor;
			}
		}

		return grid;
	}

	// Konsolen-Vorschau zum Testen
	public function printGrid() {
		var rows = new Array<StringBuf>();
		for (y in 0...this.height) {
			rows.push(new StringBuf());
		}
		
		var wallChar = "##";
		var floorChar = "  ";
		
		// CACHE-FRIENDLY: Iterate 'x' on the outside to match Vector<Vector> memory layout
		for (x in 0...this.width) {
			var gridX = this.grid[x];
			for (y in 0...this.height) {
				rows[y].add(gridX[y] == TileType.Wall ? wallChar : floorChar);
			}
		}
		
		for (y in 0...this.height) {
			trace(rows[y].toString());
		}
	}
}

// ---------------------------------------------
// ------------------- TEST --------------------
// ---------------------------------------------

class Test extends lime.app.Application {

	public function new() {
		super();
		

		// Erzeugt ein Labyrinth mit 25x15 Feldern
		// var maze = new KruskalCellMergingMazeTest(100, 100); // how CRAZY \o/
		var maze = new KruskalCellMergingMazeTestOpt(100, 100);
		
		// Generiert das Labyrinth und verschmilzt vorab 8 zufällige Bereiche zu großen Gängen/Räumen
		maze.generate(500);
		
		// Gibt das Labyrinth in der CLI aus
		maze.printGrid();
	}
}

