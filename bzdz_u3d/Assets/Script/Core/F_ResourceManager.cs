using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System;
using System.IO;
using LuaInterface;
using UObject = UnityEngine.Object;
using FairyGUI;
using System.Linq;
using UnityDebuger;

public class AssetBundleInfo
{
    public AssetBundle m_AssetBundle;
    public int m_ReferencedCount;

    public AssetBundleInfo(AssetBundle assetBundle)
    {
        m_AssetBundle = assetBundle;
        m_ReferencedCount = 0;
    }
}
public class F_ResourceManager : F_Singleton<F_ResourceManager>
{

    string m_BaseDownloadingURL = "";
    string[] m_AllManifest = null;
    AssetBundleManifest m_AssetBundleManifest = null;
    Dictionary<string, string[]> m_Dependencies = new Dictionary<string, string[]>();
    Dictionary<string, AssetBundleInfo> m_LoadedAssetBundles = new Dictionary<string, AssetBundleInfo>();
    Dictionary<string, List<LoadAssetRequest>> m_LoadRequests = new Dictionary<string, List<LoadAssetRequest>>();

    class LoadAssetRequest
    {
        public Type assetType;
        public string[] assetNames;
        public LuaFunction luaFunc;
        public Action<UObject[]> sharpFunc;

    }

    // Load AssetBundleManifest.
    public void InitLua(string manifestName, Action<string[]> initOK)
    {
        m_BaseDownloadingURL = F_Util.GetRelativePath();
        LoadAsset<AssetBundleManifest>(manifestName, new string[] { "AssetBundleManifest" }, delegate (UObject[] objs)
        {
            if (objs.Length > 0)
            {
                m_AssetBundleManifest = objs[0] as AssetBundleManifest;
                m_AllManifest = m_AssetBundleManifest.GetAllAssetBundles();

                if (initOK != null) initOK(m_AllManifest);
            }
        }, null, false, manifestName);
    }

    /// <summary>
    /// 添加FGUI AB包
    /// </summary>
    public void AddPackage(string packName, LuaFunction func)
    {
#if UNITY_EDITOR
        FairyGUI.UIPackage.AddPackage("Assets/buildAB/ui/" + packName+"/"+ packName).LoadAllAssets();
        if (func!=null)
        {
            func.Call();
            func.Dispose();
        }
#else
        LoadAssetRequest request = new LoadAssetRequest();
        request.luaFunc = func;
       
        List<LoadAssetRequest> requests = null;
        if (!m_LoadRequests.TryGetValue(packName, out requests))
        {
            requests = new List<LoadAssetRequest>();
            requests.Add(request);
            m_LoadRequests.Add(packName, requests);
            StartCoroutine(OnLoadPackage(packName));
        }
        else
        {
            requests.Add(request);
        }
#endif

    }

    IEnumerator OnLoadPackage(string packName)
    {
        string desc_bundle = packName + "_fui.unity3d";
        yield return StartCoroutine(OnLoadPackageAB(desc_bundle));
        AssetBundleInfo desc_bundleInfo = GetLoadedAssetBundle(desc_bundle);

        string res_bundle = packName + "_atlas.unity3d";
        yield return StartCoroutine(OnLoadPackageAB(res_bundle));
        AssetBundleInfo res_bundleInfo = GetLoadedAssetBundle(res_bundle);

        if (desc_bundleInfo.m_ReferencedCount == 0 && res_bundleInfo.m_ReferencedCount == 0)
        {
            UIPackage.AddPackage(desc_bundleInfo.m_AssetBundle, res_bundleInfo.m_AssetBundle);

            desc_bundleInfo.m_ReferencedCount = 1;
            res_bundleInfo.m_ReferencedCount = 1;
        }
        List<LoadAssetRequest> list = null;
        if (!m_LoadRequests.TryGetValue(packName, out list))
        {
            m_LoadRequests.Remove(packName);
            yield break;
        }
        for (int i = 0; i < list.Count; i++)
        {
            if (list[i].luaFunc!=null)
            {
                list[i].luaFunc.Call();
                list[i].luaFunc.Dispose();
            }
        }
        m_LoadRequests.Remove(packName);
    }
    IEnumerator OnLoadPackageAB(string abName)
    {
        AssetBundleInfo bundleInfo = GetLoadedAssetBundle(abName);
        if (bundleInfo == null)
        {
            yield return StartCoroutine(OnLoadAssetBundle(abName, typeof(UObject)));

            bundleInfo = GetLoadedAssetBundle(abName);
            if (bundleInfo == null)
            {
                m_LoadRequests.Remove(abName);
                Debug.LogError("OnLoadAsset--->>>" + abName);
                yield break;
            }
        }
    }
    
