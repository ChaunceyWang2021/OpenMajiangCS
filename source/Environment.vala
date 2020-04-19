using Gee;
using Engine;

public class Environment
{
    private const int VERSION_MAJOR = 0;
    private const int VERSION_MINOR = 2;
    private const int VERSION_PATCH = 0;
    private const int VERSION_REVIS = 3;

    public const int MIN_NAME_LENGTH =  2;
    public const int MAX_NAME_LENGTH = 12;

    public const uint16 GAME_PORT     = 1337;
    public const uint16 LOBBY_PORT    = 1337;
    public const string LOBBY_ADDRESS = "riichi.fluffy.is";

    private static bool initialized = false;

    private static Logger logger;
    private static LogCallback engine_logger;

    private Environment() {}

    public static bool init(bool do_debug)
    {
        if (initialized)
            return false;
        initialized = true;
        debug = do_debug;

        version_info = new VersionInfo(VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH, VERSION_REVIS);

        logger = new Logger("application/");
        logger.use_color = set_console_color_mode();

        log(LogType.INFO, "Environment", "Logging started (" + version_info.to_string() + ")");
        log(LogType.DEBUG, "Environment", "Logging debug information");
        log(LogType.DEBUG, "Environment", "Console color mode " + (logger.use_color ? "" : "not ") + "applied");

        Log.set_default_handler(glib_log_func);
        set_print_handler(glib_print);
        set_printerr_handler(glib_error);
        engine_logger = new LogCallback();
        engine_logger.log.connect(engine_log);
        EngineLog.set_log_callback(engine_logger);

        if (!set_working_dir())
            return false;
        
        reflection_bug_fix();
        fc_bug_fix();

        return true;
    }

    private static void glib_log_func(string? log_domain, LogLevelFlags log_levels, string message)
    {
        string origin = "glib";
        if (log_domain != null)
            origin += "[" + log_domain + "]";

        log(LogType.ERROR, origin, message);
    }

    private static void glib_print(string text)
    {
        log(LogType.INFO, "glib", text);
    }

    private static void glib_error(string text)
    {
        log(LogType.ERROR, "glib", text);
    }

    private static void engine_log(EngineLogType log_type, string origin, string message)
    {
        LogType t;

        switch (log_type)
        {
        case EngineLogType.ERROR:
            t = LogType.ERROR;
            break;
        case EngineLogType.NETWORK:
            t = LogType.NETWORK;
            break;
        case EngineLogType.DEBUG:
            t = LogType.DEBUG;
            break;
        default:
            t = LogType.SYSTEM;
            break;
        }

        log(t, origin, message);
    }

