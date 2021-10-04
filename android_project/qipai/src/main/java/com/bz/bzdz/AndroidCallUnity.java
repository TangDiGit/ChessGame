package com.bz.bzdz;

import android.util.Log;

import com.bz.bzdz.wxapi.ApiConstant;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.unity3d.player.UnityPlayer;
import com.xinstall.XInstall;
import com.xinstall.listener.XInstallAdapter;
import com.xinstall.listener.XWakeUpAdapter;
import com.xinstall.model.XAppData;

public class AndroidCallUnity {

    /*请求微信登录*/
    public static void requestWxLogin() {
        if (!ApiConstant.wx_api.isWXAppInstalled()) {
            Log.d(ApiConstant.WX_LOGIN_LOG, "您的设备未安装微信客户端");
        } else {
            final SendAuth.Req req = new SendAuth.Req();
            //应用授权作用域，如获取用户个人信息则填写 snsapi_userinfo
            req.scope = "snsapi_userinfo";
            //用于保持请求和回调的状态，授权请求后原样带回给第三方。
            //该参数可用于防止 csrf 攻击（跨站请求伪造攻击），
            //建议第三方带上该参数，可设置为简单的随机数加 session 进行校验
            req.state = "wechat_sdk_demo";
            ApiConstant.wx_api.sendReq(req);
        }
    }

    /*安卓回调Unity微信登录*/
    public static void callBackWxLogin(String str) {
        UnityPlayer.UnitySendMessage(ApiConstant.UNITY_GAME_OBJ, "OnCallBackWxLogin", str);
    }

    /*安卓回调XInstall唤醒*/
    public static void callBackXInstallWake(String str) {
        UnityPlayer.UnitySendMessage(ApiConstant.UNITY_GAME_OBJ, "OnCallBackXInstallWake", str);
    }

    /*安卓回调XInstall安装*/
    public static void callBackXInstallInstall(String str) {
        UnityPlayer.UnitySendMessage(ApiConstant.UNITY_GAME_OBJ, "OnCallBackXInstallInstall", str);
    }

    public void requestXInstallInstall() {
        XInstall.getInstallParam(installAdapter);
    }

    public void requestXInstallAwake() {
        //XInstall.getWakeUpParam(getApplication, getIntent(), wakeUpAdapter);
    }

    //获取渠道数据
    //String channelCode = xAppData.getChannelCode();
    //获取数据
    //Map<String, String> data = xAppData.getExtraData();
    //通过链接后面携带的参数或者通过webSdk初始化传入的data值。
    //String uo = data.get("uo");
    //webSdk初始，在buttonId里面定义的按钮点击携带数据
    //String co = data.get("co");
    //获取时间戳
    //String timeSpan = xAppData.getTimeSpan();

    XWakeUpAdapter wakeUpAdapter = new XWakeUpAdapter() {
        @Override
        public void onWakeUp(XAppData xAppData) {
            String result = xAppData.toJsonObject().toString();
            callBackXInstallWake(result);
        }
    };

    XInstallAdapter installAdapter = new XInstallAdapter() {
        @Override
        public void onInstall(XAppData xAppData) {
            String result = xAppData.toJsonObject().toString();
            callBackXInstallInstall(result);
        }
    };
}
