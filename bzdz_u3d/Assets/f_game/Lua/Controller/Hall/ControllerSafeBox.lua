--保险箱界面
local ControllerSafeBox = class("ControllerSafeBox")

function ControllerSafeBox:Init()
	self.m_view=UIPackage.CreateObject('hall','safeBoxView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerSafeBox')
	end)

	self.m_txtAccessCoin=self.m_view:GetChild("txtAccessCoin")
	self.m_txtAccessCoinWan=self.m_view:GetChild("txtAccessCoinWan")
	

	self.m_txtTransferCoin=self.m_view:GetChild("txtTransferCoin")
	self.m_txtTransferCoinWan=self.m_view:GetChild("txtTransferCoinWan")
	
	self.m_numbers={}
	for i=0,9 do
		local index=i
		self.m_view:GetChild("fbtn"..i).onClick:Add(function ()
			if index==0 then
				if #self.m_numbers<=0 then
					print('第一个数不能为零')
					return
				end
			end

			self.m_txtAccessCoin.text=self.m_txtAccessCoin.text..index
			self.m_txtTransferCoin.text=self.m_txtTransferCoin.text..index

			table.insert(self.m_numbers,index)
			self.m_txtAccessCoinWan.visible=#self.m_numbers>0
			self.m_txtTransferCoinWan.visible=#self.m_numbers>0
		end)
	end
	self.m_view:GetChild('fbtnDel').onClick:Add(function ()
		if #self.m_numbers>0 then
			table.remove(self.m_numbers)
			self.m_txtAccessCoin.text=table.concat(self.m_numbers,"")
			self.m_txtTransferCoin.text=table.concat(self.m_numbers,"")
		end
		self.m_txtAccessCoinWan.visible=#self.m_numbers>0
		self.m_txtTransferCoinWan.visible=#self.m_numbers>0
	end)
	local _c1=self.m_view:GetController('c1')
	self.m_view:GetChild('fbtnAll').onClick:Add(function ()
		print('全部')
		if self.externalCoin==nil or self.safeBoxCoin==nil then
			return
		end
		
		local _v=0
		--取出
		if _c1.selectedIndex==0 then
			_v=self.safeBoxCoin
		elseif _c1.selectedIndex==1 then
			--存入
				_v=self.externalCoin
		elseif _c1.selectedIndex==2 then
			--转账
			_v=self.safeBoxCoin			
		end

		if _v<10000 then
			self.m_txtAccessCoin.text=0
			self.m_txtTransferCoin.text=0

			self.m_txtAccessCoinWan.visible=false
			self.m_txtTransferCoinWan.visible=false

			if _v>0 then
				UIManager.AddPopTip({strTit='操作金额不能低于1万'})
			end
			
		else
			local _num=math.floor( _v/10000 ) 

			self.m_numbers={}
			local _strNumber=tostring(_num)
			for i = 1, string.len(_strNumber) do
				local _s=string.sub(_strNumber,i,i)
				--print(_s)
				table.insert(self.m_numbers,_s)
			end
			self.m_txtAccessCoin.text=table.concat(self.m_numbers,"")
			self.m_txtTransferCoin.text=table.concat(self.m_numbers,"")

			self.m_txtAccessCoinWan.visible=#self.m_numbers>0
			self.m_txtTransferCoinWan.visible=#self.m_numbers>0
		end		
	end)

	
	_c1.onChanged:Add(function ()
		print('index:'.._c1.selectedIndex)
		self:ClearNumber()
	end)
	self.m_view:GetChild('n27').onClick:Add(function ()
		self:RequestRecord()
	end)

	--携带
	self.m_txtExternalCoin=self.m_view:GetChild("txtExternalCoin")
	--存款
	self.m_txtSafeBoxCoin=self.m_view:GetChild("txtSafeBoxCoin")

	self.m_view:GetChild('btnY').onClick:Add(function ()
		if _c1.selectedIndex==0 then
			print('请求取出')
			if utf8.len(self.m_txtAccessCoin.text)<=0  then
				return
			end
			local _v=tonumber(self.m_txtAccessCoin.text)
			if _v<=0 then
				UIManager.AddPopTip({strTit='操作金额不能低于1万'})
				return
			end
			coroutine.start(SafeBox_Deposit_Pull,{
				userid=loginSucceedInfo.user_info.userid,
				gold=_v*10000,
				callbackSuccess=function (info)
					self:RefreshGold(info)
					UIManager.AddPopTip({strTit=info.content})
				end
			});	
			self:ClearNumber()
		elseif _c1.selectedIndex==1 then
			print('请求存入')
			if utf8.len(self.m_txtAccessCoin.text)<=0  then
				return
			end
			local _v=tonumber(self.m_txtAccessCoin.text)
			if _v<=0 then
				UIManager.AddPopTip({strTit='操作金额不能低于1万'})
				return
			end
			coroutine.start(SafeBox_Deposit_Push,{
				userid=loginSucceedInfo.user_info.userid,
				gold=_v*10000,
				callbackSuccess=function (info)
					self:RefreshGold(info)
					UIManager.AddPopTip({strTit=info.content})
				end
			});
			self:ClearNumber()
		elseif _c1.selectedIndex==2 then
			print('请求转账')
			if utf8.len(self.m_txtTransferCoin.text)<=0  then
				return
			end
			local _v=tonumber(self.m_txtTransferCoin.text)
			if _v<=0 then
				UIManager.AddPopTip({strTit='操作金额不能低于1万'})
				return
			end
			print('请求查询好友')
			
			local _dUserid=self.m_view:GetChild('txtTransferID').text
			coroutine.start(Friend_Find,{
            	userid=_dUserid,
				callbackSuccess=function (info)
					UIManager.Show('ControllerSafeBoxTransferCoinMsg',{
						state=1,
						headurl=info.headurl,
						nickname=info.nickname,
						userid=info.userid,
						val=_v,
						dUserid=_dUserid,
						callback=function (info)
							self:RefreshGold(info)
							self:ClearNumber()
						end,
					})
				end,
				callbackFailure=function (info)
					UIManager.Show('ControllerSafeBoxTransferCoinMsg',{
						state=0
					})
				end
        	});
		end
	end)

	--记录列表
	self.m_recordList=self.m_view:GetChild('listLog').asList
	self.m_recordList:SetVirtual()
	self.m_recordList.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_recordData[theIndex+1]
		_com:GetChild("txtNickName").text=_t.nickname
		_com:GetChild("txtID").text=_t.userid
		_com:GetChild("txtTime").text=_t.createtime
		_com:GetChild("txtAccessType").text=_t.operate==1 and '转出' or '转入'
		_com:GetChild("txtCoin").text=formatVal(_t.gold)

		
		_com:GetChild('head'):GetChild('icon').asLoader.url=HandleWXIcon(_t.headurl)
	end
	--接受服务器数据后设置
	self.m_recordList.numItems = 0
	self.m_recordData=nil
