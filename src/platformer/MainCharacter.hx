package platformer;

import utils.GameAction;
import dn.heaps.input.ControllerAccess;

class MainCharacter extends Entity {
    private static final INITIAL_X = 8;
    private static final INITIAL_Y = 8;
    var controllerAccess: ControllerAccess<GameAction>;
    var walkSpeed = 0.;
    public function new() {
        super(INITIAL_X, INITIAL_Y);

        setPosCase(INITIAL_X, INITIAL_Y);
        velocity.setFricts(0.84, 0.94);

        controllerAccess = App.GLOBAL_INSTANCE.controller.createAccess();
        controllerAccess.lockCondition = Game.isGameControllerLocked;

        var bitmap = new h2d.Bitmap( h2d.Tile.fromColor(0x00FF00, iwidth, iheight), sprite);
        bitmap.tile.setCenterRatio(0.5, 1);

    }

    override function dispose() {
        super.dispose();
        controllerAccess.dispose();
    }
    override function preUpdate() {
        super.preUpdate();
        walkSpeed = 0;
        var analogDist = controllerAccess.getAnalogDist2(MoveLeft, MoveRight);
        if (analogDist > 0) {
            walkSpeed = controllerAccess.getAnalogValue2(MoveLeft, MoveRight);
        }
    }

    override function fixedUpdate() {
        super.fixedUpdate();
        if (walkSpeed != 0)
            velocity.dx += walkSpeed * 0.045;
    }
}
