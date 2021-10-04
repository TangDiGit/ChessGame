using UnityEngine;
using System.Collections;
using FairyGUI;
using System.Collections.Generic;
/// <summary>
/// http下载图片
/// </summary>
public delegate void LoadCompleteCallback(NTexture texture);
public delegate void LoadErrorCallback(string error);
class LoadItem
{
    public string url;
    public LoadCompleteCallback onSuccess;
    public LoadErrorCallback onFail;
}
public class F_IconManager : MonoBehaviour
{
    static F_IconManager _instance;
    public static F_IconManager getInstance()
    {
        if (_instance == null)
        {
            GameObject go = new GameObject("F_IconManager");
            DontDestroyOnLoad(go);
            _instance = go.AddComponent<F_IconManager>();
            _instance.InitInfo();
        }
        return _instance;
    }
    bool _started;
    List<LoadItem> _items;
    Hashtable _pool;
    void InitInfo()
    {
        _items = new List<LoadItem>();
        _pool = new Hashtable();
    }
    public void LoadIcon(string url,
                    LoadCompleteCallback onSuccess,
                    LoadErrorCallback onFail)
    {
        LoadItem item = new LoadItem();
        item.url = url;
        item.onSuccess = onSuccess;
        item.onFail = onFail;
        _items.Add(item);
        if (!_started)
            StartCoroutine(Run());
    }
    IEnumerator Run()
    {
        _started = true;

        LoadItem item = null;
        while (true)
        {
            if (_items.Count > 0)
            {
                item = _items[0];
                _items.RemoveAt(0);
            }
            else
                break;

            if (_pool.ContainsKey(item.url))
            {
                //Debug.Log("hit " + item.url);

                NTexture texture = (NTexture)_pool[item.url];
                texture.refCount++;

                if (item.onSuccess != null)
                    item.onSuccess(texture);

                continue;
            }

            WWW www = new WWW(item.url);
            yield return www;

            if (string.IsNullOrEmpty(www.error))
            {
                NTexture texture = new NTexture(www.texture);
                texture.refCount++;
                _pool[item.url] = texture;

                if (item.onSuccess != null)
                    item.onSuccess(texture);
            }
            else
            {
                if (item.onFail != null)
                    item.onFail(www.error);
            }
        }

        _started = false;
    }
    public void AddTexture(string key, Texture _2d)
    {
        if (_pool.ContainsKey(key))
        {
            return;
        }
        if (_2d == null)
        {
            return;
        }
        NTexture texture = new NTexture(_2d);
        texture.refCount++;
        _pool[key] = texture;
    }
    public Texture GetTexture(string key)
    {
        if (_pool.ContainsKey(key))
        {
            NTexture texture = (NTexture)_pool[key];
            return texture.nativeTexture;
        }
        return null;
    }
}