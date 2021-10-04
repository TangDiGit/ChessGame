--设置界面
local ControllerSetting = class("ControllerSetting")

function ControllerSetting:Init()
	self.m_view=UIPackage.CreateObject('hall','settingView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerSetting')
    end)

    self.yinxiao=self.m_view:GetChild("yinxiao").asButton
    self.yinyue=self.m_view:GetChild("yinyue").asButton

    self.jinchang=self.m_view:GetChild("jinchang").asButton

    self.yinxiao.selected=PlayerPrefs.GetFloat("SoundEffect2",100)>0
    self.yinyue.selected=PlayerPrefs.GetFloat("SoundMusic3",80)>0

    self.jinchang.selected=PlayerPrefs.GetInt("jinchangEff",1)>0

    self.yinxiao.onClick:Add(function ()
        PlayerPrefs.SetFloat("SoundEffect2",self.yinxiao.selected and 100 or 0)
        PlayerPrefs.Save()
        F_SoundManager.instance:SetEffVolume(self.yinxiao.selected and 1 or 0)
    end)
    self.yinyue.onClick:Add(function ()
        PlayerPrefs.SetFloat("SoundMusic3",self.yinyue.selected and 80 or 0)
        PlayerPrefs.Save()
        F_SoundManager.instance:SetMusicVolume(self.yinyue.selected and 1*0.8 or 0)
    end)

    self.jinchang.onClick:Add(function ()
        PlayerPrefs.SetInt("jinchangEff",self.jinchang.selected and 1 or 0)
        PlayerPrefs.Save()
        
    end)

    self.m_view:GetChild("btnChangeAccount").onClick:Add(function ()
        print('切换账号')

        UIManager.Show('ControllerLogin')
    end)
    self.m_view:GetChild("btnExitGame").onClick:Add(function ()
        UIManager.Show('ControllerMessageBox',{
            strTit='确定退出?',
            callY=function ()
                print('退出游戏')
                UnityEngine.Application.Quit()
            end,
            callN=function ()
                
            end
        })
    end)
end

function ControllerSetting:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	if arg then
        self.m_view:GetChild('btnChangeAccount').visible=false
        self.m_view:GetChild('btnExitGame').visible=false
    else
        self.m_view:GetChild('btnChangeAccount').visible=true
        self.m_view:GetChild('btnExitGame').visible=true
    end
end

function ControllerSetting:OnHide()
	self.m_view.visible=false
end
return ControllerSetting