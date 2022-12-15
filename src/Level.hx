import dn.MarkerMap;
import utils.Constants;
import utils.GameChildProcess;

enum abstract LevelMark(Int) to Int {
    var MARK_WALL_COLLIDER;
}

class Level extends GameChildProcess {
    public var gWidth(default, null): Int;
    public var gHeight(default, null): Int;
    public var pxWidth(default, null): Int;
    public var pxHeight(default, null): Int;

    var srcTileset: h2d.Tile;
    var invalidated: Bool = false;
    public var data: Dynamic;
    public var marks: MarkerMap<LevelMark>;

    public function new() {
        super();
        createRootInLayers(Game.GLOBAL_INSTANCE.layers, Constants.LAYER_BG);
    }

    override function onDispose() {
        super.onDispose();
        data = null;
        srcTileset = null;
        marks.dispose();
        marks = null;
    }

    public inline function inBounds(x, y) return (x >= 0 && x < gWidth) && (y >= 0 && y < gHeight);
    public inline function coordId(x, y) return x + y*gWidth;
    public inline function invalidate() invalidated = true;
    public inline function hasCollision(x, y) : Bool { return !inBounds(x, y) ? true : marks.has(MARK_WALL_COLLIDER, x, y); }

    function render() {
        // root.removeChildren();
    }

    override function postUpdate() {
        super.postUpdate();
        if (invalidated) {
            invalidated = false;
            render();
        }
    }
}
