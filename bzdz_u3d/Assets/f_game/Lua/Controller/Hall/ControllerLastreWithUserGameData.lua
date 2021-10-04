--游戏内查看上局回顾,从玩家查询游戏记录
local ControllerLastreWithUserGameData = class("ControllerLastreWithUserGameData")

function ControllerLastreWithUserGameData:Init()
	self.m_view=UIPackage.CreateObject('texas','texasLastreView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerLastreWithUserGameData')
    end)
end

function ControllerLastreWithUserGameData:Show(arg)
	--保持在前面
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible=true

	--设置房间信息
	local _tableconf=json.decode(arg.data1.table_conf)
	local _str1=string.format( "%s（%s）",_tableconf.nickname,arg.data1.game_log_id)
	local _str2
	if _tableconf.frontbet>0 then
		_str2=string.format("盲注：%s/%s 前注：%s",_tableconf.smallblind,_tableconf.smallblind*2,_tableconf.frontbet)
	else
		_str2=string.format("盲注：%s/%s",_tableconf.smallblind,_tableconf.smallblind*2)
	end

	self.m_view:GetChild('txtEndpoints').text=_str1..' '.._str2

	--设置列表
	self.m_list=self.m_view:GetChild('list').asList
	self.m_list:RemoveChildrenToPool()
	--只能显示一回合数据,暂时没做切页
		for i,v in ipairs(arg.data2.result) do
			local _gcom=self.m_list:AddItemFromPool()
			_gcom:GetChild('xiaoMang').visible=false
			_gcom:GetChild('daMang').visible=false

			
			_gcom:GetChild('txtNickName').text=v.nickname
			--wx头像连接
			_gcom:GetChild("head"):GetChild("icon").asLoader.url=HandleWXIcon(v.headurl)
			--玩家牌
			local c1=_gcom:GetChild("c1").asCom
			c1:GetChild("txtMessage").text=''
			if tonumber(v.status)~=USER_STATUS_GAME_NULL then
				c1:GetChild("txtMessage").text=USER_STATUS_GAME_DIC[tonumber(v.status)]
			end
			
			local handcards=lua_string_split(v.handcards,'#')
			c1:GetChild("card3").visible=false
			UIManager.SetPoker(c1:GetChild("card1"),tonumber(handcards[1]))
			UIManager.SetPoker(c1:GetChild("card2"),tonumber(handcards[2]))
			


			local publiccards=nil
			if v.public_cards then
				publiccards=lua_string_split(v.public_cards,'#')
			end
			 
			--公共牌
			local c2=_gcom:GetChild("c2").asCom
			if publiccards and #publiccards>=3 then
				c2.visible=true
				c2:GetChild("txtMessage").text = ''
				UIManager.SetPoker(c2:GetChild("card1"),tonumber(publiccards[1]))
				UIManager.SetPoker(c2:GetChild("card2"),tonumber(publiccards[2]))
				UIManager.SetPoker(c2:GetChild("card3"),tonumber(publiccards[3]))
			else
				c2.visible=false
			end

			--和牌
			local c3=_gcom:GetChild("c3").asCom
			if publiccards and #publiccards>=4 then
				c3.visible=true
				c3:GetChild("txtMessage").text=''
				c3:GetChild("card2").visible=false
				c3:GetChild("card3").visible=false
				UIManager.SetPoker(c3:GetChild("card1"),tonumber(publiccards[4]))
			else
				c3.visible=false
			end

			--转牌
			local c4=_gcom:GetChild("c4").asCom
			if publiccards and #publiccards>=5 then
				c4.visible=true
				c4:GetChild("txtMessage").text=''
				c4:GetChild("card2").visible=false
				c4:GetChild("card3").visible=false
				UIManager.SetPoker(c4:GetChild("card1"),tonumber(publiccards[5]))

				--todo显示暗牌
				local _comCards={
					c1:GetChild("card1"),
					c1:GetChild("card2"),

					c2:GetChild("card1"),
					c2:GetChild("card2"),
					c2:GetChild("card3"),

					c3:GetChild("card1"),

					c4:GetChild("card1"),
				}
				for k,_com in ipairs(_comCards) do
					_com:GetController("cGray").selectedIndex=1
				end

				local _str=lua_string_split(v.cards,'#')
				for m,vv in ipairs(_str) do
					local _mark=true
					for n,_com in ipairs(_comCards) do
						if _mark and _com.data==tonumber(vv) and _com:GetController("cGray").selectedIndex==1 then
							_com:GetController("cGray").selectedIndex=0
							_mark=false
						end
					end
				end


			else
				c4.visible=false
			end

			--牌型
			_gcom:GetChild("txtPatterns").text=CT_Chinese_Dic[tonumber(v.cardtype)]
			--分数
			local gold = tonumber(v.win_gold)
			_gcom:GetChild("txtValue").text=(gold < 0 and "-" or "+")..formatVal(math.abs(gold))
			_gcom:GetChild("winIcon").visible = gold > 0
		end
end

function ControllerLastreWithUserGameData:OnHide()
	self.m_view.visible=false
end
return ControllerLastreWithUserGameData