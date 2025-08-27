package util.pool;

// origin by haxiomic: https://gist.github.com/haxiomic/568e381f65716ddf977c2e1a46234e05 
// -> fixed the bytes amount into getFieldByteLength()

/**
 * ObjectPool is a type building macro to create array-of-structure or structure-of-array pools.
 * With the intention being to improve access performance, both in CPU cache coherence by avoiding the GC
 * 
 * This implementation is a minimal working proof of concept
 * 
 * Improvements you may want to make
 * - Support deallocation of instances and space reclaiming
 * - Replace haxe.io.Bytes because field access has overhead
 */

#if !macro

@:genericBuild(util.pool.ObjectPool.ObjectPoolMacro.buildModule(AoS))
class ObjectPool<@:const GeneratedTypeName, T> { }

/**
 * Array-of-structures object pool
 */
@:genericBuild(util.pool.ObjectPool.ObjectPoolMacro.buildModule(AoS))
class AoS<@:const GeneratedTypeName, T> { }

/**
 * Structure-of-arrays object pool
 */
@:genericBuild(util.pool.ObjectPool.ObjectPoolMacro.buildModule(SoA))
class SoA<@:const GeneratedTypeName, T> { }

#else

import haxe.macro.Context;
import haxe.macro.TypeTools;
import haxe.macro.Expr;

enum abstract PoolMode(Int) {
	var AoS;
	var SoA;
}

class ObjectPoolMacro {

	static function buildModule(poolMode: Expr) {
		var poolMode: PoolMode = switch poolMode.expr {
			case EConst(CIdent('AoS')): AoS;
			case EConst(CIdent('SoA')): SoA;
			default: AoS;
		}

		// extract name and structure from type parameters
		var typeParams = switch Context.followWithAbstracts(Context.getLocalType()) {
			case TInst(_, [
				TInst(
					_.get() => {
						kind: KExpr({expr: EConst(CString(name))})
				}, []),
				anon = TAnonymous(a)
			]):
				{
					anon: anon,
					fields: a.get().fields,
					name: name
				};
			case type: Context.fatalError('First type parameter must be a string and second must be a structure', Context.currentPos());
		}

		var moduleName = typeParams.name;
		var moduleTypes = getModuleTypes(poolMode, typeParams);

		Context.defineModule('objectpool.$moduleName', moduleTypes);
		
		return macro : objectpool.$moduleName;
	}

