using UnityEngine;
using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using System.IO;
using UnityEngine.Networking;
using UnityDebuger;

public enum WebType
{
    outerNet = 1,  // 外网（外网包）
    inNet = 2,     // 内网（客户端 / 服务器联调）
    localNet = 3,  // 本地测试（服务端自己调试自己用）
    normalNet = 4, // 正常启动模式（配置文件控制）
}

public enum DownLoadType
{
    webRequest = 1,// iunity webRequest
    thread = 2,    // 线程下载
}

public class F_GameManager : F_Singleton<F_GameManager>
{
    private LuaFunction OnApplicationPauseWithLua;

    private WebType webTypeCfg = WebType.normalNet;

    public void Run()
    {
        ConvertLocalIpAddress();
    }

    // 获取本地 ip 配置
    public void ConvertLocalIpAddress()
    {
        //从 Resources JSON 文件中加载
        TextAsset jsonTextFile = Resources.Load<TextAsset>("cfg/ipinfo");

        Debuger.Log("本地的ipJsonStr:" + jsonTextFile.text);

        F_AppConst.ipInfoCfg = JsonUtility.FromJson<F_AppConst.IpInfo>(jsonTextFile.text);

        // 配置文件
        webTypeCfg = (WebType)F_AppConst.ipInfoCfg.server_type;

        F_AppConst.ipVer = F_AppConst.ipInfoCfg.ipVer;

        bool isLog = false;
        if (webTypeCfg == WebType.inNet || webTypeCfg == WebType.localNet)
        {
            isLog = true;
        }
        else
        {
            isLog = F_AppConst.ipInfoCfg.enable_debug;
        }

        CheckExtractResource();

        F_Log.instance.Run(isLog);

    }

    /// <summary>
    /// 检查资源
    /// </summary>
    public void CheckExtractResource()
    {
        downloadFiles.Clear();
        bool isExists = Directory.Exists(F_Util.DataPath) && File.Exists(F_Util.DataPath + "files.txt");
        if (isExists)
        {
            StartCoroutine(CheckNewVersion());      // 文件已经解压过了，自己可添加检查文件列表逻辑
            return;
        }
        StartCoroutine(OnExtractResource());        // 启动释放协成
    }

    IEnumerator OnExtractResource()
    {
        string resPath = F_Util.AppContentPath();   // 游戏包资源目录
        string dataPath = F_Util.DataPath;          // 数据存放读写目录（游戏用）

        // 清空文件夹
        if (Directory.Exists(dataPath))
        {
            Directory.Delete(dataPath, true);
        }

        Directory.CreateDirectory(dataPath);

        // 先把 files.txt 文件拷过去
        string infile = resPath + "files.txt";
        string outfile = dataPath + "files.txt";

        if (File.Exists(outfile))
        {
            File.Delete(outfile);
        }

        string message = "正在解包文件";
        
        if (Application.platform == RuntimePlatform.Android)
        {
            WWW www = new WWW(infile);
            yield return www;

            if (www.isDone)
            {
                File.WriteAllBytes(outfile, www.bytes);
            }
            yield return 0;
        }
        else
        {
            File.Copy(infile, outfile, true);
        }
        yield return new WaitForEndOfFrame();

        //释放所有文件到数据目录
        string[] files = File.ReadAllLines(outfile);
        for (int i = 0; i < files.Length; i++)
        {
            string[] fs = files[i].Split('|');
            infile = resPath + fs[0] + ".zip";
            outfile = dataPath + fs[0] + ".zip";
            message = "正在解包文件（版本V9.0）";

            F_LogoView.instance.SetNow(message);

            float valUnPackPackage = (i + 1) * 1.0f / files.Length;
            F_LogoView.instance.SetBar(valUnPackPackage);
            F_LogoView.instance.SetTit(string.Format("正在为您解压资源包(过程不耗流量){0}%", Mathf.Round(valUnPackPackage * 100)));

            string dir = Path.GetDirectoryName(outfile);
            if (!Directory.Exists(dir))
            {
                Directory.CreateDirectory(dir);
            }

            if (Application.platform == RuntimePlatform.Android)
            {
                WWW www = new WWW(infile);
                yield return www;

                if (www.isDone)
                {
                    File.WriteAllBytes(outfile, www.bytes);
                }
                yield return null;
            }
            else
            {
                if (File.Exists(outfile))
                {
                    File.Delete(outfile);
                }
                File.Copy(infile, outfile, true);
            }
            yield return new WaitForEndOfFrame();
        }

        string zipFilePath;
        string outFilePath;

        for (int i = 0; i < files.Length; i++)
        {
            string[] fs = files[i].Split('|');
            outFilePath = dataPath + fs[0];
            zipFilePath = outFilePath + ".zip";
            message = "正在解压缩文件（版本V9.0）";
            F_LogoView.instance.SetNow(message);
            float valUnPackRes = (i + 1) * 1.0f / files.Length;
            F_LogoView.instance.SetBar(valUnPackRes);
            F_LogoView.instance.SetTit(string.Format("正在为您解压压缩包(过程不耗流量){0}%", Mathf.Round(valUnPackRes * 100)));

            yield return StartCoroutine(DecompressFile(zipFilePath, outFilePath));
        }

        message = "解包完成!!!";
        F_LogoView.instance.SetNow(message);
        yield return new WaitForSeconds(0.1f);

        message = string.Empty;
        //释放完成，开始启动更新资源

        StartCoroutine(CheckNewVersion());
    }