    // TODO: Find better way to fix class reflection bug
    private static void reflection_bug_fix()
    {
        log(LogType.DEBUG, "Environment", "Calling class_ref for reflection");

        typeof(Serializable).class_ref();
        typeof(SerializableList).class_ref();
        typeof(ObjInt).class_ref();
        typeof(GamePlayer).class_ref();

        typeof(ServerMessage).class_ref();
        typeof(ServerMessageGameStart).class_ref();
        typeof(ServerMessageRoundStart).class_ref();
        typeof(ServerMessagePlayerLeft).class_ref();

        typeof(ServerMessageTileAssignment).class_ref();
        typeof(ServerMessageTileDraw).class_ref();
        typeof(ServerMessageTileDiscard).class_ref();
        typeof(ServerMessageCallDecision).class_ref();
        typeof(ServerMessageTurnDecision).class_ref();
        typeof(ServerMessageRon).class_ref();
        typeof(ServerMessageTsumo).class_ref();
        typeof(ServerMessageRiichi).class_ref();
        typeof(ServerMessageLateKan).class_ref();
        typeof(ServerMessageClosedKan).class_ref();
        typeof(ServerMessageOpenKan).class_ref();
        typeof(ServerMessagePon).class_ref();
        typeof(ServerMessageChii).class_ref();
        typeof(ServerMessageCallsFinished).class_ref();
        typeof(ServerMessageDraw).class_ref();

        typeof(ServerMessageAcceptJoin).class_ref();
        typeof(ServerMessageMenuSlotAssign).class_ref();
        typeof(ServerMessageMenuSlotClear).class_ref();
        typeof(ServerMessageMenuSettings).class_ref();
        typeof(ServerMessageMenuGameLog).class_ref();

        typeof(ClientMessageMenuReady).class_ref();

        typeof(ServerAction).class_ref();
        typeof(DefaultDiscardServerAction).class_ref();
        typeof(DefaultNoCallServerAction).class_ref();
        typeof(ClientServerAction).class_ref();
        typeof(ClientAction).class_ref();
        typeof(TileDiscardClientAction).class_ref();
        typeof(NoCallClientAction).class_ref();
        typeof(RonClientAction).class_ref();
        typeof(TsumoClientAction).class_ref();
        typeof(VoidHandClientAction).class_ref();
        typeof(RiichiClientAction).class_ref();
        typeof(LateKanClientAction).class_ref();
        typeof(ClosedKanClientAction).class_ref();
        typeof(OpenKanClientAction).class_ref();
        typeof(PonClientAction).class_ref();
        typeof(ChiiClientAction).class_ref();

        typeof(Lobby.LobbyInformation).class_ref();
        typeof(Lobby.ServerLobbyMessage).class_ref();
        typeof(Lobby.ServerLobbyMessageCloseTunnel).class_ref();
        typeof(Lobby.ServerLobbyMessageVersionMismatch).class_ref();
        typeof(Lobby.ServerLobbyMessageVersionInfo).class_ref();
        typeof(Lobby.ServerLobbyMessageAuthenticationResult).class_ref();
        typeof(Lobby.ServerLobbyMessageLobbyEnumerationResult).class_ref();
        typeof(Lobby.ServerLobbyMessageEnterLobbyResult).class_ref();
        typeof(Lobby.ServerLobbyMessageEnterGameResult).class_ref();
        typeof(Lobby.ServerLobbyMessageLeaveGameResult).class_ref();
        typeof(Lobby.ServerLobbyMessageUserEnteredLobby).class_ref();
        typeof(Lobby.ServerLobbyMessageUserLeftLobby).class_ref();
        typeof(Lobby.ServerLobbyMessageCreateGameResult).class_ref();
        typeof(Lobby.ServerLobbyMessageGameAdded).class_ref();
        typeof(Lobby.ServerLobbyMessageUserEnteredGame).class_ref();
        typeof(Lobby.ServerLobbyMessageUserLeftGame).class_ref();

        typeof(Lobby.ClientLobbyMessage).class_ref();
        typeof(Lobby.ClientLobbyMessageCloseTunnel).class_ref();
        typeof(Lobby.ClientLobbyMessageVersionInfo).class_ref();
        typeof(Lobby.ClientLobbyMessageGetLobbies).class_ref();
        typeof(Lobby.ClientLobbyMessageAuthenticate).class_ref();
        typeof(Lobby.ClientLobbyMessageEnterLobby).class_ref();
        typeof(Lobby.ClientLobbyMessageLeaveLobby).class_ref();
        typeof(Lobby.ClientLobbyMessageEnterGame).class_ref();
        typeof(Lobby.ClientLobbyMessageLeaveGame).class_ref();
        typeof(Lobby.ClientLobbyMessageCreateGame).class_ref();

        typeof(GameLog).class_ref();
        typeof(GameLogRound).class_ref();
        typeof(GameLogLine).class_ref();

        typeof(NullBot).class_ref();
        typeof(SimpleBot).class_ref();
    }

    private static void fc_bug_fix()
    {
        log(LogType.DEBUG, "Environment", "Clearing LC_CTYPE environment variable");

        GLib.Environment.set_variable("LC_CTYPE", "", true); // Fixes a fontconfig warning on macOS
    }

    private static bool set_working_dir()
    {
        bool ret = true;

	// This makes relative paths work by changing directory to the Resources folder inside the .app bundle
	#if DARWIN
        log(LogType.DEBUG, "Environment", "Setting working directory to bundle for macOS");

        void *mainBundle = CFBundleGetMainBundle();
        void *resourcesURL = CFBundleCopyResourcesDirectoryURL(mainBundle);
        char path[PATH_MAX];

        if (!CFURLGetFileSystemRepresentation(resourcesURL, true, (uint8*)path, PATH_MAX))
        {
            log(LogType.ERROR, "Environment", "Could not set working dir");
            ret = false;
        }
        else
        {
            GLib.Environment.set_current_dir((string)path);
            log(LogType.DEBUG, "Environment", "Working directory: " + (string)path);
        }

        CFRelease(resourcesURL);
    #endif
    
        return ret;
    }

    private static bool set_console_color_mode()
    {
    // This makes console colors work in Windows 10
    #if WINDOWS
        void *handle = Win.GetStdHandle(Win.STD_OUTPUT_HANDLE);
        if ((int)handle == 0 || (int)handle == -1)
            return false;

        uint mode = 0;
        if (!Win.GetConsoleMode(handle, out mode))
            return true; // Let's assume it works anyway
        
        return Win.SetConsoleMode(handle, mode | 0x0200);
    #else
        return true;
    #endif
    }

    public static bool compatible(VersionInfo version)
    {
        return
            version.major == version_info.major &&
            version.minor == version_info.minor &&
            version.patch >= version_info.patch;
    }

    public static string sanitize_name(string input)
    {
        return Helper.sanitize_string(input).strip();
    }