	static function getModuleTypes(
		poolMode: PoolMode,
		params: {
			name: String,
			anon: haxe.macro.Type,
			fields: Array<haxe.macro.Type.ClassField>,
		},
		?parentTypeName
	) {
		var subModules = [];

		var generatedTypeName = params.name;

		// define abstract type
		var anonTypeComplex = TypeTools.toComplexType(params.anon);

		// determine byte length
		var byteLengths = [for (field in params.fields) {
			var length = getFieldByteLength(field);
			length;
		}];

		var totalLength = 0;
		for (x in byteLengths) totalLength += x;

		var generatedType = macro class $generatedTypeName { };
		generatedType.kind = TDAbstract(macro : Int);

		// memory allocation
		switch poolMode {
			case AoS:
				if (parentTypeName == null) {
					// add memory allocator
					var newFields = (macro class {
						static public var memory = haxe.io.Bytes.alloc(1024 * 1024); // default is 1 MiB

						static var index = 0;
						static function allocate(): Int {
							var ret = index;
							// out of space, allocate more!
							if (index + byteLength > memory.length) {
								var largerMemory = haxe.io.Bytes.alloc(memory.length * 2);
								largerMemory.blit(0, memory, 0, memory.length);
								memory = largerMemory;
							}
							index += byteLength;
							return ret;
						}

						public inline function new(fields: $anonTypeComplex) {
							this = allocate();
							set(fields);
						}

					}).fields;

					for (f in newFields) generatedType.fields.push(f);
				} else {
					// alias to parent memory
					var newFields = (macro class {
						static public var memory = $i{parentTypeName}.memory;
					}).fields;

					for (f in newFields) generatedType.fields.push(f);
				}

			case SoA:
				var initialLength = 262144;

				var doubleAllocExprs = new Array<Expr>();

				// add memory allocator
				for (i => field in params.fields) {
					// room for 262144 values initially
					var allocSize = byteLengths[i] * initialLength;
					switch Context.followWithAbstracts(field.type) {
						case anon = TAnonymous(a): // skip, sub-types declare their own memory arrays
						default:
							var memoryName = '__${field.name}_memory';
							generatedType.fields.push((macro class {
								static var $memoryName = haxe.io.Bytes.alloc($v{allocSize});
							}).fields[0]);

							doubleAllocExprs.push(macro {
								{
									var newBuffer = haxe.io.Bytes.alloc($i{memoryName}.length * 2);
									newBuffer.blit(0, $i{memoryName}, 0, $i{memoryName}.length);
									$i{memoryName} = newBuffer;
								}
							});
					}
				}

				// add constructor
				var newFields = (macro class {
					static var index = 0;
					static var length = $v{initialLength};
					static function allocate(): Int {
						if (index + 1 > length) {
							// allocate more space!
							$b{doubleAllocExprs}
							length *= 2;
						}
						return index++;
					}

					public inline function new(fields: $anonTypeComplex) {
						this = allocate();
						set(fields);
					}
				}).fields;

				for (f in newFields) generatedType.fields.push(f);
		}


		// add byteLength
		generatedType.fields.push((macro class {
			static public final byteLength = $v{totalLength};
		}).fields[0]);

		// add getter and setter fields
		for (i => field in params.fields) {
			var name = field.name;

			var subStructField = false;

			var complexType: ComplexType = switch Context.followWithAbstracts(field.type) {
				case anon = TAnonymous(a):
					var subTypeName =
						'${generatedTypeName}_' +
						name.substr(0, 1).toUpperCase() + name.substr(1);
					
					// we need to build a sub type for this field
					subModules = subModules.concat(
						getModuleTypes(
							poolMode,
							{
								name: subTypeName,
								fields: a.get().fields,
								anon: anon
							},
							generatedTypeName
						)
					);

					subStructField = true;

					TPath({name: subTypeName, pack: []});
				default: TypeTools.toComplexType(field.type);
			}

			var byteOffsetExpr = switch poolMode {
				case AoS:
					var o = 0;
					for (j in 0...i) o += byteLengths[j];
					macro $v{o};
				case SoA:
					var byteLength = byteLengths[i];
					macro $v{byteLength} * this;
			}

			var buffer = switch poolMode {
				case AoS: 'memory';
				case SoA: '__${name}_memory';
			}
			
			var get_name = 'get_$name';
			var set_name = 'set_$name';
			var newFields = if (subStructField) {
				var returnExpr = switch poolMode {
					case AoS: macro this + ${byteOffsetExpr};
					case SoA: macro this;
				}
				(macro class {
					public var $name(get, never): $complexType;
					inline function $get_name(): $complexType {
						return cast $returnExpr;
					}
				}).fields;
			} else {
				(macro class {
					public var $name(get, set): $complexType;
					inline function $get_name(): $complexType {
						return ${getReadExpr(field, buffer, byteOffsetExpr)}
					}
					inline function $set_name(v: $complexType) {
						${getWriteExpr(field, buffer, byteOffsetExpr)}
						return v;
					}
				}).fields;
			}

			for (newField in newFields) {
				generatedType.fields.push(newField);
			}
		}

		// add set(obj)
		generatedType.fields.push({
			var setExpr = [for (field in params.fields) {
				var name = field.name;

				switch Context.followWithAbstracts(field.type) {
					case anon = TAnonymous(a):
						macro $i{name}.set(values.$name);
					default:
						macro $i{name} = values.$name;
				}
			}];
			(macro class {
				public inline function set(values: $anonTypeComplex) {
					$b{setExpr};
				}
			}).fields[0];
		});

		// add toString()
		generatedType.fields.push({
			var lineExprs = [for (field in params.fields) {
				var name = field.name;
				switch Context.followWithAbstracts(field.type) {
					case anon = TAnonymous(a):
						macro str += '\n$tabDepth' + $v{name} + ': ' + $i{name}.toString(tabDepth + '\t');
					default:
						macro str += '\n$tabDepth' + $v{name} + ': ' + $i{name};
				}
			}];
			(macro class {
				public function toString(?tabDepth = '\t'): String {
					var str = '';
					var name = $v{generatedTypeName};
					str += '$name ($this) {';
					$b{lineExprs}
					str += '\n${tabDepth.substr(1)}}';
					return str;
				}
			}).fields[0];
		});

		trace(new haxe.macro.Printer().printTypeDefinition(generatedType, false));

		return [generatedType].concat(subModules);
	}

