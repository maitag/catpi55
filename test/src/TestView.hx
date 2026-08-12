package;

import haxe.Timer;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;

import catpi.automat.Cell.CellType;
import catpi.render.actor.ActorRender;
import catpi.render.cell.CellRender;

import catpi.automat.Grid;
import catpi.automat.MultiGridView;

import catpi.util.Pos.xy as P;
import catpi.util.Maze;

import catpi.render.Render;
import catpi.render.RenderView;
import catpi.view.View;

import actors.*;
// import actors.ActorType;

import catpi.asset.Tile;

import asset.generated.cells.Cells.Cells;
import asset.generated.cells.Cells.TileID as CellTileID;
import asset.generated.cells.Cells.AnimID as CellAnimID;

import asset.generated.actors.Actors.Actors;
import asset.generated.actors.Actors.TileID as ActorTileID;
import asset.generated.actors.Actors.AnimID as ActorAnimID;

class TestView extends Application
{
	override function onWindowCreate():Void
	{
		switch (window.context.type)
		{
			case WEBGL, OPENGL, OPENGLES:
				try start(window)
				catch (_) trace(CallStack.toString(CallStack.exceptionStack()), _);
			default: throw("Sorry, only works with OpenGL.");
		}
	}
	
	// ------------------------------------------------------------
	// --------------- SAMPLE STARTS HERE -------------------------
	// ------------------------------------------------------------	
	var peoteView:PeoteView;
	var multiGridView:MultiGridView;
	var view:View;
	var grid:Grid;

	var semmi = new Semmi("player");

	static inline var SIM_STEP_TIME:Int = 100;

	public function start(window:Window)
	{
		peoteView = new PeoteView(window);

		
		var rootX:Int = 0;
		var rootY:Int = 0;
		var maxWidth = 40;
		var maxHeight = 30;
		var zoom = 0.620921323059155;
		

		// TODO: Render.init(peoteView, SIM_STEP_TIME);

		var cellRenderConfig:Map<Int, {tile:Tile, anim:Int}> = [
			CellType.EARTH  => { tile:Cells.tile(CellTileID.EARTH) , anim:CellAnimID.still },
			CellType.WOOD   => { tile:Cells.tile(CellTileID.WOOD)  , anim:CellAnimID.still },
			CellType.ROCK   => { tile:Cells.tile(CellTileID.ROCK)  , anim:CellAnimID.still },
			CellType.METAL  => { tile:Cells.tile(CellTileID.METAL) , anim:CellAnimID.still },
			CellType.WATER  => { tile:Cells.tile(CellTileID.WATER) , anim:CellAnimID.still },
			CellType.AIR    => { tile:Cells.tile(CellTileID.AIR)   , anim:CellAnimID.still },
		];
		CellRender.init(peoteView, Cells.sheets, cellRenderConfig);
		
		// TODO: make the "anim" another "map" later to define how animActions are mapped to assets !!!
		var actorRenderConfig:Map<Int, {tile:Tile, anim:Int}> = [
			ActorType.STONE1x1  => { tile:Actors.tile(ActorTileID.STONE1x1) , anim:ActorAnimID.still },
			ActorType.STONE1x2  => { tile:Actors.tile(ActorTileID.STONE1x2) , anim:ActorAnimID.still },
			ActorType.STONE2x2  => { tile:Actors.tile(ActorTileID.STONE2x2) , anim:ActorAnimID.still },
			ActorType.CROSS     => { tile:Actors.tile(ActorTileID.CROSS)    , anim:ActorAnimID.still },
			ActorType.EDGEBR3x3 => { tile:Actors.tile(ActorTileID.EDGEBR3x3), anim:ActorAnimID.still },
			ActorType.HAXE      => { tile:Actors.tile(ActorTileID.HAXE)     , anim:ActorAnimID.still },
			ActorType.LIME      => { tile:Actors.tile(ActorTileID.LIME)     , anim:ActorAnimID.still },
			ActorType.OPENFL    => { tile:Actors.tile(ActorTileID.OPENFL)   , anim:ActorAnimID.still },
			ActorType.FLIXEL    => { tile:Actors.tile(ActorTileID.FLIXEL)   , anim:ActorAnimID.still },
			ActorType.SEMMI     => { tile:Actors.tile(ActorTileID.SEMMI)    , anim:ActorAnimID.still }
		];
		ActorRender.init(peoteView, SIM_STEP_TIME, Actors.sheets, actorRenderConfig);

		// var renderView = new RenderView(0, 0, 800, 600);
		var renderView = new RenderView(0, 0, Std.int(maxWidth*32*zoom), Std.int(maxHeight*32*zoom));
		
		view = new View(renderView);
		view.zoom = zoom;


		grid = GridTestData.create3x3(); // GridTestData.createMaze(2,2);
		// GridTestData.traceGrid(grid, 64, 64);

		// only for testing:
		semmi.addToGrid(grid, P(14,6));
		
		multiGridView = new MultiGridView(view, grid, rootX, rootY, maxWidth, maxHeight);
		// trace(multiGridView.gridViewCache);

	
		// ---- test SIMMULATION ---
		
		// spawn some haxe actors
		for (i in 0...17)new Haxe(grid, P(10+i*3,10));
		for (i in 0...9) new Haxe(grid, P(17+i*3,12));
		for (i in 0...9) new Haxe(grid, P(16+i*3,14));
		for (i in 0...9) new Haxe(grid, P(17+i*3,16));
		for (i in 0...9) new Haxe(grid, P(16+i*3,18));
		for (i in 0...9) new Haxe(grid, P(17+i*3,20));
		for (i in 0...9) new Haxe(grid, P(16+i*3,22));
		for (i in 0...9) new Haxe(grid, P(17+i*3,24));
		for (i in 0...9) new Haxe(grid, P(16+i*3,26));
		for (i in 0...9) new Haxe(grid, P(17+i*3,28));
		
		new Flixel("A",grid, P(62,27));
		new Flixel("B",grid, P(62,29));
		
		new Cross("C",grid, P(2,5));
		new Cross("C",grid, P(5,5));
		new Cross("C",grid, P(8,5));
		new Cross("C",grid, P(1,7));
		new Cross("C",grid, P(3,8));
		new Cross("C",grid, P(2,10));
		for (i in 0...17) new Cross("C",grid, P(1,12+i*3));

		for (i in 0...7) new EdgeBR3x3("E",grid, P(14+i,1+i));

		// ((hope will H E L P ;))
		new Lime("4theSIGNmajesties", grid, P(1,1));
		new OpenFL("flash for fantasy", grid, P(2,1));
		
		peoteView.start();		
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	var deltaTimeSum:Int = SIM_STEP_TIME;

	override function update(deltaTime:Int):Void {
		if (grid==null) return;

		if (deltaTimeSum < SIM_STEP_TIME) {
			deltaTimeSum += deltaTime;
		}
		else 
		{
			deltaTimeSum -= SIM_STEP_TIME;

			grid.step(); grid.right.step();	grid.right.right.step();
			grid.bottom.step(); grid.bottom.right.step(); grid.bottom.right.right.step();
			grid.bottom.bottom.step(); grid.bottom.bottom.right.step(); grid.bottom.bottom.right.right.step();
			// spawn a new on if there is free space:
			// if (grid.get(P(0,4)).actor == CellActor.EMPTY ) new Lime("", grid, P(0,4));
		}
	}

	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		// if (deltaY<0) peoteView.zoom /= 1.1; else peoteView.zoom *= 1.1;
		if (deltaY<0) {
			if (view.zoom > 0.63) view.zoom /= 1.1;
		}			
		else view.zoom *= 1.1;
		// trace(view.zoom);
	}