    public static bool is_valid_name(string name)
    {
        int chars = sanitize_name(name).char_count();
        return chars >= MIN_NAME_LENGTH && chars <= MAX_NAME_LENGTH;
    }

    public static string get_user_dir()
    {
        return GLib.Environment.get_user_config_dir() + "/OpenRiichi/";
    }

    public static string get_datetime_string()
    {
        return new DateTime.now_local().format("%F_%H-%M-%S");
    }

    public static void log(LogType log_type, string origin, string message)
    {
        logger.log(log_type, origin, message);
    }

    public static GameLogger open_game_log(GameStartInfo start_info, ServerSettings settings)
    {
        return new GameLogger(start_info, settings);
    }

    public static GameLog? load_game_log(string name)
    {
        uint8[]? data = FileLoader.load_data(name);
        return (GameLog?)Serializable.deserialize(data);
    }

    public static string[] get_game_log_names()
    {
        ArrayList<string> logs = new ArrayList<string>();

        foreach (string log in FileLoader.get_files_in_dir(game_log_dir))
        {
            string extension = log_extension;
            if (log.last_index_of(extension) == log.length - extension.length)
                logs.add(log.substring(0, log.length - extension.length));
        }

        return logs.to_array();
    }

    public static bool debug { get; private set; }
    public static VersionInfo version_info { get; private set; }
    public static string log_dir { owned get { return Environment.get_user_dir() + "logs/"; } }
    public static string game_log_dir { owned get { return log_dir + "game/"; } }
    public static string log_extension { owned get { return ".log"; } }
}

public class GameLogger
{
    private Mutex log_lock;
    private GameLog game_log;
    private string name;

    public GameLogger(GameStartInfo start_info, ServerSettings settings)
    {
        log_lock = Mutex();
        game_log = new GameLog(Environment.version_info, start_info, settings);
        name = Environment.game_log_dir + Environment.get_datetime_string() + Environment.log_extension;
    }

    private void write()
    {
        FileWriter file = FileLoader.open(name);
        file.write_data(game_log.serialize());
    }

    public void log(GameLogLine line)
    {
        log_lock.lock();
        game_log.add_line(line);
        write();
        log_lock.unlock();
    }

    public void log_round(RoundStartInfo info, Tile[] tiles)
    {
        log_lock.lock();
        game_log.start_round(info, tiles);
        write();
        log_lock.unlock();
    }
}

public class Logger
{
    private const string RED     = "\x1b[31m";
    private const string GREEN   = "\x1b[32m";
    private const string YELLOW  = "\x1b[33m";
    private const string BLUE    = "\x1b[34m";
    private const string MAGENTA = "\x1b[35m";
    private const string CYAN    = "\x1b[36m";
    private const string RESET   = "\x1b[00m";
    private const string NEWLINE = "\r\n";

    private Mutex log_lock;
    private FileWriter log_stream;

    public Logger(string name)
    {
        log_stream = FileLoader.open(Environment.log_dir + name + Environment.get_datetime_string() + Environment.log_extension);
        log_lock = Mutex();

        log_stream.write("%VersionInfo:" + Environment.version_info.to_string() + NEWLINE);
    }

    public void log(LogType log_type, string origin, string message)
    {
        if ((log_type == LogType.DEBUG || log_type == LogType.NETWORK) && !Environment.debug)
            return;

        log_lock.lock();
        string type = log_type.to_string().substring(9);
        string date = Environment.get_datetime_string();

        string[] lines = message.strip().replace("\t", "    ").split("\n");

        for (int i = 0; i < lines.length; i++)
        {
            string line = lines[i];
            string number = (i + 1).to_string("%02d");
            string log_line = "[%s] %s from %s(%s): %s%s".printf(date, type, origin, number, line, NEWLINE);
            string col_line = "%s[%s%s%s] %s%s %sfrom %s%s%s(%s): %s%s%s%s".printf(GREEN, RED, date, GREEN, YELLOW, type, GREEN, BLUE, origin, GREEN, number, RED, line, RESET, NEWLINE);

            string con_line = use_color ? col_line : log_line;

            stdout.printf("%s", con_line);
            log_stream.write(log_line);
        }

        stdout.flush();
        log_lock.unlock();
    }

    public bool use_color { get; set; }
}

public enum LogType
{
    ERROR,
    SYSTEM,
    INFO,
    GAME,
    NETWORK,
    DEBUG
}



#if DARWIN
extern const int PATH_MAX;
static extern void* CFBundleGetMainBundle();
static extern void* CFBundleCopyResourcesDirectoryURL(void *bundle);
static extern bool CFURLGetFileSystemRepresentation(void *url, bool b, uint8 *path, int max_path);
static extern void CFRelease(void *url);
#endif
