import dn.Process;
class Boot extends hxd.App {
    /** Main entry point. **/
    static function main() {
        new Boot();
    }

    /** App start event **/
    override function init() {
        new App(s2d);
        onResize();
    }

    /** App event loop **/
    override function update(dt: Float) {
        super.update(dt);
        var adjustedTmod = hxd.Timer.tmod;
#if hl
        try {
#end
            Process.updateAll(adjustedTmod);
            // Assets.update(adjustedTmod);
#if hl
        } catch (err) {
            App.onCrash(err);
        }
#end
    }

    /** Window resized **/
    override function onResize() {
        super.onResize();
        dn.Process.resizeAll();
    }
}
