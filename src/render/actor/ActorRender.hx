package render.actor;

import lime.graphics.Image;

import peote.view.intern.Util;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;
import peote.view.Load;

import render.actor.ActorDisplay;
import render.actor.ActorElemAnim;
import render.actor.ActorElemStatic;

class ActorRender {

	var peoteView:PeoteView;
	var actorDisplay:ActorDisplay;

	var actorBufferStatic:Buffer<ActorElemStatic>;
	var actorBufferAnim:Buffer<ActorElemAnim>;

	public static function loadTextures() {
		/*
		var textureStatic = new Texture(Tiles.width, Tiles.height, 1, {
			format:TextureFormat.RGBA,
			// smoothExpand: true,
			smoothShrink: true,
			// mipmap: true,
			powerOfTwo: false
		});

		textureStatic.tilesX = Tiles.tilesX;
		textureStatic.tilesY = Tiles.tilesY;
		
		Load.imageArray([
			Tiles.fileName
			],
			true,
			function (image:Array<Image>) {

				textureStatic.setData(image[0]);
				
			}
		);
		*/
	}

	//----------------------------------------------------

 	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;
	
		actorBufferStatic = new Buffer<ActorElemStatic>(1024, 512);
		actorBufferAnim = new Buffer<ActorElemAnim>(1024, 512);

		// ----------------------------------------

		actorDisplay = new ActorDisplay(0, 0, 512, 512, actorBufferStatic, actorBufferAnim);
		peoteView.addDisplay(actorDisplay);
		

	}


}