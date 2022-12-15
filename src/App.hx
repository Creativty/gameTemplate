import dn.Process;
// import dn.heaps.GameFocusHelper;
import utils.Constants;
import utils.GameAction;
import dn.heaps.input.Controller;
import dn.heaps.input.ControllerAccess;

/** `App` Class takes care of all the low-level stuff in the whole application.
  Any other `Process`, including `Game` should be a child of `App`. **/
class App extends Process {
    public static var GLOBAL_INSTANCE: App;
    public var scene(default, null): h2d.Scene;
    public var controller: Controller<GameAction>;
    public var controllerAccess: ControllerAccess<GameAction>;
    public function new(?parent: h2d.Scene) {
        super();
        GLOBAL_INSTANCE = this;
        scene = parent;
        createRoot(scene);
        // Setup window events
        hxd.Window.getInstance().addEventTarget(onWindowEvent);

        initEngine();
        initController();
        // if (GameFocusHelper.isUseful()) new GameFocusHelper(scene, );
        startGame();
    }

    function onWindowEvent(e: hxd.Event) {
        switch (e.kind) {
            case EPush:
            case ERelease:
            case EMove:
            case EOver: onMouseEnter(e);
            case EOut: onMouseLeave(e);
            case EWheel:
            case EFocus: onWindowFocus(e);
            case EFocusLost: onWindowBlur(e);
            case EKeyDown:
            case EKeyUp:
            case EReleaseOutside:
            case ETextInput:
            case ECheck:
        }
    }

    function onMouseEnter(e: hxd.Event) {}
    function onMouseLeave(e: hxd.Event) {}
    function onWindowFocus(e: hxd.Event) {}
    function onWindowBlur(e: hxd.Event) {}
    
#if hl
    public static function onCrash(err: Dynamic) {
        var title = "Crash report";
        var message = 'I\'m really sorry but the game crashed! Report: ${Std.string(err)}';
        var flags : haxe.EnumFlags<hl.UI.DialogFlags> = new haxe.EnumFlags();
        flags.set(IsError);
        var log = [ Std.string(err) ];
        try {
            log.push("Exception:");
            log.push(haxe.CallStack.toString( haxe.CallStack.exceptionStack() ) );
            log.push("Call:");
            log.push(haxe.CallStack.toString( haxe.CallStack.callStack() ) );

            sys.io.File.saveContent("crash.log", log.join("\n"));
            hl.UI.dialog(title, message, flags);
        } catch (_) {
            sys.io.File.saveContent("crash_failsafe.log", log.join("\n"));
            hl.UI.dialog(title, message, flags);
        }
        hxd.System.exit();
    }
#end

    /** Start game process **/
    public function startGame() {
        if (Game.exists()) {
            Game.GLOBAL_INSTANCE.destroy();
            Process.updateAll(1);
            _createGameInstance();
            hxd.Timer.skip();
        } else {
            delayer.addF( () -> {
                _createGameInstance();
                hxd.Timer.skip();
            }, 1);
        }
    }

    final function _createGameInstance() {
        // new Game();
        new platformer.PlatformerGame();
    }


    public inline function toggleGamePause() setGamePause(!isGamePaused());
    public function setGamePause(pauseState: Bool) {
        if (Game.exists())
            if (pauseState)
                Game.GLOBAL_INSTANCE.pause();
            else
                Game.GLOBAL_INSTANCE.resume();
    }
    public inline function isGamePaused() return Game.exists() && Game.GLOBAL_INSTANCE.isPaused();
    function initEngine() {
        engine.backgroundColor = 0x181818;
        hxd.snd.Manager.get();
        hxd.Timer.skip();
        hxd.Timer.smoothFactor = 0.4;
        hxd.Timer.wantedFPS = Constants.TARGET_FPS;
        Process.FIXED_UPDATE_FPS = Constants.TARGET_UPS;
    }

    function initController() {
        controller = Controller.createFromAbstractEnum(GameAction);
        controllerAccess = controller.createAccess();
        controllerAccess.lockCondition = ()->return(destroyed || anyInputHasFocus());
        initControllerBindings();
    }

    public function anyInputHasFocus(): Bool {
        return false;
    }
    public function initControllerBindings() {
        controller.removeBindings();
        // Gamepad.
        controller.bindPadLStick4(MoveLeft, MoveRight, MoveUp, MoveDown);
        controller.bindPad(MoveLeft, DPAD_LEFT);
        controller.bindPad(MoveRight, DPAD_RIGHT);
        controller.bindPad(MoveUp, DPAD_UP);
        controller.bindPad(MoveDown, DPAD_DOWN);
        // Keyboard
        controller.bindKeyboard(MoveLeft, [hxd.Key.LEFT, hxd.Key.Q, hxd.Key.A]);
        controller.bindKeyboard(MoveUp, [hxd.Key.UP, hxd.Key.Z, hxd.Key.W]);
        controller.bindKeyboard(MoveRight, [hxd.Key.RIGHT, hxd.Key.D]);
        controller.bindKeyboard(MoveDown, [hxd.Key.DOWN, hxd.Key.S]);
    }

    public static inline function exists() return GLOBAL_INSTANCE != null && !GLOBAL_INSTANCE.destroyed;

    public function exit() {
        destroy();
    }

    override function onDispose() {
        super.onDispose();
        hxd.Window.getInstance().removeEventTarget(onWindowEvent);
#if hl
        hxd.System.exit();
#end
    }

    override function update() {
        super.update();
        // TODO: Screenshot
        // TODO: Pause
        // TODO: Menu cancel
    }
}
