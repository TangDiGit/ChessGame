//this source code was auto-generated by tolua#, do not modify it
using System;
using LuaInterface;

public class LTSplineWrap
{
	public static void Register(LuaState L)
	{
		L.BeginClass(typeof(LTSpline), typeof(System.Object));
		L.RegFunction("map", map);
		L.RegFunction("interp", interp);
		L.RegFunction("ratioAtPoint", ratioAtPoint);
		L.RegFunction("point", point);
		L.RegFunction("place2d", place2d);
		L.RegFunction("placeLocal2d", placeLocal2d);
		L.RegFunction("place", place);
		L.RegFunction("placeLocal", placeLocal);
		L.RegFunction("gizmoDraw", gizmoDraw);
		L.RegFunction("drawGizmo", drawGizmo);
		L.RegFunction("drawLine", drawLine);
		L.RegFunction("drawLinesGLLines", drawLinesGLLines);
		L.RegFunction("generateVectors", generateVectors);
		L.RegFunction("New", _CreateLTSpline);
		L.RegFunction("__tostring", ToLua.op_ToString);
		L.RegVar("DISTANCE_COUNT", get_DISTANCE_COUNT, set_DISTANCE_COUNT);
		L.RegVar("SUBLINE_COUNT", get_SUBLINE_COUNT, set_SUBLINE_COUNT);
		L.RegVar("distance", get_distance, set_distance);
		L.RegVar("constantSpeed", get_constantSpeed, set_constantSpeed);
		L.RegVar("pts", get_pts, set_pts);
		L.RegVar("ptsAdj", get_ptsAdj, set_ptsAdj);
		L.RegVar("ptsAdjLength", get_ptsAdjLength, set_ptsAdjLength);
		L.RegVar("orientToPath", get_orientToPath, set_orientToPath);
		L.RegVar("orientToPath2d", get_orientToPath2d, set_orientToPath2d);
		L.EndClass();
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int _CreateLTSpline(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				UnityEngine.Vector3[] arg0 = ToLua.CheckStructArray<UnityEngine.Vector3>(L, 1);
				LTSpline obj = new LTSpline(arg0);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else if (count == 2)
			{
				UnityEngine.Vector3[] arg0 = ToLua.CheckStructArray<UnityEngine.Vector3>(L, 1);
				bool arg1 = LuaDLL.luaL_checkboolean(L, 2);
				LTSpline obj = new LTSpline(arg0, arg1);
				ToLua.PushObject(L, obj);
				return 1;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to ctor method: LTSpline.New");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int map(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 o = obj.map(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int interp(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 o = obj.interp(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int ratioAtPoint(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			UnityEngine.Vector3 arg0 = ToLua.ToVector3(L, 2);
			float o = obj.ratioAtPoint(arg0);
			LuaDLL.lua_pushnumber(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int point(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 2);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Vector3 o = obj.point(arg0);
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int place2d(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			obj.place2d(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int placeLocal2d(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
			obj.placeLocal2d(arg0, arg1);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int place(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
				UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				obj.place(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
				UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				UnityEngine.Vector3 arg2 = ToLua.ToVector3(L, 4);
				obj.place(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LTSpline.place");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int placeLocal(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 3)
			{
				LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
				UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				obj.placeLocal(arg0, arg1);
				return 0;
			}
			else if (count == 4)
			{
				LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
				UnityEngine.Transform arg0 = (UnityEngine.Transform)ToLua.CheckObject<UnityEngine.Transform>(L, 2);
				float arg1 = (float)LuaDLL.luaL_checknumber(L, 3);
				UnityEngine.Vector3 arg2 = ToLua.ToVector3(L, 4);
				obj.placeLocal(arg0, arg1, arg2);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LTSpline.placeLocal");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int gizmoDraw(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 1)
			{
				LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
				obj.gizmoDraw();
				return 0;
			}
			else if (count == 2)
			{
				LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
				float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
				obj.gizmoDraw(arg0);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LTSpline.gizmoDraw");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int drawGizmo(IntPtr L)
	{
		try
		{
			int count = LuaDLL.lua_gettop(L);

			if (count == 2 && TypeChecker.CheckTypes<LTSpline, UnityEngine.Color>(L, 1))
			{
				LTSpline obj = (LTSpline)ToLua.ToObject(L, 1);
				UnityEngine.Color arg0 = ToLua.ToColor(L, 2);
				obj.drawGizmo(arg0);
				return 0;
			}
			else if (count == 2 && TypeChecker.CheckTypes<UnityEngine.Transform[], UnityEngine.Color>(L, 1))
			{
				UnityEngine.Transform[] arg0 = ToLua.ToObjectArray<UnityEngine.Transform>(L, 1);
				UnityEngine.Color arg1 = ToLua.ToColor(L, 2);
				LTSpline.drawGizmo(arg0, arg1);
				return 0;
			}
			else
			{
				return LuaDLL.luaL_throw(L, "invalid arguments to method: LTSpline.drawGizmo");
			}
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int drawLine(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 3);
			UnityEngine.Transform[] arg0 = ToLua.CheckObjectArray<UnityEngine.Transform>(L, 1);
			float arg1 = (float)LuaDLL.luaL_checknumber(L, 2);
			UnityEngine.Color arg2 = ToLua.ToColor(L, 3);
			LTSpline.drawLine(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int drawLinesGLLines(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 4);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			UnityEngine.Material arg0 = (UnityEngine.Material)ToLua.CheckObject<UnityEngine.Material>(L, 2);
			UnityEngine.Color arg1 = ToLua.ToColor(L, 3);
			float arg2 = (float)LuaDLL.luaL_checknumber(L, 4);
			obj.drawLinesGLLines(arg0, arg1, arg2);
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int generateVectors(IntPtr L)
	{
		try
		{
			ToLua.CheckArgsCount(L, 1);
			LTSpline obj = (LTSpline)ToLua.CheckObject<LTSpline>(L, 1);
			UnityEngine.Vector3[] o = obj.generateVectors();
			ToLua.Push(L, o);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_DISTANCE_COUNT(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, LTSpline.DISTANCE_COUNT);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_SUBLINE_COUNT(IntPtr L)
	{
		try
		{
			LuaDLL.lua_pushinteger(L, LTSpline.SUBLINE_COUNT);
			return 1;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_distance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			float ret = obj.distance;
			LuaDLL.lua_pushnumber(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index distance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_constantSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			bool ret = obj.constantSpeed;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index constantSpeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_pts(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			UnityEngine.Vector3[] ret = obj.pts;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index pts on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ptsAdj(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			UnityEngine.Vector3[] ret = obj.ptsAdj;
			ToLua.Push(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ptsAdj on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_ptsAdjLength(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			int ret = obj.ptsAdjLength;
			LuaDLL.lua_pushinteger(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ptsAdjLength on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_orientToPath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			bool ret = obj.orientToPath;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orientToPath on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int get_orientToPath2d(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			bool ret = obj.orientToPath2d;
			LuaDLL.lua_pushboolean(L, ret);
			return 1;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orientToPath2d on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_DISTANCE_COUNT(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			LTSpline.DISTANCE_COUNT = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_SUBLINE_COUNT(IntPtr L)
	{
		try
		{
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			LTSpline.SUBLINE_COUNT = arg0;
			return 0;
		}
		catch (Exception e)
		{
			return LuaDLL.toluaL_exception(L, e);
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_distance(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			float arg0 = (float)LuaDLL.luaL_checknumber(L, 2);
			obj.distance = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index distance on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_constantSpeed(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.constantSpeed = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index constantSpeed on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_pts(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			UnityEngine.Vector3[] arg0 = ToLua.CheckStructArray<UnityEngine.Vector3>(L, 2);
			obj.pts = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index pts on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ptsAdj(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			UnityEngine.Vector3[] arg0 = ToLua.CheckStructArray<UnityEngine.Vector3>(L, 2);
			obj.ptsAdj = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ptsAdj on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_ptsAdjLength(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			int arg0 = (int)LuaDLL.luaL_checknumber(L, 2);
			obj.ptsAdjLength = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index ptsAdjLength on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_orientToPath(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.orientToPath = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orientToPath on a nil value");
		}
	}

	[MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
	static int set_orientToPath2d(IntPtr L)
	{
		object o = null;

		try
		{
			o = ToLua.ToObject(L, 1);
			LTSpline obj = (LTSpline)o;
			bool arg0 = LuaDLL.luaL_checkboolean(L, 2);
			obj.orientToPath2d = arg0;
			return 0;
		}
		catch(Exception e)
		{
			return LuaDLL.toluaL_exception(L, e, o, "attempt to index orientToPath2d on a nil value");
		}
	}
}

