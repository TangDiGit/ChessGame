--好友送礼物界面
local ControllerFriendPresented = class("ControllerFriendPresented")

function ControllerFriendPresented:Init()
	self.m_view=UIPackage.CreateObject('hall','friendPresentedView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerFriendPresented')
	end)

	self.m_view:GetChild("btnY").onClick:Add(function ()
		if self.giftInfo then
			--print('请求赠送礼物')
			coroutine.start(Friend_Gift,{
				fromuserid=loginSucceedInfo.user_info.userid,
				touserid=self.m_touserid,
				gifttype=self.giftInfo.selectItem.type,
				number=self.giftInfo.giftCount,
				callbackSuccess=function (info)
					UIManager.AddPopTip({strTit=info.content})
					self.giftInfo=nil
					self.m_c.selectedIndex=0
					self.m_view:GetChild('txtDes').text=''
				end
			})
		end
	end)

	self.m_view:GetChild("btnAdd").onClick:Add(function ()
        UIManager.Show('ControllerBag',{isWithFriendOpen=true})
	end)

	self.m_c=self.m_view:GetController('c1')

	H_EventDispatcher:addEventListener('refreshFriendGift',function (arg)
		self.giftInfo = arg
		if arg.giftCount > 0 then
			self.m_c.selectedIndex = 1
			self.m_view:GetChild('txtDes').text = arg.selectItem.des
			self.m_view:GetChild('icon').asLoader.url = arg.selectItem.url
			self.m_view:GetChild('txtCount').text = string.format('[color=#%s]数量：%s[/color]', arg.selectItem.is_frame and "FFFFFF" or "550103", arg.giftCount)
		else 
			self.m_c.selectedIndex=0
		end
    end)
end

function ControllerFriendPresented:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.giftInfo=nil
	self.m_touserid=arg.userid
	self.m_view:GetChild("txtNickName").text=arg.nickname
	self.m_view:GetChild("txtID").text='ID:'..arg.userid
	self.m_view:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(arg.headurl)

	self.m_c.selectedIndex=0
	self.m_view:GetChild('txtDes').text=''
end

function ControllerFriendPresented:OnHide()
	self.m_view.visible=false
end
return ControllerFriendPresented