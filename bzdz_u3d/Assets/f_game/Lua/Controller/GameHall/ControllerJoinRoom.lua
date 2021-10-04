--加入房间界面
local ControllerJoinRoom = class("ControllerJoinRoom")

function ControllerJoinRoom:Init()
	self.m_view=UIPackage.CreateObject('gamehall','joinRoomView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
	self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerJoinRoom')
	end)
    
	self.m_txtRoomNumber=self.m_view:GetChild("txtRoomNumber")
	self.m_numbers={}
	for i=0,9 do
		local index=i
		self.m_view:GetChild("fbtn"..i).onClick:Add(function ()
			if #self.m_numbers<6 then
				self.m_txtRoomNumber.text=self.m_txtRoomNumber.text..index
				table.insert(self.m_numbers,index)
			end
			
			if #self.m_numbers>=6 then
				local _roomNumber=tonumber(table.concat(self.m_numbers,"")) 
				print('请求进入房间'.._roomNumber)
				UIManager.Hide('ControllerJoinRoom')
				UIManager.Show('ControllerPW',{callback=function (arg)
					UIManager.Show('ControllerWaitTip')
					sendTablePwdValidate(_roomNumber,arg)
				end})
			end
		end)
	end
	self.m_view:GetChild('fbtnDel').onClick:Add(function ()
		if #self.m_numbers>0 then
			table.remove(self.m_numbers)
			self.m_txtRoomNumber.text=table.concat(self.m_numbers,"")
		end
	end)
	self.m_view:GetChild('fbtnRe').onClick:Add(function ()
		self.m_txtRoomNumber.text=""
		self.m_numbers={}
	end)
end

function ControllerJoinRoom:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_txtRoomNumber.text=""
	self.m_numbers={}
	self.m_view:GetChild('n4').text='加入房间'
end

function ControllerJoinRoom:OnHide()
	self.m_view.visible=false
end
return ControllerJoinRoom