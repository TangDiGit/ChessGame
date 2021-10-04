using UnityEngine;
using FairyGUI;

public class F_WaitTipView : F_Singleton<F_WaitTipView>
{
    GComponent _view;
    GTextField textMsg;
    public void Run()
    {
        _view = UIPackage.CreateObject("main", "WaitTipView").asCom;
        _view.visible = false;
        GRoot.inst.AddChild(_view);
        _view.SetSize(GRoot.inst.width, GRoot.inst.height);
        textMsg = _view.GetChild("n2").asTextField;

        /*GameObject _obj = GameObject.Instantiate(Resources.Load<GameObject>("Eff/quan"));
        _view.GetChild("n1").asGraph.SetNativeObject(new GoWrapper(_obj));
        _obj.transform.localScale = new Vector3(0.1f, 0.1f, 0.1f);*/
    }

    public void Show(string str = "")
    {
        textMsg.text = str;
        _view.visible = true;
    }
    public void Hide()
    {
        _view.visible = false;
    }
}