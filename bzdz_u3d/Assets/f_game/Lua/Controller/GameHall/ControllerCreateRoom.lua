--创建房间界面
local H_SliderCreateRoom=require("Controller/GameHall/H_SliderCreateRoom")
local ControllerCreateRoom = class("ControllerCreateRoom")
--小盲注
local SmallBlindValueMap={250,500,1000,2500,5000,10000,20000,50000,100000,200000,500000,1000000}
--大盲注
local BigBlindValueMap={500,1000,2000,5000,10000,20000,40000,100000,200000,400000,1000000,2000000}

--最小携带
local SmallBringValueMap={5000,10000,20000,50000,100000,200000,400000,1000000,2000000,4000000,5000000,10000000}

--最大携带
local BigBringValueMap={100000,200000,400000,1000000,2000000,4000000,8000000,20000000,40000000,80000000,100000000,200000000}

--前注设置
local BeforeValueMap={0,20000,50000,100000,1000000,2000000,3000000,4000000,5000000}

--时间设置
local GameTimeMap={5,10,30,60}

--游戏人数
local PersonNumMap={5,9}


function ControllerCreateRoom:Init()
	self.m_view=UIPackage.CreateObject('gamehall','createRoomView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
	self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerCreateRoom')
	end)
	
	

	--前注设置
	local _before=math.max(0,PlayerPrefs.GetInt("Before2",0))
    local _hSliderBefore=H_SliderCreateRoom.new()
	_hSliderBefore:Init({view=self.m_view:GetChild("BeforeSlider").asCom,onChangeCall=function (index)
		local _blindBet=math.max(0,PlayerPrefs.GetInt("BlindBet",0))
		
		if BeforeValueMap[index+1]>=SmallBringValueMap[_blindBet+1] then
			local _mark=true
			for i=#BeforeValueMap,1,-1 do
				if _mark and BeforeValueMap[i]<SmallBringValueMap[_blindBet+1] then
					_mark=false
					index=i-1
					_hSliderBefore:SetJ(index)
				end
			end
		end

		PlayerPrefs.SetInt("Before2",index)
		PlayerPrefs.Save()
		
	end})
	_hSliderBefore:SetJ(_before)
	self.m_hSliderBefore=_hSliderBefore
	for i,v in pairs(BeforeValueMap) do
		self.m_view:GetChild("txtBefore"..i).text=formatVal(v)
	end

	--小盲/大盲
	
	local _blindBet=math.max(0,PlayerPrefs.GetInt("BlindBet",0))
    self.m_hSliderBlindBet=H_SliderCreateRoom.new()
    self.m_hSliderBlindBet:Init({view=self.m_view:GetChild("BlindBetSlider").asCom,onChangeCall=function (index)
		self:SetBlindBetAndBringBet(index)
	end})
	--最小携带/最大携带
    self.m_hSliderBringBet=H_SliderCreateRoom.new()
    self.m_hSliderBringBet:Init({view=self.m_view:GetChild("BringBetSlider").asCom,onChangeCall=function (index)
		self:SetBlindBetAndBringBet(index)

		
	end})
	self.m_hSliderBringBet:SetJ(_blindBet)
	self.m_hSliderBlindBet:SetJ(_blindBet)
	self:SetBlindBetAndBringBet(_blindBet)

	--时间设置
	local _gameTime=math.max(0,PlayerPrefs.GetInt("GameTime",0))
    local _hSliderGameTime=H_SliderCreateRoom.new()
    _hSliderGameTime:Init({view=self.m_view:GetChild("GameTimeSlider").asCom,onChangeCall=function (index)
		PlayerPrefs.SetInt("GameTime",index)
		PlayerPrefs.Save()
	end})
	_hSliderGameTime:SetJ(_gameTime)
	for i,v in pairs(GameTimeMap) do
		self.m_view:GetChild("txtTime"..i).text=v..'min'
	end

	--人数设置
	local _gamePeople=math.max(0,PlayerPrefs.GetInt("GamePeople",0))
	self.m_controllerGamePeople=self.m_view:GetController("cPeople")
	self.m_controllerGamePeople.selectedIndex=_gamePeople
	self.m_view:GetChild("toggle5").onClick:Add(function ()
		PlayerPrefs.SetInt("GamePeople",self.m_controllerGamePeople.selectedIndex)
		PlayerPrefs.Save()
	end)
	self.m_view:GetChild("toggle9").onClick:Add(function ()
		PlayerPrefs.SetInt("GamePeople",self.m_controllerGamePeople.selectedIndex)
		PlayerPrefs.Save()
	end)

	--确定创建房间
	self.m_view:GetChild("btnY").onClick:Add(function ()
		if tonumber(loginSucceedInfo.user_info.viptime)<=0 then
			UIManager.AddPopTip({strTit='亲爱的玩家，您不是VIP暂时无法使用该功能'})
			return
		end

		local _pw=self.m_view:GetChild("txtPassword").text
		if utf8.len(_pw)<6 then
			UIManager.AddPopTip({strTit='密码长度6'})
			return
		end

		local _roomName=self.m_view:GetChild("txtRoomName").text
		if utf8.len(_roomName)<=-1 or utf8.len(_roomName)>6 then
			UIManager.AddPopTip({strTit='房间名长度0-6'})
			return
		end

		local _blindBet=math.max(0,PlayerPrefs.GetInt("BlindBet",0))
		local _t={
			roomName=_roomName,
			bigBlindValue=BigBlindValueMap[_blindBet+1],
			smallBlindValue=SmallBlindValueMap[_blindBet+1],
			bigBringValue=BigBringValueMap[_blindBet+1],
			smallBringValue=SmallBringValueMap[_blindBet+1],
			beforeValue=BeforeValueMap[math.max(0,PlayerPrefs.GetInt("Before2",0))+1],
			gameTime=GameTimeMap[math.max(0,PlayerPrefs.GetInt("GameTime",0))+1],
			personNum=PersonNumMap[math.max(0,PlayerPrefs.GetInt("GamePeople",0))+1],
			roomPassword=tonumber(self.m_view:GetChild("txtPassword").text),
		}
		print('创建房间配置:'..json.encode(_t))

		UIManager.Show('ControllerWaitTip')
		

		local msg = Protol.Poker_pb.CreateTable()
		--桌子名称
		msg.tableconfig.tablename=_t.roomName
		--小盲
		msg.tableconfig.xiaomangbet=_t.smallBlindValue
		--前注
		msg.tableconfig.frontbet=_t.beforeValue
		--分钟
		msg.tableconfig.lefttime=_t.gameTime
		--人数
		msg.tableconfig.person=_t.personNum
		--密码
		msg.tableconfig.passwd=_t.roomPassword
		--带入最小值
		msg.tableconfig.bringmingold=_t.smallBringValue
		--带入最大值
		msg.tableconfig.bringmaxgold=_t.bigBringValue

		--默认
		msg.tableconfig.tableid=0
		msg.tableconfig.online_person=0

		local pb_data = msg:SerializeToString()
		--请求创建房间
		NetManager.SendMessage(GameServerConfig.logic,'CreateTable',pb_data)
	end)
	--输入密码
	self.m_view:GetChild("btnPW").onClick:Add(function ()
		UIManager.Show('ControllerPW',{callback=function (arg)
			self.m_view:GetChild("txtPassword").text=arg
		end})
	end)

	--创建房间返回
    H_NetMsg:addEventListener('CreateTableResponse',function (arg)
        print('收到消息 CreateTableResponse')

        local msg = Protol.Poker_pb.CreateTableResponse()
        msg:ParseFromString(arg.pb_data)
		print(tostring(msg))
		
		
		UIManager.AddPopTip({strTit='创建房间成功.'})
		
		--todo默认让玩家进入房间
		sendTablePwdValidate(msg.tableid,tonumber(self.m_view:GetChild("txtPassword").text))
    end)