    // 检查新版本
    private IEnumerator CheckNewVersion()
    {
        F_LogoView.instance.SetNow("");
        F_LogoView.instance.SetTit(string.Format("{0}", "正在为您检查版本更新"));
        F_LogoView.instance.SetBar(1);

        F_WaitTipView.instance.Show();

        string webRequestFullAddress = "";

        // 根据配置来读
        if (webTypeCfg == WebType.normalNet)
        {
            webRequestFullAddress = F_AppConst.ipInfoCfg.mainEntranceIp + F_AppConst.ipInfoCfg.webServerPath;
        }
        else if (webTypeCfg == WebType.outerNet)
        {
            webRequestFullAddress = F_AppConst.ipInfoCfg.mainEntranceIp + F_AppConst.ipInfoCfg.webServerPath;
        }
        else if (webTypeCfg == WebType.inNet)
        {
            webRequestFullAddress = F_AppConst.ipInfoCfg.devEntranceIp + F_AppConst.ipInfoCfg.webServerPath;
        }
        else if (webTypeCfg == WebType.localNet)
        {
            webRequestFullAddress = F_AppConst.ipInfoCfg.localEntranceIp + F_AppConst.ipInfoCfg.webServerPath;
        }

        Debuger.Log("F_AppConst 配置的WebServerInfo信息：" + webRequestFullAddress);

        using (UnityWebRequest www = UnityWebRequest.Get(webRequestFullAddress + "?v=" + DateTime.Now.ToString("yyyymmddhhmmss")))
        {
            www.timeout = 5;    //超时时间
            yield return www.SendWebRequest();
            F_WaitTipView.instance.Hide();
            if (www.error != null)
            {
                F_MessageView.instance.Show("获取服务器版本失败,请检查网络重试。", () =>
                {
                    CheckExtractResource();
                });
                Debuger.Log("www.uri:" + www.uri);
                Debuger.Log("www.error:" + www.error);
                yield break;
            }
            else
            {
                F_AppConst.jsonServerInfo = www.downloadHandler.text;
            }
        }

        Debuger.Log("获取的配置的 serverInfoCfg 信息：" + F_AppConst.jsonServerInfo);

        F_AppConst.serverInfoCfg = JsonUtility.FromJson<F_AppConst.ServerInfo>(F_AppConst.jsonServerInfo);

        if (!string.IsNullOrEmpty(F_AppConst.serverInfoCfg.mainResIp))
        {
            StartCoroutine(OnUpdateResource());
        }
        else
        {
            F_MessageView.instance.Show("客户端获取mainIpAddress失败");
        }
    }

    // 玩家第一次加载资源会清掉 _ip_json.json 执行了，这里再写入一次
    // 写入到本地
    //private void WriteIpInfoToLocal()
    //{
    //    F_AppConst.ipVer = F_AppConst.serverInfoCfg.ipVer;
    //    bool isExists = Directory.Exists(F_Util.DataPath) && File.Exists(F_Util.DataPath + "_ip_json.json");
    //    if (!isExists)
    //    {
    //        string json = JsonUtility.ToJson(F_AppConst.ipInfoCfg, true);
    //        File.WriteAllText(F_Util.DataPath + "_ip_json.json", json);
    //    }
    //    StartCoroutine(OnUpdateResource());
    //}

