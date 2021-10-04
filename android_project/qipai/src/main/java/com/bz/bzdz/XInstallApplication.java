package com.bz.bzdz;

import android.app.ActivityManager;
import android.app.Application;
import android.content.Context;

import com.xinstall.XInstall;

public class XInstallApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        if (isMainProcess()) {
            XInstall.init(this);
            XInstall.setDebug(true);
        }
    }

    private boolean isMainProcess() {
        int pid = android.os.Process.myPid();
        ActivityManager activityManager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo appProcess : activityManager.getRunningAppProcesses()) {
            if (appProcess.pid == pid) {
                return getApplicationInfo().packageName.equals(appProcess.processName);
            }
        }
        return false;
    }
}
