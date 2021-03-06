//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class F_ResourceManagerWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(F_ResourceManager), typeof(F_Singleton<F_ResourceManager>));
		L.RegFunction("InitLua", InitLua);
		L.RegFunction("AddPackage", AddPackage);
		L.RegFunction("LoadPrefab", LoadPrefab);
		L.RegFunction("LoadAudioClip", LoadAudioClip);
		L.RegFunction("LoadTextAsset", LoadTextAsset);
		L.RegFunction("UnloadAssetBundle", UnloadAssetBundle);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int InitLua(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			F_ResourceManager obj = (F_ResourceManager)ToLua.CheckObject<F_ResourceManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			System.Action<string[]> arg1 = (System.Action<string[]>)ToLua.CheckDelegate<System.Action<string[]>>(L, 3);
			obj.InitLua(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int AddPackage(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			F_ResourceManager obj = (F_ResourceManager)ToLua.CheckObject<F_ResourceManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			LuaFunction arg1 = ToLua.CheckLuaFunction(L, 3);
			obj.AddPackage(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadPrefab(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			F_ResourceManager obj = (F_ResourceManager)ToLua.CheckObject<F_ResourceManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string[] arg1 = ToLua.CheckStringArray(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			obj.LoadPrefab(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadAudioClip(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			F_ResourceManager obj = (F_ResourceManager)ToLua.CheckObject<F_ResourceManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string[] arg1 = ToLua.CheckStringArray(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			obj.LoadAudioClip(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int LoadTextAsset(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			F_ResourceManager obj = (F_ResourceManager)ToLua.CheckObject<F_ResourceManager>(L, 1);
			string arg0 = ToLua.CheckString(L, 2);
			string[] arg1 = ToLua.CheckStringArray(L, 3);
			LuaFunction arg2 = ToLua.CheckLuaFunction(L, 4);
			obj.LoadTextAsset(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int UnloadAssetBundle(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				F_ResourceManager obj = (F_ResourceManager)ToLua.CheckObject<F_ResourceManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				obj.UnloadAssetBundle(arg0);
				return 0;
			}
			else if (count == 3)
			{
				F_ResourceManager obj = (F_ResourceManager)ToLua.CheckObject<F_ResourceManager>(L, 1);
				string arg0 = ToLua.CheckString(L, 2);
				bool arg1 = LuaDLL.luaL_checkboolean(L, 3);
				obj.UnloadAssetBundle(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: F_ResourceManager.UnloadAssetBundle");
			}
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

