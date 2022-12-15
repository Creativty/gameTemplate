package utils;

class GameChildProcess extends dn.Process {
    public var app(get, never): App; inline function get_app() return App.GLOBAL_INSTANCE;
    public var game(get, never): Game; inline function get_game() return Game.GLOBAL_INSTANCE;
    public var level(get, never): Level; inline function get_level() return Game.exists() ? Game.GLOBAL_INSTANCE.level : null;

    public function new() {
        super(Game.GLOBAL_INSTANCE);
    }
}
