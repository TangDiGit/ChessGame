using System;
using System.Collections.Generic;
using FairyGUI;
using UnityEngine;

/// <summary>
/// UIPackage.AddPackage("UI/Extension");
///	UIObjectFactory.SetPackageItemExtension("ui://Extension/mailItem", typeof(MailItem));
///	MailItem item = (MailItem)_list.AddItemFromPool();
/// </summary>
public class F_ExtensionCard : GButton
{

    GObject _back;
    GObject _front;

    public override void ConstructFromXML(FairyGUI.Utils.XML xml)
    {
        base.ConstructFromXML(xml);

        _back = GetChild("n10");
        _front = GetChild("n0");


        _front.displayObject.perspective = true;
        _back.displayObject.perspective = true;

    }

    /// <summary>
    /// 转牌显示
    /// </summary>
    public void Turn()
    {

        _front.visible = false;
        _back.visible = true;
        _back.rotationY = 0;
        _front.rotationY = -180;

        LeanTween.cancel(this.displayObject.gameObject);
        //不使用ltdescr来暂停动画.有bug
        LeanTween.value(this.displayObject.gameObject, (x) =>
        {

            _back.rotationY = x;
            _front.rotationY = -180 + x;
            if (x > 90)
            {
                _front.visible = true;
                _back.visible = false;
            }
        }, 0, 180, 0.8f).setEaseOutQuad();

    }
}
