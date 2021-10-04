using UnityEngine;
using LuaInterface;
using UnityDebuger;

public class F_UnityAndroidMsg : F_Singleton<F_UnityAndroidMsg>
{
    private LuaFunction OnWXLogin;
    private AndroidJavaClass javaClass;

    public void Run()
    {
        OnWXLogin = LuaClient.GetMainState().GetFunction("OnWXLogin");
    }

    /* 微信登陆 */
    public void OnRequestWxLogin()
    {
        if (F_Util.isAndroid() && Application.isMobilePlatform)
        {
            if (javaClass == null)
            {
                javaClass = new AndroidJavaClass("com.bz.bzdz.AndroidCallUnity");
            }

            javaClass.CallStatic("requestWxLogin");
            Debuger.Log("请求微信登陆");
        }
    }

    private void OnCallBackWxLogin(string resStr)
    {
        OnWXLogin.Call(resStr);
        Debuger.Log("收到微信登陆：" + resStr);
    }

    /* Xinstall */
    private void OnCallBackXInstallWake(string resStr)
    {
        F_AppConst.xInstallAwakeInfo = resStr;
        Debuger.Log("XInstallWake：唤醒参数" + resStr);
    }

    private void OnCallBackXInstallInstall(string resStr)
    {
        F_AppConst.xInstallInstallInfo = resStr;
        Debuger.Log("XInstallInstall：安装参数" + resStr);
    }
}
