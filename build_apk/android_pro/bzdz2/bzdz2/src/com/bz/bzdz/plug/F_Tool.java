package com.bz.bzdz.plug;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;

public class F_Tool {
	//Unity�˵��øú��� �������
    public static void OpenBrowser(Activity activity,String strUrl)
	{
		Intent intent= new Intent();        
	    intent.setAction("android.intent.action.VIEW");    
	    Uri content_url = Uri.parse(strUrl);   
	    intent.setData(content_url);  
	    activity.startActivity(intent);
	}
}
