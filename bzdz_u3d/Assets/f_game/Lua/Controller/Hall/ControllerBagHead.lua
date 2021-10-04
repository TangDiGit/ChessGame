--背包界面
local ControllerBagHead = class("ControllerBagHead")

function ControllerBagHead:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

    self.m_view=UIPackage.CreateObject('hall','bagHead').asCom
    self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)

    self.m_slt_id = 0

    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBagHead')
    end)

    -- 用回微信头像
    self.m_view:GetChild("btnWx").onClick:Add(function ()
        if loginSucceedInfo.user_info.faceID > 0 then
            UIManager.Show('ControllerHallTips', { title = "", content = "确定换回微信头像吗？", confirm = function()
                coroutine.start(Person_Update_FaceId, {
                    isHideWaitTip = false,
                    faceID = 0,
                    userid = loginSucceedInfo.user_info.userid,
                    callbackSuccess = function (info)
                        self.m_click_time = Time.time
                        loginSucceedInfo.user_info.faceID = info.param.faceID
                        H_EventDispatcher:dispatchEvent({ name = 'refreshSelfHead'})
                        UIManager.AddPopTip({ strTit = "头像更换成功" })
                    end
                })
            end })
        else
            UIManager.AddPopTip({strTit='当前头像已经是微信头像'})
        end
    end)

    -- 确定
    self.m_view:GetChild("btnY").onClick:Add(function ()
        if self.m_slt_id > 0 then
            if loginSucceedInfo.user_info.faceID == self.m_slt_id then
                UIManager.AddPopTip({strTit='已使用当前头像'})
                return
            end
            if tonumber(loginSucceedInfo.user_info.viptime) > 0 then
                if Time.time - self.m_click_time > 0.3 then
                    coroutine.start(Person_Update_FaceId, {
                        isHideWaitTip = false,
                        faceID = self.m_slt_id,
                        userid = loginSucceedInfo.user_info.userid,
                        callbackSuccess = function (info)
                            self.m_click_time = Time.time
                            loginSucceedInfo.user_info.faceID = info.param.faceID
                            H_EventDispatcher:dispatchEvent({ name = 'refreshSelfHead'})
                            UIManager.AddPopTip({ strTit = "头像更换成功" })
                        end
                    })
                end
            else
                UIManager.AddPopTip({strTit='亲爱的玩家，您不是VIP暂时无法修改头像'})
            end
        else
            UIManager.AddPopTip({strTit='请选择需要更换的头像'})
        end
    end)

    self:InitHead()
end

function ControllerBagHead:InitHead()
    self.m_click_time = 0
    self.m_list = self.m_view:GetChild('list').asList
    self.m_list:SetVirtual()
    self.m_list.itemRenderer = function (theIndex,theGObj)
        local _com = theGObj.asCom
        local _t = self.m_listData[theIndex+1]
        _com.data = _t
        _com:GetChild('icon').asLoader.url = _t.url
    end

    self.m_list.onClickItem:Add(function (context)
        self.m_slt_id = context.data.data.id
        H_EventDispatcher:dispatchEvent({ name = 'previewSelfHead', head_url = HeadIconConfig[self.m_slt_id].url })
    end)

    self.m_listData = HeadIconConfig
    self.m_list.numItems = #HeadIconConfig
end

function ControllerBagHead:Show(arg)
    --保持在前面
    self.m_slt_id = 0
    self.m_click_time = Time.time
    UIManager.normal:AddChild(self.m_viewParent)
    self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()
end

function ControllerBagHead:OnHide()
    self.m_viewParent.visible=false

    H_EventDispatcher:dispatchEvent({ name = 'refreshSelfHead'})
end
return ControllerBagHead