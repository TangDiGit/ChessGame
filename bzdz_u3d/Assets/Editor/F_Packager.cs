using UnityEditor;
using UnityEngine;
using System.IO;
using System.Text;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Threading;
using System;

public class F_Packager
{
    static List<AssetBundleBuild> maps = new List<AssetBundleBuild>();
    static List<string> paths = new List<string>();
    static List<string> files = new List<string>();

    [MenuItem("Packager/BuildResource/Android", false, 100001)]
    public static void BuildAssetResource_Android()
    {
        BuildAssetResource(BuildTarget.Android);
    }

    [MenuItem("Packager/BuildResource/Windows", false, 100002)]
    public static void BuildAssetResource_Windows()
    {
        BuildAssetResource(BuildTarget.StandaloneWindows);
    }

    [MenuItem("Packager/BuildResource/iPhone", false, 100003)]
    public static void BuildAssetResource_iPhone()
    {
        BuildAssetResource(BuildTarget.iOS);
    }

    static void BuildAssetResource(BuildTarget target)
    {
        if (Directory.Exists(Application.streamingAssetsPath))
        {
            Directory.Delete(Application.streamingAssetsPath, true);
        }
        Directory.CreateDirectory(Application.streamingAssetsPath);
        AssetDatabase.Refresh();

        maps.Clear();
        //处理lua资源
        ToLuaMenu.BuildNotJitBundles(target, maps);
        
        HandleBundle();

        BuildAssetBundleOptions options = BuildAssetBundleOptions.DeterministicAssetBundle |
                                          BuildAssetBundleOptions.UncompressedAssetBundle;
        BuildPipeline.BuildAssetBundles(Application.streamingAssetsPath, maps.ToArray(), options, target);
        //清空.manifest
        ClearInvalidFile();
        BuildFileIndex();

        Directory.Delete(Application.dataPath + "/temp", true);
        AssetDatabase.Refresh();
        UnityEngine.Debug.Log("生成完毕.");
    }

    static void HandleBundle()
    {
        Handle_UI();
        Handle_Other();
    }

    /// <summary>
    /// 处理UI部分
    /// </summary>
    static void Handle_UI()
    {
        string _path = "Assets/buildAB/ui";
        string[] ps = Directory.GetDirectories(_path);
        for (int i = 0; i < ps.Length; i++)
        {
            string[] files = Directory.GetFiles(ps[i]);
            string abNameHead = new FileInfo(ps[i]).Name;
            List<string> dataFiles = new List<string>();
            List<string> atlasFiles = new List<string>();
            for (int j = 0; j < files.Length; j++)
            {
                if (files[j].EndsWith(".meta"))
                {
                    continue;
                }
                files[j] = files[j].Replace('\\', '/');

                if (files[j].IndexOf("atlas") == -1)
                {
                    dataFiles.Add(files[j]);
                }
                else if (files[j].IndexOf("fui") == -1)
                {
                    atlasFiles.Add(files[j]);
                }
            }
            _addAB(abNameHead + "_fui.unity3d", dataFiles.ToArray());
            _addAB(abNameHead + "_atlas.unity3d", atlasFiles.ToArray());
        }
    }

    static void Handle_Other()
    {
        string _path = "Assets/buildAB";
        FindFile(_path, "");
    }

    static void FindFile(string dirPath, string abNameHeadWithParent)
    {
        DirectoryInfo dir = new DirectoryInfo(dirPath);
        string abNameHead = "";
        if (dir.Name != "buildAB")
        {
            if (abNameHeadWithParent.Length > 0)
            {
                abNameHead = abNameHeadWithParent + "_" + dir.Name;
            }
            else
            {
                abNameHead = dir.Name;
            }
        }

        //查找子目录
        foreach (DirectoryInfo d in dir.GetDirectories())
        {
            string subDir = dirPath + "/" + d.Name;
            if (d.Name != "ui")
            {
                FindFile(subDir, abNameHead);
            }
        }

        //查找文件
        string[] files = Directory.GetFiles(dirPath);
        List<string> resFiles = new List<string>();
        for (int i = 0; i < files.Length; i++)
        {
            if (files[i].EndsWith(".meta"))
            {
                continue;
            }
            files[i] = files[i].Replace('\\', '/');
            resFiles.Add(files[i]);
        }
        if (resFiles.Count > 0)
        {
            _addAB(abNameHead + ".unity3d", resFiles.ToArray());
        }
    }

    static void _addAB(string bundleName, string[] files)
    {
        if (bundleName == ".unity3d")
        {
            return;
        }
        AssetBundleBuild build = new AssetBundleBuild();
        build.assetBundleName = bundleName;
        build.assetNames = files;
        maps.Add(build);
    }

    static void ClearInvalidFile()
    {
        string resPath = Application.streamingAssetsPath;
        string[] files = Directory.GetFiles(resPath);
        for (int i = 0; i < files.Length; i++)
        {
            if (files[i].EndsWith(".manifest") || files[i].EndsWith(".manifest.meta"))
            {
                File.Delete(files[i]);
            }
        }
    }

    static void BuildFileIndex()
    {
        string resPath = Application.streamingAssetsPath;
        ///----------------------创建文件列表-----------------------
        string newFilePath = resPath + "/files.txt";
        if (File.Exists(newFilePath)) File.Delete(newFilePath);

        paths.Clear();
        files.Clear();
        Recursive(resPath);

        FileStream fs = new FileStream(newFilePath, FileMode.CreateNew);
        StreamWriter sw = new StreamWriter(fs);
        for (int i = 0; i < files.Count; i++)
        {
            string file = files[i];
            string ext = Path.GetExtension(file);
            if (file.EndsWith(".meta") || file.Contains(".DS_Store")) continue;

            string md5 = F_Util.md5file(file);
            string value = file.Replace(resPath, string.Empty);
            value = value.Replace("/","");
            FileInfo fileInfo = new FileInfo(file);
            sw.WriteLine(value + "|" + md5 + "|" + fileInfo.Length);
            //Thread thread = new Thread(new ParameterizedThreadStart(CompressThread));
            //thread.Start((object)string.Format("{0}/{1}", resPath, value));
            CompressThread((object)string.Format("{0}/{1}", resPath, value));
        }
        sw.Close();
        fs.Close();
    }

    /// <summary>
    /// 遍历目录及其子目录
    /// </summary>
    static void Recursive(string path)
    {
        string[] names = Directory.GetFiles(path);
        string[] dirs = Directory.GetDirectories(path);
        foreach (string filename in names)
        {
            string ext = Path.GetExtension(filename);
            if (ext.Equals(".meta")) continue;
            files.Add(filename.Replace('\\', '/'));
        }
        foreach (string dir in dirs)
        {
            paths.Add(dir.Replace('\\', '/'));
            Recursive(dir);
        }
    }

    // 打包成 ZIP
    static void CompressThread(object path)
    {
        try
        {
            string targetPath = (string)path;
            Lzma.CompressFileLZMA(targetPath, targetPath + ".zip");
            File.Delete(targetPath);
        }
        catch (Exception e)
        {
            UnityEngine.Debug.Log(e);
        }
    }
}