end

function ControllerCreateRoom:SetBlindBetAndBringBet(index)
	PlayerPrefs.SetInt("BlindBet",index)
	self.m_view:GetChild("txtBlindBet").text=string.format( "%s/%s", formatVal(SmallBlindValueMap[index+1]),formatVal(BigBlindValueMap[index+1]))
	self.m_view:GetChild("txtBringBet").text=string.format( "%s/%s", formatVal(SmallBringValueMap[index+1]),formatVal(BigBringValueMap[index+1]))
	self.m_hSliderBlindBet:SetJ(index)
	self.m_hSliderBringBet:SetJ(index)
	PlayerPrefs.Save()

	local _before=math.max(0,PlayerPrefs.GetInt("Before2",0))
		if BeforeValueMap[_before+1]>=SmallBringValueMap[index+1] then
			local _mark=true
			for i=#BeforeValueMap,1,-1 do
				if _mark and BeforeValueMap[i]<SmallBringValueMap[index+1] then
					_mark=false
					local _beforeindex=i-1
					self.m_hSliderBefore:SetJ(_beforeindex)
					PlayerPrefs.SetInt("Before2",_beforeindex)
					PlayerPrefs.Save()
				end
			end
		end
end

function ControllerCreateRoom:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	self.m_view:GetChild("txtPassword").text=''
	self.m_view:GetChild("txtRoomName").text=''
end

function ControllerCreateRoom:OnHide()
	self.m_view.visible=false
end
return ControllerCreateRoom