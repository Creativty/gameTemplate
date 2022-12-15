import dn.M;
import dn.struct.FixedArray;
import dn.heaps.slib.HSprite;
import utils.Velocity;
import utils.Constants;

class Entity {
	private static final MAX_ENTITIES:Int = 1024;
	public static var ENTITIES:FixedArray<Entity> = new FixedArray(MAX_ENTITIES);
    public static var GARBAGE_COLLECTOR: FixedArray<Entity> = new FixedArray(ENTITIES.maxSize);

	public var game(get, never):Game;

	inline function get_game()
		return Game.GLOBAL_INSTANCE;

	public var level(get, never):Level;

	inline function get_level()
		return Game.GLOBAL_INSTANCE.level;

	public var destroyed(default, null):Bool = false;
	public var uid(default, null):Int;

	/** Grid position **/
	public var gx = 0;

	public var gy = 0;

	/** Sub-Grid position **/
	public var sx = 0.5;

	public var sy = 1.0;

	/** Entity Visibility **/
	public var visibility = true;

	/** Controlled Velocity **/
	public var velocity:Velocity;

	/** External Forces Velocity **/
	public var extVelocity:Velocity;

	/** Velocities Array **/
	public var velocities:FixedArray<Velocity>;

	/** Width in pixels **/
	public var width(default, set):Float = Constants.GRID_UNIT;

	inline function set_width(value) {
		return width = value;
	}

	public var iwidth(get, set):Int;

	inline function get_iwidth()
		return M.round(width);

	inline function set_iwidth(value:Int) {
		width = value;
		return iwidth;
	}

	/** Height in pixels **/
	public var height(default, set):Float = Constants.GRID_UNIT;

	inline function set_height(value) {
		return height = value;
	}

	public var iheight(get, set):Int;

	inline function get_iheight()
		return M.round(height);

	inline function set_iheight(value:Int) {
		height = value;
		return iheight;
	}

	/** Sprite X **/
	public var spriteX(get, never):Float;

	inline function get_spriteX()
		return (gx + sx) * Constants.GRID_UNIT;

	/** Sprite Y **/
	public var spriteY(get, never):Float;

	inline function get_spriteY()
		return (gy + sy) * Constants.GRID_UNIT;

	/** Sprite scale factor X **/
	public var spriteScaleX = 1.0;

	/** Sprite scale factor Y **/
	public var spriteScaleY = 1.0;

	/** Entity's display `HSprite` instance **/
	public var sprite:HSprite;

	/** Debug Text **/
	var debugLabel:Null<h2d.Text>;

	/** Defines X alignment of entity at its attach point (0 to 1.0) **/
	public var pivotX(default, set):Float = 0.5;

	function set_pivotX(value) {
		pivotX = M.fclamp(value, 0, 1);
		if (sprite != null)
			sprite.setCenterRatio(pivotX, pivotY);
		return pivotX;
	}

	/** Defines Y alignment of entity at its attach point (0 to 1.0) **/
	public var pivotY(default, set):Float = 1;

	function set_pivotY(value) {
		pivotY = M.fclamp(value, 0, 1);
		if (sprite != null)
			sprite.setCenterRatio(pivotX, pivotY);
		return pivotY;
	}

	/** Entity attach X pixel coordinate **/
	public var attachX(get, never):Float;

	inline function get_attachX()
		return (gx + sx) * Constants.GRID_UNIT;

	/** Entity attach Y pixel coordinate **/
	public var attachY(get, never):Float;

	inline function get_attachY()
		return (gx + sx) * Constants.GRID_UNIT;

	// Bounding box getters

	/** Left coordinate of the bounding box **/
	public var bound_left(get, never):Float;

	inline function get_bound_left()
		return attachX + (0 - pivotX) * width;

	/** Right coordinate of the bounding box **/
	public var bound_right(get, never):Float;

	inline function get_bound_right()
		return attachX + (1 - pivotX) * width;

	/** Top coordinate of the bounding box **/
	public var bound_top(get, never):Float;

