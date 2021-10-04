--商城购买记录界面(没用了)
local ControllerShopLog = class("ControllerShopLog")

function ControllerShopLog:Init()
	self.m_view=UIPackage.CreateObject('hall','shopLogView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
    
    self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerShopLog')
	end)

	self.m_list=self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t

		local _goodInfo=Bag_Config[_t.goodsid]
		_com:GetChild('txtDes').text=string.format( "花费%s积分购买【%s】X%s",_t.integral,_goodInfo.name,_t.goodsnumber)
		_com:GetChild('txtTime').text=_t.createtime
	end
	--接受服务器数据后设置
	self.m_list.numItems = 0
	self.m_listData=nil
end

function ControllerShopLog:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_list.numItems = 0
	self.m_listData=nil
	print('请求商品兑换记录')
	coroutine.start(Shop_Log,{
        userid=loginSucceedInfo.user_info.userid,
        callbackSuccess=function (info)
			self.m_listData=info.result
			self.m_list.numItems = #info.result
        end
    })
end

function ControllerShopLog:OnHide()
	self.m_view.visible=false
end
return ControllerShopLog