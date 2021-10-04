using UnityEngine;
using UnityDebuger;

public class F_Log : F_Singleton<F_Log>
{
    public void Run(bool isDebug)
    {
        Debuger.m_EnableLog = isDebug;
        GetComponent<Reporter>().enabled = isDebug;
        GetComponent<ReporterMessageReceiver>().enabled = isDebug;
    }

    public static void Logd(string msg)
    {
        Debuger.Log(msg);
    }
}