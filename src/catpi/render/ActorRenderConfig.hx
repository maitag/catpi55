package catpi.render;

import catpi.render.actor.ActorElemConfig;
import haxe.ds.Vector;

// import catpi.render.actor.ActorElemConfig;

// assets
import catpi.asset.Sheet;
import catpi.asset.Tile;
import catpi.asset.Anim;

abstract ActorRenderConfig(Map<ActorRenderType, Map<Int, { tile:Tile, action:Map<Int,{anim:Int}> }> >)
	from Map<ActorRenderType, Map<Int, { tile:Tile, action:Map<Int,{anim:Int}> }> >
{
	public function toConfigVector(sheets:Array<Sheet>):{config:Vector<ActorElemConfig>, renderTypeSheets:Map<ActorRenderType, Array<Int>>, maxActions:Int} {
			
		var maxActors:Int = 0;
		var maxActions:Int = 0;

		var renderTypeSheets = new Map<ActorRenderType, Array<Int>>();
		
		for ( renderTypeKey => renderTypeValue in this)
		{
			for ( actorTypeKey => actorTypeValue in renderTypeValue) 
			{
				if ((actorTypeKey:Int) > maxActors) maxActors = actorTypeKey;

				var tile:Tile = actorTypeValue.tile;
				var sheetArray:Array<Int> = renderTypeSheets.get(renderTypeKey);
				if (sheetArray == null)
					renderTypeSheets.set(renderTypeKey, [tile.sheet]);
				else 
				{
					if (sheetArray.indexOf(tile.sheet) < 0) {
						sheetArray.push(tile.sheet);
						// renderTypeSheets.set(renderTypeKey, sheetArray);
					}
				} 

				for ( actionTypeKey in actorTypeValue.action.keys())
				{
					if ((actionTypeKey:Int) > maxActions) maxActions = actionTypeKey;
				}
			}
		}
		maxActors++;
		maxActions++;

		var conf = new Vector<ActorElemConfig>( maxActors * maxActions ) ;
		
		for ( renderTypeKey => renderTypeValue in this) 
		{
			var sheetArray:Array<Int> = renderTypeSheets.get(renderTypeKey);
			sheetArray.sort((a, b) -> a - b);
			// renderTypeSheets.set(renderTypeKey, sheetArray);

			for ( actorTypeKey => actorTypeValue in renderTypeValue)
			{
				var tile:Tile = actorTypeValue.tile;
				var sheet:Sheet = sheets[ tile.sheet ];

				for (actionTypeKey => actionTypeValue in actorTypeValue.action)
				{	
					var anim:Anim = tile.anim(tile.animID[actionTypeValue.anim]);	

					conf.set(actorTypeKey * maxActions + actionTypeKey, {
						renderType: renderTypeKey,
						tileStart: anim.start,
						tileEnd: anim.end,
						sheetNr: sheetArray.indexOf(tile.sheet),
						width: sheet.width,
						height: sheet.height
					});
				}
			}
		}

		return {config:conf, renderTypeSheets:renderTypeSheets, maxActions:maxActions};
	}
}