	static function getFieldByteLength(field: haxe.macro.Type.ClassField): Int {
		var resolved = Context.followWithAbstracts(field.type);
		var byteLength = switch resolved {
			case TAbstract(_.get() => t, []):
				switch t {
					case {module: 'StdTypes', name: 'Float'}: 8;
					case {module: 'StdTypes', name: 'Int'}: 4;
					case {module: 'StdTypes', name: 'Bool'}: 1;
					default: null;
				}
			case TInst(_.get() => t, []):
				switch t {
					case {module: 'haxe.Int64', name: '___Int64'}: 8;
					default: null;
				}
			case TAnonymous(_.get() => anon):
				var structLength = 0;
				for (f in anon.fields) {
					structLength += getFieldByteLength(f);
				}
				structLength;
			default:
				null;
		}

		if (byteLength == null) {
			Context.error('Unsupported type ${TypeTools.toString(field.type)}', field.pos);
		}

		return byteLength;
	}

	static function getReadExpr(field: haxe.macro.Type.ClassField, buffer: String, byteOffsetExpr: Expr) {
		var resolved = Context.followWithAbstracts(field.type);
		var expr = switch resolved {
			case TAbstract(_.get() => t, []):
				switch t {
					case {module: 'StdTypes', name: 'Float'}: macro $i{buffer}.getDouble(this + $byteOffsetExpr);
					case {module: 'StdTypes', name: 'Int'}: macro cast $i{buffer}.getInt32(this + $byteOffsetExpr);
					case {module: 'StdTypes', name: 'Bool'}: macro cast $i{buffer}.get(this + $byteOffsetExpr);
					default: null;
				}
			case TInst(_.get() => t, []):
				switch t {
					case {module: 'haxe.Int64', name: '___Int64'}: macro $i{buffer}.getInt64(this + $byteOffsetExpr);
					default: null;
				}
			case TAnonymous(_.get() => anon): macro null;
			default:
				null;
		}

		if (expr == null) {
			Context.error('Unsupported type ${TypeTools.toString(field.type)}', field.pos);
		}

		return expr;
	}

	static function getWriteExpr(field: haxe.macro.Type.ClassField, buffer: String, byteOffsetExpr: Expr) {
		var resolved = Context.followWithAbstracts(field.type);
		var expr = switch resolved {
			case TAbstract(_.get() => t, []):
				switch t {
					case {module: 'StdTypes', name: 'Float'}: macro $i{buffer}.setDouble(this + $byteOffsetExpr, v);
					case {module: 'StdTypes', name: 'Int'}: macro $i{buffer}.setInt32(this + $byteOffsetExpr, cast v);
					case {module: 'StdTypes', name: 'Bool'}: macro cast $i{buffer}.set(this + $byteOffsetExpr, v ? 1 : 0);
					default: null;
				}
			case TInst(_.get() => t, []):
				switch t {
					case {module: 'haxe.Int64', name: '___Int64'}: macro $i{buffer}.setInt64(this + $byteOffsetExpr, v);
					default: null;
				}
			case TAnonymous(_.get() => anon): macro null;
			default:
				null;
		}

		if (expr == null) {
			Context.error('Unsupported type ${TypeTools.toString(field.type)}', field.pos);
		}

		return expr;
	}
}
#end