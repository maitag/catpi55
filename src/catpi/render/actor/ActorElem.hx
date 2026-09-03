package catpi.render.actor;


interface ActorElem {
    
    public var x(get, set):Int;
    public var y(get, set):Int;

    public function add():Void;
    public function remove():Void;

    public function goLeft (startTime:Float, duration:Float):Void;
	public function goRight(startTime:Float, duration:Float):Void;
	public function goUp   (startTime:Float, duration:Float):Void;
	public function goDown (startTime:Float, duration:Float):Void;
	
	public function goLeftUp   (startTime:Float, duration:Float):Void;
	public function goLeftDown (startTime:Float, duration:Float):Void;
	public function goRightUp  (startTime:Float, duration:Float):Void;
	public function goRightDown(startTime:Float, duration:Float):Void;

}