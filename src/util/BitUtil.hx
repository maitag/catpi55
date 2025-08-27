package util;

class BitUtil 
{	
	public inline static var MAX_BITSIZE:Int = 32;
	
	public static macro function nextPowerOfTwo(i:haxe.macro.Expr, maxBitsize:Int = MAX_BITSIZE) {
		return macro {
			
				if ($i < 3) $i;
				else {
					var bitsize = cell.BitUtil._bitsize($i - 1, $v{maxBitsize >> 1}, $v{maxBitsize >> 1});
					if (bitsize >= $v{maxBitsize})
						throw("Error calculating nextPowerOfTwo: reaching maxBitSize of " + $v{maxBitsize});
					1 << bitsize;
				};
		}
	}
	
	public static macro function bitsize(i:haxe.macro.Expr, maxBitsize:Int = MAX_BITSIZE) {
		maxBitsize = maxBitsize >> 1;
		return macro ($i < 3) ? $i : cell.BitUtil._bitsize($i, $v{maxBitsize}, $v{maxBitsize});
	}
	
	
	// how to make "private"? (no access from bitsize and _bitsize itself!)
	public static macro function _bitsize(i:haxe.macro.Expr, n:Int, delta:Int) {
		if (delta == 0)
			return macro throw('Error calculating intBitLength: ' + $i + ' has more bits than maxBitSize of ' + $v{MAX_BITSIZE});
		else {
			delta = delta >> 1;
			return macro {
				if ( ($i >> $v{n}) == 1 ) $v{n + 1};
				else if ( ($i >> $v{n}) < 1 ) cell.BitUtil._bitsize($i, $v{n - delta}, $v{delta});
				else cell.BitUtil._bitsize($i, $v{n + delta}, $v{delta});
			}
		}
	}	
	
	
}
