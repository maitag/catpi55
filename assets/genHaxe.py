import bpy, math, re, os
trace = bpy.data.texts["util"].as_module().trace
getTile = bpy.data.texts["util"].as_module().getTile
getSheet = bpy.data.texts["util"].as_module().getSheet

# template spice by: https://www.simple-is-better.org/template/pyratemp.html
# (feels better then into my old perl times;)
Template = bpy.data.texts["pyratemp"].as_module().Template
pyraTemplate = Template( bpy.data.texts["haxeTMPL"].as_string() );

def genHaxe(_context, _config, _filteredTiles):
    if len(_filteredTiles)==0: return

    global context
    context = _context
    global config
    config = _config
    global filteredTiles
    filteredTiles = _filteredTiles
    
    tmpl_sheets = []
    tmpl_tiles = []
    tmpl_all_anims = []
    sheetIndex = 0
            
    for sheetName in config.sheets:
        
        sheet = getSheet(config, sheetName)
        tiles_per_sheet = 0
        animFrame = 0
        
        for tileIndex in range(len(filteredTiles)):
            tile = getTile(config, filteredTiles[tileIndex])
            tmpl_anims = []
            if tile["sheet"]["name"] == sheetName:
                for anim in tile["anim"]:
                    tiles_per_sheet += anim["end"] - anim["start"] + 1
                    
                    if anim["name"] not in tmpl_all_anims:
                        tmpl_all_anims.append(
                            anim["name"]
                        )

                    tmpl_anims.append({
                        "name": anim["name"],
                        "start": animFrame,
                        "end": animFrame + anim["end"]-anim["start"],
                    })
                    
                    animFrame += anim["end"]-anim["start"]+1


                tmpl_tiles.append({
                    "name": tile["name"],
                    "sheetIndex": sheetIndex,
                    "tmpl_anims": tmpl_anims,
                })
        
        if tiles_per_sheet == 0: continue
        
        sheetPath = re.sub(r"/$","",config.sheetPath)
        if sheetPath != "": sheetPath += "/"
        
        # ----- the sheet is in usage -----
        tmpl_sheets.append({
            "pathName": sheetPath + sheetName + ".png",
            "width": sheet["res_x"],
            "height": sheet["res_x"],
            "gap": sheet["gap"],
            "tilesX": sheet["tilesX"],
            "tilesY": math.ceil(tiles_per_sheet / sheet["tilesX"]),
        })     
        sheetIndex += 1    
    
    
    # fill Template
    out = pyraTemplate(
        blenderFilename = bpy.path.basename(bpy.context.blend_data.filepath),
        haxePackage = config.haxePackage,
        haxeClass = config.haxeClass,
        tmpl_all_anims = tmpl_all_anims,
        tmpl_tiles = tmpl_tiles,
        tmpl_sheets = tmpl_sheets,
    )
    
    
    
    # save file
    trace("-------- GENERATE HAXE FILE ----------\n\n" + out)
    
    filename = re.sub(r"/$","",config.haxeSrcPath)
    if filename != "": filename += "/"
    if config.haxePackage != "": filename += re.sub("\.","/",config.haxePackage) + "/"
    filename += config.haxeClass + ".hx"
    
    if os.path.dirname(filename) != "." and os.path.dirname(filename) != "":
        os.makedirs(os.path.dirname(filename), exist_ok=True)
    
    with open(filename, "w") as f: f.write(out)
    trace('saved into: "' + filename + "'")
