
﻿using UnityEngine;
namespace DragonBones
{
    [System.Serializable]
    public class UnityDragonBonesData : ScriptableObject
    {
        [System.Serializable]
        public class TextureAtlas
        {
            public TextAsset textureAtlasJSON; 
            public Texture2D texture;
            public Material material;
            public Material uiMaterial;
        }
        public string dataName;
        public TextAsset dragonBonesJSON;
        public TextureAtlas[] textureAtlas;
        
        public void RemoveFromFactory(bool disposeData =true)
        {
            UnityFactory.factory.RemoveDragonBonesData(dataName, disposeData);
            if(textureAtlas != null)
            {
                foreach(TextureAtlas ta in textureAtlas)
                {
                    if(ta != null && ta.texture != null)
                    {
                        UnityFactory.factory.RemoveTextureAtlasData(ta.texture.name,disposeData);
                    }
                }
            }
        }
    }
}
