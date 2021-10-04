﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class F_MsgWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(F_Msg), typeof(System.Object));
		L.RegFunction("New", _CreateF_Msg);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("logicID", get_logicID, set_logicID);
		L.RegVar("f_Protocal", get_f_Protocal, set_f_Protocal);
		L.RegVar("Mcmd", get_Mcmd, set_Mcmd);
		L.RegVar("Scmd", get_Scmd, set_Scmd);
		L.RegVar("luaByteBuffer", get_luaByteBuffer, set_luaByteBuffer);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateF_Msg(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 2);
				F_Msg obj = new F_Msg(arg0, arg1);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else if (count == 5)
			{
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 2);
				short arg2 = (short)LuaDLL.luaL_checknumber(L, 3);
				short arg3 = (short)LuaDLL.luaL_checknumber(L, 4);
				LuaByteBuffer arg4 = new LuaByteBuffer(ToLua.CheckByteBuffer(L, 5));
				F_Msg obj = new F_Msg(arg0, arg1, arg2, arg3, arg4);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: F_Msg.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_logicID(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			int ret = obj.logicID;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index logicID on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_f_Protocal(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			int ret = obj.f_Protocal;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index f_Protocal on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Mcmd(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			short ret = obj.Mcmd;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Mcmd on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Scmd(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			short ret = obj.Scmd;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Scmd on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_luaByteBuffer(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			LuaInterface.LuaByteBuffer ret = obj.luaByteBuffer;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaByteBuffer on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_logicID(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.logicID = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index logicID on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_f_Protocal(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.f_Protocal = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index f_Protocal on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Mcmd(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			short arg0 = (short)LuaDLL.luaL_checknumber(L, 2);
			obj.Mcmd = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Mcmd on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_Scmd(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			short arg0 = (short)LuaDLL.luaL_checknumber(L, 2);
			obj.Scmd = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Scmd on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_luaByteBuffer(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			F_Msg obj = (F_Msg)o;
			LuaByteBuffer arg0 = new LuaByteBuffer(ToLua.CheckByteBuffer(L, 2));
			obj.luaByteBuffer = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index luaByteBuffer on a nil value");
		}
	}
}
