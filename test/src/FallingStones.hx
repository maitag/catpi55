package;

import haxe.Timer;
import haxe.CallStack;
import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;
import peote.view.Color;

import catpi.automat.Cell.CellType;
import catpi.automat.Grid;
import catpi.automat.MultiGridView;
// import catpi.render.Render;
import catpi.render.RenderView;
import catpi.render.ActorRenderConfig;
import catpi.render.ActorRenderType;
import catpi.render.cell.CellRender;
import catpi.render.actor.ActorRender;
import catpi.render.debug.DebugDisplay;
import catpi.view.View;
import catpi.util.Pos.xy as P;


import actors.*;
// import actors.ActorType;

import catpi.asset.Tile;

import asset.generated.cells.Cells.Cells;
import asset.generated.cells.Cells.TileID as CellTileID;
import asset.generated.cells.Cells.AnimID as CellAnimID;

import asset.generated.actors.Actors.Actors;
import asset.generated.actors.Actors.TileID as ActorTileID;
import asset.generated.actors.Actors.AnimID as ActorAnimID;

class FallingStones extends Application
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

	var debugDisplay:DebugDisplay;

	var multiGridView:MultiGridView;
	var view:View;
	var grid:Grid;

	var actor = new Semmi("player");

	static inline var SIM_STEP_TIME:Int = 100;

	var zoom:Float;
	var simRun = false;

	// debug
	var simTime:Float = 0.0; var simTimeCount:Int = 0; var debugSimTime:DebugItem;
	var debugActors:DebugItem;

	public function start(window:Window)
	{
		peoteView = new PeoteView(window);
		#if peoteview_fps
		// peoteView.FPS.x = window.width - peoteView.FPS.width;
		#end


		var debugDisplay = new DebugDisplay(300, 0, Color.RED1 - 0x33);
		new DebugItem(debugDisplay, " move View  :", "cursor keys");
		new DebugItem(debugDisplay, " move Player:", "awsd");
		new DebugItem(debugDisplay, " start/stop:", "space");
		new DebugItem(debugDisplay, "----------------------");
		debugActors  = new DebugItem(debugDisplay, "actors :");
		debugSimTime = new DebugItem(debugDisplay, "simTime:", 3);
		debugDisplay.x = window.width - debugDisplay.width;


		
		var rootX:Int = 19; // TODO: 20; needs offset like->view.scrollRight();
		var rootY:Int = 15;

		var maxWidth = 40;
		var maxHeight = 30;
		zoom = 0.620921323059155;

		// TODO: for more then z=3 the rootXY will be outside (needs some modulo then ;)
		var z=2; maxWidth *= z; maxHeight *= z; zoom = 0.620921323059155 / z; rootX = (maxWidth>>1)-1; rootY = (maxHeight>>1)-1;
		

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
		var actorRenderConfig:ActorRenderConfig = [
			ActorRenderType.SIMPLE => [
				ActorType.STONE1x1  => { tile:Actors.tile(ActorTileID.STONE1x1) , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.STONE1x2  => { tile:Actors.tile(ActorTileID.STONE1x2) , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.STONE2x2  => { tile:Actors.tile(ActorTileID.STONE2x2) , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.CROSS     => { tile:Actors.tile(ActorTileID.CROSS)    , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.EDGEBR3x3 => { tile:Actors.tile(ActorTileID.EDGEBR3x3), action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.HAXE      => { tile:Actors.tile(ActorTileID.HAXE)     , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.LIME      => { tile:Actors.tile(ActorTileID.LIME)     , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.OPENFL    => { tile:Actors.tile(ActorTileID.OPENFL)   , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.FLIXEL    => { tile:Actors.tile(ActorTileID.FLIXEL)   , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] },
				ActorType.SEMMI     => { tile:Actors.tile(ActorTileID.SEMMI)    , action: [ ActorAction.STILL => {anim:ActorAnimID.still} ] }
			]
		];
		ActorRender.init(peoteView, SIM_STEP_TIME, Actors.sheets, actorRenderConfig);

		// var renderView = new RenderView(0, 0, 800, 600);
		var renderView = new RenderView(0, 0, Std.int(maxWidth*32*zoom), Std.int(maxHeight*32*zoom));
		
		view = new View(renderView);
		view.zoom = zoom;


		grid = GridTestData.create2x2(false, true); // GridTestData.createMaze(2,2);
		// GridTestData.traceGrid(grid, 64, 64);

		
		actor.addToGrid(grid, P(31,30));

		// var cross = new Cross("cross",grid,P(16,3));

		var stone1 = new Stone1x1("stone 1"); stone1.addToGrid(grid, P(10,1)); 
		var stone2 = new Stone1x1("stone 2"); stone2.addToGrid(grid, P(10,2)); 
		var stone3 = new Stone1x1("stone 3"); stone3.addToGrid(grid, P(10,3));
		
		var stone4 = new Stone2x2("stone 4"); stone4.addToGrid(grid, P(31,26));
		var stone5 = new Stone2x2("stone 5"); stone5.addToGrid(grid, P(33,24));
		stone1.tryFallDown();
		stone2.tryFallDown();
		stone3.tryFallDown();
		stone4.tryFallDown();
		stone5.tryFallDown();

		// spawn mass of stones into grid.right.top
		for (x in 1...31) {
			var stone = new Stone2x2(""); stone.addToGrid(grid.right.top, P(x*2,39));
		}
		for (y in 41...61)
			for (x in 2...63) {
				var stone = new Stone1x1(""); stone.addToGrid(grid.right.top, P(x,y)); //stone.onStartMove();
			}	
		for (x in 1...32) {
			var stone = new Stone1x1(""); stone.addToGrid(grid.right.top, P(x*2,61)); stone.tryFallDown();
		}

		// spawn mass of stones into grid.bottom
		for (x in 1...31) {
			var stone = new Stone2x2(""); stone.addToGrid(grid.bottom, P(x*2,39));
		}

		for (y in 41...61)
			for (x in 2...63) {
				var stone = new Stone1x1(""); stone.addToGrid(grid.bottom, P(x,y)); //stone.onStartMove();
			}		
		for (x in 1...32) {
			var stone = new Stone1x1(""); stone.addToGrid(grid.bottom, P(x*2,61)); stone.tryFallDown();
		}

		debugActors.valueInt = grid.actors.length  + grid.right.actors.length + grid.bottom.actors.length + grid.rightBottom.actors.length;

		multiGridView = new MultiGridView(view, grid, rootX, rootY, maxWidth, maxHeight);
		// trace(multiGridView.gridViewCache);
		
		
		// add debugdisplay on top
		peoteView.addDisplay(debugDisplay);

		// ---- test SIMMULATION ---
				
		peoteView.start();
		simRun = true;
	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	var deltaTimeSum:Int = SIM_STEP_TIME;

	override function update(deltaTime:Int):Void {
		if (!simRun) return;

		if (deltaTimeSum < SIM_STEP_TIME) {
			deltaTimeSum += deltaTime;
		}
		else 
		{
			deltaTimeSum -= SIM_STEP_TIME;
			var time = Timer.stamp();
			grid.stepAll();
			simTime += Timer.stamp()-time; simTimeCount++;
		}
	}

	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		// if (deltaY<0) peoteView.zoom /= 1.1; else peoteView.zoom *= 1.1;
		if (deltaY<0) {
			if (view.zoom > zoom) view.zoom /= 1.1;
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
			
			
			case SPACE:
				if (simRun) peoteView.stop() else peoteView.start();
				simRun = !simRun;


			// move the actor
			case A: if (actor.freeLeft()) {
				actor.goLeft();
				actor.startNeighborMove();
			}
			case D: if (actor.freeRight()) {
				actor.goRight();
				actor.startNeighborMove();
			}
			case W: if (actor.freeUp()) {
				actor.goUp();
				actor.startNeighborMove();
			}
			case S: if (actor.freeDown()) {
				actor.goDown();
				actor.startNeighborMove();
			}
			case Q: if (actor.freeLeftUp()) {
				actor.goLeftUp();
				actor.startNeighborMove();
			}
			case Y: if (actor.freeLeftDown()) {
				actor.goLeftDown();
				actor.startNeighborMove();
			}
			case E: if (actor.freeRightUp()) {
				actor.goRightUp();
				actor.startNeighborMove();
			}
			case C: if (actor.freeRightDown()) {
				actor.goRightDown();	
				actor.startNeighborMove();
			}

			default:
		}
	}	

	var debugUpdateStep:Int = 0;

	override function render(context:lime.graphics.RenderContext):Void {
		if (debugUpdateStep++ == 10) {
			if (simTimeCount>0) debugSimTime.valueFloat = simTime/simTimeCount;
			simTime = 0.0;
			simTimeCount = 0;

			debugUpdateStep = 0;
		}
	}
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
	override function onWindowMove(x:Float, y:Float):Void { deltaTimeSum=SIM_STEP_TIME; }
	// override function onWindowMinimize():Void { trace("onWindowMinimize"); }
	// override function onWindowRestore():Void { trace("onWindowRestore"); }
	
}
