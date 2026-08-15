package catpi.automat.actor;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;

class Actor {
	static public function build(shape:String, unroll = #if catpi_macro_unroll true #else false#end):Array<Field>
	{
		var fields = Context.getBuildFields();
		var fieldNames:Array<String> = [for (field in fields) field.name]; // to check for custom fields and overwrites

		var bitGrid:catpi.util.BitGrid = shape;
		
		// ---- pos, grid and gridKeys ----

		fields.push({ name: "pos", doc: "Position inside grid",
			access: [APublic],
			kind: FVar(macro:catpi.util.Pos),
			pos: Context.currentPos()
		});

		fields.push({ name: "grid", doc: "The grid where the actor is inside",
			access: [APublic],
			kind: FVar(macro:catpi.automat.Grid, null),
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
			// kind: FProp("default", "null", macro:Bool, macro false),
			kind: FVar(macro:Bool, macro false),
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
				expr: macro return catpi.automat.actor.ActorSim.tryFallDown(this),
				ret: macro:Bool
			})
		});

		
		for (fname in ["onAddToGrid", "onAfterMove"]) {
			var customFunctionName:String = null; 
			
			// check for custom actor-sim-eventfunctions with same name to give the generated a SUPER postfix:
			var i = fieldNames.indexOf(fname);
			// if (i >= 0) {
				// TODO: check that it have the same props (will also result into error without cos of the interface!)
				// if (fields[i]...)
			// }

			fields.push({ name: (i >= 0) ? fname + "_SUPER" : fname,
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [],
					expr: macro catpi.automat.actor.ActorSim.$fname(this),
					ret: null
				})
			});
		}

		// ------------------------------------------------
		// -------------- Shape functions -----------------
		// ------------------------------------------------

		if (unroll) {
			// builds the unrolled functions of Shape.hx
			catpi.automat.actor.ShapeMacro.build(bitGrid, fields);
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
						{name:"grid", opt:false, meta:[], type: macro:catpi.automat.Grid},
						{name:"pos", opt:false, meta:[], type: macro:catpi.util.Pos},
						{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
					],
					expr: macro catpi.automat.actor.Shape.addToGrid(this, grid, pos, shapeBitGrid, syncToView),
					ret: null
				})
			});

			fields.push({ name: "removeFromGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}],
					expr: macro catpi.automat.actor.Shape.removeFromGrid(this, shapeBitGrid, syncToView),
					ret: null
				})
			});

			fields.push({ name: "isFitIntoGrid",
				access: [APublic, AInline],
				pos: Context.currentPos(),
				kind: FFun({
					args: [
						{name:"grid", opt:false, meta:[], type: macro:catpi.automat.Grid},
						{name:"pos", opt:false, meta:[], type: macro:catpi.util.Pos}
					],
					expr: macro return catpi.automat.actor.Shape.isFitIntoGrid(grid, pos, blockedCellType, shapeBitGrid),
					ret: macro:Bool
				})
			});

			for (fname in ["freeLeft","freeRight","freeUp","freeDown"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro return catpi.automat.actor.Shape.$fname(grid, pos, blockedCellType, shapeBitGrid),
						ret: macro:Bool
					})
				});

			for (fname in ["freeLeftUp","freeLeftDown","freeRightUp","freeRightDown"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [{name:"checkSide", opt:false, meta:[], type: macro:Bool, value:macro false}],
						expr: macro return catpi.automat.actor.Shape.$fname(grid, pos, blockedCellType, shapeBitGrid, checkSide),
						ret: macro:Bool
					})
				});

			for (fname in ["goLeft","goRight","goUp","goDown","goLeftUp","goLeftDown","goRightUp","goRightDown"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [
							{name:"time", opt:false, meta:[], type: macro:Int, value:macro 0},
							{name:"syncToView", opt:false, meta:[], type: macro:Bool, value:macro true}
						],
						expr: macro catpi.automat.actor.Shape.$fname(this, shapeBitGrid, time, syncToView),
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