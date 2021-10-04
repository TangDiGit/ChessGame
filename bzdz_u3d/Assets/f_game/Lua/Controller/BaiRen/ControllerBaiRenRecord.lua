--百人场记录数据界面
local ControllerBaiRenRecord = class("ControllerBaiRenRecord")

function ControllerBaiRenRecord:Init()
	self.m_view=UIPackage.CreateObject('bairen','baiRenRecordView').asCom
	UIManager.normal:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
	self.m_view:GetChild("btnClose").onClick:Add(function ()
        UIManager.Hide('ControllerBaiRenRecord')
    end)
end

function ControllerBaiRenRecord:SetCardInfo(com, msg)
    for i=1,5 do
        UIManager.SetPoker(com:GetChild('c'..i), BaiRenPokerCardConversionMap[msg.poker_value[i]])
    end
    com:GetChild('n20').text = CT_Chinese_Dic[msg.poker_type + 1]
end

function ControllerBaiRenRecord:Show(arg)
	UIManager.normal:AddChild(self.m_view)
	self.m_view.visible = true
    self.m_view:GetController('c1').selectedIndex = 0
    --local _Url = { [0] = 'ui://bairen/pic_jilu_bai', [1] = 'ui://bairen/pic_jilu_sheng', }
    for i = 1, 10 do
        local _t = arg[i]
        local _com = self.m_view:GetChild('n13'):GetChild('groupReview'..i).asCom
        local _com_result = self.m_view:GetChild('Trend'..i).asCom
        if _t then
            _com.visible = true
            _com_result.visible = true
            --输赢信息走势
            local real_tab = { 3, 1, 2, 0 }
            for j = 1, 4 do
                _com_result:GetChild('result'..real_tab[j]).asLoader.url = 'ui://bairen/pic_jilu_'..(_t.win_and_lose[j] == 0 and 'bai' or 'sheng')
            end
            --时间
            _com:GetChild('txtTime').text = os.date("%Y-%m-%d %H:%M %S", _t.datatime)
            --牌型庄家
            local _zhuangCom=_com:GetChild('psZhuang').asCom
            _zhuangCom:GetController("c1").selectedIndex=0
            self:SetCardInfo(_zhuangCom,_t.poker_info[1])
            --闲家闲家
            local _com0=_com:GetChild('ps0').asCom
            _com0:GetController("c1").selectedIndex=0
            self:SetCardInfo(_com0,_t.poker_info[2])

            local _com1=_com:GetChild('ps1').asCom
            _com1:GetController("c1").selectedIndex=1
            self:SetCardInfo(_com1,_t.poker_info[3])

            local _com2=_com:GetChild('ps2').asCom
            _com2:GetController("c1").selectedIndex=2
            self:SetCardInfo(_com2,_t.poker_info[4])

            local _com3=_com:GetChild('ps3').asCom
            _com3:GetController("c1").selectedIndex=3
            self:SetCardInfo(_com3,_t.poker_info[5])
        else
            _com.visible = false
            _com_result.visible = false
        end
    end
end

function ControllerBaiRenRecord:OnHide()
	self.m_view.visible=false
end

return ControllerBaiRenRecord