    /// <summary>
    /// 启动更新下载，这里只是个思路演示，此处可启动线程下载更新
    /// </summary>
    IEnumerator OnUpdateResource()
    {
        Debuger.Log("F_AppConst是否开始下载更新:?" + F_AppConst.ipInfoCfg.enable_hot_update);

        if (!F_AppConst.ipInfoCfg.enable_hot_update)
        {
            Debuger.Log("更新模式关闭不更新！");
            OnResourceInited();
            yield break;
        }

        if (Application.platform == RuntimePlatform.IPhonePlayer && F_AppConst.serverInfoCfg.isAppleReview
            && F_AppConst.appVer == F_AppConst.serverInfoCfg.appleReviewVer)
        {
            Debuger.Log("预览版不更新！");
            OnResourceInited();
            yield break;
        }

        string resourcesUrl = "";

        if (webTypeCfg == WebType.normalNet)
        {
            resourcesUrl = F_AppConst.serverInfoCfg.mainResIp + F_AppConst.ipInfoCfg.resourcesPath;
        }
        else if (webTypeCfg == WebType.outerNet)
        {
            resourcesUrl = F_AppConst.serverInfoCfg.mainResIp + F_AppConst.ipInfoCfg.resourcesPath;
        }
        else if (webTypeCfg == WebType.inNet)
        {
            resourcesUrl = F_AppConst.serverInfoCfg.devResIp + F_AppConst.ipInfoCfg.resourcesPath;
        }
        else if (webTypeCfg == WebType.localNet)
        {
            resourcesUrl = F_AppConst.serverInfoCfg.localResIp + F_AppConst.ipInfoCfg.resourcesPath;
        }

        string resUrl = resourcesUrl + F_Util.GetOS() + "/";
        long serverVer = -1;

        if (F_Util.GetOS() == "Android")
        {
            serverVer = F_AppConst.serverInfoCfg.androidVer;
        }
        else if (F_Util.GetOS() == "iOS")
        {
            serverVer = F_AppConst.serverInfoCfg.appleVer;
        }
        else if (F_Util.GetOS() == "Win")
        {
            serverVer = F_AppConst.serverInfoCfg.winVer;
        }
        Debuger.Log("F_AppConst的App版本：" + F_AppConst.appVer);
        Debuger.Log("serverVer的App版本：" + serverVer);
        if (F_AppConst.appVer != serverVer)
        {
            F_MessageView.instance.Show("检测到有新的安装包,请更新!", () =>
            {
#if UNITY_ANDROID
                Application.OpenURL(F_AppConst.serverInfoCfg.androidDownloadGame);
#elif UNITY_IOS || UNITY_IPHONE
                Application.OpenURL(F_AppConst.serverInfoCfg.iosDownloadGame);
#elif UNITY_STANDALONE_WIN || UNITY_EDITOR
                Application.OpenURL(F_AppConst.serverInfoCfg.androidDownloadGame);
#endif
                Application.Quit();
            }, () =>
            {
                Application.Quit();
            });
            yield break;
        }
        bool userConfirmUpdate = false;

        string filesText = "";

        Debuger.Log("开始进入files.txt文件中：" + resUrl + "files.txt?v=" + DateTime.Now.ToString("yyyymmddhhmmss"));
        F_WaitTipView.instance.Show();
        using (UnityWebRequest www = UnityWebRequest.Get(resUrl + "files.txt?v=" + DateTime.Now.ToString("yyyymmddhhmmss")))
        {
            www.timeout = 3;//超时时间
            yield return www.SendWebRequest();
            F_WaitTipView.instance.Hide();

            if (www.error != null)
            {
                F_MessageView.instance.Show("获取服务器资源文件失败,请检查网络重试。", () =>
                {
                    CheckExtractResource();
                });
                Debuger.Log("www.uri:" + www.uri);
                Debuger.Log("www.error:" + www.error);
                yield break;
            }
            else
            {
                filesText = www.downloadHandler.text;
            }
        }

        string dataPath = F_Util.DataPath;  //数据目录
        string message = string.Empty;
        string random = DateTime.Now.ToString("yyyymmddhhmmss");

        if (!Directory.Exists(dataPath))
        {
            Directory.CreateDirectory(dataPath);
        }

        string[] files = filesText.Split('\n');

        List<string> waitUpdateUrls = new List<string>();
        List<string> waitUpdateLocalFilesZip = new List<string>();
        List<string> waitUpdateLocalFilesOriginal = new List<string>();
        float sumLen = 0;
        for (int i = 0; i < files.Length; i++)
        {
            if (string.IsNullOrEmpty(files[i])) continue;
            string[] keyValue = files[i].Split('|');
            string fileZip = keyValue[0] + ".zip";
            string localfileZip = (dataPath + fileZip).Trim();
            string localfileOriginal = (dataPath + keyValue[0]).Trim();
            string fileUrl = resUrl + fileZip + "?v=" + random;
            bool canUpdate = !File.Exists(localfileOriginal);

            if (!canUpdate)
            {
                string remoteMd5 = keyValue[1].Trim();
                string localMd5 = F_Util.md5file(localfileOriginal);
                canUpdate = !remoteMd5.Equals(localMd5);
            }

            if (canUpdate)
            {
                //Debuger.Log("本地缺少文件：直接下载更新");
                long _len = Convert.ToInt64(keyValue[2]);
                sumLen = sumLen + _len;
                waitUpdateUrls.Add(fileUrl);
                waitUpdateLocalFilesZip.Add(localfileZip);
                waitUpdateLocalFilesOriginal.Add(localfileOriginal);
            }
        }
        if (sumLen != 0)
        {
            Debuger.Log("需要热更的文件长度：" + sumLen);
            F_MessageView.instance.Show(string.Format("检查到热更资源，点击确定下载更新，点击取消退出游戏",
                Mathf.Max(Mathf.Round(sumLen / 1024f / 1024f * 100f) / 10000, 0.1f)),
                () => {
                    userConfirmUpdate = true;
                }, () => {
                    Application.Quit();
                });
            //不提示玩家更新大小
            //userConfirmUpdate = true;
        }
        else
        {
            userConfirmUpdate = true;
        }

        while (!userConfirmUpdate)
        {
            yield return new WaitForEndOfFrame();
        }

        // 1.开始下载
        F_LogoView.instance.SetTit("正在下载资源");
        F_LogoView.instance.SetBar(0);

        for (int i = 0; i < waitUpdateUrls.Count; i++)
        {
            string fileUrl = waitUpdateUrls[i];
            string localfile = waitUpdateLocalFilesZip[i];
            message = "downloading>>" + fileUrl;
            F_LogoView.instance.SetNow("正在下载中..");

            if (File.Exists(localfile))
            {
                File.Delete(localfile);
            }

            DownLoadType downType = (DownLoadType)F_AppConst.ipInfoCfg.download_type;

            if (downType == DownLoadType.webRequest)
            {
                // 1.用WebRequest下载
                using (UnityWebRequest www = UnityWebRequest.Get(fileUrl))
                {
                    www.timeout = 10;//超时时间
                    yield return www.SendWebRequest();
                    if (www.isHttpError || www.isNetworkError || www.error != "")
                    {
                        F_MessageView.instance.Show("热更服务器资源文件失败,请检查网络重试。", () =>
                        {
                            CheckExtractResource();
                        });

                        Debuger.Log("www.uri:" + www.uri);
                        Debuger.Log("www.error:" + www.error);
                        yield break;
                    }

                    byte[] bytes = www.downloadHandler.data;

                    FileInfo file = new FileInfo(localfile);
                    Stream stream = file.Create();
                    stream.Write(bytes, 0, bytes.Length);
                    stream.Close();
                    stream.Dispose();
                }
            }
            else if (downType == DownLoadType.thread)
            {
                // 2.这里都是资源文件，用线程下载
                BeginDownload(fileUrl, localfile);

                while (!(IsDownOK(localfile)))
                {
                    yield return new WaitForEndOfFrame();
                }
            }

            float valDownloadHotRes = (i + 1) * 1.0f / waitUpdateUrls.Count;
            F_LogoView.instance.SetBar(valDownloadHotRes);
            F_LogoView.instance.SetTit(string.Format("正在为您下载热更资源{0}%", Mathf.Round(valDownloadHotRes * 100)));
        }
        yield return new WaitForEndOfFrame();
        message = "下载完成!!";
        F_LogoView.instance.SetNow(message);

        // 2.开始解压缩文件
        F_LogoView.instance.SetBar(0);
        int filesZipCount = waitUpdateLocalFilesZip.Count;
        for (int i = 0; i < waitUpdateLocalFilesZip.Count; i++)
        {
            string zipFilePath = waitUpdateLocalFilesZip[i];
            string outFilePath = waitUpdateLocalFilesOriginal[i];
            message = "正在解压缩文件";
            //Debuger.Log("正在解压缩文件:>" + zipFilePath);
            F_LogoView.instance.SetNow(message);
            float valUnPackHotRes = (i + 1) * 1.0f / filesZipCount;
            F_LogoView.instance.SetBar(valUnPackHotRes);
            F_LogoView.instance.SetTit(string.Format("正在为您解压压缩包(过程不耗流量){0}%", Mathf.Round(valUnPackHotRes * 100)));
            yield return StartCoroutine(DecompressFile(zipFilePath, outFilePath));
        }
        OnResourceInited();
    }

