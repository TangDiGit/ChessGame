﻿//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class System_TimeSpanWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(System.TimeSpan), null);
		L.RegFunction("Add", Add);
		L.RegFunction("Compare", Compare);
		L.RegFunction("CompareTo", CompareTo);
		L.RegFunction("FromDays", FromDays);
		L.RegFunction("Duration", Duration);
		L.RegFunction("Equals", Equals);
		L.RegFunction("GetHashCode", GetHashCode);
		L.RegFunction("FromHours", FromHours);
		L.RegFunction("FromMilliseconds", FromMilliseconds);
		L.RegFunction("FromMinutes", FromMinutes);
		L.RegFunction("Negate", Negate);
		L.RegFunction("FromSeconds", FromSeconds);
		L.RegFunction("Subtract", Subtract);
		L.RegFunction("FromTicks", FromTicks);
		L.RegFunction("Parse", Parse);
		L.RegFunction("ParseExact", ParseExact);
		L.RegFunction("TryParse", TryParse);
		L.RegFunction("TryParseExact", TryParseExact);
		L.RegFunction("ToString", ToString);
		L.RegFunction("New", _CreateSystem_TimeSpan);
		L.RegFunction("__add", op_Addition);
		L.RegFunction("__sub", op_Subtraction);
		L.RegFunction("__eq", op_Equality);
		L.RegFunction("__unm", op_UnaryNegation);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegConstant("TicksPerMillisecond", 10000);
		L.RegConstant("TicksPerSecond", 10000000);
		L.RegConstant("TicksPerMinute", 600000000);
		L.RegConstant("TicksPerHour", 36000000000);
		L.RegConstant("TicksPerDay", 864000000000);
		L.RegVar("Zero", get_Zero, null);
		L.RegVar("MaxValue", get_MaxValue, null);
		L.RegVar("MinValue", get_MinValue, null);
		L.RegVar("Ticks", get_Ticks, null);
		L.RegVar("Days", get_Days, null);
		L.RegVar("Hours", get_Hours, null);
		L.RegVar("Milliseconds", get_Milliseconds, null);
		L.RegVar("Minutes", get_Minutes, null);
		L.RegVar("Seconds", get_Seconds, null);
		L.RegVar("TotalDays", get_TotalDays, null);
		L.RegVar("TotalHours", get_TotalHours, null);
		L.RegVar("TotalMilliseconds", get_TotalMilliseconds, null);
		L.RegVar("TotalMinutes", get_TotalMinutes, null);
		L.RegVar("TotalSeconds", get_TotalSeconds, null);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateSystem_TimeSpan(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				long arg0 = LuaDLL.tolua_checkint64(L, 1);
				System.TimeSpan obj = new System.TimeSpan(arg0);
				ToLua.PushValue(L, obj);
				return 1;
			}
			else if (count == 3)
			{
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 2);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 3);
				System.TimeSpan obj = new System.TimeSpan(arg0, arg1, arg2);
				ToLua.PushValue(L, obj);
				return 1;
			}
			else if (count == 4)
			{
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 2);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 3);
				int arg3 = (int)LuaDLL.luaL_checknumber(L, 4);
				System.TimeSpan obj = new System.TimeSpan(arg0, arg1, arg2, arg3);
				ToLua.PushValue(L, obj);
				return 1;
			}
			else if (count == 5)
			{
				int arg0 = (int)LuaDLL.luaL_checknumber(L, 1);
				int arg1 = (int)LuaDLL.luaL_checknumber(L, 2);
				int arg2 = (int)LuaDLL.luaL_checknumber(L, 3);
				int arg3 = (int)LuaDLL.luaL_checknumber(L, 4);
				int arg4 = (int)LuaDLL.luaL_checknumber(L, 5);
				System.TimeSpan obj = new System.TimeSpan(arg0, arg1, arg2, arg3, arg4);
				ToLua.PushValue(L, obj);
				return 1;
			}
			else if (count == 0)
			{
				System.TimeSpan obj = new System.TimeSpan();
				ToLua.PushValue(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: System.TimeSpan.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Add(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
			System.TimeSpan arg0 = StackTraits<System.TimeSpan>.Check(L, 2);
			System.TimeSpan o = obj.Add(arg0);
			ToLua.PushValue(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Compare(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			System.TimeSpan arg0 = StackTraits<System.TimeSpan>.Check(L, 1);
			System.TimeSpan arg1 = StackTraits<System.TimeSpan>.Check(L, 2);
			int o = System.TimeSpan.Compare(arg0, arg1);
			LuaDLL.lua_pushinteger(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int CompareTo(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<System.TimeSpan>(L, 2))
			{
				System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
				System.TimeSpan arg0 = StackTraits<System.TimeSpan>.To(L, 2);
				int o = obj.CompareTo(arg0);
				LuaDLL.lua_pushinteger(L, o);
				ToLua.SetBack(L, 1, obj);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<object>(L, 2))
			{
				System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
				object arg0 = ToLua.ToVarObject(L, 2);
				int o = obj.CompareTo(arg0);
				LuaDLL.lua_pushinteger(L, o);
				ToLua.SetBack(L, 1, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.TimeSpan.CompareTo");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromDays(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 1);
			System.TimeSpan o = System.TimeSpan.FromDays(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Duration(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
			System.TimeSpan o = obj.Duration();
			ToLua.PushValue(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Equals(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<System.TimeSpan>(L, 2))
			{
				System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
				System.TimeSpan arg0 = StackTraits<System.TimeSpan>.To(L, 2);
				bool o = obj.Equals(arg0);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.SetBack(L, 1, obj);
				return 1;
			}
			else if (count == 2 && TypeChecker.CheckTypes<object>(L, 2))
			{
				System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
				object arg0 = ToLua.ToVarObject(L, 2);
				bool o = obj.Equals(arg0);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.SetBack(L, 1, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.TimeSpan.Equals");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int GetHashCode(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
			int o = obj.GetHashCode();
			LuaDLL.lua_pushinteger(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromHours(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 1);
			System.TimeSpan o = System.TimeSpan.FromHours(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromMilliseconds(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 1);
			System.TimeSpan o = System.TimeSpan.FromMilliseconds(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromMinutes(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 1);
			System.TimeSpan o = System.TimeSpan.FromMinutes(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Negate(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
			System.TimeSpan o = obj.Negate();
			ToLua.PushValue(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromSeconds(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			double arg0 = (double)LuaDLL.luaL_checknumber(L, 1);
			System.TimeSpan o = System.TimeSpan.FromSeconds(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Subtract(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
			System.TimeSpan arg0 = StackTraits<System.TimeSpan>.Check(L, 2);
			System.TimeSpan o = obj.Subtract(arg0);
			ToLua.PushValue(L, o);
			ToLua.SetBack(L, 1, obj);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int FromTicks(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			long arg0 = LuaDLL.tolua_checkint64(L, 1);
			System.TimeSpan o = System.TimeSpan.FromTicks(arg0);
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int Parse(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.TimeSpan o = System.TimeSpan.Parse(arg0);
				ToLua.PushValue(L, o);
				return 1;
			}
			else if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.IFormatProvider arg1 = (System.IFormatProvider)ToLua.CheckObject<System.IFormatProvider>(L, 2);
				System.TimeSpan o = System.TimeSpan.Parse(arg0, arg1);
				ToLua.PushValue(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.TimeSpan.Parse");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ParseExact(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3 && TypeChecker.CheckTypes<string, System.IFormatProvider>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.ToString(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.TimeSpan o = System.TimeSpan.ParseExact(arg0, arg1, arg2);
				ToLua.PushValue(L, o);
				return 1;
			}
			else if (count == 3 && TypeChecker.CheckTypes<string[], System.IFormatProvider>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string[] arg1 = ToLua.ToStringArray(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.TimeSpan o = System.TimeSpan.ParseExact(arg0, arg1, arg2);
				ToLua.PushValue(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes<string, System.IFormatProvider, System.Globalization.TimeSpanStyles>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.ToString(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.Globalization.TimeSpanStyles arg3 = (System.Globalization.TimeSpanStyles)ToLua.ToObject(L, 4);
				System.TimeSpan o = System.TimeSpan.ParseExact(arg0, arg1, arg2, arg3);
				ToLua.PushValue(L, o);
				return 1;
			}
			else if (count == 4 && TypeChecker.CheckTypes<string[], System.IFormatProvider, System.Globalization.TimeSpanStyles>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string[] arg1 = ToLua.ToStringArray(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.Globalization.TimeSpanStyles arg3 = (System.Globalization.TimeSpanStyles)ToLua.ToObject(L, 4);
				System.TimeSpan o = System.TimeSpan.ParseExact(arg0, arg1, arg2, arg3);
				ToLua.PushValue(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.TimeSpan.ParseExact");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TryParse(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.TimeSpan arg1;
				bool o = System.TimeSpan.TryParse(arg0, out arg1);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.PushValue(L, arg1);
				return 2;
			}
			else if (count == 3)
			{
				string arg0 = ToLua.CheckString(L, 1);
				System.IFormatProvider arg1 = (System.IFormatProvider)ToLua.CheckObject<System.IFormatProvider>(L, 2);
				System.TimeSpan arg2;
				bool o = System.TimeSpan.TryParse(arg0, arg1, out arg2);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.PushValue(L, arg2);
				return 2;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.TimeSpan.TryParse");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int TryParseExact(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 4 && TypeChecker.CheckTypes<string, System.IFormatProvider, LuaInterface.LuaOut<System.TimeSpan>>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.ToString(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.TimeSpan arg3;
				bool o = System.TimeSpan.TryParseExact(arg0, arg1, arg2, out arg3);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.PushValue(L, arg3);
				return 2;
			}
			else if (count == 4 && TypeChecker.CheckTypes<string[], System.IFormatProvider, LuaInterface.LuaOut<System.TimeSpan>>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string[] arg1 = ToLua.ToStringArray(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.TimeSpan arg3;
				bool o = System.TimeSpan.TryParseExact(arg0, arg1, arg2, out arg3);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.PushValue(L, arg3);
				return 2;
			}
			else if (count == 5 && TypeChecker.CheckTypes<string, System.IFormatProvider, System.Globalization.TimeSpanStyles, LuaInterface.LuaOut<System.TimeSpan>>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string arg1 = ToLua.ToString(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.Globalization.TimeSpanStyles arg3 = (System.Globalization.TimeSpanStyles)ToLua.ToObject(L, 4);
				System.TimeSpan arg4;
				bool o = System.TimeSpan.TryParseExact(arg0, arg1, arg2, arg3, out arg4);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.PushValue(L, arg4);
				return 2;
			}
			else if (count == 5 && TypeChecker.CheckTypes<string[], System.IFormatProvider, System.Globalization.TimeSpanStyles, LuaInterface.LuaOut<System.TimeSpan>>(L, 2))
			{
				string arg0 = ToLua.CheckString(L, 1);
				string[] arg1 = ToLua.ToStringArray(L, 2);
				System.IFormatProvider arg2 = (System.IFormatProvider)ToLua.ToObject(L, 3);
				System.Globalization.TimeSpanStyles arg3 = (System.Globalization.TimeSpanStyles)ToLua.ToObject(L, 4);
				System.TimeSpan arg4;
				bool o = System.TimeSpan.TryParseExact(arg0, arg1, arg2, arg3, out arg4);
				LuaDLL.lua_pushboolean(L, o);
				ToLua.PushValue(L, arg4);
				return 2;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.TimeSpan.TryParseExact");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ToString(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
				string o = obj.ToString();
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else if (count == 2)
			{
				System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
				string arg0 = ToLua.CheckString(L, 2);
				string o = obj.ToString(arg0);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else if (count == 3)
			{
				System.TimeSpan obj = (System.TimeSpan)ToLua.CheckObject(L, 1, typeof(System.TimeSpan));
				string arg0 = ToLua.CheckString(L, 2);
				System.IFormatProvider arg1 = (System.IFormatProvider)ToLua.CheckObject<System.IFormatProvider>(L, 3);
				string o = obj.ToString(arg0, arg1);
				LuaDLL.lua_pushstring(L, o);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: System.TimeSpan.ToString");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_UnaryNegation(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			System.TimeSpan arg0 = StackTraits<System.TimeSpan>.Check(L, 1);
			System.TimeSpan o = -arg0;
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Subtraction(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			System.TimeSpan arg0 = StackTraits<System.TimeSpan>.Check(L, 1);
			System.TimeSpan arg1 = StackTraits<System.TimeSpan>.Check(L, 2);
			System.TimeSpan o = arg0 - arg1;
			ToLua.PushValue(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int op_Addition(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			System.TimeSpan arg0 = StackTraits<System.TimeSpan>.Check(L, 1);
			System.TimeSpan arg1 = StackTraits<System.TimeSpan>.Check(L, 2);
			System.TimeSpan o = arg0 + arg1;
			ToLua.PushValue(L, o);
			return 1;
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
			System.TimeSpan arg0 = StackTraits<System.TimeSpan>.To(L, 1);
			System.TimeSpan arg1 = StackTraits<System.TimeSpan>.To(L, 2);
			bool o = arg0 == arg1;
			LuaDLL.lua_pushboolean(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Zero(IntPtr L)
	{
		try
		{
			ToLua.PushValue(L, System.TimeSpan.Zero);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_MaxValue(IntPtr L)
	{
		try
		{
			ToLua.PushValue(L, System.TimeSpan.MaxValue);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_MinValue(IntPtr L)
	{
		try
		{
			ToLua.PushValue(L, System.TimeSpan.MinValue);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Ticks(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			long ret = obj.Ticks;
			LuaDLL.tolua_pushint64(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Ticks on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Days(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			int ret = obj.Days;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Days on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Hours(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			int ret = obj.Hours;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Hours on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Milliseconds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			int ret = obj.Milliseconds;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Milliseconds on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Minutes(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			int ret = obj.Minutes;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Minutes on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_Seconds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			int ret = obj.Seconds;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index Seconds on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_TotalDays(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			double ret = obj.TotalDays;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index TotalDays on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_TotalHours(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			double ret = obj.TotalHours;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index TotalHours on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_TotalMilliseconds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			double ret = obj.TotalMilliseconds;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index TotalMilliseconds on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_TotalMinutes(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			double ret = obj.TotalMinutes;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index TotalMinutes on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_TotalSeconds(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			System.TimeSpan obj = (System.TimeSpan)o;
			double ret = obj.TotalSeconds;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index TotalSeconds on a nil value");
		}
	}
}

