--输入密码
local ControllerPW = class("ControllerPW")

function ControllerPW:Init()
	self.m_view=UIPackage.CreateObject('gamehall','joinRoomView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
	self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerPW')
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
				--print('确定密码'.._roomNumber)
				if self.m_data and self.m_data.callback then
					self.m_data.callback(_roomNumber)
					UIManager.Hide('ControllerPW')
				end
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

function ControllerPW:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_txtRoomNumber.text=""
	self.m_numbers={}

	self.m_view:GetChild('n4').text='输入密码'
	self.m_data=arg
end

function ControllerPW:OnHide()
	self.m_view.visible=false
end
return ControllerPW