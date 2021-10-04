using UnityEngine;
using System;
using System.IO;
using System.Net;
using System.Net.Sockets;
using System.Text;
using LuaInterface;
using UnityDebuger;

public enum F_DisType
{
    Exception,
    Disconnect,
}

public class F_SocketClient
{

    private TcpClient client = null;
    private NetworkStream outStream = null;
    private MemoryStream memStream;
    private BinaryReader reader;

    private const int MAX_READ = 8192;
    private byte[] byteBuffer = new byte[MAX_READ];
    public bool loggedIn = false;

    public int id;
    /// <summary>
    /// 用来区分服务器,大厅,游戏
    /// </summary>
    public int logicID;


    public int send_To;
    public short send_Mcmd;
    public int send_From;

    public F_SocketClient(int _id, int _logicID, int _From, int _To, short _Mcmd)
    {
        id = _id;
        logicID = _logicID;

        send_From = _From;
        send_To = _To;
        send_Mcmd = _Mcmd;


        memStream = new MemoryStream();
        reader = new BinaryReader(memStream);
    }



    /// <summary>
    /// 移除代理
    /// </summary>
    public void OnRemove()
    {
        this.Close();
        reader.Close();
        memStream.Close();
    }

    /// <summary>
    /// 连接服务器
    /// </summary>
    public void ConnectServer(string host, int port)
    {
        Debuger.Log("连接socket:" + host + " 端口:" + port);
        client = null;
        try
        {
            IPAddress[] address = Dns.GetHostAddresses(host);
            if (address.Length == 0)
            {
                Debuger.Log("host invalid");
                return;
            }
            if (address[0].AddressFamily == AddressFamily.InterNetworkV6)
            {
                client = new TcpClient(AddressFamily.InterNetworkV6);
            }
            else
            {
                client = new TcpClient(AddressFamily.InterNetwork);
            }
            client.SendTimeout = 1000;
            client.ReceiveTimeout = 1000;
            client.NoDelay = true;
            client.BeginConnect(host, port, new AsyncCallback(OnConnect), null);
        }
        catch (Exception e)
        {
            Close();
            Debuger.Log(e.Message);
            F_NetManager.AddEvent(new F_Msg(logicID, F_Protocal.ConnectErr));
        }
    }

    /// <summary>
    /// 连接上服务器
    /// </summary>
    void OnConnect(IAsyncResult asr)
    {
        try
        {
            outStream = client.GetStream();
            client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
            F_NetManager.AddEvent(new F_Msg(logicID, F_Protocal.Connect));
        }
        catch (Exception e)
        {

            Close();
            Debuger.Log(e.Message);
            F_NetManager.AddEvent(new F_Msg(logicID, F_Protocal.ConnectErr));
        }

    }

    /// <summary>
    /// 写数据
    /// </summary>
    void WriteMessage(byte[] message)
    {
        MemoryStream ms = null;
        using (ms = new MemoryStream())
        {
            ms.Position = 0;
            BinaryWriter writer = new BinaryWriter(ms);
            writer.Write(message);
            writer.Flush();
            if (client != null && client.Connected)
            {
                //NetworkStream stream = client.GetStream();
                byte[] payload = ms.ToArray();
                outStream.BeginWrite(payload, 0, payload.Length, new AsyncCallback(OnWrite), null);
            }
            else
            {
                Debuger.Log("client.connected----->>false");
            }
        }
    }

    /// <summary>
    /// 读取消息
    /// </summary>
    void OnRead(IAsyncResult asr)
    {
        int bytesRead = 0;
        try
        {
            lock (client.GetStream())
            {         //读取字节流到缓冲区
                bytesRead = client.GetStream().EndRead(asr);
            }
            if (bytesRead < 1)
            {                //包尺寸有问题，断线处理
                OnDisconnected(F_DisType.Disconnect, "bytesRead < 1");
                return;
            }
            OnReceive(byteBuffer, bytesRead);   //分析数据包内容，抛给逻辑层
            lock (client.GetStream())
            {         //分析完，再次监听服务器发过来的新消息
                Array.Clear(byteBuffer, 0, byteBuffer.Length);   //清空数组
                client.GetStream().BeginRead(byteBuffer, 0, MAX_READ, new AsyncCallback(OnRead), null);
            }
        }
        catch (Exception ex)
        {
            Debuger.Log("网络流读取失败");
            //PrintBytes();
            OnDisconnected(F_DisType.Exception, ex.Message);
        }
    }

