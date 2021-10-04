using FairyGUI;
using System;

public class F_MessageView : F_Singleton<F_MessageView>
{
    GComponent _view;
    GTextField txt;
    GButton btnY, btnN;
    public void Run()
    {
        _view = UIPackage.CreateObject("main", "MessageBoxView").asCom;
        _view.visible = false;
        GRoot.inst.AddChild(_view);
        _view.SetSize(GRoot.inst.width, GRoot.inst.height);
        txt = _view.GetChild("n8").asTextField;
        btnY = _view.GetChild("btnY").asButton;
        btnN = _view.GetChild("btnN").asButton;
    }

    public void Show(string strTit, Action callY = null, Action callN = null, string strY = "确定", string strN = "取消")
    {
        _view.visible = true;
        txt.text = strTit;
        btnY.text = strY;
        btnN.text = strN;
        btnN.visible = callN != null;
        //单选
        if (callN == null)
        {
            _view.GetController("c1").selectedIndex = 0;
        }
        else
        {
            _view.GetController("c1").selectedIndex = 1;
        }
        btnY.RemoveEventListeners();
        btnN.RemoveEventListeners();

        btnY.onClick.Add(() => {
            if (callY != null)
            {
                callY();
            }
            Hide();
        });

        btnN.onClick.Add(() => {
            if (callN != null)
            {
                callN();
            }
            Hide();
        });
    }
    public void Hide()
    {
        _view.visible = false;
    }
}