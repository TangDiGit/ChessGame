using System.Collections;
using UnityEngine;
using FairyGUI;

public class F_Loader : GLoader
{
    protected override void LoadExternal()
    {
        if (this.url.Length < 3)
        {
            OnLoadFail("长度有问题");
            return;
        }
        F_IconManager.getInstance().LoadIcon(this.url, OnLoadSuccess, OnLoadFail);
    }

    protected override void FreeExternal(NTexture texture)
    {
        texture.refCount--;
    }

    void OnLoadSuccess(NTexture texture)
    {
        if (string.IsNullOrEmpty(this.url))
            return;

        this.onExternalLoadSuccess(texture);
    }

    void OnLoadFail(string error)
    {
        Debug.Log("load " + this.url + " failed: " + error);
        this.onExternalLoadFailed();

        if (this.url.Length < 10)
        {

            return;
        }
        string _str = this.url;
        Timer.Register(5f, () =>
        {
            F_IconManager.getInstance().LoadIcon(_str, OnLoadSuccess, OnLoadFail);
        }, null, false, true);

    }
}
