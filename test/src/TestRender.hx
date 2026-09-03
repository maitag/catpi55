package;

import peote.view.Color;
import peote.view.Display;
import haxe.CallStack;

import lime.app.Application;
import lime.ui.Window;

import peote.view.PeoteView;

import catpi.automat.Cell;
import catpi.render.cell.CellRender;
import catpi.render.actor.ActorRender;

import catpi.render.actor.simple.ElemSimple;
import catpi.render.actor.simple.ProgSimple;

import catpi.render.actor.ActorElem;

import catpi.render.ActorRenderConfig;
import catpi.render.ActorRenderType;

import catpi.asset.Tile;

import asset.generated.cells.Cells.Cells;
import asset.generated.cells.Cells.TileID as CellTileID;
import asset.generated.cells.Cells.AnimID as CellAnimID;

import asset.generated.actors.Actors.Actors;
import asset.generated.actors.Actors.TileID as ActorTileID;
import asset.generated.actors.Actors.AnimID as ActorAnimID;

import actors.ActorType;
import actors.ActorAction;

class TestRender extends Application
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

	public function start(window:Window)
	{
		peoteView = new PeoteView(window);
		#if peoteview_fps
		peoteView.FPS.x = window.width - peoteView.FPS.width;
		#end

		var display = new Display(0,0,800,600,Color.GREEN1);
		peoteView.addDisplay(display);
		var prog = new ProgSimple(null, 1024, 1024);
		display.addProgram(prog);

		var e:ActorElem;
		e = new ElemSimple(0, 0, 100, 100, 100, 100);
		e.add();
		e.goLeft(peoteView.time, 2);peoteView.start();	

		return;

		// ------------------ CellRender -----------------------
		
		var cellRenderConfig:Map<Int, {tile:Tile, anim:Int}> = [
			CellType.EARTH  => { tile:Cells.tile(CellTileID.EARTH) , anim:CellAnimID.still },
			CellType.WOOD   => { tile:Cells.tile(CellTileID.WOOD)  , anim:CellAnimID.still },
			CellType.ROCK   => { tile:Cells.tile(CellTileID.ROCK)  , anim:CellAnimID.still },
			CellType.METAL  => { tile:Cells.tile(CellTileID.METAL) , anim:CellAnimID.still },
			CellType.WATER  => { tile:Cells.tile(CellTileID.WATER) , anim:CellAnimID.still },
			CellType.AIR    => { tile:Cells.tile(CellTileID.AIR)   , anim:CellAnimID.still },
		];
		CellRender.init(peoteView, Cells.sheets, cellRenderConfig);
		
		var cellRender = new CellRender(0, 0, 400, 400);
		
		cellRender.initView(64, 64);
		
		cellRender.addCell( 0, 0, CellType.EARTH );
		cellRender.addCellsHorizontal( 0, 1, 3, [new Cell(CellType.EARTH), new Cell(CellType.ROCK)] );
		cellRender.addCellsVertical( 0, 1, 3, [new Cell(CellType.EARTH), new Cell(CellType.ROCK)] );
		
		// ------------------ ActorRender -----------------------

		var actorRenderConfigOld:catpi.render.actor.ActorConfig = [
			ActorType.STONE1x1  => { tile:Actors.tile(ActorTileID.STONE1x1) , anim:ActorAnimID.still },
			/*ActorType.STONE1x1  => { 
				tile:Actors.tile(ActorTileID.STONE1x1),
				type:ActorRenderType.SIMPLE,
				defaultAction:ActorAction.STILL,
				actions: [
					ActorAction.STILL: {anim:ActorAnimID.still},
					ActorAction.WALK: {anim:ActorAnimID.walk}
				]
			}*/
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
		
		var actorRenderConfig:ActorRenderConfig = [
			ActorRenderType.SIMPLE => [
				ActorType.STONE1x1  => {
					tile:Actors.tile(ActorTileID.STONE1x1),
					action: [ ActorAction.STILL => {anim:ActorAnimID.still} ]
				},
				ActorType.STONE2x2  => {
					tile:Actors.tile(ActorTileID.STONE2x2),
					action: [ ActorAction.STILL => {anim:ActorAnimID.still} ]
				}
			],
			/*ActorRenderType.ANIM => [
				ActorType.STONE1x1  => {
					// tile:Actors.tile(ActorTileID.STONE1x2_EFFECTS),
					tile:Actors.tile(ActorTileID.STONE1x1),
					action: [ ActorAction.WALK => {anim:ActorAnimID.still} ]
					// action: [ ActorAction.EXPLODE => {anim:ActorAnimID.explode} ]
				}
			]*/

		];
		trace(actorRenderConfig.toConfigVector(Actors.sheets).maxActions);
		trace(actorRenderConfig.toConfigVector(Actors.sheets).conf);
		trace(actorRenderConfig.toConfigVector(Actors.sheets).renderTypeSheets);

		ActorRender.init(peoteView, 100, Actors.sheets, actorRenderConfigOld);

		var actorRender = new ActorRender(0, 0, 400, 400);
		
		actorRender.initView(64, 64);
		
		actorRender.addActor(1, 1, 0, ActorType.HAXE);

	}
	
	// ------------------------------------------------------------
	// ----------------- LIME EVENTS ------------------------------
	// ------------------------------------------------------------	

	
	override function update(deltaTime:Int):Void {
		// for game-logic update
	}
	
	// override function render(context:lime.graphics.RenderContext):Void {}
	// override function onRenderContextLost ():Void trace(" --- WARNING: LOST RENDERCONTEXT --- ");		
	// override function onRenderContextRestored (context:lime.graphics.RenderContext):Void trace(" --- onRenderContextRestored --- ");		
		
	// override function onPreloadComplete():Void {} // access embeded assets from here

	// ----------------- MOUSE EVENTS ------------------------------
	// override function onMouseMove (x:Float, y:Float):Void {}	
	// override function onMouseDown (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	// override function onMouseUp (x:Float, y:Float, button:lime.ui.MouseButton):Void {}	
	override function onMouseWheel (deltaX:Float, deltaY:Float, deltaMode:lime.ui.MouseWheelMode):Void {
		if (deltaY<0) peoteView.zoom /= 1.1;
		else peoteView.zoom *= 1.1;
	}
	// override function onMouseMoveRelative (x:Float, y:Float):Void {}

	// ----------------- TOUCH EVENTS ------------------------------
	// override function onTouchStart (touch:lime.ui.Touch):Void {}
	// override function onTouchMove (touch:lime.ui.Touch):Void	{}
	// override function onTouchEnd (touch:lime.ui.Touch):Void {}
	
	// ----------------- KEYBOARD EVENTS ---------------------------
	// override function onKeyDown (keyCode:lime.ui.KeyCode, modifier:lime.ui.KeyModifier):Void {}	
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
