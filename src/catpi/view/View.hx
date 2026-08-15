package catpi.view;

import haxe.ds.Vector;

import catpi.util.Pos;
// import catpi.util.Pos.xy as P;

// import catpi.util.Pos.Pos8x8Neg;

import catpi.automat.Grid;

// TODO: replace by Int or special types
import catpi.automat.Cell;
import catpi.automat.Cell.CellActor;


import catpi.render.RenderView;


// this will be later handled by Remote-Client in peote-net!
class View {

	public var renderView:RenderView;
	
	// todo: setter of xFrom ...
	// public var width:Int = 0;
	// public var height:Int = 0;

	// each added grid will store its data here (at now only the offset!)
	var gridData:Vector<Int>;

	// from here it grows into all directions (set on first root-grid initialization)
	public var rootX:Int = 0;
	public var rootY:Int = 0;

	// actual range into global position values over multigridviews from where it starts
	public var xFrom:Int = 0;
	public var xTo:Int = 0;
	public var yFrom:Int = 0;
	public var yTo:Int = 0;

	public var zoom(get,set):Float;
	inline function get_zoom():Float return (renderView==null) ? 0.0 : renderView.zoom;
	inline function set_zoom(z:Float):Float return (renderView==null) ? 0.0 : renderView.zoom = z;

	// ----------------------------------------------

	public function new(renderView:RenderView)
	{
		this.renderView = renderView;
	}

	// ----------------------------------------------
	// --------- Sync from MultiGridView ------------
	// ----------------------------------------------

	public function init(maxGrids:Int, maxWidth:Int, maxHeight:Int) {
		trace("init", maxGrids, maxWidth, maxHeight);
		gridData = new Vector<Int>(maxGrids);
		renderView.initView(maxWidth, maxHeight);
	}

	public inline function addGridView(index:Int, offset:Pos8x8Neg) {
		trace("addGridView", index, offset);
		gridData.set(index, offset);
	}

	public inline function removeGridView(index:Int) {
		trace("removeGridView", index);
	}

	// current gridViewIndex and position-offsets
	var gridViewIndex:Int = -1;
	var gridViewX:Int = 0;
	var gridViewY:Int = 0;

	public inline function switchGridViewIndex(index:Int) {
		// trace("switchGridViewIndex", index);
		gridViewIndex = index;
		var offset:Pos8x8Neg = gridData.get(index);
		gridViewX = offset.x * Grid.WIDTH;
		gridViewY = offset.y * Grid.HEIGHT;
	}

	// ------- add cells ----------

