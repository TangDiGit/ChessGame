--显示邮件详情界面
local ControllerMail = class("ControllerMail")

function ControllerMail:Init()
	self.m_view=UIPackage.CreateObject('hall','mailView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerMail')
        UIManager.Show('ControllerMsg')
	end)

    self.m_view:GetChild("btnY").onClick:Add(function ()
        print('请求删除')
        coroutine.start(Mail_Del,{
            userid=loginSucceedInfo.user_info.userid,
            emailid_list={self.m_data.log_id},
            callbackSuccess=function (info)
                UIManager.Hide('ControllerMail')
                UIManager.Show('ControllerMsg')
            end
        })
	end)
end

function ControllerMail:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

    self.m_view:GetChild('txtDes').text=arg.email_msg
    self.m_data=arg
end

function ControllerMail:OnHide()
	self.m_view.visible=false
end
return ControllerMail