
﻿using System.Collections.Generic;
namespace DragonBones
{
    public abstract class BaseObject
    {
        private static uint _hashCode = 0;
        private static uint _defaultMaxCount = 3000;
        private static readonly Dictionary<System.Type, uint> _maxCountMap = new Dictionary<System.Type, uint>();
        private static readonly Dictionary<System.Type, List<BaseObject>> _poolsMap = new Dictionary<System.Type, List<BaseObject>>();
        private static void _ReturnObject(BaseObject obj)
        {
            var classType = obj.GetType();
            var maxCount = _maxCountMap.ContainsKey(classType) ? _maxCountMap[classType] : _defaultMaxCount;
            var pool = _poolsMap.ContainsKey(classType) ? _poolsMap[classType] : _poolsMap[classType] = new List<BaseObject>();
            if (pool.Count < maxCount)
            {
                if (!pool.Contains(obj))
                {
                    pool.Add(obj);
                }
                else
                {
                    Helper.Assert(false, "The object is already in the pool.");
                }
            }
            else
            {
            }
        }
        public static void SetMaxCount(System.Type classType, uint maxCount)
        {
            if (classType != null)
            {
                if (_poolsMap.ContainsKey(classType))
                {
                    var pool = _poolsMap[classType];
                    if (pool.Count > maxCount)
                    {
                        pool.ResizeList((int)maxCount, null);
                    }
                }
                _maxCountMap[classType] = maxCount;
            }
            else
            {
                _defaultMaxCount = maxCount;
                foreach (var key in _poolsMap.Keys)
                {
                    var pool = _poolsMap[key];
                    if (pool.Count > maxCount)
                    {
                        pool.ResizeList((int)maxCount, null);
                    }
                    if (_maxCountMap.ContainsKey(key))
                    {
                        _maxCountMap[key] = maxCount;
                    }
                }
            }
        }
        public static void ClearPool(System.Type classType)
        {
            if (classType != null)
            {
                if (_poolsMap.ContainsKey(classType))
                {
                    var pool = _poolsMap[classType];
                    if (pool != null)
                    {
                        pool.Clear();
                    }
                }
            }
            else
            {
                foreach (var pair in _poolsMap)
                {
                    var pool = _poolsMap[pair.Key];
                    if (pool != null)
                    {
                        pool.Clear();
                    }
                }
            }
        }
        public static T BorrowObject<T>() where T : BaseObject, new()
        {
            var type = typeof(T);
            var pool = _poolsMap.ContainsKey(type) ? _poolsMap[type] : null;
            if (pool != null && pool.Count > 0)
            {
                var index = pool.Count - 1;
                var obj = pool[index];
                pool.RemoveAt(index);
                return (T)obj;
            }
            else
            {
                var obj = new T();
                obj._OnClear();
                return obj;
            }
        }
        public readonly uint hashCode = _hashCode++;
        protected BaseObject()
        {
        }
        protected abstract void _OnClear();
        public void ReturnToPool()
        {
            _OnClear();
            _ReturnObject(this);
        }
    }
}