	public function addCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int, cells:Array<Cell>) {
		#if catpi_debug_view
		trace("addCells", 'from:${xFrom+gridViewX},${yFrom+gridViewY} -> to ${xTo+gridViewX},${yTo+gridViewY}', [for (cell in cells) cell.type.toString()].join(",") );		
		#end
		renderView.cellRender.addCells(xFrom+gridViewX, yFrom+gridViewY, xTo+gridViewX, yTo+gridViewY, cells);
	}

	public function addCellsHorizontal(y:Int, xFrom:Int, xTo:Int, cells:Array<Cell>) {
		#if catpi_debug_view
		trace("addCellsHorizontal", 'y:${y+gridViewY}, xFrom:${xFrom+gridViewX} -> xTo:${xTo+gridViewX}', [for (cell in cells) cell.type.toString()].join(",") );
		#end
		renderView.cellRender.addCellsHorizontal(y+gridViewY, xFrom+gridViewX, xTo+gridViewX, cells);
	}

	public function addCellsVertical(x:Int, yFrom:Int, yTo:Int, cells:Array<Cell>) {
		#if catpi_debug_view
		trace("addCellsVertical", 'x:${x+gridViewX}, yFrom:${yFrom+gridViewY} -> yTo:${yTo+gridViewY}', [for (cell in cells) cell.type.toString()].join(",") );
		#end
		renderView.cellRender.addCellsVertical(x+gridViewX, yFrom+gridViewY, yTo+gridViewY, cells);
	}

	// ------ remove cells ---------

	public function removeCells(xFrom:Int, yFrom:Int, xTo:Int, yTo:Int) {
		#if catpi_debug_view
		trace("removeCells", 'from:${xFrom+gridViewX},${yFrom+gridViewY} -> to ${xTo+gridViewX},${yTo+gridViewY}');
		#end
		renderView.cellRender.removeCells(xFrom+gridViewX, yFrom+gridViewY, xTo+gridViewX, yTo+gridViewY);
	}

	public function removeCellsHorizontal(y:Int, xFrom:Int, xTo:Int) {
		#if catpi_debug_view
		trace("removeCellsHorizontal", 'y:{$y+gridViewY}, xFrom:${xFrom+gridViewX} -> xTo:${xTo+gridViewX}');
		#end
		renderView.cellRender.removeCellsHorizontal(y+gridViewY, xFrom+gridViewX, xTo+gridViewX);
	}

	public function removeCellsVertical(x:Int, yFrom:Int, yTo:Int) {
		#if catpi_debug_view
		trace("removeCellsVertical", 'x:${x+gridViewX}, yFrom:${yFrom+gridViewY} -> yTo:${yTo+gridViewY}');
		#end
		renderView.cellRender.removeCellsVertical(x+gridViewX, yFrom+gridViewY, yTo+gridViewY);
	}


	// ------ ACTOR --------

	public inline function mapKey(index:Int, actorKey:Int) return (index << (CellActor.bits-1)) | actorKey;

	public function addActor(x:Int, y:Int, actorKey:Int, actorType:Int) {
		#if catpi_debug_view
		trace("addActor", 'x:${x+gridViewX} y:${y+gridViewY}, actorKey:$actorKey, actorType:$actorType, mapkey:${mapKey(gridViewIndex, actorKey)}');		
		#end
		renderView.actorRender.addActor(x+gridViewX, y+gridViewY, mapKey(gridViewIndex, actorKey), actorType);
	}

	public function removeActor(actorKey:Int) {
		#if catpi_debug_view
		trace("removeActor", 'actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');		
		#end
		renderView.actorRender.removeActor(mapKey(gridViewIndex, actorKey));
	}

	// if actors origin moved to a side-grid -> switch the mapkeys
	public inline function actorToSideGrid(newIndex:Int, oldActorKey:Int, newActorKey:Int) {
		#if catpi_debug_view
		trace("actorToSideGrid", 'index:$gridViewIndex newIndex:$newIndex, oldActorKey:$oldActorKey, newActorKey:$newActorKey, oldMapkey:${mapKey(gridViewIndex, oldActorKey)}, newMapkey:${mapKey(newIndex, newActorKey)}');		
		#end
		renderView.actorRender.actorChangeMapkey(mapKey(gridViewIndex, oldActorKey), mapKey(newIndex, newActorKey));
	}

	// actor MOVES
	public function actorGoLeft(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoLeft", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoLeft(mapKey(gridViewIndex, actorKey), time);
	}
	public function actorGoRight(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoRight", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoRight(mapKey(gridViewIndex, actorKey), time);
	}
	public function actorGoUp(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoTop", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoUp(mapKey(gridViewIndex, actorKey), time);
	}
	public function actorGoDown(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoDown", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoDown(mapKey(gridViewIndex, actorKey), time);
	}
	public function actorGoLeftUp(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoLeftUp", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoLeftUp(mapKey(gridViewIndex, actorKey), time);
	}
	public function actorGoLeftDown(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoLeftDown", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoLeftDown(mapKey(gridViewIndex, actorKey), time);
	}
	public function actorGoRightUp(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoRightUp", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoRightUp(mapKey(gridViewIndex, actorKey), time);
	}
	public function actorGoRightDown(actorKey:Int, time:Int) {
		#if catpi_debug_view
		trace("actorGoRightDown", 'index:$gridViewIndex, actorKey:$actorKey, mapkey:${mapKey(gridViewIndex, actorKey)}');
		#end
		renderView.actorRender.actorGoRightDown(mapKey(gridViewIndex, actorKey), time);
	}

	

	// TODO:
	// ------- update --------
	public function updateCell(pos:Pos, cell:CellType) { // CellParam!
		trace("updateCell", pos, cell);
	}
	public function updateActor(actorKey:CellActor, action:Int) { // TODO: action!
		trace("updateActor", actorKey, action);
	}
	

	// ------- scrolling ----------
	public function scrollLeft() {
		renderView.scrollLeft();
	}
	public function scrollRight() {
		renderView.scrollRight();
	}
	public function scrollTop() {
		renderView.scrollTop();
	}
	public function scrollBottom() {
		renderView.scrollBottom();
	}

}