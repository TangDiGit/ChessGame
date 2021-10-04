using System;

public class F_AppConst
{
    public const string AppName = "f_game";

    public static long ipVer;

    public static long appVer = 20210718;

    public static string jsonServerInfo = null;

    public static string xInstallAwakeInfo = "";

    public static string xInstallInstallInfo = "";

    public static IpInfo ipInfoCfg = null;

    public static ServerInfo serverInfoCfg = null;

    [Serializable]
    public class ServerInfo
    {
        //ios审核相关
        public bool isAppleReview;
        public long appleReviewVer;

        public long appleVer;
        public long androidVer;
        public long winVer;

        public long ipVer;

        public string mainResIp;
        public string devResIp;
        public string localResIp;

        public string androidDownloadGame;
        public string iosDownloadGame;

        public string gameJsonIpAddress;
        public string shareIpAddress;

        public int wxLoginOutDay;
    }

    // 本地配置文件使用
    [Serializable]
    public class IpInfo
    {
        public long ipVer;

        public string mainEntranceIp;
        public string devEntranceIp;
        public string localEntranceIp;

        public string webServerPath;
        public string resourcesPath;
        
        public int server_type;             // 内网、外网、本地
        public int download_type;           // 从服务器下载的方式
        public bool enable_debug;           // 开启 debug
        public bool enable_hot_update;      // 是否开启热更的标志
    }

    //debug设置
    public static string jsonDebugInfo = null;
    public static DebugInfo debugInfoCfg = null;
    [Serializable]
    public class DebugInfo
    {
        //debug开关
        public bool debug;
    }
}
