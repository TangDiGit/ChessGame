
﻿using System.Collections.Generic;
using UnityEngine;
namespace DragonBones
{
    
    public class UnityTextureAtlasData : TextureAtlasData
    {
        
        internal bool _disposeEnabled;
        
        public Material texture;
        public Material uiTexture;
        
        public UnityTextureAtlasData()
        {
        }
        
        protected override void _OnClear()
        {
            base._OnClear();
            if (_disposeEnabled && texture != null)
            {
                UnityFactoryHelper.DestroyUnityObject(texture);
            }
            if (_disposeEnabled && uiTexture != null)
            {
                UnityFactoryHelper.DestroyUnityObject(uiTexture);
            }
            _disposeEnabled = false;
            texture = null;
            uiTexture = null;
        }
        
        public override TextureData CreateTexture()
        {
            return BaseObject.BorrowObject<UnityTextureData>();
        }
    }
    internal class UnityTextureData : TextureData
    {
        public const string SHADER_PATH = "Shaders/";
        public const string SHADER_GRAP = "DB_BlendMode_Grab";
        public const string SHADER_FRAME_BUFFER = "DB_BlendMode_Framebuffer";
        public const string UI_SHADER_GRAP = "DB_BlendMode_UIGrab";
        public const string UI_SHADER_FRAME_BUFFER = "DB_BlendMode_UIFramebuffer";
        internal Dictionary<string, Material> _cacheBlendModeMats = new Dictionary<string, Material>();
        public UnityTextureData()
        {
        }
        protected override void _OnClear()
        {
            base._OnClear();
            foreach (var key in this._cacheBlendModeMats.Keys)
            {
                var mat = this._cacheBlendModeMats[key];
                if (mat != null)
                {
                    UnityFactoryHelper.DestroyUnityObject(mat);
                }
            }
            this._cacheBlendModeMats.Clear();
        }
        private Material _GetMaterial(BlendMode blendMode)
        {
            if (blendMode == BlendMode.Normal)
            {
                return (this.parent as UnityTextureAtlasData).texture;
            }
            var blendModeStr = blendMode.ToString();
            if (this._cacheBlendModeMats.ContainsKey(blendModeStr))
            {
                return this._cacheBlendModeMats[blendModeStr];
            }
#if UNITY_EDITOR
            var newMaterial = new Material(Resources.Load<Shader>(SHADER_PATH + SHADER_GRAP));
#else
            var newMaterial = new Material(Resources.Load<Shader>(SHADER_PATH + SHADER_GRAP));
#endif
            var texture = (this.parent as UnityTextureAtlasData).texture.mainTexture;
            newMaterial.name = texture.name + "_" + SHADER_GRAP + "_Mat";
            newMaterial.hideFlags = HideFlags.HideAndDontSave;
            newMaterial.mainTexture = texture;
            this._cacheBlendModeMats.Add(blendModeStr, newMaterial);
            return newMaterial;
        }
        private Material _GetUIMaterial(BlendMode blendMode)
        {
            if (blendMode == BlendMode.Normal)
            {
                return (this.parent as UnityTextureAtlasData).uiTexture;
            }
            var blendModeStr = "UI_" + blendMode.ToString();
            if (this._cacheBlendModeMats.ContainsKey(blendModeStr))
            {
                return this._cacheBlendModeMats[blendModeStr];
            }
#if UNITY_EDITOR
            var newMaterial = new Material(Resources.Load<Shader>(SHADER_PATH + UI_SHADER_GRAP));
#else
            var newMaterial = new Material(Resources.Load<Shader>(SHADER_PATH + UI_SHADER_GRAP));
#endif
            var texture = (this.parent as UnityTextureAtlasData).uiTexture.mainTexture;
            newMaterial.name = texture.name + "_" + SHADER_GRAP + "_Mat";
            newMaterial.hideFlags = HideFlags.HideAndDontSave;
            newMaterial.mainTexture = texture;
            this._cacheBlendModeMats.Add(blendModeStr, newMaterial);
            return newMaterial;
        }
        internal Material GetMaterial(BlendMode blendMode, bool isUGUI = false)
        {
            if (isUGUI)
            {
                return _GetUIMaterial(blendMode);
            }
            else
            {
                return _GetMaterial(blendMode);
            }
        }
        public override void CopyFrom(TextureData value)
        {
            base.CopyFrom(value);
            (value as UnityTextureData)._cacheBlendModeMats = this._cacheBlendModeMats;
        }
    }
}