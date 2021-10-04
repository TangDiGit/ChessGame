--好友验证界面
local ControllerFriendVerify = class("ControllerFriendVerify")

function ControllerFriendVerify:Init()
	self.m_view=UIPackage.CreateObject('hall','friendVerifyView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
		UIManager.Hide('ControllerFriendVerify')
		UIManager.Show('ControllerFriend')
		RefreshTipFriend()
	end)

    --记录列表
	self.m_pursuerList=self.m_view:GetChild('list').asList
	self.m_pursuerList:SetVirtual()
	self.m_pursuerList.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_pursuerData[theIndex+1]
		
		_com:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(_t.headurl)
		_com:GetChild('txtNickName').text=_t.nickname
		_com:GetChild('txtID').text=_t.userid
		_com:GetChild("txtTime").text=_t.creattime

		local _touserid=_t.userid
		--添加
		local _btnAgree=_com:GetChild("btnAgree").asButton
		_btnAgree:RemoveEventListeners()
		_btnAgree.onClick:Add(function ()
			self:_Op({
				touserid=_touserid,
				type=1
			})
		end)
		--拒绝
		local _btnRepulse=_com:GetChild("btnRepulse")
		_btnRepulse:RemoveEventListeners()
		_btnRepulse.onClick:Add(function ()
			self:_Op({
				touserid=_touserid,
				type=3
			})
		end)
		--屏蔽
		local _btnBlock=_com:GetChild("btnBlock")
		_btnBlock:RemoveEventListeners()
		_btnBlock.onClick:Add(function ()
			self:_Op({
				touserid=_touserid,
				type=2
			})
		end)
	end
	--接受服务器数据后设置
	self.m_pursuerList.numItems = 0
	self.m_pursuerData=nil

end
function ControllerFriendVerify:_Op(arg)
	--print(debug.traceback('对追求者进行操作'))
	coroutine.start(Friend_Pursuer_OP,{
		fromuserid=loginSucceedInfo.user_info.userid,
		touserid=arg.touserid,
		type=arg.type,
		callbackSuccess=function (info)
			self:_RequestPursuer()
		end
	})
end
function ControllerFriendVerify:_RequestPursuer()
	--接受服务器数据后设置
	self.m_pursuerList.numItems = 0
	self.m_pursuerData=nil
	coroutine.start(Friend_Pursuer,{
		userid=loginSucceedInfo.user_info.userid,
		callbackSuccess=function (info)
			if info.array then
				local _arr=json.decode(info.array)
				self.m_pursuerData=_arr
				self.m_pursuerList.numItems = #_arr
			end
		end
	})
end
function ControllerFriendVerify:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self:_RequestPursuer()
end

function ControllerFriendVerify:OnHide()
	self.m_view.visible=false
end
return ControllerFriendVerify