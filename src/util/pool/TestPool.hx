package util.pool;

import lime.app.Application;

import util.pool.ObjectPool;

enum abstract CellType(Int) {
	final Sand;
	final Rock;
	final Water;
	final Gas;
}

typedef Cell = SoA<'Cell', {
	cellType:CellType,
	value:Float,
	age:Int,
	alive:Bool,
	velocity:{
		x:Float,
		y:Float,
		q:{a:Int, b:Int},
	}
}>;

class TestPool extends Application {


	public function new() {
		super();
		
		trace("start");

		var cellPool = [
			for (i in 0...2) {
				new Cell({
					cellType: [Sand, Rock, Water, Gas][i % 4],
					value: i + 0.1234,
					velocity: {x: i, y: 2 * i, q: {a: -i, b: 2 * i}},
					alive: i % 2 == 0,
					age: -i,
				});
			}
		];

		for (cell in cellPool) {
			trace(cell);
		}

	}
}
