--添加好友界面
local ControllerFriendAdd = class("ControllerFriendAdd")

function ControllerFriendAdd:Init()
	self.m_view=UIPackage.CreateObject('hall','friendAddView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerFriendAdd')
	end)

    self.m_view:GetChild("btnSearch").onClick:Add(function ()
		print('请求查询好友')
		self.m_view:GetController('c1').selectedIndex=0
		coroutine.start(Friend_Find,{
            userid=self.m_view:GetChild("txtSearch").text,
            callbackSuccess=function (info)
				self.m_view:GetController('c1').selectedIndex=1
				self.m_view:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(info.headurl)
				self.m_view:GetChild('txtNickName').text=info.nickname
				self.m_view:GetChild('txtID').text=info.userid
				--todo 暂无
				self.m_view:GetChild('txtLV').text=info.level
				self.m_view:GetChild('txtCity').text=''
				if utf8.len(info.location)>0 then
					local _data=json.decode(info.location)
					self.m_view:GetChild('txtCity').text=_data.region.._data.city
				end
				self.m_view:GetChild('txtDes').text=info.note
            end
        })
	end)
	self.m_view:GetChild("btnAdd").onClick:Add(function ()
		coroutine.start(Friend_Add,{
			fromuserid=loginSucceedInfo.user_info.userid,
			touserid=self.m_view:GetChild("txtSearch").text,
            callbackSuccess=function (info)
				UIManager.AddPopTip({strTit=info.content})
            end
        });
	end)
end

function ControllerFriendAdd:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_view:GetChild("txtSearch").text=''
	self.m_view:GetController('c1').selectedIndex=0
end

function ControllerFriendAdd:OnHide()
	self.m_view.visible=false
end
return ControllerFriendAdd