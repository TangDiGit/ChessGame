using UnityEngine;
using System.Collections;
using System.IO;
using System.Text;
using System;
using LuaInterface;
using System.Security.Cryptography;
using System.Text.RegularExpressions;

public class F_Util
{
    public static string GetOS()
    {
        return LuaConst.osDir;
    }
    [LuaByteBufferAttribute]
    public static byte[] data;
    public static LuaByteBuffer luaByteBuffer;
    
    /// <summary>
    /// 计算文件的MD5值
    /// </summary>
    public static string md5file(string file)
    {
        try
        {
            FileStream fs = new FileStream(file, FileMode.Open);
            System.Security.Cryptography.MD5 md5 = new System.Security.Cryptography.MD5CryptoServiceProvider();
            byte[] retVal = md5.ComputeHash(fs);
            fs.Close();

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < retVal.Length; i++)
            {
                sb.Append(retVal[i].ToString("x2"));
            }
            return sb.ToString();
        }
        catch (Exception ex)
        {
            throw new Exception("md5file() fail, error:" + ex.Message);
        }
    }
    /// <summary>
    /// 取得数据存放目录
    /// </summary>
    public static string DataPath
    {
        get
        {
            string game = F_AppConst.AppName.ToLower();
            if (Application.isMobilePlatform)
            {
                return Application.persistentDataPath + "/" + game + "/";
            }
            if (Application.platform == RuntimePlatform.OSXEditor)
            {
                int i = Application.dataPath.LastIndexOf('/');
                return Application.dataPath.Substring(0, i + 1) + game + "/";
            }
            return "c:/" + game + "/";
        }
    }
    /// <summary>
    /// 应用程序内容路径
    /// </summary>
    public static string AppContentPath()
    {
        string path = string.Empty;
        switch (Application.platform)
        {
            case RuntimePlatform.Android:
                path = "jar:file://" + Application.dataPath + "!/assets/";
                break;
            case RuntimePlatform.IPhonePlayer:
                path = Application.dataPath + "/Raw/";
                break;
            default:
                path = Application.dataPath + "/StreamingAssets/";
                break;
        }
        return path;
    }

    public static bool isAndroid()
    {
        return Application.platform == RuntimePlatform.Android;
    }

    public static bool isIOS()
    {
        return Application.platform == RuntimePlatform.IPhonePlayer;
    }

    public static bool isWin()
    {
        return Application.platform == RuntimePlatform.WindowsPlayer || Application.platform == RuntimePlatform.WindowsEditor;
    }

    public static bool isEditor()
    {
        return Application.platform == RuntimePlatform.OSXEditor || Application.platform == RuntimePlatform.WindowsEditor;
    }

    public static string GetRelativePath()
    {
        return "file:///" + DataPath;
    }
    public static string EncryptString(string str)
    {
        MD5 md5 = MD5.Create();
        // 将字符串转换成字节数组
        byte[] byteOld = Encoding.UTF8.GetBytes(str);
        // 调用加密方法
        byte[] byteNew = md5.ComputeHash(byteOld);
        // 将加密结果转换为字符串
        StringBuilder sb = new StringBuilder();
        foreach (byte b in byteNew)
        {
            // 将字节转换成16进制表示的字符串，
            sb.Append(b.ToString("x2"));
        }
        // 返回加密的字符串
        return sb.ToString();
    }

    //Unicode与中文互转
    public static string Unescape(string str)
    {
        return Regex.Unescape(str);
    }
    public static string Escape(string str)
    {
        return Regex.Escape(str);
    }

    /// <summary>
    /// 获取时间戳
    /// </summary>
    /// <returns></returns>
    public static string GetTimeStamp()
    {
        TimeSpan ts = DateTime.Now - new DateTime(1970, 1, 1, 0, 0, 0, 0);
        return Convert.ToInt64(ts.TotalSeconds).ToString();
    }
    /// <summary>
    /// 获取时间戳
    /// </summary>
    /// <returns></returns>
    public static string GetTimeStamp2()
    {
        TimeSpan ts = DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0, 0);
        return Convert.ToInt64(ts.TotalMilliseconds).ToString();
    }
}