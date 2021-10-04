package com.bz.bzdz;

import android.content.Intent;
import android.os.Bundle;

import com.bz.bzdz.wxapi.ApiConstant;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;
import com.xinstall.XInstall;
import com.xinstall.listener.XInstallAdapter;
import com.xinstall.listener.XWakeUpAdapter;
import com.xinstall.model.XAppData;

public class XInstallActivity extends UnityPlayerActivity {

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
            AndroidCallUnity.callBackXInstallWake(result);
        }
    };

    XInstallAdapter installAdapter = new XInstallAdapter() {
        @Override
        public void onInstall(XAppData xAppData) {
            String result = xAppData.toJsonObject().toString();
            AndroidCallUnity.callBackXInstallInstall(result);
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        XInstall.getWakeUpParam(this, getIntent(), wakeUpAdapter);

        // 通过WXAPIFactory工厂，获取IWXAPI的实例
        ApiConstant.wx_api = WXAPIFactory.createWXAPI(this, ApiConstant.APP_ID, true);
        // 将应用的appId注册到微信
        ApiConstant.wx_api.registerApp(ApiConstant.APP_ID);
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);

        XInstall.getWakeUpParam(this, intent, wakeUpAdapter);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        wakeUpAdapter = null;
        installAdapter = null;
    }
}
