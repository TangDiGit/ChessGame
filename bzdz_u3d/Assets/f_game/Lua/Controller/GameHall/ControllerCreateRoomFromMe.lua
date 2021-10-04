--查看我创建的房间界面
local ControllerCreateRoomFromMe = class("ControllerCreateRoomFromMe")

function ControllerCreateRoomFromMe:Init()
	self.m_view=UIPackage.CreateObject('gamehall','createRoomFromMeView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
	self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerCreateRoomFromMe')
	end)
    
    self.m_privateRoomList=self.m_view:GetChild('list').asList
	self.m_privateRoomList:SetVirtual()
	self.m_privateRoomList.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		
		local _t=self.m_privateRoomData[theIndex+1]
		_com.data=_t
		local _tableconf=_t
		
		_com:GetChild("txtRoomNameId").text=string.format( "%s(%s)",_tableconf.tablename,_tableconf.tableid)
		_com:GetChild("txtRoomPW").text=string.format( "密码:%s",_tableconf.passwd)
		_com:GetChild("txtBlinds").text=string.format( "%s/%s",formatVal(_tableconf.xiaomangbet),formatVal(_tableconf.xiaomangbet*2))
		_com:GetChild("txtBringLimit").text=string.format( "%s/%s",formatVal(_tableconf.bringmingold), formatVal(_tableconf.bringmaxgold))

		_com:GetChild("n10").visible=_tableconf.frontbet>0
		_com:GetChild("txtMustBet").visible=_tableconf.frontbet>0
		_com:GetChild("txtMustBet").text=formatVal(_tableconf.frontbet)

		_com:GetChild("txtTime").text=string.format("%s分",_tableconf.lefttime)

		--人数
		local maxPerson=_tableconf.person
		local person=_com:GetChild('n13')
		person.width=_tableconf.online_person/maxPerson*367
		_com:GetChild("txtPlayerCount").text=string.format("%s/%s",_tableconf.online_person,maxPerson)
		
	end
	self.m_privateRoomList.onClickItem:Add(function (context)
		local _gcom=context.data
		print(_gcom.data.tableid)

		local _tableid=_gcom.data.tableid
		sendTablePwdValidate(_tableid,tonumber(_gcom.data.passwd))

		--[[UIManager.Show('ControllerPW',{callback=function (arg)
			UIManager.Show('ControllerWaitTip')
			--sendEnterGameRequst(_tableid,arg)
			sendTablePwdValidate(_tableid,arg)
		end})]]

		roomCfg=_gcom.data
	end)
	
	self.m_privateRoomList.numItems = 0
	self.m_privateRoomData=nil
end


function ControllerCreateRoomFromMe:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	--接受服务器数据后设置
	self.m_privateRoomData=arg.tableconfig
	self.m_privateRoomList.numItems = #arg.tableconfig
end

function ControllerCreateRoomFromMe:OnHide()
	self.m_view.visible=false
end
return ControllerCreateRoomFromMe