	inline function get_bound_top()
		return attachY + (0 - pivotY) * height;

	/** Down coordinate of the bounding box **/
	public var bound_bottom(get, never):Float;

	inline function get_bound_bottom()
		return attachY + (1 - pivotY) * height;

	/** Center X pixel coordinate of the bounding box **/
	public var centerX(get, never):Float;

	inline function get_centerX()
		return attachX + (0.5 - pivotX) * width;

	/** Center Y pixel coordinate of the bounding box **/
	public var centerY(get, never):Float;

	inline function get_centerY()
		return attachY + (0.5 - pivotY) * height;

	/** Current X position on screen (ie. absolute) **/
	public var screenAttachX(get, never):Float;

	inline function get_screenAttachX() {
		if (game != null && !game.destroyed)
			return spriteX * Constants.SCALE + game.layers.x;
		return spriteX * Constants.SCALE;
	}

	/** Current Y position on screen (ie. absolute) **/
	public var screenAttachY(get, never):Float;

	inline function get_screenAttachY() {
		if (game != null && !game.destroyed)
			return spriteY * Constants.SCALE + game.layers.y;
		return spriteY * Constants.SCALE;
	}

	/** `attachX` value during last frame **/
	public var prevFrameAttachX(default, null):Float = -Constants.INFINITE;

	/** `attachY` value during last frame **/
	public var prevFrameAttachY(default, null):Float = -Constants.INFINITE;

	/** Last `x` position of attach point (pixels) at the beginning of the latest `fixedUpdate` **/
	var lastFixedUpdateX = 0.;

	/** Last `y` position of attach point (pixels) at the beginning of the latest `fixedUpdate` **/
	var lastFixedUpdateY = 0.;

    /** Total of all `x` velocities. **/
    public var dxTotal(get, never): Float; 
        inline function get_dxTotal() {
            var t = 0.;
            for (v in velocities) t += v.dx;
            return t;
        }

    /** Total of all `y` velocities. **/
    public var dyTotal(get, never): Float; 
        inline function get_dyTotal() {
            var t = 0.;
            for (v in velocities) t += v.dy;
            return t;
        }

	public function new(x:Int, y:Int) {
		uid = Constants.makeUniqueId();
		ENTITIES.push(this);

		velocity = new Velocity(0);
		extVelocity = new Velocity(0);
		velocities = new FixedArray(16);
		velocities.push(velocity);
		velocities.push(extVelocity);

		sprite = new HSprite();
        sprite.setCenterRatio(pivotX, pivotY);
		Game.GLOBAL_INSTANCE.layers.add(sprite, Constants.LAYER_MAIN);
	}

	/** Remove sprite from display contenxt. WARNING: Only if you are sure `sprite` is never called. **/
	function noSprite() {
		sprite.setEmptyTexture();
		sprite.remove();
	}

	/** Set position in pixel coordinates **/
	public function setPosPixel(x:Float, y:Float) {
		gx = Std.int(x / Constants.GRID_UNIT);
		gy = Std.int(y / Constants.GRID_UNIT);
		sx = (x - gx * Constants.GRID_UNIT) / Constants.GRID_UNIT;
		sy = (y - gy * Constants.GRID_UNIT) / Constants.GRID_UNIT;
		onPositionManuallyChangedBoth();
	}

    public function setPosCase(x: Int, y: Int) {
        gx = x;
        gy = y;
        sx = 0.5;
        sy = 1.0;
        onPositionManuallyChangedBoth();
    }

	/** You call this when both (X, Y) have been manually edited (i.e ignoring physics) **/
	function onPositionManuallyChangedBoth() {
		var distance = M.dist(attachX, attachY, prevFrameAttachX, prevFrameAttachY);
		if (distance > Constants.GRID_UNIT * 2) {
			prevFrameAttachX = attachX;
			prevFrameAttachY = attachY;
		}
		updateLastFixedUpdatePos();
	}

