package com.bz.bzdz.wxapi;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;

import com.bz.bzdz.AndroidCallUnity;
import com.tencent.mm.opensdk.constants.ConstantsAPI;
import com.tencent.mm.opensdk.modelbase.BaseReq;
import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelmsg.SendAuth;
import com.tencent.mm.opensdk.openapi.IWXAPIEventHandler;

import org.jetbrains.annotations.NotNull;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.IOException;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.Response;

public class WXEntryActivity extends Activity implements IWXAPIEventHandler {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Intent intent = getIntent();
        ApiConstant.wx_api.handleIntent(intent, this);
    }

    @Override
    public void onReq(BaseReq baseReq) {

    }

    @Override
    public void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        ApiConstant.wx_api.handleIntent(intent, this);
    }

    @Override
    public void onResp(BaseResp baseResp) {
        //回调
        if (baseResp.getType() == ConstantsAPI.COMMAND_SENDAUTH) {
            switch (baseResp.errCode) {
                case BaseResp.ErrCode.ERR_OK:
                    String code = ((SendAuth.Resp) baseResp).code;
                    //获取 accesstoken
                    Log.d(ApiConstant.WX_LOGIN_LOG, "微信授权成功");
                    getAccessToken(code);
                    //Toast.makeText(this, "微信授权成功",  Toast.LENGTH_LONG);
                    break;
                case BaseResp.ErrCode.ERR_AUTH_DENIED:
                    //用户拒绝授权
                    //Toast.makeText(this, "用户拒绝授权",  Toast.LENGTH_LONG);
                    Log.d(ApiConstant.WX_LOGIN_LOG, "用户拒绝授权");
                    finish();
                    break;
                case BaseResp.ErrCode.ERR_USER_CANCEL:
                    //用户取消授权
                    //Toast.makeText(this, "用户取消授权",  Toast.LENGTH_LONG);
                    Log.d(ApiConstant.WX_LOGIN_LOG, "用户取消授权");
                    finish();
                    break;
            }
        }
    }

    private void getAccessToken(String code) {
        /*
         *        access_token:接口调用凭证
         *        appid：应用唯一标识，在微信开放平台提交应用审核通过后获得。
         *        secret：应用密钥AppSecret，在微信开放平台提交应用审核通过后获得。
         *        code：填写第一步获取的code参数。
         *        grant_type：填authorization_code。
         */
        OkHttpClient okHttpClient = new OkHttpClient();
        String loginUrl = "https://api.weixin.qq.com/sns/oauth2/access_token" +
                "?appid=" +
                ApiConstant.APP_ID +
                "&secret=" +
                ApiConstant.APP_SECRET +
                "&code=" +
                code +
                "&grant_type=authorization_code";
        Request request = new Request.Builder()
                .url(loginUrl)
                .get()
                .build();
        Call call = okHttpClient.newCall(request);
        call.enqueue(new Callback() {
            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                Log.d(ApiConstant.WX_LOGIN_LOG, "onFailure1：" + call.toString());
            }

            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                String responseInfo = response.body().string();
                String access = null;
                String openid = null;
                //用json去解析返回来的access和token值
                try {
                    JSONObject jsonObject = new JSONObject(responseInfo);
                    access = jsonObject.getString("access_token");
                    openid = jsonObject.getString("openid");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                getUserInfo(access, openid);
            }
        });
    }

    private void getUserInfo(String access, String openid) {
        String getUserInfoUrl = "https://api.weixin.qq.com/sns/userinfo?access_token=" + access + "&openid=" + openid;
        OkHttpClient okHttpClient = new OkHttpClient();
        Request request = new Request.Builder()
                .url(getUserInfoUrl)
                .get()
                .build();
        Call call = okHttpClient.newCall(request);
        call.enqueue(new Callback() {
            @Override
            public void onFailure(@NotNull Call call, @NotNull IOException e) {
                Log.d(ApiConstant.WX_LOGIN_LOG, "onFailure2：" + call.toString());
            }

            @Override
            public void onResponse(@NotNull Call call, @NotNull Response response) throws IOException {
                sendUserInfoUnity(response.body().string());
            }
        });
    }

    private void sendUserInfoUnity(String responseInfo) {
        if (!TextUtils.isEmpty(responseInfo)) {
            AndroidCallUnity.callBackWxLogin(responseInfo);
        }
        finish();
    }
}