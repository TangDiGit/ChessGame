--控制器德州牛仔: 走势数据
local CtrlDZNZ_DataView = class("CtrlDZNZ_DataView")
local this = CtrlDZNZ_DataView
local m_jinGangList
local m_jinGangData

local mView = nil

require('Controller/DeZhouNiuZai/CtrlDZNZ_Data')

function CtrlDZNZ_DataView:Init()
	self.m_view = UIPackage.CreateObject('niuzai','niuZaiDataView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false

	self.m_slt_ctrl = self.m_view:GetController('c1')

	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('CtrlDZNZ_DataView')
	end)
	
	--self.m_view:GetChild("tag1").onClick:Add(function ()
	--
	--end)
	
	self.m_view:GetChild("tag2").onClick:Add(function ()
        this:UpdateHandCards()
	end)
	
	self.m_view:GetChild("tag3").onClick:Add(function ()
        this:UpdateGameCards()
    end)

	self.m_view:GetChild("tag4").onClick:Add(function ()
		this:UpdateJinGang()
	end)

    mView = self.m_view

	this:InitJinGang()

	H_EventDispatcher:addEventListener('updateNiuZaiData',function (arg)
		if self.m_view.visible then
			click_DZNZ_Data()
		end
	end)
end

function CtrlDZNZ_DataView:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
	--self.m_slt_ctrl.selectedIndex = 0
	this:UpdateTodayWinLoser()
	this:UpdateToDayTrend()
end

function CtrlDZNZ_DataView:OnHide()
	self.m_view.visible = false
end

-- 更新进入输赢记录
function this:UpdateTodayWinLoser()

	-- 红色区域获胜记录
	mView:GetChild('sub0'):GetChild('n19').text = string.format('红方获胜:[color=#D0732F]%s[/color]次',
		Data_WinOrLoser['red_win'])

	-- 平手区域区域获胜记录
	mView:GetChild('sub0'):GetChild('n22').text = string.format('平手:[color=#D0732F]%s[/color]次',
		Data_WinOrLoser['pingshou'])

	-- 蓝色区域区域获胜记录
	mView:GetChild('sub0'):GetChild('n21').text = string.format('蓝方获胜:[color=#D0732F]%s[/color]次',
		Data_WinOrLoser['blue_win'])

	-- 同花连牌区域
	mView:GetChild('sub0'):GetChild('n23').text = string.format('同花连牌:[color=#D0732F]%s[/color]次',
		Data_WinOrLoser['tonghualianpai_win'])

	-- 对A
	mView:GetChild('sub0'):GetChild('n24').text = string.format('对A:[color=#D0732F]%s[/color]次',
		Data_WinOrLoser['duiA_win'])

	-- 葫芦
	mView:GetChild('sub0'):GetChild('n25').text = string.format('葫芦:[color=#D0732F]%s[/color]次',
		Data_WinOrLoser['hulu_win'])

	-- 金刚/同花顺/皇家同花顺
	mView:GetChild('sub0'):GetChild('n26').text = string.format('金刚/同花顺/皇家同花顺:[color=#D0732F]%s[/color]次',
		Data_WinOrLoser['jingang_win'])
end

-- 更新今日胜负走势
function this:UpdateToDayTrend()
	local count = 0
	for k,v in pairs(Data_CardGaneTrend) do
		count = count + 1
	end
	mView:GetChild('sub0'):GetChild('list1').asList.itemRenderer = function (index, itemOBJ)
		local tab_temp = Data_CardGaneTrend[index + 1]
		local wintype = tab_temp['wintype']
		local cardtype = tab_temp['cardtype']
		local c1 = itemOBJ:GetController('c1')
		c1.selectedIndex = cardtype
		itemOBJ:GetChild('n'..cardtype-1):GetController('c1').selectedIndex = wintype
		itemOBJ:GetChild('n'..cardtype-1):GetChild('newTag').visible = index == count - 1
	end
    mView:GetChild('sub0'):GetChild('list1').numItems = count
end

