package automat.actor;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;

class Actor {
	static public function build(shape:String, unroll = false):Array<Field>
	{
		var fields = Context.getBuildFields();
		var bitGrid:util.BitGrid = shape;
		
		// ---- pos, grid and gridKeys ----

		fields.push({ name: "pos", doc: "Position inside grid",
			access: [APublic],
			kind: FVar(macro:util.Pos),
			pos: Context.currentPos()
		});

		fields.push({ name: "grid", doc: "The grid where the actor is inside",
			access: [APublic],
			kind: FVar(macro:automat.Grid, null),
			pos: Context.currentPos()
		});

		for (name in ["gridKey","gridKeyR","gridKeyB","gridKeyRB"])
			fields.push({ name: name,
				access: [APublic],
				kind: FVar(macro:Int, macro -1),
				pos: Context.currentPos()
			});

		
		// ---- width and height getters of the shape ----

		fields.push({ name: "width", doc: "shape width",
			access: [APublic],
			// kind: FProp("get", "never", macro:Int, null),
			kind: FProp("get", "never", macro:Int, null),
			pos: Context.currentPos()
		});
		fields.push({ name: "get_width",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return $v{bitGrid.width},
				ret: macro:Int
			})
		});

		fields.push({ name: "height", doc: "shape height",
			access: [APublic],
			// kind: FProp("get", "never", macro:Int, null),
			kind: FProp("get", "never", macro:Int, null),
			pos: Context.currentPos()
		});
		fields.push({ name: "get_height",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return $v{bitGrid.height},
				params: [],
				ret: macro:Int
			})
		});
		
		fields.push({ name: "isMove",
			access: [APublic],
			kind: FProp("default", "null", macro:Bool, macro false),
			pos: Context.currentPos()
		});

		// ------------------------------------------------
		// --------------- SIM functions ------------------
		// ------------------------------------------------

		// delegates to the functions of ActorSim.hx

		fields.push({ name: "tryFallDown",
			access: [APublic, AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return automat.actor.ActorSim.tryFallDown(this),
				ret: macro:Bool
			})
		});

		for (fname in ["onAddToGrid", "onAfterMove"])
			fields.push({ name: fname,
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro automat.actor.ActorSim.$fname(this),
					ret: null
				})
			});
		

		// ------------------------------------------------
		// -------------- Shape functions -----------------
		// ------------------------------------------------

		if (unroll) {
			// builds the unrolled functions of Shape.hx
			automat.actor.ShapeMacro.build(bitGrid, fields);
		}
		else {
			// delegates to the functions of Shape.hx
			fields.push({ name: "shapeBitGrid",
				access: [APublic],
				pos: Context.currentPos(),
				kind: FVar(macro:Array<String>, macro $v{bitGrid.toArrayString()})
			});

			fields.push({ name: "addToGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
						{name:"pos", opt:false, meta:[], type: macro:util.Pos},
						{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
					],
					expr: macro automat.actor.Shape.addToGrid(this, grid, pos, shapeBitGrid, syncToView),
					ret: null
				})
			});

			fields.push({ name: "removeFromGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}],
					expr: macro automat.actor.Shape.removeFromGrid(this, shapeBitGrid),
					ret: null
				})
			});

			fields.push({ name: "isFitIntoGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
						{name:"pos", opt:false, meta:[], type: macro:util.Pos}
					],
					expr: macro return automat.actor.Shape.isFitIntoGrid(grid, pos, blockedCellType, shapeBitGrid),
					ret: macro:Bool
				})
			});

			for (fname in ["freeLeft","freeRight","freeUp","freeDown","freeLeftUp","freeLeftDown","freeRightUp","freeRightDown"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro return automat.actor.Shape.$fname(grid, pos, blockedCellType, shapeBitGrid),
						ret: macro:Bool
					})
				});

			for (fname in ["goLeft","goRight","goUp","goDown","goLeftUp","goLeftDown","goRightUp","goRightDown"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}],
						expr: macro automat.actor.Shape.$fname(this, shapeBitGrid, syncToView),
						ret: null
					})
				});
		}
	
		// trace("ActorMacro");
		// for (field in fields) trace(new haxe.macro.Printer().printField(field));
		return fields;
	}
}
#end