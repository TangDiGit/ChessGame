﻿
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;
using UnityEditor.SceneManagement;
using System.Text.RegularExpressions;
namespace DragonBones
{
    public class UnityEditor
    {
        [MenuItem("GameObject/DragonBones/Armature Object", false, 10)]
        private static void _CreateArmatureObjectMenuItem()
        {
            _CreateEmptyObject(GetSelectionParentTransform());
        }
        [MenuItem("Assets/Create/DragonBones/Armature Object", true)]
        private static bool _CreateArmatureObjectFromSkeValidateMenuItem()
        {
            return _GetDragonBonesSkePaths().Count > 0;
        }
        [MenuItem("Assets/Create/DragonBones/Armature Object", false, 10)]
        private static void _CreateArmatureObjectFromSkeMenuItem()
        {
            var parentTransform = GetSelectionParentTransform();
            foreach (var dragonBonesJSONPath in _GetDragonBonesSkePaths())
            {
                var armatureComponent = _CreateEmptyObject(parentTransform);
                var dragonBonesJSON = AssetDatabase.LoadMainAssetAtPath(dragonBonesJSONPath) as TextAsset;
                ChangeDragonBonesData(armatureComponent, dragonBonesJSON);
            }
        }
        [MenuItem("GameObject/DragonBones/Armature Object(UGUI)", false, 11)]
        private static void _CreateUGUIArmatureObjectMenuItem()
        {
            var armatureComponent = _CreateEmptyObject(GetSelectionParentTransform());
            armatureComponent.isUGUI = true;
            if (armatureComponent.GetComponentInParent<Canvas>() == null)
            {
                var canvas = GameObject.Find("/Canvas");
                if (canvas)
                {
                    armatureComponent.transform.SetParent(canvas.transform);
                }
            }
            armatureComponent.transform.localScale = Vector2.one * 100.0f;
            armatureComponent.transform.localPosition = Vector3.zero;
        }
        [MenuItem("Assets/Create/DragonBones/Armature Object(UGUI)", true)]
        private static bool _CreateUGUIArmatureObjectFromJSONValidateMenuItem()
        {
            return _GetDragonBonesSkePaths().Count > 0;
        }
        [MenuItem("Assets/Create/DragonBones/Armature Object(UGUI)", false, 11)]
        private static void _CreateUGUIArmatureObjectFromJSOIMenuItem()
        {
            var parentTransform = GetSelectionParentTransform();
            foreach (var dragonBonesJSONPath in _GetDragonBonesSkePaths())
            {
                var armatureComponent = _CreateEmptyObject(parentTransform);
                armatureComponent.isUGUI = true;
                if (armatureComponent.GetComponentInParent<Canvas>() == null)
                {
                    var canvas = GameObject.Find("/Canvas");
                    if (canvas)
                    {
                        armatureComponent.transform.SetParent(canvas.transform);
                    }
                }
                armatureComponent.transform.localScale = Vector2.one * 100.0f;
                armatureComponent.transform.localPosition = Vector3.zero;
                var dragonBonesJSON = AssetDatabase.LoadMainAssetAtPath(dragonBonesJSONPath) as TextAsset;
                ChangeDragonBonesData(armatureComponent, dragonBonesJSON);
            }
        }
        [MenuItem("Assets/Create/DragonBones/Create Unity Data", true)]
        private static bool _CreateUnityDataValidateMenuItem()
        {
            return _GetDragonBonesSkePaths(true).Count > 0;
        }
        [MenuItem("Assets/Create/DragonBones/Create Unity Data", false, 32)]
        private static void _CreateUnityDataMenuItem()
        {
            foreach (var dragonBonesSkePath in _GetDragonBonesSkePaths(true))
            {
                var dragonBonesSke = AssetDatabase.LoadMainAssetAtPath(dragonBonesSkePath) as TextAsset;
                var textureAtlasJSONs = new List<string>();
                GetTextureAtlasConfigs(textureAtlasJSONs, AssetDatabase.GetAssetPath(dragonBonesSke.GetInstanceID()));
                UnityDragonBonesData.TextureAtlas[] textureAtlas = new UnityDragonBonesData.TextureAtlas[textureAtlasJSONs.Count];
                for (int i = 0; i < textureAtlasJSONs.Count; ++i)
                {
                    string path = textureAtlasJSONs[i];
                    UnityDragonBonesData.TextureAtlas ta = new UnityDragonBonesData.TextureAtlas();
                    ta.textureAtlasJSON = AssetDatabase.LoadAssetAtPath<TextAsset>(path);
                    path = path.Substring(0, path.LastIndexOf(".json"));
                    ta.texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path + ".png");
                    ta.material = AssetDatabase.LoadAssetAtPath<Material>(path + "_Mat.mat");
                    ta.uiMaterial = AssetDatabase.LoadAssetAtPath<Material>(path + "_UI_Mat.mat");
                    textureAtlas[i] = ta;
                }
                CreateUnityDragonBonesData(dragonBonesSke, textureAtlas);
            }
        }
        public static UnityDragonBonesData.TextureAtlas[] GetTextureAtlasByJSONs(List<string> textureAtlasJSONs)
        {
            UnityDragonBonesData.TextureAtlas[] textureAtlas = new UnityDragonBonesData.TextureAtlas[textureAtlasJSONs.Count];
            for (int i = 0; i < textureAtlasJSONs.Count; ++i)
            {
                string path = textureAtlasJSONs[i];
                UnityDragonBonesData.TextureAtlas ta = new UnityDragonBonesData.TextureAtlas();
                ta.textureAtlasJSON = AssetDatabase.LoadAssetAtPath<TextAsset>(path);
                path = path.Substring(0, path.LastIndexOf(".json"));
                ta.texture = AssetDatabase.LoadAssetAtPath<Texture2D>(path + ".png");
                ta.material = AssetDatabase.LoadAssetAtPath<Material>(path + "_Mat.mat");
                ta.uiMaterial = AssetDatabase.LoadAssetAtPath<Material>(path + "_UI_Mat.mat");
                textureAtlas[i] = ta;
            }
            return textureAtlas;
        }
        public static bool ChangeDragonBonesData(UnityArmatureComponent _armatureComponent, TextAsset dragonBoneJSON)
        {
            if (dragonBoneJSON != null)
            {
                var textureAtlasJSONs = new List<string>();
                UnityEditor.GetTextureAtlasConfigs(textureAtlasJSONs, AssetDatabase.GetAssetPath(dragonBoneJSON.GetInstanceID()));
                UnityDragonBonesData.TextureAtlas[] textureAtlas = UnityEditor.GetTextureAtlasByJSONs(textureAtlasJSONs);
                UnityDragonBonesData data = UnityEditor.CreateUnityDragonBonesData(dragonBoneJSON, textureAtlas);
                _armatureComponent.unityData = data;
                var dragonBonesData = UnityFactory.factory.LoadData(data, _armatureComponent.isUGUI);
                if (dragonBonesData != null)
                {
                    Undo.RecordObject(_armatureComponent, "Set DragonBones");
                    _armatureComponent.unityData = data;
                    var armatureName = dragonBonesData.armatureNames[0];
                    ChangeArmatureData(_armatureComponent, armatureName, _armatureComponent.unityData.dataName);
                    _armatureComponent.gameObject.name = armatureName;
                    EditorUtility.SetDirty(_armatureComponent);
                    return true;
                }
                else
                {
                    EditorUtility.DisplayDialog("Error", "Could not load dragonBones data.", "OK", null);
                    return false;
                }
            }
            else if (_armatureComponent.unityData != null)
            {
                Undo.RecordObject(_armatureComponent, "Set DragonBones");
                _armatureComponent.unityData = null;
                if (_armatureComponent.armature != null)
                {
                    _armatureComponent.Dispose(false);
                }
                EditorUtility.SetDirty(_armatureComponent);
                return true;
            }
            return false;
        }
        public static void ChangeArmatureData(UnityArmatureComponent _armatureComponent, string armatureName, string dragonBonesName)
        {
            bool isUGUI = _armatureComponent.isUGUI;
            UnityDragonBonesData unityData = null;
            Slot slot = null;
            if (_armatureComponent.armature != null)
            {
                unityData = _armatureComponent.unityData;
                slot = _armatureComponent.armature.parent;
                _armatureComponent.Dispose(false);
                UnityFactory.factory._dragonBones.AdvanceTime(0.0f);
                _armatureComponent.unityData = unityData;
            }
            _armatureComponent.armatureName = armatureName;
            _armatureComponent.isUGUI = isUGUI;
            _armatureComponent = UnityFactory.factory.BuildArmatureComponent(_armatureComponent.armatureName, dragonBonesName, null, _armatureComponent.unityData.dataName, _armatureComponent.gameObject, _armatureComponent.isUGUI);
            if (slot != null)
            {
                slot.childArmature = _armatureComponent.armature;
            }
            _armatureComponent.sortingLayerName = _armatureComponent.sortingLayerName;
            _armatureComponent.sortingOrder = _armatureComponent.sortingOrder;
        }
        public static void ReplaceAnimation(UnityArmatureComponent _armatureComponent, string armatureName)
        {
            _armatureComponent.armatureBaseName = armatureName;
            if (!string.IsNullOrEmpty(armatureName))
            {
                string dragonBonesName = _armatureComponent.unityData.dataName;
                ArmatureData baseDiceArmature = UnityFactory.factory.GetArmatureData(armatureName, dragonBonesName);
                UnityFactory.factory.ReplaceAnimation(_armatureComponent.armature, baseDiceArmature);
            }
        }
        public static UnityEngine.Transform GetSelectionParentTransform()
        {
            var parent = Selection.activeObject as GameObject;
            return parent != null ? parent.transform : null;
        }
        public static void GetTextureAtlasConfigs(List<string> textureAtlasFiles, string filePath, string rawName = null, string suffix = "tex")
        {
            var folder = Directory.GetParent(filePath).ToString();
            var name = rawName != null ? rawName : filePath.Substring(0, filePath.LastIndexOf(".")).Substring(filePath.LastIndexOf("/") + 1);
            if (name.LastIndexOf("_ske") == name.Length - 4)
            {
                name = name.Substring(0, name.LastIndexOf("_ske"));
            }
            int index = 0;
            var textureAtlasName = "";
            var textureAtlasConfigFile = "";
            textureAtlasName = !string.IsNullOrEmpty(name) ? name + (!string.IsNullOrEmpty(suffix) ? "_" + suffix : suffix) : suffix;
            textureAtlasConfigFile = folder + "/" + textureAtlasName + ".json";
            if (File.Exists(textureAtlasConfigFile))
            {
                textureAtlasFiles.Add(textureAtlasConfigFile);
                return;
            }
            while (true)
            {
                textureAtlasName = (!string.IsNullOrEmpty(name) ? name + (!string.IsNullOrEmpty(suffix) ? "_" + suffix : suffix) : suffix) + "_" + (index++);
                textureAtlasConfigFile = folder + "/" + textureAtlasName + ".json";
                if (File.Exists(textureAtlasConfigFile))
                {
                    textureAtlasFiles.Add(textureAtlasConfigFile);
                }
                else if (index > 1)
                {
                    break;
                }
            }
            if (textureAtlasFiles.Count > 0 || rawName != null)
            {
                return;
            }
            GetTextureAtlasConfigs(textureAtlasFiles, filePath, "", suffix);
            if (textureAtlasFiles.Count > 0)
            {
                return;
            }
            index = name.LastIndexOf("_");
            if (index >= 0)
            {
                name = name.Substring(0, index);
                GetTextureAtlasConfigs(textureAtlasFiles, filePath, name, suffix);
                if (textureAtlasFiles.Count > 0)
                {
                    return;
                }
                GetTextureAtlasConfigs(textureAtlasFiles, filePath, name, "");
                if (textureAtlasFiles.Count > 0)
                {
                    return;
                }
            }
            if (suffix != "texture")
            {
                GetTextureAtlasConfigs(textureAtlasFiles, filePath, null, "texture");
            }
        }
        public static UnityDragonBonesData CreateUnityDragonBonesData(TextAsset dragonBonesAsset, UnityDragonBonesData.TextureAtlas[] textureAtlas)
        {
            if (dragonBonesAsset != null)
            {
                bool isDirty = false;
                string path = AssetDatabase.GetAssetPath(dragonBonesAsset);
                path = path.Substring(0, path.Length - 5);
                int index = path.LastIndexOf("_ske");
                if (index > 0)
                {
                    path = path.Substring(0, index);
                }
                string dataPath = path + "_Data.asset";
                Dictionary<string, object> jsonObject = null;
                if (dragonBonesAsset.text.StartsWith("DBDT") || string.IsNullOrEmpty(dragonBonesAsset.text))
                {
                    int headerLength = 0;
                    jsonObject = BinaryDataParser.DeserializeBinaryJsonData(dragonBonesAsset.bytes, out headerLength);
                }
                else
                {
                    jsonObject = Json.Deserialize(dragonBonesAsset.text) as Dictionary<string, object>;
                }
                var dataName = jsonObject.ContainsKey("name") ? jsonObject["name"] as string : "";
                UnityDragonBonesData data = UnityFactory.factory.GetCacheUnityDragonBonesData(dataName);
                if (data == null)
                {
                    data = AssetDatabase.LoadAssetAtPath<UnityDragonBonesData>(dataPath);
                }
                if (data == null)
                {
                    data = UnityDragonBonesData.CreateInstance<UnityDragonBonesData>();
                    data.dataName = dataName;
                    AssetDatabase.CreateAsset(data, dataPath);
                    isDirty = true;
                }
                if (string.IsNullOrEmpty(data.dataName) || !data.dataName.Equals(dataName))
                {
                    data.dataName = dataName;
                    isDirty = true;
                }
                if (data.dragonBonesJSON != dragonBonesAsset)
                {
                    data.dragonBonesJSON = dragonBonesAsset;
                    isDirty = true;
                }
                if (textureAtlas != null && textureAtlas.Length > 0 && textureAtlas[0] != null && textureAtlas[0].texture != null)
                {
                    if (data.textureAtlas == null || data.textureAtlas.Length != textureAtlas.Length)
                    {
                        isDirty = true;
                    }
                    else
                    {
                        for (int i = 0; i < textureAtlas.Length; ++i)
                        {
                            if (textureAtlas[i].material != data.textureAtlas[i].material ||
                                textureAtlas[i].uiMaterial != data.textureAtlas[i].uiMaterial ||
                                textureAtlas[i].texture != data.textureAtlas[i].texture ||
                                textureAtlas[i].textureAtlasJSON != data.textureAtlas[i].textureAtlasJSON
                            )
                            {
                                isDirty = true;
                                break;
                            }
                        }
                    }
                    data.textureAtlas = textureAtlas;
                }
                if (isDirty)
                {
                    AssetDatabase.Refresh();
                    EditorUtility.SetDirty(data);
                }
                UnityFactory.factory.AddCacheUnityDragonBonesData(data);
                AssetDatabase.SaveAssets();
                return data;
            }
            return null;
        }
        private static List<string> _GetDragonBonesSkePaths(bool isCreateUnityData = false)
        {
            var dragonBonesSkePaths = new List<string>();
            foreach (var guid in Selection.assetGUIDs)
            {
                var assetPath = AssetDatabase.GUIDToAssetPath(guid);
                if (assetPath.EndsWith(".json"))
                {
                    var jsonCode = File.ReadAllText(assetPath);
                    if (jsonCode.IndexOf("\"armature\":") > 0)
                    {
                        dragonBonesSkePaths.Add(assetPath);
                    }
                }
                if (assetPath.EndsWith(".bytes"))
                {
                    TextAsset asset = AssetDatabase.LoadAssetAtPath<TextAsset>(assetPath);
                    if (asset && asset.text == "DBDT")
                    {
                        dragonBonesSkePaths.Add(assetPath);
                    }
                }
                else if (!isCreateUnityData && assetPath.EndsWith("_Data.asset"))
                {
                    UnityDragonBonesData data = AssetDatabase.LoadAssetAtPath<UnityDragonBonesData>(assetPath);
                    dragonBonesSkePaths.Add(AssetDatabase.GetAssetPath(data.dragonBonesJSON));
                }
            }
            return dragonBonesSkePaths;
        }
        private static UnityArmatureComponent _CreateEmptyObject(UnityEngine.Transform parentTransform)
        {
            var gameObject = new GameObject("New Armature Object", typeof(UnityArmatureComponent));
            var armatureComponent = gameObject.GetComponent<UnityArmatureComponent>();
            gameObject.transform.SetParent(parentTransform, false);
            EditorUtility.FocusProjectWindow();
            Selection.activeObject = gameObject;
            EditorGUIUtility.PingObject(Selection.activeObject);
            Undo.RegisterCreatedObjectUndo(gameObject, "Create Armature Object");
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
            return armatureComponent;
        }
    }
}