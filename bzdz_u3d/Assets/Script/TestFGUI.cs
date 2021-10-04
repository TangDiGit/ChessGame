
using UnityEngine;
using System.Collections;
using FairyGUI;
public class TestFGUI: MonoBehaviour
{
    string touchTargetName = "";
    void Update()
    {
        if (GRoot.inst.touchTarget!=null&& touchTargetName!= GRoot.inst.touchTarget.name)
        {
            touchTargetName = GRoot.inst.touchTarget.name;
            UnityEngine.Debug.Log(GRoot.inst.touchTarget.name);
        }
        
    }
}