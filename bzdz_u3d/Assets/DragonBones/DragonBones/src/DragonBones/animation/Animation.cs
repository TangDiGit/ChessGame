
using System.Collections.Generic;
namespace DragonBones
{
    public class Animation : BaseObject
    {
        public float timeScale;
        private bool _lockUpdate;
        private bool _animationDirty;
        private float _inheritTimeScale;
        private readonly List<string> _animationNames = new List<string>();
        private readonly List<AnimationState> _animationStates = new List<AnimationState>();
        private readonly Dictionary<string, AnimationData> _animations = new Dictionary<string, AnimationData>();
        private Armature _armature;
        private AnimationConfig _animationConfig = null; // Initial value.
        private AnimationState _lastAnimationState;
        protected override void _OnClear()
        {
            foreach (var animationState in this._animationStates)
            {
                animationState.ReturnToPool();
            }
            if (this._animationConfig != null)
            {
                this._animationConfig.ReturnToPool();
            }
            this.timeScale = 1.0f;
            this._lockUpdate = false;
            this._animationDirty = false;
            this._inheritTimeScale = 1.0f;
            this._animationNames.Clear();
            this._animationStates.Clear();
            this._animations.Clear();
            this._armature = null; //
            this._animationConfig = null; //
            this._lastAnimationState = null;
        }
        private void _FadeOut(AnimationConfig animationConfig)
        {
            switch (animationConfig.fadeOutMode)
            {
                case AnimationFadeOutMode.SameLayer:
                    foreach (var animationState in this._animationStates)
                    {
                        if (animationState._parent != null)
                        {
                            continue;
                        }
                        if (animationState.layer == animationConfig.layer)
                        {
                            animationState.FadeOut(animationConfig.fadeOutTime, animationConfig.pauseFadeOut);
                        }
                    }
                    break;
                case AnimationFadeOutMode.SameGroup:
                    foreach (var animationState in this._animationStates)
                    {
                        if (animationState._parent != null)
                        {
                            continue;
                        }
                        if (animationState.group == animationConfig.group)
                        {
                            animationState.FadeOut(animationConfig.fadeOutTime, animationConfig.pauseFadeOut);
                        }
                    }
                    break;
                case AnimationFadeOutMode.SameLayerAndGroup:
                    foreach (var animationState in this._animationStates)
                    {
                        if (animationState._parent != null)
                        {
                            continue;
                        }
                        if (animationState.layer == animationConfig.layer &&
                            animationState.group == animationConfig.group)
                        {
                            animationState.FadeOut(animationConfig.fadeOutTime, animationConfig.pauseFadeOut);
                        }
                    }
                    break;
                case AnimationFadeOutMode.All:
                    foreach (var animationState in this._animationStates)
                    {
                        if (animationState._parent != null)
                        {
                            continue;
                        }
                        animationState.FadeOut(animationConfig.fadeOutTime, animationConfig.pauseFadeOut);
                    }
                    break;
                case AnimationFadeOutMode.None:
                case AnimationFadeOutMode.Single:
                default:
                    break;
            }
        }
        internal void Init(Armature armature)
        {
            if (this._armature != null)
            {
                return;
            }
            this._armature = armature;
            this._animationConfig = BaseObject.BorrowObject<AnimationConfig>();
        }
        internal void AdvanceTime(float passedTime)
        {
            if (passedTime < 0.0f)
            {
                passedTime = -passedTime;
            }
            if (this._armature.inheritAnimation && this._armature._parent != null)
            {
                this._inheritTimeScale = this._armature._parent._armature.animation._inheritTimeScale * this.timeScale;
            }
            else
            {
                this._inheritTimeScale = this.timeScale;
            }
            if (this._inheritTimeScale != 1.0f)
            {
                passedTime *= this._inheritTimeScale;
            }
            var animationStateCount = this._animationStates.Count;
            if (animationStateCount == 1)
            {
                var animationState = this._animationStates[0];
                if (animationState._fadeState > 0 && animationState._subFadeState > 0)
                {
                    this._armature._dragonBones.BufferObject(animationState);
                    this._animationStates.Clear();
                    this._lastAnimationState = null;
                }
                else
                {
                    var animationData = animationState._animationData;
                    var cacheFrameRate = animationData.cacheFrameRate;
                    if (this._animationDirty && cacheFrameRate > 0.0f)
                    {
                        this._animationDirty = false;
                        foreach (var bone in this._armature.GetBones())
                        {
                            bone._cachedFrameIndices = animationData.GetBoneCachedFrameIndices(bone.name);
                        }
                        foreach (var slot in this._armature.GetSlots())
                        {
                            var rawDisplayDatas = slot.rawDisplayDatas;
                            if (rawDisplayDatas != null && rawDisplayDatas.Count > 0)
                            {
                                var rawDsplayData = rawDisplayDatas[0];
                                if (rawDsplayData != null)
                                {
                                    if (rawDsplayData.parent == this._armature.armatureData.defaultSkin)
                                    {
                                        slot._cachedFrameIndices = animationData.GetSlotCachedFrameIndices(slot.name);
                                        continue;
                                    }
                                }
                            }
                            slot._cachedFrameIndices = null;
                        }
                    }
                    animationState.AdvanceTime(passedTime, cacheFrameRate);
                }
            }
            else if (animationStateCount > 1)
            {
                for (int i = 0, r = 0; i < animationStateCount; ++i)
                {
                    var animationState = this._animationStates[i];
                    if (animationState._fadeState > 0 && animationState._subFadeState > 0)
                    {
                        r++;
                        this._armature._dragonBones.BufferObject(animationState);
                        this._animationDirty = true;
                        if (this._lastAnimationState == animationState)
                        {
                            this._lastAnimationState = null;
                        }
                    }
                    else
                    {
                        if (r > 0)
                        {
                            this._animationStates[i - r] = animationState;
                        }
                        animationState.AdvanceTime(passedTime, 0.0f);
                    }
                    if (i == animationStateCount - 1 && r > 0)
                    {
                        this._animationStates.ResizeList(this._animationStates.Count - r);
                        if (this._lastAnimationState == null && this._animationStates.Count > 0)
                        {
                            this._lastAnimationState = this._animationStates[this._animationStates.Count - 1];
                        }
                    }
                }
                this._armature._cacheFrameIndex = -1;
            }
            else
            {
                this._armature._cacheFrameIndex = -1;
            }
        }
        public void Reset()
        {
            foreach (var animationState in this._animationStates)
            {
                animationState.ReturnToPool();
            }
            this._animationDirty = false;
            this._animationConfig.Clear();
            this._animationStates.Clear();
            this._lastAnimationState = null;
        }
        public void Stop(string animationName = null)
        {
            if (animationName != null)
            {
                var animationState = this.GetState(animationName);
                if (animationState != null)
                {
                    animationState.Stop();
                }
            }
            else
            {
                foreach (var animationState in this._animationStates)
                {
                    animationState.Stop();
                }
            }
        }
        public AnimationState PlayConfig(AnimationConfig animationConfig)
        {
            var animationName = animationConfig.animation;
            if (!(this._animations.ContainsKey(animationName)))
            {
                Helper.Assert(false,
                    "Non-existent animation.\n" +
                    "DragonBones name: " + this._armature.armatureData.parent.name +
                    "Armature name: " + this._armature.name +
                    "Animation name: " + animationName
                );
                return null;
            }
            var animationData = this._animations[animationName];
            if (animationConfig.fadeOutMode == AnimationFadeOutMode.Single)
            {
                foreach (var aniState in this._animationStates)
                {
                    if (aniState._animationData == animationData)
                    {
                        return aniState;
                    }
                }
            }
            if (this._animationStates.Count == 0)
            {
                animationConfig.fadeInTime = 0.0f;
            }
            else if (animationConfig.fadeInTime < 0.0f)
            {
                animationConfig.fadeInTime = animationData.fadeInTime;
            }
            if (animationConfig.fadeOutTime < 0.0f)
            {
                animationConfig.fadeOutTime = animationConfig.fadeInTime;
            }
            if (animationConfig.timeScale <= -100.0f)
            {
                animationConfig.timeScale = 1.0f / animationData.scale;
            }
            if (animationData.frameCount > 1)
            {
                if (animationConfig.position < 0.0f)
                {
                    animationConfig.position %= animationData.duration;
                    animationConfig.position = animationData.duration - animationConfig.position;
                }
                else if (animationConfig.position == animationData.duration)
                {
                    animationConfig.position -= 0.000001f; // Play a little time before end.
                }
                else if (animationConfig.position > animationData.duration)
                {
                    animationConfig.position %= animationData.duration;
                }
                if (animationConfig.duration > 0.0f && animationConfig.position + animationConfig.duration > animationData.duration)
                {
                    animationConfig.duration = animationData.duration - animationConfig.position;
                }
                if (animationConfig.playTimes < 0)
                {
                    animationConfig.playTimes = (int)animationData.playTimes;
                }
            }
            else
            {
                animationConfig.playTimes = 1;
                animationConfig.position = 0.0f;
                if (animationConfig.duration > 0.0)
                {
                    animationConfig.duration = 0.0f;
                }
            }
            if (animationConfig.duration == 0.0f)
            {
                animationConfig.duration = -1.0f;
            }
            this._FadeOut(animationConfig);
            var animationState = BaseObject.BorrowObject<AnimationState>();
            animationState.Init(this._armature, animationData, animationConfig);
            this._animationDirty = true;
            this._armature._cacheFrameIndex = -1;
            if (this._animationStates.Count > 0)
            {
                var added = false;
                for (int i = 0, l = this._animationStates.Count; i < l; ++i)
                {
                    if (animationState.layer > this._animationStates[i].layer)
                    {
                        added = true;
                        this._animationStates.Insert(i, animationState);
                        break;
                    }
                    else if (i != l - 1 && animationState.layer > this._animationStates[i + 1].layer)
                    {
                        added = true;
                        this._animationStates.Insert(i + 1, animationState);
                        break;
                    }
                }
                if (!added)
                {
                    this._animationStates.Add(animationState);
                }
            }
            else
            {
                this._animationStates.Add(animationState);
            }
            foreach (var slot in this._armature.GetSlots())
            {
                var childArmature = slot.childArmature;
                if (childArmature != null &&
                    childArmature.inheritAnimation &&
                    childArmature.animation.HasAnimation(animationName) &&
                    childArmature.animation.GetState(animationName) == null)
                {
                    childArmature.animation.FadeIn(animationName); //
                }
            }
            if (!this._lockUpdate)
            {
                if (animationConfig.fadeInTime <= 0.0f)
                {
                    this._armature.AdvanceTime(0.0f);
                }
            }
            this._lastAnimationState = animationState;
            return animationState;
        }
        public AnimationState Play(string animationName = null, int playTimes = -1)
        {
            this._animationConfig.Clear();
            this._animationConfig.resetToPose = true;
            this._animationConfig.playTimes = playTimes;
            this._animationConfig.fadeInTime = 0.0f;
            this._animationConfig.animation = animationName != null ? animationName : "";
            if (animationName != null && animationName.Length > 0)
            {
                this.PlayConfig(this._animationConfig);
            }
            else if (this._lastAnimationState == null)
            {
                var defaultAnimation = this._armature.armatureData.defaultAnimation;
                if (defaultAnimation != null)
                {
                    this._animationConfig.animation = defaultAnimation.name;
                    this.PlayConfig(this._animationConfig);
                }
            }
            else if (!this._lastAnimationState.isPlaying && !this._lastAnimationState.isCompleted)
            {
                this._lastAnimationState.Play();
            }
            else
            {
                this._animationConfig.animation = this._lastAnimationState.name;
                this.PlayConfig(this._animationConfig);
            }
            return this._lastAnimationState;
        }
        public AnimationState FadeIn(string animationName, float fadeInTime = -1.0f, int playTimes = -1,
                                    int layer = 0, string group = null,
                                    AnimationFadeOutMode fadeOutMode = AnimationFadeOutMode.SameLayerAndGroup)
        {
            this._animationConfig.Clear();
            this._animationConfig.fadeOutMode = fadeOutMode;
            this._animationConfig.playTimes = playTimes;
            this._animationConfig.layer = layer;
            this._animationConfig.fadeInTime = fadeInTime;
            this._animationConfig.animation = animationName;
            this._animationConfig.group = group != null ? group : "";
            return this.PlayConfig(this._animationConfig);
        }
        public AnimationState GotoAndPlayByTime(string animationName, float time = 0.0f, int playTimes = -1)
        {
            this._animationConfig.Clear();
            this._animationConfig.resetToPose = true;
            this._animationConfig.playTimes = playTimes;
            this._animationConfig.position = time;
            this._animationConfig.fadeInTime = 0.0f;
            this._animationConfig.animation = animationName;
            return this.PlayConfig(this._animationConfig);
        }
        public AnimationState GotoAndPlayByFrame(string animationName, uint frame = 0, int playTimes = -1)
        {
            this._animationConfig.Clear();
            this._animationConfig.resetToPose = true;
            this._animationConfig.playTimes = playTimes;
            this._animationConfig.fadeInTime = 0.0f;
            this._animationConfig.animation = animationName;
            var animationData = this._animations.ContainsKey(animationName) ? this._animations[animationName] : null;
            if (animationData != null)
            {
                this._animationConfig.position = animationData.duration * frame / animationData.frameCount;
            }
            return this.PlayConfig(this._animationConfig);
        }
        public AnimationState GotoAndPlayByProgress(string animationName, float progress = 0.0f, int playTimes = -1)
        {
            this._animationConfig.Clear();
            this._animationConfig.resetToPose = true;
            this._animationConfig.playTimes = playTimes;
            this._animationConfig.fadeInTime = 0.0f;
            this._animationConfig.animation = animationName;
            var animationData = this._animations.ContainsKey(animationName) ? this._animations[animationName] : null;
            if (animationData != null)
            {
                this._animationConfig.position = animationData.duration * (progress > 0.0f ? progress : 0.0f);
            }
            return this.PlayConfig(this._animationConfig);
        }
        public AnimationState GotoAndStopByTime(string animationName, float time = 0.0f)
        {
            var animationState = this.GotoAndPlayByTime(animationName, time, 1);
            if (animationState != null)
            {
                animationState.Stop();
            }
            return animationState;
        }
        public AnimationState GotoAndStopByFrame(string animationName, uint frame = 0)
        {
            var animationState = this.GotoAndPlayByFrame(animationName, frame, 1);
            if (animationState != null)
            {
                animationState.Stop();
            }
            return animationState;
        }
        public AnimationState GotoAndStopByProgress(string animationName, float progress = 0.0f)
        {
            var animationState = this.GotoAndPlayByProgress(animationName, progress, 1);
            if (animationState != null)
            {
                animationState.Stop();
            }
            return animationState;
        }
        public AnimationState GetState(string animationName)
        {
            var i = this._animationStates.Count;
            while (i-- > 0)
            {
                var animationState = this._animationStates[i];
                if (animationState.name == animationName)
                {
                    return animationState;
                }
            }
            return null;
        }
        public bool HasAnimation(string animationName)
        {
            return this._animations.ContainsKey(animationName);
        }
        public List<AnimationState> GetStates()
        {
            return this._animationStates;
        }
        public bool isPlaying
        {
            get
            {
                foreach (var animationState in this._animationStates)
                {
                    if (animationState.isPlaying)
                    {
                        return true;
                    }
                }
                return false;
            }
        }
        public bool isCompleted
        {
            get
            {
                foreach (var animationState in this._animationStates)
                {
                    if (!animationState.isCompleted)
                    {
                        return false;
                    }
                }
                return this._animationStates.Count > 0;
            }
        }
        public string lastAnimationName
        {
            get { return this._lastAnimationState != null ? this._lastAnimationState.name : ""; }
        }
        public List<string> animationNames
        {
            get { return this._animationNames; }
        }
        public Dictionary<string, AnimationData> animations
        {
            get { return this._animations; }
            set
            {
                if (this._animations == value)
                {
                    return;
                }
                this._animationNames.Clear();
                this._animations.Clear();
                foreach (var k in value)
                {
                    this._animationNames.Add(k.Key);
                    this._animations[k.Key] = value[k.Key];
                }
            }
        }
        public AnimationConfig animationConfig
        {
            get
            {
                this._animationConfig.Clear();
                return this._animationConfig;
            }
        }
        public AnimationState lastAnimationState
        {
            get { return this._lastAnimationState; }
        }
    }
}
