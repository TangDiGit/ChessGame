package com.bz.bzdz.plug;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

public class F_Tool {
	//Unity端调用该函数 打开浏览器
    public static void OpenBrowser(Activity activity,String strUrl)
	{
		Intent intent= new Intent();        
	    intent.setAction("android.intent.action.VIEW");    
	    Uri content_url = Uri.parse(strUrl);   
	    intent.setData(content_url);  
	    activity.startActivity(intent);
	}
}
