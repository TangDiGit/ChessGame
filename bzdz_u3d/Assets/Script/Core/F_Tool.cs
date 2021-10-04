using UnityEngine;
using System.Collections;
using System.IO;
using System;
using UnityEngine.Networking;
using UnityDebuger;
using LuaInterface;

public class F_Tool : F_Singleton<F_Tool>
{
    public static bool isWxLoginOutTime = false;
    //private AndroidJavaClass F_Tool_Class;
    //private AndroidJavaObject activity;
    //public void Run()
    //{
        
    //}

    // 1.复制到黏贴版
    public void SetCopyStr(string str)
    {
        GUIUtility.systemCopyBuffer = str;
    }

    // 2.截屏：图片保存路径 ,左下角为原点（0, 0）开始
    public void ScreenShootOnClick(int width, int height, Action action)
    {
        // Screen.width  Screen.height
        width = width == 0 ? Screen.width : width;
        height = height == 0 ? Screen.height : height;
        StartCoroutine(ScreenShoot(width, height, action));
    }

    // 截图保存之后刷新相册
    private IEnumerator ScreenShoot(int width, int height, Action action)
    {
        //图片大小  
        Texture2D tex = new Texture2D(width, height, TextureFormat.RGB24, true);
        yield return new WaitForEndOfFrame();
        tex.ReadPixels(new Rect(0, 0, width, height), 0, 0, true);
        tex.Apply();
        yield return tex;
        byte[] byt = tex.EncodeToPNG();

        string fileName = DateTime.Now.ToString("yyyyMMddhhmmss") + ".jpg";
        string path = ScreenshotPath() + fileName;
        File.WriteAllBytes(path, byt);
        string[] paths = { path };
        ScanFile(paths);
#if UNITY_EDITOR
        System.Diagnostics.Process.Start(path);
#endif

        yield return new WaitForEndOfFrame();
        if (action != null)
        {
            action();
        }
    }

    // 3.下载保存
    public void DownloadSavePhotoAlbum(string url, Action action)
    {
        StartCoroutine(IDownloadSavePhotoAlbum(url, action));
    }

    // 下载保存
    private IEnumerator IDownloadSavePhotoAlbum(string url, Action action)
    {
        //WWW www = new WWW(infile);
        //yield return www;

        //if (www.isDone)
        //{
        //    File.WriteAllBytes(outfile, www.bytes);
        //}
        //yield return 0;

        UnityWebRequest www = UnityWebRequest.Get(url);
        www.timeout = 3;//超时时间
        yield return www.SendWebRequest();
        Debuger.Log("下载完毕");
        if (www.error != null)
        {
            F_MessageView.instance.Show("获取图片信息失败,请检查网络后重试。");
            Debuger.Log(www.uri);
            Debuger.Log(www.error);
            yield break;
        }
        else
        {
            string fileName = DateTime.Now.ToString("yyyyMMddhhmmss") + ".jpg";
            string path = ScreenshotPath() + fileName;
            File.WriteAllBytes(path, www.downloadHandler.data);
            string[] paths = { path };


#if UNITY_STANDALONE_WIN || UNITY_EDITOR
            System.Diagnostics.Process.Start(path);
#elif UNITY_IOS || UNITY_IPHONE
                
#elif UNITY_ANDROID
                Debuger.Log("安卓保存图片");
                ScanFile(paths);
#endif

            yield return new WaitForEndOfFrame();
            Debuger.Log("安卓保存图片成功");
            if (action != null)
            {
                action();
            }
        }
    }

    //刷新图片，显示到相册中
    private void ScanFile(string[] path)
    {
        using (AndroidJavaClass PlayerActivity = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
        {
            AndroidJavaObject playerActivity = PlayerActivity.GetStatic<AndroidJavaObject>("currentActivity");
            using (AndroidJavaObject Conn = new AndroidJavaObject("android.media.MediaScannerConnection", playerActivity, null))
            {
                Conn.CallStatic("scanFile", playerActivity, path, null, null);
            }
        }
    }

    private string ScreenshotPath()
    {
        string filePath = "";
        switch (Application.platform)
        {
            case RuntimePlatform.WindowsEditor:
                filePath = "c:/" + F_AppConst.AppName.ToLower() + "/";
                break;
            case RuntimePlatform.OSXEditor:
                filePath = Application.dataPath + "/storage/emulated/0/Camera/";
                break;
            case RuntimePlatform.Android:
                filePath = "/storage/emulated/0/DCIM/Screenshots/";
                break;
            case RuntimePlatform.IPhonePlayer:
                filePath = Application.persistentDataPath + "/";
                break;
        }
        if (!Directory.Exists(filePath))
        {
            Directory.CreateDirectory(filePath);
        }
        return filePath;
    }

    //4.微信登陆计算时间差，是否超时
    public void GetWxLoginIsOutTime(int outDay)
    {
        string lastTime = PlayerPrefs.GetString("wx_login_time");
        if (lastTime.Length == 0)
        {
            // 第一次登陆
            lastTime = DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
            SetWxLoginTime(lastTime);
            isWxLoginOutTime = true;
            return;
        }

        else if (lastTime.Length > 0)
        {

            if (GetSubDays(Convert.ToDateTime(lastTime), DateTime.Now) > outDay)
            {
                // 已经超时天
                isWxLoginOutTime = true;
                return;
            }
            else
            {
                // 未超时
                isWxLoginOutTime = false;
                return;
            }
        }

        isWxLoginOutTime = false;
    }

    private void SetWxLoginTime(string time)
    {
        PlayerPrefs.SetString("wx_login_time", time);
    }

    public void SetWxLoginTimeNow()
    {
        SetWxLoginTime(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"));
    }

    /// <summary>
    /// 获取两个时间的相差多少天
    /// </summary>
    /// <param name="startTimer"></param>
    /// <param name="endTimer"></param>
    /// <returns></returns>
    private int GetSubDays(DateTime startTimer, DateTime endTimer)
    {
        TimeSpan startSpan = new TimeSpan(startTimer.Ticks);

        TimeSpan nowSpan = new TimeSpan(endTimer.Ticks);

        TimeSpan subTimer = nowSpan.Subtract(startSpan).Duration();
        //return subTimer.Days;
        //返回相差时长（返回相差的总天数）
        return (int)subTimer.TotalDays;
    }
}