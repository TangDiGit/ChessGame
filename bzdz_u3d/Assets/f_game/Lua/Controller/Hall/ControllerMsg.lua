--消息榜界面
local ControllerMsg = class("ControllerMsg")

function ControllerMsg:Init()
	self.m_view=UIPackage.CreateObject('hall','msgView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
		UIManager.Hide('ControllerMsg')
		RefreshTipMail()
	end)

	self.m_list=self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t
		
		_com:GetController('c1').selectedIndex=_t.status
		_com:GetChild('txtDes').text=_t.email_title
		_com:GetChild('txtTime').text=_t.createtime

		local _check=_com:GetChild('check').asButton
		if not _t.selected then
			_check.selected=false
		else
			_check.selected=_t.selected
		end
		

		_check:RemoveEventListeners()
		_check.onClick:Add(function (context)
			context:StopPropagation()
			_com.data.selected=_check.selected
		end)
	end
	self.m_list.onClickItem:Add(function (context)
		local _gcom=context.data
		--print(_gcom.data.status)

		_gcom:GetController('c1').selectedIndex=1
		_gcom.data.status=1
		print('请求已读')
		coroutine.start(Mail_Read,{
			userid=loginSucceedInfo.user_info.userid,
			emailid_list={_gcom.data.log_id},
			callbackSuccess=function (info)
				UIManager.Show('ControllerMail',_gcom.data)
			end
		})
		
	end)
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil

	self.m_btnCheckAll=self.m_view:GetChild('checkAll').asButton
	self.m_btnCheckAll.onClick:Add(function ()
		--只显示不修改数据
		local _numChildren=self.m_list.numChildren
		for i=1,_numChildren do
			local _com=self.m_list:GetChildAt(i-1)
			local _check=_com:GetChild('check').asButton
			_check.selected=self.m_btnCheckAll.selected
		end

		for i,v in pairs(self.m_listData) do
			v.selected=self.m_btnCheckAll.selected
		end
	end)

	self.m_view:GetChild("btnReceiveAll").onClick:Add(function ()
		print('请求已读全部')
		--只显示不修改数据
		local _numChildren=self.m_list.numChildren
		for i=1,_numChildren do
			local _com=self.m_list:GetChildAt(i-1)
			local _check=_com:GetChild('check').asButton
			if _check.selected then
				_com:GetController('c1').selectedIndex=1
			end
		end


		local _send_email_id={}
		for i,v in pairs(self.m_listData) do
			if v.selected then
				table.insert(_send_email_id,v.log_id)
				v.status=1
			end
		end

		coroutine.start(Mail_Read,{
			userid=loginSucceedInfo.user_info.userid,
			emailid_list=_send_email_id,
			callbackSuccess=function (info)
				
			end
		})
	end)

	self.m_view:GetChild("btnDeleteAll").onClick:Add(function ()
		print('请求删除全部')
		local _send_email_id={}
		for i,v in pairs(self.m_listData) do
			if v.selected then
				table.insert(_send_email_id,v.log_id)
			end
		end

		coroutine.start(Mail_Del,{
			userid=loginSucceedInfo.user_info.userid,
			emailid_list=_send_email_id,
			callbackSuccess=function (info)
				self:GetMail()
			end
		})
	end)
end

function ControllerMsg:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self:GetMail()
end

function ControllerMsg:GetMail()
	self.m_btnCheckAll.selected=false
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil
	print('请求查询邮件')
	coroutine.start(Mail_Get,{
		userid=loginSucceedInfo.user_info.userid,
		callbackSuccess=function (info)
			local _arr=json.decode(info.array)
			self.m_listData=_arr
			self.m_list.numItems = #_arr
		end
	})
end

function ControllerMsg:OnHide()
	self.m_view.visible=false
end
return ControllerMsg