end

function ControllerSafeBox:RequestRecord()
	print('查询转账记录')
	--接受服务器数据后设置
	self.m_recordList.numItems = 0
	self.m_recordData=nil
	--coroutine.start(SafeBox_Deposit_Log,{
	--	userid=loginSucceedInfo.user_info.userid,
	--	indexStart=0,
	--	indexEnd=25,--默认查询25条记录
	--	callbackSuccess=function (info)
	--		local _arr=json.decode(info.array)
	--		self.m_recordData=_arr
	--		self.m_recordList.numItems = #_arr
	--	end
	--});
end

function ControllerSafeBox:ClearNumber()
	self.m_txtAccessCoin.text=""
	self.m_txtTransferCoin.text=""
	self.m_numbers={}
	self.m_txtAccessCoinWan.visible=#self.m_numbers>0
	self.m_txtTransferCoinWan.visible=#self.m_numbers>0

	self.m_view:GetChild('txtTransferID').text=''
end
function ControllerSafeBox:RefreshGold(info)
	self.m_txtExternalCoin.text=info.gold
	self.m_txtSafeBoxCoin.text=info.strongboxgold

	self.externalCoin=tonumber(info.gold)
	self.safeBoxCoin=tonumber(info.strongboxgold)

	setSelfMoney(tonumber(info.gold))

	
end
function ControllerSafeBox:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_view:GetController('c1').selectedIndex=0
	self:ClearNumber()
	self.m_txtExternalCoin.text=''
	self.m_txtSafeBoxCoin.text=''
	self.m_view:GetChild('txtTransferID').text=''
	self.m_recordList.numItems = 0
	self.m_recordData=nil

	coroutine.start(SafeBox_Deposit_Check,{
		userid=loginSucceedInfo.user_info.userid,
		callbackSuccess=function (info)
			self:RefreshGold(info)
		end
	});
end

function ControllerSafeBox:OnHide()
	self.m_view.visible=false
end
return ControllerSafeBox