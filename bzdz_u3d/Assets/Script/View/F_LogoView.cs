using FairyGUI;
using UnityEngine;
public class F_LogoView : F_Singleton<F_LogoView>
{
    GComponent _view;
    GTextField textNow;
    GTextField textTit;
    GComponent bar;
    float _barWidth;
    public void Run()
    {
        _view = UIPackage.CreateObject("main", "LoginView").asCom;
        _view.visible = false;
        GRoot.inst.AddChild(_view);
        _view.SetSize(GRoot.inst.width, GRoot.inst.height);

        _view.GetController("c1").selectedIndex = 0;
        textNow = _view.GetChild("textNow").asTextField;
        textTit = _view.GetChild("textTit").asTextField;
        bar = _view.GetChild("n19").asCom;
        _barWidth = bar.width;

        //角色
        GameObject _u3djueseOBJ = UnityEngine.GameObject.Instantiate(Resources.Load<GameObject>("spine/jueseOBJ"));
        GoWrapper _gw2 = new FairyGUI.GoWrapper(_u3djueseOBJ);
        _view.GetChild("n41").asCom.GetChild("sp").asGraph.SetNativeObject(_gw2);
        _u3djueseOBJ.transform.localScale = new Vector3(100 , 100 , 100 );

        /*_view.GetChild("n41").draggable = true;
        Timer.Register(1, () =>
        {
        }, (float v) => {
            Vector2 _xy = GRoot.inst.GlobalToLocal(_view.GetChild("n41").xy);
            Debug.Log(_xy);
        }, true);*/

        //spine大厅背景
        GameObject _u3dOBJ = UnityEngine.GameObject.Instantiate(Resources.Load<GameObject>("spine/puke_obj"));


        GoWrapper _gw = new FairyGUI.GoWrapper(_u3dOBJ);
        _view.GetChild("spineBG").asGraph.SetNativeObject(_gw);


        float designWidth = 1920f;
        float designHeight = 1080f;
        float designScale = designWidth / designHeight;
        float scaleRate = (float)UnityEngine.Screen.width / (float)UnityEngine.Screen.height;

        float scaleFactor = 1;
        if (scaleRate < designScale)
        { scaleFactor = designScale / scaleRate; }
        else

        { scaleFactor = scaleRate / designScale; }


        _u3dOBJ.transform.localScale = new Vector3(100 * scaleFactor, 100 * scaleFactor, 100 * scaleFactor);
    }

    public void Show()
    {
        _view.visible = true;
    }
    public void Hide()
    {
        _view.visible = false;
    }
    public void SetNow(string str)
    {
        textNow.text = str;
    }
    public void SetTit(string str)
    {
        textTit.text = str;
    }
    public void SetBar(float v)
    {
        bar.width = v * _barWidth;
    }
}