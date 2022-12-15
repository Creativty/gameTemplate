import utils.Constants;
import utils.GameAction;
import utils.AppChildProcess;
import dn.heaps.input.ControllerAccess;

class Game extends AppChildProcess {
	public static var GLOBAL_INSTANCE:Game;

	public var level:Level;
	public var layers:h2d.Layers;
    public var controllerAccess:ControllerAccess<GameAction>;

	public static inline function exists()
		return GLOBAL_INSTANCE != null && !GLOBAL_INSTANCE.destroyed;

	public function new() {
		super();
		GLOBAL_INSTANCE = this;

        controllerAccess = App.GLOBAL_INSTANCE.controller.createAccess();
        controllerAccess.lockCondition = isGameControllerLocked;
		createRootInLayers(App.GLOBAL_INSTANCE.root, Constants.LAYER_BG);
		dn.Gc.runNow();

		layers = new h2d.Layers();
		root.add(layers, Constants.LAYER_BG);
		layers.filter = new h2d.filter.Nothing();
	}

    public static function isGameControllerLocked() {
        return !exists() || GLOBAL_INSTANCE.isPaused() || App.GLOBAL_INSTANCE.anyInputHasFocus();
    }

	/** 
        Garbage collect any Entity marked for destruction.
		This is normally done at the end of the frame, but you can call it manually 
		if you want to make sure marked entities are disposed right away,
		and removed from lists.
	**/
	public function garbageCollectEntities() {
		if (Entity.GARBAGE_COLLECTOR == null || Entity.GARBAGE_COLLECTOR.allocated == 0)
			return;
		for (entity in Entity.GARBAGE_COLLECTOR)
			entity.dispose();
		Entity.GARBAGE_COLLECTOR.empty();
	}

    public function loadLevel(levelToLoad: Dynamic) {

    }

	// TODO:`stopFrame` check [[gameBase/src/game/Game.hx | "public inline function stopFrame()"]].

	/** Called if the `Game` process is destroyed, but only at the end of the frame **/
	override function onDispose() {
		super.onDispose();
		for (entity in Entity.GARBAGE_COLLECTOR)
			entity.destroy();
		garbageCollectEntities();
		if (GLOBAL_INSTANCE == this)
			GLOBAL_INSTANCE = null;
	}

	override function onResize() {
        super.onResize();
	}

	override function preUpdate() {
		super.preUpdate();
		for (entity in Entity.ENTITIES)
			if (!entity.destroyed)
				entity.preUpdate();
	}

	override function postUpdate() {
		super.postUpdate();
		for (entity in Entity.ENTITIES)
			if (!entity.destroyed)
				entity.postUpdate();
		for (entity in Entity.ENTITIES)
			if (!entity.destroyed)
				entity.finalUpdate();
		garbageCollectEntities();
	}

	override function fixedUpdate() {
		super.fixedUpdate();
		for (entity in Entity.ENTITIES)
			if (!entity.destroyed)
				entity.fixedUpdate();
	}

	override function update() {
		super.update();
		for (entity in Entity.ENTITIES)
			if (!entity.destroyed)
				entity.frameUpdate();
		// TODO: Global Key Shortcuts.
	}
}
