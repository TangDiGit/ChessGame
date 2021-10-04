--排行榜界面
local ControllerRanking2 = class("ControllerRanking2")

function ControllerRanking2:Init()
	self.m_view = UIPackage.CreateObject('hall','rankingView2').asCom
	UIManager.normal:AddChild(self.m_view)

	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

	self.m_controllerType = self.m_view:GetController("c1")

	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerRanking2')
    end)

	self.m_view:GetChild("btn_caifu").onClick:Add(function ()
		self:GetRankingInfo(1)
	end)

	self.m_view:GetChild("btn_gonghui").onClick:Add(function ()
		self:GetRankingInfo(2)
	end)

	self.m_list = self.m_view:GetChild('list').asList
	self.m_list:SetVirtual()
	self.m_list.itemRenderer = function (theIndex,theGObj)
		local _com=theGObj.asCom
		local _t=self.m_listData[theIndex+1]
		_com.data=_t
		local i = theIndex+1
		if i<4 then
			_com:GetController('c1').selectedIndex=i-1
		else
			_com:GetController('c1').selectedIndex=3
			_com:GetChild('4').text=i
		end
		_com:GetChild('icon').asLoader.url = GetPlayerHeadUrl(_t.headurl, _t.faceID)
		_com:GetChild('txtNickName').text=_t.nickname
		_com:GetChild('txtMoney').text=formatVal(tonumber(_t.gold))
	end

	--接受服务器数据后设置
	self.m_list.numItems = 0
    self.m_listData = nil

	self.m_click_time = Time.time - 1.1
	self:GetRankingInfo(1)

    UIManager.SetDragonBonesAniObjPos2('sgj_hall_npc_OBJ',self.m_view:GetChild("n30"), Vector3.New(100,100,100))
end

function ControllerRanking2:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
end

function ControllerRanking2:GetRankingInfo(type)
	if Time.time - self.m_click_time > 0.3 then
		self.m_click_time = Time.time
		coroutine.start(Ranking_Get, {
			userid = loginSucceedInfo.user_info.userid,
			operatetype = type,
			callbackSuccess = function(info)
				local _array = json.decode(info.array)
				if _array then
					self.m_listData = _array
					self.m_list.numItems = #_array

					-- 大厅里面刷新用
					if self.m_controllerType.selectedIndex == 0 then
						UIManager.GetController('ControllerHall'):ShowRanking(_array)
					end
				end
			end
		})
	else
		UIManager.AddPopTip({strTit='太累了，休息一下吧'})
	end
end

function ControllerRanking2:OnHide()
	self.m_view.visible = false
end

return ControllerRanking2