local H_SliderBet=class("H_SliderBet")
--筹码列表中显示筹码最大的数量
local MaxShowChip = 40
function H_SliderBet:Init(arg)
    local m_view=arg.view
    self.m_onChangeCall=arg.onChangeCall
    self.listChip=m_view:GetChild('listProgressBar').asList
    self.grip=m_view:GetChild("Grip")

    self.grip.onTouchBegin:Add(function (context)
        self:CalaVal()
        self.canCala=true
    end)
    Stage.inst.onTouchMove:Add(function (context)
        if self.canCala then
            self:CalaVal()
        end
    end)

    Stage.inst.onTouchEnd:Add(function (context)
        self.canCala=false
    end)

end
function H_SliderBet:CalaVal()
    local _mY=GRoot.inst:GlobalToLocal(Stage.inst:GetTouchPosition(-1)).y
    local _startY=GRoot.inst:GlobalToLocal(self.grip:LocalToGlobal(Vector2.zero)).y
    local _val=(_startY-_mY)/self.grip.height
    _val=math.max(0,_val)
    _val=math.min(1,_val)

    self:SetVal(_val)
    if self.m_onChangeCall then
        self.m_onChangeCall(_val)
    end
end
function H_SliderBet:SetVal(val)
    self.listChip:RemoveChildrenToPool()
    local count = math.ceil(MaxShowChip * val)
    count = count == 0 and 1 or count
    for i = 1, count do
        self.listChip:AddItemFromPool()
    end
end
return H_SliderBet