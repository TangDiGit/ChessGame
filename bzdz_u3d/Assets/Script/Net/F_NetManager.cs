using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;

public class F_NetManager : F_Singleton<F_NetManager>
{
    static readonly object m_lockObject = new object();
    static Queue<F_Msg> mEvents = new Queue<F_Msg>();
    LuaFunction OnSocket;

    int socketClientID = 1000;
    Dictionary<int, F_SocketClient> socketClientDic = new Dictionary<int, F_SocketClient>();
    public void Run()
    {
        OnSocket=LuaClient.GetMainState().GetFunction("OnSocket");
    }

    public static void AddEvent(F_Msg data)
    {
        lock (m_lockObject)
        {
            mEvents.Enqueue(data);
        }
    }
    void Update()
    {
        if (mEvents.Count > 0)
        {
            while (mEvents.Count > 0)
            {
                F_Msg _event = mEvents.Dequeue();
                OnSocket.Call<F_Msg>(_event);
            }
        }
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="logicID">多socket区分</param>
    /// <returns></returns>
    public F_SocketClient CreateSocketClient(int logicID, int _From, int _To, short _Mcmd)
    {
        int _id = socketClientID++;
        F_SocketClient f_SocketClient = new F_SocketClient(_id, logicID, _From,_To, _Mcmd);
        socketClientDic[_id] = f_SocketClient;
        return f_SocketClient;
    }

    public void RemoveSocketClient(int _socketClientID)
    {
        if (socketClientDic.ContainsKey(_socketClientID))
        {
            socketClientDic[_socketClientID].OnRemove();
            socketClientDic.Remove(_socketClientID);
        }
    }

    void OnDestroy()
    {
        foreach (int key in socketClientDic.Keys)
        {
            socketClientDic[key].OnRemove();
        }
        socketClientDic.Clear();
    }
}
