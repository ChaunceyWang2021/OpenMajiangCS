using Engine;
using GameServer;

public class MainWindow : RenderWindow
{
    private MainMenuControlView? menu;
    private View2D game_view;
    private GameController? game_controller = null;
    private GameEscapeMenuView? escape_menu;
    private bool game_running = false;
    private MusicPlayer music;
    private RectangleControl fade_rect;

    public MainWindow(IWindowTarget window, RenderTarget renderer)
    {
        base(window, renderer);
        back_color = Color(0, 0.01f, 0.02f, 1);
    }

    protected override void shown()
    {
        set_icon(FileLoader.find_file(GLib.Path.build_filename("Data", "Icon.png")));
        music = new MusicPlayer(store.audio_player);

        Options options = new Options.from_disk();
        load_options(options);

        create_main_menu();

        game_view = new View2D();
        main_view.add_child(game_view);
    }

    protected override void resized()
    {
        Options options = new Options.from_disk();
        options.screen_type = screen_type;

        if (screen_type == ScreenTypeEnum.WINDOWED)
        {
            options.window_width = size.width;
            options.window_height = size.height;
        }
        options.save();
    }

    protected override void moved()
    {
        if (screen_type == ScreenTypeEnum.WINDOWED)
        {
            Options options = new Options.from_disk();
            options.window_x = position.x;
            options.window_y = position.y;
            options.save();
        }
    }

    private void create_main_menu()
    {
        menu = new MainMenuControlView();
        menu.game_start.connect(game_start);
        menu.restart.connect(restart);
        menu.quit.connect(quit);
        main_view.add_child(menu);
    }

    private void game_loaded()
    {
        var anim = new Animation.preset(1);
        anim.curve = new SmoothDepartCurve();
        anim.animate.connect(animate_fade_rect);
        anim.finished.connect(remove_fade_rect);
        fade_rect.add_animation(anim);
    }

    private void animate_fade_rect(float time)
    {
        fade_rect.color = Color.with_alpha(1 - time);
    }

    private void remove_fade_rect()
    {
        main_view.remove_child(fade_rect);
    }

    private GameController game_start(GameStartInfo info, ServerSettings settings, IGameConnection connection, int player_index)
    {
        menu.visible = false;
        game_controller = new GameController(game_view, info, settings, connection, player_index, new Options.from_disk());
        game_controller.game_loaded.connect(game_loaded);
        game_controller.finished.connect(game_finished);
        
        game_running = true;
    
        fade_rect = new RectangleControl();
        main_view.add_child(fade_rect);
        fade_rect.color = Color.black();
        fade_rect.resize_style = ResizeStyle.RELATIVE;

        return game_controller;
    }

    private void game_finished()
    {
        game_running = false;
        game_controller = null;
        menu.visible = true;
        if (escape_menu != null)
        {
            main_view.remove_child(escape_menu);
            escape_menu = null;
        }
    }

    private void leave_game_pressed()
    {
        game_controller.finished();
    }

    private void restart()
    {
        do_restart = true;
        finish();
    }

    private void quit()
    {
        finish();
    }

    protected override void do_process(DeltaArgs delta)
    {
        if (game_running && game_controller != null)
            game_controller.process(delta);
    }

    protected override bool key_press(KeyArgs key)
    {
        if (key.scancode == ScanCode.F12)
        {
            if (key.down)
                screen_type = screen_type == ScreenTypeEnum.FULLSCREEN ? ScreenTypeEnum.WINDOWED : ScreenTypeEnum.FULLSCREEN;
            return true;
        }
        else if (key.scancode == ScanCode.ESCAPE)
        {
            if (game_running && key.down)
            {
                if (escape_menu == null)
                {
                    escape_menu = new GameEscapeMenuView();
                    escape_menu.apply_options.connect(apply_options);
                    escape_menu.close_menu.connect(close_menu);
                    escape_menu.leave_game.connect(leave_game_pressed);
                    main_view.add_child(escape_menu);
                }
                else
                {
                    main_view.remove_child(escape_menu);
                    escape_menu = null;
                }
            }

            return true;
        }

        return false;
    }

    private void close_menu()
    {
        main_view.remove_child(escape_menu);
        escape_menu = null;
    }

    private void apply_options(Options options)
    {
        load_options(options);
        game_controller.load_options(options);
    }

    private void load_options(Options options)
    {
        renderer.anisotropic_filtering = options.anisotropic_filtering == OnOffEnum.ON;
        renderer.v_sync = options.v_sync == OnOffEnum.ON;
        store.audio_player.muted = options.sounds == OnOffEnum.OFF;
        screen_type = options.screen_type;

        if (options.music == OnOffEnum.ON)
            music.start();
        else
            music.stop();
    }

    public bool do_restart { get; private set; }
}
