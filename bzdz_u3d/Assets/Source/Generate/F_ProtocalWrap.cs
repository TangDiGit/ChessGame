﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class F_ProtocalWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(F_Protocal), typeof(System.Object));
		L.RegFunction("New", _CreateF_Protocal);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegConstant("Connect", 901);
		L.RegConstant("Exception", 902);
		L.RegConstant("Disconnect", 903);
		L.RegConstant("ConnectErr", 904);
		L.RegConstant("NormalData", 905);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateF_Protocal(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 0)
			{
				F_Protocal obj = new F_Protocal();
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: F_Protocal.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}