    public void LoadPrefab(string abName, string[] assetNames, LuaFunction func)
    {
#if UNITY_EDITOR 
        List<GameObject> fs = new List<GameObject>();
        string path = "Assets/buildAB/";
        string[] files = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++)
        {
            string p = files[i].Replace("\\", "/");
            FileInfo f = new FileInfo(p);
            if (assetNames != null)
            {
                for (int j = 0; j < assetNames.Length; j++)
                {
                    if (assetNames[j] + ".prefab" == f.Name)
                    {
                        fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(p));
                    }
                }
            }
            else
            {
                fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<GameObject>(p));
            }

        }
        func.Call(fs.ToArray());
        func.Dispose();
        func = null;
#else
         LoadAsset<GameObject>(abName, assetNames, (UObject[] objs)=> {
             UnloadAssetBundle(abName);
         }, func);
#endif

    }

    public void LoadAudioClip(string abName, string[] assetNames, LuaFunction func)
    {
#if UNITY_EDITOR 
        List<AudioClip> fs = new List<AudioClip>();
        string path = "Assets/buildAB/";
        var files = Directory.GetFiles(path, "*.*", SearchOption.AllDirectories).Where(s => s.EndsWith(".mp3") || s.EndsWith(".wav") || s.EndsWith(".ogg") || s.EndsWith(".aif"));
        foreach (var file in files)
        {
            string p = file.Replace("\\", "/");
            FileInfo f = new FileInfo(p);
            if (assetNames != null)
            {
                for (int j = 0; j < assetNames.Length; j++)
                {
                    if (assetNames[j] + ".mp3" == f.Name)
                    {
                        fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<AudioClip>(p));
                    }
                    else if (assetNames[j] + ".wav" == f.Name)
                    {
                        fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<AudioClip>(p));
                    }
                    else if (assetNames[j] + ".ogg" == f.Name)
                    {
                        fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<AudioClip>(p));
                    }
                    else if (assetNames[j] + ".aif" == f.Name)
                    {
                        fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<AudioClip>(p));
                    }
                }
            }
            else
            {
                fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<AudioClip>(p));
            }
        }
        
        func.Call(fs.ToArray());
        func.Dispose();
        func = null;
#else
         LoadAsset<AudioClip>(abName, assetNames, (UObject[] objs)=> {
             UnloadAssetBundle(abName);
         }, func);
#endif

    }

    public void LoadTextAsset(string abName, string[] assetNames, LuaFunction func)
    {
#if UNITY_EDITOR 
        List<TextAsset> fs = new List<TextAsset>();
        string path = "Assets/buildAB/";
        string[] files = Directory.GetFiles(path, "*.txt", SearchOption.AllDirectories);
        for (int i = 0; i < files.Length; i++)
        {
            string p = files[i].Replace("\\", "/");
            FileInfo f = new FileInfo(p);
            if (assetNames != null)
            {
                for (int j = 0; j < assetNames.Length; j++)
                {
                    if (assetNames[j] + ".txt" == f.Name)
                    {
                        fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<TextAsset>(p));
                    }
                }
            }
            else
            {
                fs.Add(UnityEditor.AssetDatabase.LoadAssetAtPath<TextAsset>(p));
            }

        }
        func.Call(fs.ToArray());
        func.Dispose();
        func = null;
