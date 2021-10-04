
--控制器德州牛仔: 所有玩家列表视图
local CtrlDZNZ_AllPlayerView = class("CtrlDZNZ_AllPlayerView")

function CtrlDZNZ_AllPlayerView:Init()
	self.m_view=UIPackage.CreateObject('niuzai','niuZaiAllPlayerView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZ_AllPlayerView')
    end)
end

function CtrlDZNZ_AllPlayerView:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
	local userinfos = arg

	self.m_view:GetChild('list').asList.itemRenderer = function (index,itemOBJ)
		local user_info = userinfos[index+1]
		itemOBJ:GetChild('n8').text = user_info.nickname
		itemOBJ:GetChild('n9').text = user_info.score
		-- print(user_info.headurl)
		itemOBJ:GetChild('icon').asLoader.url = HandleWXIcon(user_info.headurl)
	end
    self.m_view:GetChild('list').numItems = #userinfos
end

function CtrlDZNZ_AllPlayerView:OnHide()
	self.m_view.visible = false
end

return CtrlDZNZ_AllPlayerView