using LuaInterface;
public class F_Msg
{
    public F_Msg(int _logicID, int _f_Protocal)
    {
        logicID = _logicID;
        f_Protocal = _f_Protocal;
    }

    public F_Msg(int _logicID, int _f_Protocal, short _Mcmd, short _Scmd, LuaByteBuffer _luaByteBuffer)
    {
        logicID = _logicID;
        f_Protocal = _f_Protocal;
        Mcmd = _Mcmd;
        Scmd = _Scmd;

        luaByteBuffer = _luaByteBuffer;
    }
    //客户端区分哪个服务器下发的数据 大厅/游戏
    public int logicID;

    //客户端内部的协议类型 连接服务器成功/异常掉线/正常断线/连接服务器失败/正常数据
    public int f_Protocal;

    //服务端下发的主命令
    public short Mcmd;
    //服务端下发的子命令
    public short Scmd;
    //服务端下发的PB数据
    public LuaByteBuffer luaByteBuffer;
}