    private List<string> downloadFiles = new List<string>();
    /// <summary>
    /// 是否下载完成
    /// </summary>
    bool IsDownOK(string file)
    {
        return downloadFiles.Contains(file);
    }

    /// <summary>
    /// 线程下载
    /// </summary>
    void BeginDownload(string url, string file)
    {
        //线程下载
        object[] param = new object[2] { url, file };
        ThreadEvent ev = new ThreadEvent();
        ev.Key = "UPDATE_DOWNLOAD";
        ev.evParams.AddRange(param);
        F_ThreadManager.instance.AddEvent(ev, OnThreadCompleted);
    }

    /// <summary>
    /// 线程完成
    /// </summary>
    /// <param name="data"></param>
    void OnThreadCompleted(NotiData data)
    {
        switch (data.evName)
        {
            case "UPDATE_EXTRACT":  //解压一个完成
                //
                break;
            case "UPDATE_DOWNLOAD": //下载一个完成
                downloadFiles.Add(data.evParam.ToString());
                break;
        }
    }

    /// <summary>
    /// 资源初始化结束
    /// </summary>
    public void OnResourceInited()
    {
        F_LogoView.instance.SetBar(1);
        F_LogoView.instance.SetTit(string.Format("{0}", "加载完毕，祝您游戏愉快。"));
        F_LogoView.instance.SetNow("");

        F_WaitTipView.instance.Show();
        F_ResourceManager.instance.InitLua("StreamingAssets", delegate (string[] abs)
        {
            Debuger.Log("加载所有的lua代码包");
            if (Application.platform == RuntimePlatform.WindowsEditor || Application.platform == RuntimePlatform.OSXEditor)
            {
                LuaFileUtils.Instance.beZip = false;
            }
            else
            {
                LuaFileUtils.Instance.beZip = true;
            }

            for (int i = 0; i < abs.Length; i++)
            {
                string abName = abs[i];
                if (abName.StartsWith("lua"))
                {
                    string url = F_Util.DataPath + abName.ToLower();
                    Debuger.Log("lua代码包:" + url);
                    if (File.Exists(url))
                    {
                        AssetBundle bundle = AssetBundle.LoadFromFile(url);
                        if (bundle != null)
                        {
                            abName = abName.Replace("lua/", "").Replace(".unity3d", "");
                            Debuger.Log("添加tolua搜索包:" + abName);
                            LuaFileUtils.Instance.AddSearchBundle(abName, bundle);
                        }
                    }
                }
            }

            Debuger.Log("加载完毕");
            LuaClient luaClient = gameObject.AddComponent<LuaClient>();
            F_NetManager.instance.Run();
            F_UnityAndroidMsg.instance.Run();
            OnApplicationPauseWithLua = LuaClient.GetMainState().GetFunction("OnApplicationPause");
        });
    }

    private void OnApplicationPause(bool focus)
    {
        if (OnApplicationPauseWithLua != null)
        {
            OnApplicationPauseWithLua.Call<bool>(focus);
        }
    }

    IEnumerator DecompressFile(string zip_File, string out_File)
    {
        Lzma.DecompressFileLZMA(zip_File, out_File);
        File.Delete(zip_File);
        yield return null;
    }
}