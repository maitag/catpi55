package asset;

import lime.graphics.Image;
import peote.view.Load;
import peote.view.Texture;
import peote.view.TextureConfig;

class Util {
	public static function loadTextures(sheets:Array<Sheet>):Array<Texture> {
		var textures = new Array<Texture>();
		var texFileNames = new Array<String>();

		for (sheet in sheets) {
			var textureConfig:TextureConfig = {
				powerOfTwo: false,
				tilesX: sheet.tilesX,
				tilesY: sheet.tilesY
			};
			textures.push(new Texture(sheet.width*sheet.tilesX, sheet.height*sheet.tilesY, 1, textureConfig));
			texFileNames.push("assets/" + sheet.name);
		}

		Load.imageArray( texFileNames,
			true, // debug
			function(index:Int, image:Image) { // after every single image is loaded
				trace('File number $index loaded completely.');
				if (image.width != textures[index].width || image.height != textures[index].height)
					throw('Error int PipelineTools "loadTextures", image size does not fit');
				textures[index].setData(image);
			},
			function(images:Array<Image>) { // after all images is loaded
				trace(' --- all images loaded ---');
			}
		);
		
		return textures;
	}
}
