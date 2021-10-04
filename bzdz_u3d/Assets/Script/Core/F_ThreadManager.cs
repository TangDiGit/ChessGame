using System.Collections;
using System.Threading;
using System.Collections.Generic;
using System.IO;
using System.Diagnostics;
using System.Net;
using System;
using UnityDebuger;

public class ThreadEvent
{
    public string Key;
    public List<object> evParams = new List<object>();
}

public class NotiData
{
    public string evName;
    public object evParam;

    public NotiData(string name, object param)
    {
        this.evName = name;
        this.evParam = param;
    }
}
public class F_ThreadManager : F_Singleton<F_ThreadManager>
{
    private Thread thread;
    private Action<NotiData> func;
    private Stopwatch sw = new Stopwatch();
    private string currDownFile = string.Empty;

    static readonly object m_lockObject = new object();
    static Queue<ThreadEvent> events = new Queue<ThreadEvent>();

    delegate void ThreadSyncEvent(NotiData data);
    private ThreadSyncEvent m_SyncEvent;

    public override void Init()
    {
        m_SyncEvent = OnSyncEvent;
        thread = new Thread(OnUpdate);
        thread.Start();
    }
    /// <summary>
    /// 添加到事件队列
    /// </summary>
    public void AddEvent(ThreadEvent ev, Action<NotiData> func)
    {
        lock (m_lockObject)
        {
            this.func = func;
            events.Enqueue(ev);
        }
    }
    /// <summary>
    /// 通知事件
    /// </summary>
    /// <param name="state"></param>
    private void OnSyncEvent(NotiData data)
    {
        if (this.func != null) func(data);  //回调逻辑层
        //MessageDispatcher.SendMessage(new Message(data.evName, data.evParam));//通知View层
    }

    // Update is called once per frame
    void OnUpdate()
    {
        while (true)
        {
            lock (m_lockObject)
            {
                if (events.Count > 0)
                {
                    ThreadEvent e = events.Dequeue();
                    try
                    {
                        switch (e.Key)
                        {
                            case "UPDATE_EXTRACT":
                                {     //解压文件
                                    OnExtractFile(e.evParams);
                                }
                                break;
                            case "UPDATE_DOWNLOAD":
                                {    //下载文件

                                    OnDownloadFile(e.evParams);
                                }
                                break;
                        }
                    }
                    catch (System.Exception ex)
                    {
                        UnityEngine.Debug.LogError(ex.Message);
                    }
                }
            }
            Thread.Sleep(1);
        }
    }

    /// <summary>
    /// 下载文件
    /// </summary>
    void OnDownloadFile(List<object> evParams)
    {
        string url = evParams[0].ToString();
        Debuger.Log("url: " + url);
        currDownFile = evParams[1].ToString();
        using (WebClient client = new WebClient())
        {
            sw.Start();
            client.DownloadProgressChanged += new DownloadProgressChangedEventHandler(ProgressChanged);
            client.DownloadFileAsync(new System.Uri(url), currDownFile);
        }
    }

    private void ProgressChanged(object sender, DownloadProgressChangedEventArgs e)
    {
        if (e.ProgressPercentage == 100 && e.BytesReceived == e.TotalBytesToReceive)
        {
            sw.Reset();

            NotiData data = new NotiData("UPDATE_DOWNLOAD", currDownFile);
            if (m_SyncEvent != null) m_SyncEvent(data);
        }
    }

    /// <summary>
    /// 调用方法
    /// </summary>
    void OnExtractFile(List<object> evParams)
    {
        UnityEngine.Debug.LogWarning("Thread evParams: >>" + evParams.Count);

        ///------------------通知更新面板解压完成--------------------
        NotiData data = new NotiData("UPDATE_DOWNLOAD", null);
        if (m_SyncEvent != null) m_SyncEvent(data);
    }

    /// <summary>
    /// 应用程序退出
    /// </summary>
    void OnDestroy()
    {
        thread.Abort();
    }
}