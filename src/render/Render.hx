package render;

import lime.graphics.Image;
import peote.view.PeoteView;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;
import peote.view.Load;

import render.fb_light.*;

class Render {

	var peoteView:PeoteView;

 	public function new(peoteView:PeoteView)
	{
		this.peoteView = peoteView;

		var normalDepthTexture = new Texture(1024, 384, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
		var uvAoAlphaTexture = new Texture(1024, 384, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});
		normalDepthTexture.tilesX = uvAoAlphaTexture.tilesX = 8;
		normalDepthTexture.tilesY = uvAoAlphaTexture.tilesY = 3;
		
		var haxeUVTexture = new Texture(256, 256, {format:TextureFormat.RGBA, smoothExpand: true, smoothShrink: true});

		Load.imageArray([
			"assets/tentacle_normal_depth.png",
			"assets/tentacle_uv_ao_alpha.png",
			"assets/haxe.png"
			],
			true,
			function (image:Array<Image>) {
				normalDepthTexture.setData(image[0]);
				uvAoAlphaTexture.setData(image[1]);
				haxeUVTexture.setData(image[2]);
			}
		);


		
		//----------------------------------------------------
		// ----- create Buffers for Tentacles and Lights -----
		//----------------------------------------------------
		var bufferLight:Buffer<ElementLight>;
	
		var bufferTentacle = new Buffer<ElementTentacle>(1024, 512);
		bufferLight = new Buffer<ElementLight>(1024, 512);
		

		//-------------------------------------------------
		//           Framebuffer chain  
		//-------------------------------------------------

		// --- render all tentacles uv-mapped, ao-prelightned with alpha and in depth ---
		var uvAoAlphaDepthFB = new UvAoAlphaDepthFB(512, 512, bufferTentacle, normalDepthTexture, uvAoAlphaTexture, haxeUVTexture);
		uvAoAlphaDepthFB.addToPeoteView(peoteView);
		
		// ------ render all normals together to use for lightning -------
		var normalDepthFB = new NormalDepthFB(512, 512, bufferTentacle, normalDepthTexture);
		normalDepthFB.addToPeoteView(peoteView);

		// ------ render all lights while using normalDepthFB texture -----
		var lightFB = new LightFB(512, 512, bufferLight, normalDepthFB.fbTexture);
		lightFB.addToPeoteView(peoteView);
		
		// -------- combine both fb-textures (add dynamic lights to the pre-lighted) --------- 
		var combineDisplay = new CombineDisplay(0, 0, 512, 512, uvAoAlphaDepthFB.fbTexture, lightFB.fbTexture);
		peoteView.addDisplay(combineDisplay);

					
		// ----------------------------------------
		// ---------- add some tentacles ----------
		// ----------------------------------------

		var tentacle1 = new ElementTentacle();
		tentacle1.animTile(0, 24);    // params: start-tile, end-tile
		tentacle1.timeTile(0.0, 2.1); // params: start-time, duration
		bufferTentacle.addElement(tentacle1);
	
		// --------------------------------------
		// ---------- add some lights -----------
		// --------------------------------------


		var light1 = new ElementLight(10, 10, 256, Color.YELLOW);
		// light1.depth = 
		bufferLight.addElement(light1);
		
		var light2 = new ElementLight(100, 100, 256, Color.RED);
		bufferLight.addElement(light2);

		

	}


}