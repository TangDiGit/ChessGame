using System.Collections;
using UnityEngine;
using FairyGUI;
using System.IO;
using System.Text;
using UnityDebuger;

public class AppMain : MonoBehaviour
{
    void Start()
    {
        StartCoroutine(playMovice());
    }
      
    private IEnumerator playMovice()
    {
        //打印日志
        string logFile = "";
        if (Application.isMobilePlatform)
        {
            logFile= Application.persistentDataPath + "/log.txt";
        }
        else if (Application.platform == RuntimePlatform.OSXEditor)
        {
            int i = Application.dataPath.LastIndexOf('/');
            logFile = Application.dataPath.Substring(0, i + 1)  + "/log.txt";
        }
        else
        {
            //win10不允许c盘操作
            string gameLogFile = "d:/f_game_log";
            if (!Directory.Exists(gameLogFile))
            {
                Directory.CreateDirectory(gameLogFile);
            }
            logFile = string.Format(gameLogFile + "/log{0}.txt",F_Util.GetTimeStamp2());
        }
        
        try
        {
            if (File.Exists(logFile)) File.Delete(logFile);
        }
        catch (System.Exception)
        {

        }
        Application.logMessageReceived += (condition, stackTrace, type) =>
        {
            try
            {
                File.AppendAllText(logFile, condition + "\r\n", Encoding.UTF8);
            }
            catch (System.Exception)
            {
                
            }
            
        };

        if (Application.isMobilePlatform)
        {
            //Handheld.PlayFullScreenMovie("POKER_1_1.mp4", Color.black, FullScreenMovieControlMode.CancelOnInput, FullScreenMovieScalingMode.Fill);
        }
        yield return new WaitForEndOfFrame();
        yield return new WaitForEndOfFrame();

        Debuger.Log("Play Movice is finish");

#if UNITY_IPHONE || UNITY_IOS
        
#elif UNITY_ANDROID
        // 开启SDK的日志打印，发布版本请务必关闭
        BuglyAgent.ConfigDebugMode(true);
        // 注册日志回调，替换使用 'Application.RegisterLogCallback(Application.LogCallback)'注册日志回调的方式
        // BuglyAgent.RegisterLogCallback (CallbackDelegate.Instance.OnApplicationLogCallbackHandler);
        BuglyAgent.InitWithAppId("185a1e3780");
        // 如果你确认已在对应的iOS工程或Android工程中初始化SDK，那么在脚本中只需启动C#异常捕获上报功能即可
        BuglyAgent.EnableExceptionHandler();
#endif
        
        //F_Tool.instance.Run();

        //将icon写入Application.persistentDataPath 给mob分享微信使用
        if (Application.isMobilePlatform)
        {
            if (!File.Exists(Application.persistentDataPath + "/icon.png"))
            {
                Texture2D icon = Resources.Load<Texture2D>("AppIcon");
                Texture2D newIcon = new Texture2D((int)icon.width, (int)icon.height, TextureFormat.RGBA32, false);
                for (int i = 0; i < icon.width; i++)
                {
                    for (int j = 0; j < icon.height; j++)
                    {
                        newIcon.SetPixel(i, j, icon.GetPixel(i, j));
                    }
                }
                newIcon.Apply();
                byte[] bytes = newIcon.EncodeToPNG();
                File.WriteAllBytes(Application.persistentDataPath + "/icon.png", bytes);
                Debuger.Log(Application.persistentDataPath + "/icon.png");
            }
        }
        
        //屏幕适配
        GRoot.inst.SetContentScaleFactor(1920,1080);
        //重载加载器
        UIObjectFactory.SetLoaderExtension(typeof(F_Loader));

        Input.multiTouchEnabled = false;
        Screen.sleepTimeout = SleepTimeout.NeverSleep;
        Application.targetFrameRate = 30;

        //音效
        UIConfig.buttonSound = new NAudioClip(Resources.Load<AudioClip>("xt_anniu_0"));
        float v = PlayerPrefs.GetFloat("SoundEffect2", 100);
        GRoot.inst.soundVolume = (float)v / 100;

        //gui
        UIPackage.AddPackage("UI/rootPack");
        UIPackage.AddPackage("UI/main");
        F_LogoView.instance.Run();
        F_MessageView.instance.Run();
        F_WaitTipView.instance.Run();

        F_MessageView.instance.Hide();
        F_WaitTipView.instance.Hide();
        F_LogoView.instance.Show();

        F_SoundManager.instance.Run();
        F_GameManager.instance.Run();

    }

}