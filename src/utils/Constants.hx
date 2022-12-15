package utils;
/**
    This class contains constants that adhere to `frequently referenced values`.
**/

class Constants {
    /** Grid unit size in pixels **/
    public static final GRID_UNIT = 32;
    /** A stupendously large number **/
    public static final INFINITE : Int = 0xFFFFFFF;

    public static final TARGET_FPS = 60;
    public static final TARGET_UPS = 30;

    static var _nextUniqueId = 0;
    /** UID Generator **/
    public static inline function makeUniqueId() {
        return _nextUniqueId++;
    }

    /** Game layers indices **/
    static var _inc = 0;
    public static var LAYER_BG   = _inc++;
    public static var LAYER_MAIN = _inc++;
    public static var LAYER_UI   = _inc++;

	/** Viewport scaling **/
	public static var SCALE(get,never) : Int;
		static inline function get_SCALE() {
			// can be replaced with another way to determine the game scaling
			return dn.heaps.Scaler.bestFit_i(200,200);
		}
}
