package automat.actor;

#if macro

import haxe.macro.Expr;
import haxe.macro.Context;

class Actor {
	static public function build(shape:String, unroll = false):Array<Field>
	{
		var fields = Context.getBuildFields();
		var bitGrid:util.BitGrid = shape;


		// ---- width and height getters of the shape ----

		fields.push({
			name: "width",
			doc: "shape width",
			access: [APublic],
			kind: FProp("get", "never", macro:Int, null),
			pos: Context.currentPos()
		});
		fields.push({
			name: "get_width",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return $v{bitGrid.width},
				ret: macro:Int
			})
		});

		fields.push({
			name: "height",
			doc: "shape height",
			access: [APublic],
			kind: FProp("get", "never", macro:Int, null),
			pos: Context.currentPos()
		});
		fields.push({
			name: "get_height",
			access: [AInline],
			pos: Context.currentPos(),
			kind: FFun({
				args: [],
				expr: macro return $v{bitGrid.height},
				params: [],
				ret: macro:Int
			})
		});
		


		// ------------------------------------------------
		// -------------- Shape functions -----------------
		// ------------------------------------------------

		if (unroll)
		{
			// builds the unrolled functions of Shape.hx
			automat.actor.ShapeMacro.build(bitGrid, fields);
		}
		else 
		{
			// delegates to the functions of Shape.hx
			fields.push({
				name: "shapeBitGrid",
				access: [APublic],
				pos: Context.currentPos(),
				kind: FVar(macro:Array<String>, macro $v{bitGrid.toArrayString()})
			});

			for (fname in ["addToGrid"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [
							{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
							{name:"pos", opt:false, meta:[], type: macro:util.Pos}
						],
						expr: macro automat.actor.Shape.$fname(this, grid, pos, shapeBitGrid),
						ret: null
					})
				});

			for (fname in ["removeFromGrid"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro automat.actor.Shape.$fname(this, shapeBitGrid),
						ret: null
					})
				});

			for (fname in ["isFitIntoGrid"])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [
							{name:"grid", opt:false, meta:[], type: macro:automat.Grid},
							{name:"pos", opt:false, meta:[], type: macro:util.Pos}
						],
						expr: macro return automat.actor.Shape.$fname(grid, pos, blockedCellType, shapeBitGrid),
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

			for (fname in ["goLeft","goRight","goUp","goDown","goLeftUp","goLeftDown","goRightUp","goRightDown"
				])
				fields.push({
					name: fname,
					access: [APublic, AInline],
					pos: Context.currentPos(),
					kind: FFun({
						args: [],
						expr: macro automat.actor.Shape.$fname(this, shapeBitGrid),
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