-- print('更新手牌记录')
-- print(Data_HandCards['lastcards'])
-- print(Data_HandCards['lasttimer'])
-- print(Data_HandCards['totalscore'])
-- print(os.date("%Y-%m-%d %H:%M %S", Data_HandCards['lasttimer']))
-- print('时间: '..os.date("%Y:%m:%d:%H",Data_HandCards['lasttimer']))
-- print(os.date("%Y%m%d%H",Data_HandCards['lasttimer']/1000))
-- 更新手牌记录
function this:UpdateHandCards()
	local content_view = mView:GetChild('sub1_2')
	content_view:GetController('c1').selectedIndex = 1
	content_view:GetChild('n35').text = os.date("%Y-%m-%d %H:%M:%S",
	 Data_HandCards['lasttimer'])

	content_view:GetChild('n34').text = formatVal(Data_HandCards['totalscore'])
	-- local tab_user = Data_HandCards['userinfos']
	-- content_view:GetChild('list2').asList.itemRenderer = function (index,itemOBJ)
	-- 	local userinfo = tab_user[index+1]
	-- 	itemOBJ:GetChild('n43').text = userinfo.score
	-- 	itemOBJ:GetChild('n42').text = userinfo.nickname
	-- 	itemOBJ:GetChild('icon').asLoader.url = HandleWXIcon(userinfo.headurl)
	-- 	itemOBJ:GetChild('n40').text = index+1
	-- end
	-- content_view:GetChild('list2').numItems = #tab_user
	--tab_cards[index]:GetChild('card').asLoader.url = PokerUrlMap[value]	
	local card1 = content_view:GetChild('1-p1'):GetChild('n0').asLoader
	local card2 = content_view:GetChild('1-p2'):GetChild('n0').asLoader
	card1.url = PokerUrlMap[Data_HandCards['lastcards'][1]]
	card2.url = PokerUrlMap[Data_HandCards['lastcards'][2]]
	--print(#Data_HandCards['userinfos'])
	local tab_user = Data_HandCards['userinfos']
	content_view:GetChild('list2').asList.itemRenderer = function (index,itemOBJ)
		local userinfo = tab_user[index+1]
		itemOBJ:GetChild('n43').text = userinfo.score
		itemOBJ:GetChild('n42').text = userinfo.nickname
		itemOBJ:GetChild('icon').asLoader.url = HandleWXIcon(userinfo.headurl)
		itemOBJ:GetChild('n40').text = index+1
	end
	content_view:GetChild('list2').numItems = #tab_user
end


-- 更新牌型记录
function this:UpdateGameCards()
	--print("lasttimer:"..Data_GameCardRecord['lasttimer'])
	local lasttimer = tonumber(Data_GameCardRecord['lasttimer'])
	local has_data = lasttimer ~= 0 and true or false
	local content_view = mView:GetChild('sub1_2')
	content_view:GetController('c1').selectedIndex = 2
	content_view:GetChild('n35').text = has_data and os.date("%Y-%m-%d %H:%M:%S", lasttimer) or ''
	content_view:GetChild('n34').text = formatVal(Data_GameCardRecord['totalscore'])

	local item
	for i = 1, 5 do
		item = content_view:GetChild('2-p'..i)
		item.visible = has_data
		if has_data then
			item:GetChild('n0').asLoader.url = PokerUrlMap[Data_GameCardRecord['lastcards'][i]]
		end
	end
	--local card1 = content_view:GetChild('2-p1'):GetChild('n0').asLoader
	--local card2 = content_view:GetChild('2-p2'):GetChild('n0').asLoader
	--local card3 = content_view:GetChild('2-p3'):GetChild('n0').asLoader
	--local card4 = content_view:GetChild('2-p4'):GetChild('n0').asLoader
	--local card5 = content_view:GetChild('2-p5'):GetChild('n0').asLoader
	--card1.url = PokerUrlMap[Data_GameCardRecord['lastcards'][1]]
	--card2.url = PokerUrlMap[Data_GameCardRecord['lastcards'][2]]
	--card3.url = PokerUrlMap[Data_GameCardRecord['lastcards'][3]]
	--card4.url = PokerUrlMap[Data_GameCardRecord['lastcards'][4]]
	--card5.url = PokerUrlMap[Data_GameCardRecord['lastcards'][5]]

	local tab_user = Data_GameCardRecord['userinfos']
	content_view:GetChild('list2').asList.itemRenderer = function (index,itemOBJ)
		local userinfo = tab_user[index+1]
		itemOBJ:GetChild('n43').text = userinfo.score
		itemOBJ:GetChild('n42').text = userinfo.nickname
		itemOBJ:GetChild('icon').asLoader.url = HandleWXIcon(userinfo.headurl)
		itemOBJ:GetChild('n40').text = index+1
	end
	content_view:GetChild('list2').numItems = #tab_user

end

-- 金刚数据
function this:UpdateJinGang()
	m_jinGangData = Data_JinGangRecord
	m_jinGangList.numItems = #Data_JinGangRecord
end

function this:InitJinGang()
	m_jinGangList = mView:GetChild('sub'):GetChild('list2').asList
	m_jinGangList:SetVirtual()
	m_jinGangList.itemRenderer = function (theIndex, theGObj)
		local _com = theGObj.asCom
		local _data = m_jinGangData[theIndex + 1]
		_com:GetChild('jinbi').text = _data.totalscore
		_com:GetChild('jushu').text = _data.roundcount

		local lasttimer = tonumber(_data.lasttime)
		local has_data = (lasttimer and lasttimer ~= 0) and true or false
		_com:GetChild('shijian').text = has_data and os.date("%Y-%m-%d %H:%M:%S", lasttimer) or ''

		for i, v in ipairs(_data.lastcards) do
			_com:GetChild('p'..i):GetChild('n0').asLoader.url = PokerUrlMap[v]
		end
	end

	m_jinGangList.numItems = 0
	m_jinGangData = nil
end

return CtrlDZNZ_DataView