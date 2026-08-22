package;

import peote.view.math.Rnd;
import catpi.automat.Cell.CellActor;
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

class LimeAndOpenFLintoMAZE extends Application
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
	var gridList:Array<Grid>;

	static inline var SIM_STEP_TIME:Int = 100;

	var zoom:Float;


	public function start(window:Window)
	{
		peoteView = new PeoteView(window);

		
		var rootX:Int = 0;
		var rootY:Int = 0;

		var maxWidth = 40;
		var maxHeight = 30;
		zoom = 0.620921323059155;

		// TODO: for more then z=3 the rootXY will be outside (needs some modulo then ;)
		var z=3; maxWidth *= z; maxHeight *= z; zoom = 0.620921323059155 / z; rootX = (maxWidth>>1)-1; rootY = (maxHeight>>1)-1;
		

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
		
		var actorRenderConfig:Map<Int, {tile:Tile, anim:Int}> = [
			ActorType.LIME      => { tile:Actors.tile(ActorTileID.LIME)     , anim:ActorAnimID.still },
			ActorType.OPENFL    => { tile:Actors.tile(ActorTileID.OPENFL)   , anim:ActorAnimID.still },
		];
		ActorRender.init(peoteView, SIM_STEP_TIME, Actors.sheets, actorRenderConfig);

		var renderView = new RenderView(0, 0, Std.int(maxWidth*32*zoom), Std.int(maxHeight*32*zoom));
		
		view = new View(renderView);
		view.zoom = zoom;


		// grid = GridTestData.createMaze(10,10);
		grid = GridTestData.createMazeKruskal(10, 10, 60000, 12345);
		// grid = GridTestData.createMazeKruskal(4, 4, 8000, 12345);
		gridList = grid.getAllAsList();
		
		multiGridView = new MultiGridView(view, grid, rootX, rootY, maxWidth, maxHeight);
	
		// ---- test SIMMULATION ---
		
		// ((hope will H E L P ;))
		var spawnedActors:Int = 0;
		for (g in gridList) {
			for (i in 0...1000) {
				var pos = P(Rnd.intLimit(0, 63), Rnd.intLimit(0, 63));
				while (g.get(pos).actor != CellActor.EMPTY) pos = P(Rnd.intLimit(0, 63), Rnd.intLimit(0, 63));
				if (Rnd.fast() < 0.5) new Lime("4theSIGNmajesties", g, pos);
				else new OpenFL("flash for fantasy", g, pos);
				spawnedActors++;
			}
		}
		trace('spawned actors: $spawnedActors');

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
			
			// grid.stepAll(); // / / / (^_^)
			for (g in gridList) g.step();

			// spawn a new on if there is free space:
			// if (grid.get(P(0,4)).actor == CellActor.EMPTY ) new Lime("", grid, P(0,4));
			// if (grid.get(P(0,5)).actor == CellActor.EMPTY ) new OpenFL("", grid, P(0,5));
		}
	}

	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		// if (deltaY<0) peoteView.zoom /= 1.1; else peoteView.zoom *= 1.1;
		if (deltaY<0) {
			if (view.zoom > zoom+0.01) view.zoom /= 1.1;
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
