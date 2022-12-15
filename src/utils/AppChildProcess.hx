package utils;

import dn.Process;
import dn.struct.FixedArray;

class AppChildProcess extends Process {
    public static var PROCESSES: FixedArray<AppChildProcess> = new FixedArray(32);

    public var app(get, never) : App; inline function get_app() return App.GLOBAL_INSTANCE;
    public function new() {
        super(App.GLOBAL_INSTANCE);
        PROCESSES.push(this);
    }

    override function onDispose() {
        super.onDispose();
        PROCESSES.remove(this);
    }
}
