--个人信息界面
local ControllerUserData = class("ControllerUserData")
--个人简介最大长度
local MaxDes=60
function ControllerUserData:Init()
    self.m_viewParent=UIPackage.CreateObject('hall','leftToRightContent').asCom
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_viewParent.visible=false

	self.m_view=UIPackage.CreateObject('hall','userInfoDataView').asCom
	self.m_viewParent:GetChild('parent'):AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerUserData')
    end)

    --牌局记录
    self.m_view:GetChild("btnRoundRecord").onClick:Add(function ()
        coroutine.start(Game_Data_Get,{
			userid=loginSucceedInfo.user_info.userid,
            callbackSuccess=function (info)
                UIManager.Show('ControllerUserInfoRoundRecord', info)
			end
		})
    end)

    -- 德州牛仔 4
    --self.m_view:GetChild("btnRoundRecord4").onClick:Add(function ()
    --    coroutine.start(Game_Data_Get_With_Type,{
    --        userid = loginSucceedInfo.user_info.userid,
    --        type = 4,
    --        callbackSuccess = function (info)
    --
    --            for i,v in pairs(info.result) do
    --                print(tostring(v))
    --            end
    --            --UIManager.Show('ControllerUserInfoRoundRecord',info)
    --        end
    --    })
    --end)

    -- 百人场 5
    --self.m_view:GetChild("btnRoundRecord5").onClick:Add(function ()
    --    coroutine.start(Game_Data_Get_With_Type,{
    --        userid = loginSucceedInfo.user_info.userid,
    --        type = 5,
    --        callbackSuccess = function (info)
    --            --UIManager.Show('ControllerUserInfoRoundRecord',info)
    --
    --            for i,v in pairs(info.result) do
    --                print(tostring(v))
    --            end
    --        end
    --    })
    --end)
end

function ControllerUserData:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_viewParent)
	self.m_viewParent.visible=true
    self.m_viewParent:GetTransition('t0'):Play()

    local com=nil
    --胜率
    com=self.m_view:GetChild('n16').asCom
    com:GetChild('n17').text='胜率%:'
    com:GetChild('n20').text='0%'
    com:GetChild('n19').asImage.fillAmount=0
    if loginSucceedInfo.user_info.gamecount then
        local _v=tonumber(loginSucceedInfo.user_info.wincounts)/tonumber(loginSucceedInfo.user_info.gamecount)
        _v=string.format('%.2f',_v)
        com:GetChild('n19').asImage.fillAmount=tonumber(_v)
        com:GetChild('n20').text=string.format( "%s",_v*100)..'%'
    end

    --弃牌率
    com=self.m_view:GetChild('n21').asCom
    com:GetChild('n17').text = '摊牌率%:'
    com:GetChild('n20').text = '0%'
    com:GetChild('n19').asImage.fillAmount = 0

    if loginSucceedInfo.user_info.gamecount then
        if loginSucceedInfo.user_info.dropcardcount then
            local _v = 1 - tonumber(loginSucceedInfo.user_info.dropcardcount)/tonumber(loginSucceedInfo.user_info.gamecount)
            _v = string.format('%.2f', _v)
            com:GetChild('n19').asImage.fillAmount = tonumber(_v)
            com:GetChild('n20').text = string.format( "%s",_v * 100)..'%'
        end
    end

    --总局数
    com=self.m_view:GetChild('n29').asCom
    com:GetChild('n30').text='总局数'
    com:GetChild('n31').text=0
    if loginSucceedInfo.user_info.gamecount then
        com:GetChild('n31').text=tonumber(loginSucceedInfo.user_info.gamecount)
    end

    --最大赢取
    com=self.m_view:GetChild('n32').asCom
    com:GetChild('n30').text='最大赢取'
    com:GetChild('n31').text=0
    if loginSucceedInfo.user_info.winmaxgold  then
        com:GetChild('n31').text=tonumber(loginSucceedInfo.user_info.winmaxgold)
    end

    --最大手牌
    if loginSucceedInfo.user_info.maxcards then
        local _strs=lua_string_split(loginSucceedInfo.user_info.maxcards,'#')
        for i=1,5 do
            UIManager.SetPoker(self.m_view:GetChild('n22'):GetChild('card'..i),tonumber(_strs[i]))
        end
    else
        for i=1,5 do
            UIManager.SetPoker(self.m_view:GetChild('n22'):GetChild('card'..i),0)
        end  
    end
end

function ControllerUserData:OnHide()
	self.m_viewParent.visible=false
end
return ControllerUserData