    /// <summary>
    /// 丢失链接
    /// </summary>
    void OnDisconnected(F_DisType dis, string msg)
    {
        Close();   //关掉客户端链接
        int protocal = dis == F_DisType.Exception ?
        F_Protocal.Exception : F_Protocal.Disconnect;

        F_NetManager.AddEvent(new F_Msg(logicID, protocal));
        Debuger.Log("Connection was closed by the server:>" + msg + " Distype:>" + dis);
    }

    /// <summary>
    /// 打印字节
    /// </summary>
    /// <param name="bytes"></param>
    void PrintBytes()
    {
        string returnStr = string.Empty;
        for (int i = 0; i < byteBuffer.Length; i++)
        {
            returnStr += byteBuffer[i].ToString("X2");
        }
        Debuger.Log(returnStr);
    }

    /// <summary>
    /// 向链接写入数据流
    /// </summary>
    void OnWrite(IAsyncResult r)
    {
        try
        {
            outStream.EndWrite(r);
        }
        catch (Exception ex)
        {
            Debuger.Log("OnWrite--->>>" + ex.Message);
        }
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    void OnReceive(byte[] bytes, int length)
    {
        memStream.Seek(0, SeekOrigin.End);
        memStream.Write(bytes, 0, length);
        //Reset to beginning
        memStream.Seek(0, SeekOrigin.Begin);
        while (RemainingBytes() >= 22)
        {
            //0-2 包头'GS'
            byte[] bytesGS = reader.ReadBytes(2);
            //2-4 数据包长度
            short dataLen = System.Net.IPAddress.NetworkToHostOrder(reader.ReadInt16());
            //4-5 校验码C
            byte c = reader.ReadByte();
            //5-7 主命令
            short Mcmd = System.Net.IPAddress.NetworkToHostOrder(reader.ReadInt16());
            //7-9 子命令
            short Scmd = System.Net.IPAddress.NetworkToHostOrder(reader.ReadInt16());
            //9-11 游戏类型GT
            short GT = System.Net.IPAddress.NetworkToHostOrder(reader.ReadInt16());
            //11-12 加密类型CT
            byte CT = reader.ReadByte();
            //12-14 消息包序列号
            short Seq = System.Net.IPAddress.NetworkToHostOrder(reader.ReadInt16());
            //14-18 消息来源地址From
            int From = System.Net.IPAddress.NetworkToHostOrder(reader.ReadInt32());
            //18-22 消息目标标号
            int To = System.Net.IPAddress.NetworkToHostOrder(reader.ReadInt32());

            int messageLen = dataLen - 22;
            if (RemainingBytes() >= messageLen)
            {
                MemoryStream ms = new MemoryStream();
                BinaryWriter writer = new BinaryWriter(ms);
                writer.Write(reader.ReadBytes(messageLen));
                ms.Seek(0, SeekOrigin.Begin);
                OnReceivedMessage(Mcmd, Scmd, ms);
            }
            else
            {
                //Back up the position two bytes
                memStream.Position = memStream.Position - 22;
                break;
            }
        }
        //Create a new stream with any leftover bytes
        byte[] leftover = reader.ReadBytes((int)RemainingBytes());
        memStream.SetLength(0);     //Clear
        memStream.Write(leftover, 0, leftover.Length);
    }

    /// <summary>
    /// 剩余的字节
    /// </summary>
    private long RemainingBytes()
    {
        return memStream.Length - memStream.Position;
    }

    /// <summary>
    /// 接收到消息
    /// </summary>
    /// <param name="ms"></param>
    void OnReceivedMessage(short Mcmd, short Scmd, MemoryStream ms)
    {
        //Debuger.Log(Scmd + " " + logicID);

        BinaryReader r = new BinaryReader(ms);
        byte[] message = r.ReadBytes((int)(ms.Length - ms.Position));
        F_NetManager.AddEvent(new F_Msg(logicID, F_Protocal.NormalData, Mcmd, Scmd, new LuaByteBuffer(message)));
    }


    /// <summary>
    /// 会话发送
    /// </summary>
    void SessionSend(byte[] bytes)
    {
        //Debuger.Log("发送数据包长度:"+bytes.Length);
        WriteMessage(bytes);
    }

    /// <summary>
    /// 关闭链接
    /// </summary>
    public void Close()
    {
        Debuger.Log("关闭socket:" + logicID + "/id:" + id);
        if (client != null)
        {
            if (client.Connected) client.Close();
            client = null;
        }
        loggedIn = false;
    }
    /// <summary>
    /// 发送消息
    /// </summary>
    void SendMessage(short _Scmd, byte[] bytesPB, short _Mcmd = 0)
    {
        MemoryStream stream = new MemoryStream();
        BinaryWriter writer = new BinaryWriter(stream);
        //0-2 包头'GS'
        byte[] bytes = Encoding.UTF8.GetBytes("GS");
        writer.Write(bytes);

        //2-4 数据包长度
        short dataLen = (short)(22 + bytesPB.Length);
        writer.Write(System.Net.IPAddress.HostToNetworkOrder(dataLen));

        //4-5 校验码C
        byte c = 0;
        writer.Write(c);

        //5-7 主命令
        //short Mcmd = 0x20;
        short Mcmd = send_Mcmd;
        if (_Mcmd != 0)
            Mcmd = _Mcmd;

        writer.Write(System.Net.IPAddress.HostToNetworkOrder(Mcmd));

        //7-9 子命令
        short Scmd = _Scmd;
        writer.Write(System.Net.IPAddress.HostToNetworkOrder(Scmd));

        //9-11 游戏类型GT
        short GT = 0x20;
        writer.Write(System.Net.IPAddress.HostToNetworkOrder(GT));

        //11-12 加密类型
        byte CT = 0;
        writer.Write(CT);

        //12-14 消息包序列号
        short Seq = 1;
        writer.Write(System.Net.IPAddress.HostToNetworkOrder(Seq));

        //14-18 消息来源地址From
        // int From = 0;
        int From = send_From;
        writer.Write(System.Net.IPAddress.HostToNetworkOrder(From));

        //18-22 消息目标标号 todo之后从服务器端获取
        //int To = 10;
        int To = send_To;
        writer.Write(System.Net.IPAddress.HostToNetworkOrder(To));

        //pb数据
        writer.Write(bytesPB);

        writer.Flush();
        SessionSend(stream.ToArray());
        writer.Close();
        stream.Close();
    }


    /// <summary>
    /// 发送消息,有pb数据
    /// </summary>
    public void SendMessageWithPB(short _Scmd, LuaByteBuffer luaByteBuffer)
    {
        SendMessage(_Scmd, luaByteBuffer.buffer);
    }

    /// <summary>
    /// 发送消息,有pb数据
    /// </summary>
    public void SendMessageWithPB(short _Mcmd, short _Scmd, LuaByteBuffer luaByteBuffer)
    {
        SendMessage(_Scmd, luaByteBuffer.buffer, _Mcmd);
    }

    /// <summary>
    /// 发送消息,没有pb数据，没有主命令
    /// </summary>
    public void SendMessageWithNotPB(short _Scmd)
    {
        SendMessage(_Scmd, new byte[] { });
    }

    /// <summary>
    /// 发送消息,没有pb数据，有主命令
    /// </summary>
    public void SendMessageWithNotPB(short _Mcmd,short _Scmd)
    {
        SendMessage(_Scmd, new byte[] { },_Mcmd);
    }

}