#else
         LoadAsset<TextAsset>(abName, assetNames, (UObject[] objs)=> {
             UnloadAssetBundle(abName);
         }, func);
#endif

    }

    string GetRealAssetPath(string abName)
    {
        if (abName.Equals("StreamingAssets"))
        {
            return abName;
        }
        abName = abName.ToLower();
        if (!abName.EndsWith(".unity3d"))
        {
            abName += ".unity3d";
        }
        if (abName.Contains("/"))
        {
            return abName;
        }
       
        for (int i = 0; i < m_AllManifest.Length; i++)
        {
            int index = m_AllManifest[i].LastIndexOf('/');
            string path = m_AllManifest[i].Remove(0, index + 1);    //字符串操作函数都会产生GC
            if (path.Equals(abName))
            {
                return m_AllManifest[i];
            }
        }
        Debug.LogError("GetRealAssetPath Error:>>" + abName);
        return null;
    }

    /// <summary>
    /// 载入素材
    /// </summary>
    void LoadAsset<T>(string abName, string[] assetNames, Action<UObject[]> action = null, LuaFunction func = null, bool isWantAB = false, string path = null) where T : UObject
    {
        if (path == null)
        {
            abName = GetRealAssetPath(abName);
        }
        else
        {
            abName = path;
        }


        LoadAssetRequest request = new LoadAssetRequest();
        request.assetType = typeof(T);
        request.assetNames = assetNames;
        request.luaFunc = func;
        request.sharpFunc = action;


        List<LoadAssetRequest> requests = null;
        if (!m_LoadRequests.TryGetValue(abName, out requests))
        {
            requests = new List<LoadAssetRequest>();
            requests.Add(request);
            m_LoadRequests.Add(abName, requests);
            StartCoroutine(OnLoadAsset<T>(abName));
        }
        else
        {
            requests.Add(request);
        }
    }

    IEnumerator OnLoadAsset<T>(string abName) where T : UObject
    {
        AssetBundleInfo bundleInfo = GetLoadedAssetBundle(abName);
        if (bundleInfo == null)
        {
            yield return StartCoroutine(OnLoadAssetBundle(abName, typeof(T)));

            bundleInfo = GetLoadedAssetBundle(abName);
            if (bundleInfo == null)
            {
                m_LoadRequests.Remove(abName);
                Debug.LogError("OnLoadAsset--->>>" + abName);
                yield break;
            }
        }
        List<LoadAssetRequest> list = null;
        if (!m_LoadRequests.TryGetValue(abName, out list))
        {
            m_LoadRequests.Remove(abName);
            yield break;
        }
        for (int i = 0; i < list.Count; i++)
        {
            string[] assetNames = list[i].assetNames;
            List<UObject> result = new List<UObject>();

            AssetBundle ab = bundleInfo.m_AssetBundle;

            //加载所有
            if (assetNames == null)
            {
                AssetBundleRequest request = ab.LoadAllAssetsAsync(list[i].assetType);
                yield return request;
                for (int w = 0; w < request.allAssets.Length; w++)
                    result.Add(request.allAssets[w]);
            }
            else
            {
                for (int j = 0; j < assetNames.Length; j++)
                {
                    string assetPath = assetNames[j];

                    AssetBundleRequest request = ab.LoadAssetAsync(assetPath, list[i].assetType);
                    yield return request;
                    result.Add(request.asset);
                }
            }
            if (list[i].sharpFunc != null)
            {
                list[i].sharpFunc(result.ToArray());
                list[i].sharpFunc = null;
            }
            if (list[i].luaFunc != null)
            {
                list[i].luaFunc.Call((object)result.ToArray());
                list[i].luaFunc.Dispose();
                list[i].luaFunc = null;
            }
            bundleInfo.m_ReferencedCount++;
        }
        m_LoadRequests.Remove(abName);
    }

    IEnumerator OnLoadAssetBundle(string abName, Type type)
    {
        string url = m_BaseDownloadingURL + abName;
        Debuger.Log("加载ab url:"+url);

        WWW download = null;
        if (type == typeof(AssetBundleManifest))
            download = new WWW(url);
        else
        {
            string[] dependencies = m_AssetBundleManifest.GetAllDependencies(abName);
            if (dependencies.Length > 0)
            {
                m_Dependencies.Add(abName, dependencies);
                for (int i = 0; i < dependencies.Length; i++)
                {
                    string depName = dependencies[i];
                    AssetBundleInfo bundleInfo = null;
                    if (m_LoadedAssetBundles.TryGetValue(depName, out bundleInfo))
                    {
                        bundleInfo.m_ReferencedCount++;
                    }
                    else if (!m_LoadRequests.ContainsKey(depName))
                    {
                        yield return StartCoroutine(OnLoadAssetBundle(depName, type));
                    }
                }
            }
            download = WWW.LoadFromCacheOrDownload(url, m_AssetBundleManifest.GetAssetBundleHash(abName), 0);
        }
        yield return download;
        if (!string.IsNullOrEmpty(download.error))
        {
            Debug.LogError("重新加载:" + download.error);
            yield return new WaitForSeconds(3f);
            yield return StartCoroutine(OnLoadAssetBundle(abName, type));
        }

        AssetBundle assetObj = download.assetBundle;
        if (assetObj != null)
        {
            m_LoadedAssetBundles.Add(abName, new AssetBundleInfo(assetObj));
        }
    }

    AssetBundleInfo GetLoadedAssetBundle(string abName)
    {
        AssetBundleInfo bundle = null;
        m_LoadedAssetBundles.TryGetValue(abName, out bundle);
        if (bundle == null) return null;

        // No dependencies are recorded, only the bundle itself is required.
        string[] dependencies = null;
        if (!m_Dependencies.TryGetValue(abName, out dependencies))
            return bundle;

        // Make sure all dependencies are loaded
        foreach (var dependency in dependencies)
        {
            AssetBundleInfo dependentBundle;
            m_LoadedAssetBundles.TryGetValue(dependency, out dependentBundle);
            if (dependentBundle == null) return null;
        }
        return bundle;
    }

    /// <summary>
    /// 此函数交给外部卸载专用，自己调整是否需要彻底清除AB
    /// </summary>
    /// <param name="abName"></param>
    /// <param name="isThorough"></param>
    public void UnloadAssetBundle(string abName, bool isThorough = false)
    {
        abName = GetRealAssetPath(abName);
        Debuger.Log(m_LoadedAssetBundles.Count + " assetbundle(s) in memory before unloading " + abName);
        UnloadAssetBundleInternal(abName, isThorough);
        UnloadDependencies(abName, isThorough);
        Debuger.Log(m_LoadedAssetBundles.Count + " assetbundle(s) in memory after unloading " + abName);
    }

    void UnloadDependencies(string abName, bool isThorough)
    {
        string[] dependencies = null;
        if (!m_Dependencies.TryGetValue(abName, out dependencies))
            return;

        // Loop dependencies.
        foreach (var dependency in dependencies)
        {
            UnloadAssetBundleInternal(dependency, isThorough);
        }
        m_Dependencies.Remove(abName);
    }

    void UnloadAssetBundleInternal(string abName, bool isThorough)
    {
        AssetBundleInfo bundle = GetLoadedAssetBundle(abName);
        if (bundle == null) return;

        if (--bundle.m_ReferencedCount <= 0)
        {
            if (m_LoadRequests.ContainsKey(abName))
            {
                return;     //如果当前AB处于Async Loading过程中，卸载会崩溃，只减去引用计数即可
            }
            bundle.m_AssetBundle.Unload(isThorough);
            m_LoadedAssetBundles.Remove(abName);
            Debuger.Log(abName + " has been unloaded successfully");
        }
    }
}