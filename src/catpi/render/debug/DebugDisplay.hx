package catpi.render.debug;

import peote.view.intern.Util;
import peote.view.PeoteView;
import peote.view.Display;
import peote.view.Buffer;
import peote.view.Program;
import peote.view.Texture;
import peote.view.TextureFormat;
import peote.view.Color;
import peote.view.text.TextProgram;
import peote.view.text.TextOptions;
import peote.view.text.Text;

class DebugDisplay extends Display
{
	public var textProgram:TextProgram;

	public var yPosToAdd:Int = 0;

	public var textOptions:TextOptions = {
		fgColor: 0xf0f0f0ff,
		bgColor: 0,
		letterWidth: 8,
		letterHeight: 8,
		letterSpace: 0,
		lineSpace: 5,
		zIndex: 0
	};

	public function new(x:Int, y:Int, color:Color)
	{
		super(x, y, 0, 0, color);

		xOffset = 5;
		yOffset = 5;

	
		textProgram = new TextProgram( textOptions );

		addProgram(textProgram);		
	}
}

//----------------------------------------------------

class DebugItem {

	var labelText:Text;
	var valueText:Text;

	var debugDisplay:DebugDisplay;
	var textProgram(get, never):TextProgram; inline function get_textProgram() return debugDisplay.textProgram;

	public var value(get, set):String;
	inline function get_value() return valueText.text;
	inline function set_value(s:String) {
		valueText.text = s;
		textProgram.updateText(valueText);
		return s;
	}

	public var valueInt(get, set):Int;
	inline function get_valueInt() return Std.parseInt(valueText.text);
	inline function set_valueInt(n:Int) { value = Std.string(n); return n; }

	public var valueFloat(get, set):Float;
	inline function get_valueFloat() return Std.parseFloat(valueText.text);
	inline function set_valueFloat(n:Float) {
		value  = Std.string( (roundFloatsAt < 0) ? n : Math.round(n * Math.pow(10, roundFloatsAt)) / Math.pow(10, roundFloatsAt) );
		return n;
	}

	public var roundFloatsAt:Int;

	public function new(debugDisplay:DebugDisplay, label:String, value:String = "", roundFloatsAt:Int = -1)
	{
		this.debugDisplay = debugDisplay;
		this.roundFloatsAt = roundFloatsAt;

		var x:Int = 0;
		var y:Int = debugDisplay.yPosToAdd;
		 
		var labelSize:Int = (debugDisplay.textOptions.letterWidth + debugDisplay.textOptions.letterSpace + 1) * label.length;

		labelText = new Text(x, y, label);
		valueText = new Text(x + labelSize, y, value);

		var valueLines = value.split("\n").length ;
		debugDisplay.yPosToAdd += (debugDisplay.textOptions.letterHeight + debugDisplay.textOptions.lineSpace) * valueLines;

		debugDisplay.height = debugDisplay.yPosToAdd + Std.int(debugDisplay.yOffset);
		

		textProgram.add(labelText);
		textProgram.add(valueText);

		var size:Int = labelSize + (debugDisplay.textOptions.letterWidth + debugDisplay.textOptions.letterSpace) * Std.int(value.length/valueLines);
		if (debugDisplay.width < size + Std.int(debugDisplay.xOffset*2)) debugDisplay.width = size + Std.int(debugDisplay.xOffset*2);
	}
}
