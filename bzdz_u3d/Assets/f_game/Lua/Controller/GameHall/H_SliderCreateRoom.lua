local H_SliderCreateRoom=class("H_SliderCreateRoom")
function H_SliderCreateRoom:Init(arg)
    local m_view=arg.view
    self.m_onChangeCall=arg.onChangeCall
    self.m_isRun=true
    self.slider=m_view:GetChild("slider")
    self.grip=self.slider:GetChild("Fgrip")

    if self.m_isRun then
        self.grip.onTouchBegin:Add(function (context)
            self:CalaVal()
            self.canCala=true
        end)
        Stage.inst.onTouchMove:Add(function (context)
            if self.canCala then
                self:CalaVal()
            end
        end);
    
        Stage.inst.onTouchEnd:Add(function (context)
            self.canCala=false
        end)
    end
    
    --计算有多少个阶段
    self.ps={}
    local  childs = m_view:GetChildren()
    for i=0,childs.Length-1 do
        if string.find( childs[i].name,"p" ) then
            --print(childs[i].name)
            table.insert( self.ps, childs[i])
          
        end
    end
    --一个阶段的值
    self.maxJ=#self.ps-1
    self.v=1/self.maxJ
end
function H_SliderCreateRoom:CalaVal()
    local _mX=GRoot.inst:GlobalToLocal(Stage.inst:GetTouchPosition(-1)).x
    local _startX=GRoot.inst:GlobalToLocal(self.grip:LocalToGlobal(Vector2.zero)).x
    local _val=(_mX-_startX)/self.grip.width

    --print(_mX)
    --print(_startX)
    --print(_val)

    --当前第几阶段
    local _j=math.max( 0,math.floor( _val/self.v+0.5 )) 
    _j=math.min(self.maxJ,_j)
    --print(_j)
    self:SetJ(_j)

    if self.m_onChangeCall then
        self.m_onChangeCall(_j)
    end
end
--设置默认值,第几阶段
function H_SliderCreateRoom:SetJ(j)
    self.j=math.min(self.maxJ,j)
    self.slider.value=self.j*self.v*100
    for i,v in pairs(self.ps) do
        --print(i)
        if i==self.j+1 then
            v:GetController("c1").selectedIndex=2
        elseif i<self.j+1 then
            v:GetController("c1").selectedIndex=1
        else
            v:GetController("c1").selectedIndex=0
        end
    end
    
end
return H_SliderCreateRoom