﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class DragonBones_DragonBoneEventDispatcherWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(DragonBones.DragonBoneEventDispatcher), typeof(DragonBones.UnityEventDispatcher<DragonBones.EventObject>));
		L.RegFunction("AddDBEventListener", AddDBEventListener);
		L.RegFunction("DispatchDBEvent", DispatchDBEvent);
		L.RegFunction("HasDBEventListener", HasDBEventListener);
		L.RegFunction("RemoveDBEventListener", RemoveDBEventListener);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddDBEventListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			DragonBones.DragonBoneEventDispatcher obj = (DragonBones.DragonBoneEventDispatcher)ToLua.CheckObject<DragonBones.DragonBoneEventDispatcher>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			DragonBones.ListenerDelegate<DragonBones.EventObject> arg1 = (DragonBones.ListenerDelegate<DragonBones.EventObject>)ToLua.CheckDelegate<DragonBones.ListenerDelegate<DragonBones.EventObject>>(L, 3);
			obj.AddDBEventListener(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int DispatchDBEvent(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			DragonBones.DragonBoneEventDispatcher obj = (DragonBones.DragonBoneEventDispatcher)ToLua.CheckObject<DragonBones.DragonBoneEventDispatcher>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			DragonBones.EventObject arg1 = (DragonBones.EventObject)ToLua.CheckObject<DragonBones.EventObject>(L, 3);
			obj.DispatchDBEvent(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int HasDBEventListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			DragonBones.DragonBoneEventDispatcher obj = (DragonBones.DragonBoneEventDispatcher)ToLua.CheckObject<DragonBones.DragonBoneEventDispatcher>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			bool o = obj.HasDBEventListener(arg0);
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int RemoveDBEventListener(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			DragonBones.DragonBoneEventDispatcher obj = (DragonBones.DragonBoneEventDispatcher)ToLua.CheckObject<DragonBones.DragonBoneEventDispatcher>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			DragonBones.ListenerDelegate<DragonBones.EventObject> arg1 = (DragonBones.ListenerDelegate<DragonBones.EventObject>)ToLua.CheckDelegate<DragonBones.ListenerDelegate<DragonBones.EventObject>>(L, 3);
			obj.RemoveDBEventListener(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Equality(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			UnityEngine.Object arg0 = (UnityEngine.Object)ToLua.ToObject(L, 1);
			UnityEngine.Object arg1 = (UnityEngine.Object)ToLua.ToObject(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}
}

