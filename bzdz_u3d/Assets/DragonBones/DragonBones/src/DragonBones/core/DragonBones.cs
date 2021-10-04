
using System.Collections.Generic;
using System.Diagnostics;
using System;
namespace DragonBones
{
    enum BinaryOffset
    {
        WeigthBoneCount = 0,
        WeigthFloatOffset = 1,
        WeigthBoneIndices = 2,
        MeshVertexCount = 0,
        MeshTriangleCount = 1,
        MeshFloatOffset = 2,
        MeshWeightOffset = 3,
        MeshVertexIndices = 4,
        TimelineScale = 0,
        TimelineOffset = 1,
        TimelineKeyFrameCount = 2,
        TimelineFrameValueCount = 3,
        TimelineFrameValueOffset = 4,
        TimelineFrameOffset = 5,
        FramePosition = 0,
        FrameTweenType = 1,
        FrameTweenEasingOrCurveSampleCount = 2,
        FrameCurveSamples = 3,
        DeformVertexOffset = 0,
        DeformCount = 1,
        DeformValueCount = 2,
        DeformValueOffset = 3,
        DeformFloatOffset = 4
    }
    public enum ArmatureType
    {
        None = -1,
        Armature = 0,
        MovieClip = 1,
        Stage = 2
    }
    public enum DisplayType
    {
        None = -1,
        Image = 0,
        Armature = 1,
        Mesh = 2,
        BoundingBox = 3,
        Path = 4
    }
    public enum BoundingBoxType
    {
        None = -1,
        Rectangle = 0,
        Ellipse = 1,
        Polygon = 2
    }
    public enum ActionType
    {
        Play = 0,
        Frame = 10,
        Sound = 11
    }
    public enum BlendMode
    {
        Normal = 0,
        Add = 1,
        Alpha = 2,
        Darken = 3,
        Difference = 4,
        Erase = 5,
        HardLight = 6,
        Invert = 7,
        Layer = 8,
        Lighten = 9,
        Multiply = 10,
        Overlay = 11,
        Screen = 12,
        Subtract = 13
    }
    public enum TweenType
    {
        None = 0,
        Line = 1,
        Curve = 2,
        QuadIn = 3,
        QuadOut = 4,
        QuadInOut = 5
    }
    public enum TimelineType
    {
        Action = 0,
        ZOrder = 1,
        BoneAll = 10,
        BoneTranslate = 11,
        BoneRotate = 12,
        BoneScale = 13,
        SlotDisplay = 20,
        SlotColor = 21,
        SlotDeform = 22,
        IKConstraint = 30,
        AnimationTime = 40,
        AnimationWeight = 41
    }
    public enum OffsetMode
    {
        None,
        Additive,
        Override
    }
    public enum AnimationFadeOutMode
    {
        None = 0,
        SameLayer = 1,
        SameGroup = 2,
        SameLayerAndGroup = 3,
        All = 4,
        Single = 5
    }
    internal static class Helper
    {
        public static readonly int INT16_SIZE = 2;
        public static readonly int UINT16_SIZE = 2;
        public static readonly int FLOAT_SIZE = 4;
        internal static void Assert(bool condition, string message)
        {
            Debug.Assert(condition, message);
        }
        internal static void ResizeList<T>(this List<T> list, int count, T value = default(T))
        {
            if (list.Count == count)
            {
                return;
            }
            if (list.Count > count)
            {
                list.RemoveRange(count, list.Count - count);
            }
            else
            {
                for (int i = list.Count, l = count; i < l; ++i)
                {
                    list.Add(value);
                }
            }
        }
        internal static List<float> Convert(this List<object> list)
        {
            List<float> res = new List<float>();
            for (int i = 0; i < list.Count; i++)
            {
                res[i] = float.Parse(list[i].ToString());
            }
            return res;
        }
        internal static bool FloatEqual(float f0, float f1)
        {
            float f = Math.Abs(f0 - f1);
            return (f < 0.000000001f);
        }
    }
    public class DragonBones
    {
        public static bool yDown = true;
        public static bool debug = false;
        public static bool debugDraw = false;
        public static readonly string VERSION = "5.6.300";
        private readonly WorldClock _clock = new WorldClock();
        private readonly List<EventObject> _events = new List<EventObject>();
        private readonly List<BaseObject> _objects = new List<BaseObject>();
        private IEventDispatcher<EventObject> _eventManager = null;
        public DragonBones(IEventDispatcher<EventObject> eventManager)
        {
            this._eventManager = eventManager;
        }
        public void AdvanceTime(float passedTime)
        {
            if (this._objects.Count > 0)
            {
                for (int i = 0; i < this._objects.Count; ++i)
                {
                    var obj = this._objects[i];
                    obj.ReturnToPool();
                }
                this._objects.Clear();
            }
            if (this._events.Count > 0)
            {
                for (int i = 0; i < this._events.Count; ++i)
                {
                    var eventObject = this._events[i];
                    var armature = eventObject.armature;
                    if (armature._armatureData != null)
                    {
                        armature.eventDispatcher.DispatchDBEvent(eventObject.type, eventObject);
                        if (eventObject.type == EventObject.SOUND_EVENT)
                        {
                            this._eventManager.DispatchDBEvent(eventObject.type, eventObject);
                        }
                    }
                    this.BufferObject(eventObject);
                }
                this._events.Clear();
            }
            this._clock.AdvanceTime(passedTime);
        }
        public void BufferEvent(EventObject value)
        {
            if (!this._events.Contains(value))
            {
                this._events.Add(value);
            }
        }
        public void BufferObject(BaseObject value)
        {
            if (!this._objects.Contains(value))
            {
                this._objects.Add(value);
            }
        }
        public static implicit operator bool(DragonBones exists)
        {
            return exists != null;
        }
        public WorldClock clock
        {
            get { return this._clock; }
        }
        public IEventDispatcher<EventObject> eventManager
        {
            get { return this._eventManager; }
        }
    }
}