--分享游戏界面
local ControllerShare = class("ControllerShare")

function ControllerShare:Init()
	self.m_view=UIPackage.CreateObject('share','shareView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerShare')
    end)

    self.m_view:GetChild("btnWX").onClick:Add(function ()
		UIManager.AddPopTip({strTit = '该功能暂不可用'})
		--print('点击分享游戏')
		--if loginSucceedInfo.user_info.QRCodeLoaderUrl then
		--	H_EventDispatcher:dispatchEvent({name='shareQRCode',mtype=0})
		--end
    end)

	self.m_view:GetChild("btnPYQ").onClick:Add(function ()
		UIManager.AddPopTip({strTit = '该功能暂不可用'})
		--print('点击分享游戏')
		--if loginSucceedInfo.user_info.QRCodeLoaderUrl then
		--	H_EventDispatcher:dispatchEvent({name='shareQRCode',mtype=1})
		--end
	end)
	
	local _u3dOBJ=UnityEngine.GameObject.Instantiate(UIManager.GetPrefab('jueseOBJ'))
    local _gw=FairyGUI.GoWrapper(_u3dOBJ)
	self.m_view:GetChild('spineBG').asGraph:SetNativeObject(_gw)
	_u3dOBJ.transform.localScale =Vector3.New(100,100,100)

	UIManager.SetDragonBonesAniObjPos2('18888OBJ',self.m_view:GetChild("n19"):GetChild("n1"),Vector3.New(150,150,150))

	UIManager.SetDragonBonesAniObjPos2('fengxiangOBJ',self.m_view:GetChild("btnPYQ"):GetChild("n21"):GetChild("n1"),Vector3.New(150,150,150))
	
	UIManager.SetDragonBonesAniObjPos2('weixinhaoyouOBJ',self.m_view:GetChild("btnWX"):GetChild("n21"):GetChild("n1"),Vector3.New(150,150,150))
	
	--设置spine位置
	--[[self.m_view:GetChild("btnWX"):GetChild("n21").draggable = true
    Timer.New(function ()
        local _xy=GRoot.inst:GlobalToLocal(self.m_view:GetChild("btnWX"):GetChild("n21").xy)
        print(_xy.x..'/'.._xy.y)
    end,1,-1):Start()]]
end

function ControllerShare:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

end

function ControllerShare:OnHide()
	self.m_view.visible=false
end
return ControllerShare