	final function updateLastFixedUpdatePos() {
		lastFixedUpdateX = attachX;
		lastFixedUpdateY = attachY;
	}

	public function is<T:Entity>(c:Class<T>)
		return Std.isOfType(this, c);

	public function as<T:Entity>(c:Class<T>):T
		return Std.downcast(this, c);

	public function bump(x:Float, y:Float) {
		extVelocity.add(x, y);
	}

	public function cancelVelocities() {
		for (_velocity in velocities) {
			_velocity.clear();
		}
	}

    /** Calculate distance from `this` to `entity` or `coordinates` in grid cells. **/
	public inline function distanceInUnits(?entity:Entity, ?target_gx:Int, ?target_gy:Int, target_sx = 0.5, ?target_sy = 0.5) {
        if (entity != null) return M.dist(gx + sx, gy + sy, entity.gx + entity.sx, entity.gy + entity.sy)
        else return M.dist(gx + sx, gy + sy, target_gx + target_sx, target_gy + target_sy);
    }

    /** Calculate distance from `this` to `entity` or `coordinates` in pixels. **/
    public inline function distanceInPixels(?entity:Entity, ?targetX:Float, ?targetY:Float) {
        if (entity != null) return M.dist(attachX, attachY, entity.attachX, entity.attachY);
        else return M.dist(attachX, attachY, targetX, targetY);
    }

    public final function destroy() {
        if (!destroyed) {
            destroyed = true;
            GARBAGE_COLLECTOR.push(this);
        }
    }

    public function dispose() {
        ENTITIES.remove(this);
        velocities = null;
        sprite.remove();
        sprite = null;
        if (debugLabel != null) {
            debugLabel.remove();
            debugLabel = null;
        }
    }

    /** `Beginning of the frame` call stack; Is guaranteed execution before `fixedUpdate` and `postUpdate` **/
    public function preUpdate() {}

    /** `Meat of the fixed frame` Frame independent loop. Here goes gameplay related actions.**/
    public function fixedUpdate() {
        updateLastFixedUpdatePos();
        /* INFO: Stepping:
           Any movement greated that 33% of grid unit size (ie. 0.33) will increase the number of `steps` here.
           These steps will break down the full movement into smaller iterations to avoid jumping over grid collisions.
        */
        var steps = M.ceil( (M.fabs(dxTotal) + M.fabs(dyTotal)) / 0.33 );
        if (steps > 0) {
            for (i in 0...steps) {
                // Horizontal axis
                sx += dxTotal / steps;
                if (dxTotal != 0) onPreStepX(); // Collision checks and Physics go there.
                while (sx > 1) { sx--; gx++; }
                while (sx < 0) { sx++; gx--; }

                // Vertical axis
                sy += dyTotal / steps;
                if (dyTotal != 0) onPreStepY(); // Collision checks and Physics go there.
                while (sy > 1) { sy--; gy++; }
                while (sy < 0) { sy++; gy--; }
            }
        }
        // Update velocities.
        for (velocity in velocities) velocity.fixedUpdate();
    }

    /** `Meat of the frame`, Runs on every frame. **/
    public function frameUpdate() { }

    /** Called at the beginning of each X movement step **/
    function onPreStepX() {}

    /** Called at the beginning of each Y movement step **/
    function onPreStepY() {}

    /** `End of the frame` call stack; Is guaranteed execution after `preUpdate` and `fixedUpdate` **/
    public function postUpdate() {
        sprite.x = spriteX;
        sprite.y = spriteY;
        sprite.scaleX = spriteScaleX;
        sprite.scaleY = spriteScaleY;
        sprite.visible = visibility;

        if (debugLabel != null) {
            debugLabel.x = Std.int(attachX - debugLabel.textWidth * 0.5);
            debugLabel.y = Std.int(attachY + 1);
        }
    }
    /** `Terminal of the frame`, Is guaranteed execution after **everything**.**/
    public function finalUpdate() {
        lastFixedUpdateX = attachX;
        lastFixedUpdateY = attachY;
    }
}