	// ----------------- KEYBOARD EVENTS ---------------------------
	override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {
		switch(keyCode) {

			// scroll the view
			case LEFT:
				if (multiGridView.canGrowLeft(false)) {
					multiGridView.scrollLeft();
					view.scrollLeft();
				}
			case RIGHT:
				if (multiGridView.canGrowRight(false)) {
					multiGridView.scrollRight();
					view.scrollRight();
				}
			case UP:
				if (multiGridView.canGrowTop(false)) {
					multiGridView.scrollTop();
					view.scrollTop();
				}
			case DOWN:
				if (multiGridView.canGrowBottom(false)) {
					multiGridView.scrollBottom();
					view.scrollBottom();
				}
			
			// move the actor
			case A: if (semmi.freeLeft()) semmi.goLeft();
			case D: if (semmi.freeRight()) semmi.goRight();
			case W: if (semmi.freeUp()) semmi.goUp();
			case S: if (semmi.freeDown()) semmi.goDown();
			case Q: if (semmi.freeLeftUp()) semmi.goLeftUp();
			case Y: if (semmi.freeLeftDown()) semmi.goLeftDown();
			case E: if (semmi.freeRightUp()) semmi.goRightUp();
			case C: if (semmi.freeRightDown()) semmi.goRightDown();	

			default:
		}
	}	

	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		
		
	// override function onPreloadComplete():Void {} // access embeded assets from here

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}
	
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// override function onKeyUp (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}

	// -------------- other WINDOWS EVENTS ----------------------------
	// override function onWindowResize (width:Int, height:Int):Void { trace("onWindowResize", width, height); }
	// override function onWindowLeave():Void { trace("onWindowLeave"); }
	// override function onWindowActivate():Void { trace("onWindowActivate"); }
	// override function onWindowClose():Void { trace("onWindowClose"); }
	// override function onWindowDeactivate():Void { trace("onWindowDeactivate"); }
	// override function onWindowDropFile(file:String):Void { trace("onWindowDropFile"); }
	// override function onWindowEnter():Void { trace("onWindowEnter"); }
	// override function onWindowExpose():Void { trace("onWindowExpose"); }
	// override function onWindowFocusIn():Void { trace("onWindowFocusIn"); }
	// override function onWindowFocusOut():Void { trace("onWindowFocusOut"); }
	// override function onWindowFullscreen():Void { trace("onWindowFullscreen"); }
	// override function onWindowMove(x:Float, y:Float):Void { trace("onWindowMove"); }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
