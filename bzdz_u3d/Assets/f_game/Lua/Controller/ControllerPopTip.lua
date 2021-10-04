--从上往下的tip
local ControllerPopTip = class("ControllerPopTip")
local _hideY=-60
local _showY = 50
function ControllerPopTip:Init()
	self.m_view=UIPackage.CreateObject('main','PopTipView').asCom
	UIManager.top:AddChild(self.m_view)
	self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible=false
end

function ControllerPopTip:Show(arg)
    if not arg then
        return
    end

    if not arg.strTit then
        return
    end

	--保持在前面
	UIManager.top:AddChild(self.m_view)
    self.m_view.visible=true
    
    local _comPop=self.m_view:GetChild('pop')
    _comPop:GetChild('txtTitle').text=arg.strTit

    _comPop.y=_hideY
    LeanTween.cancel(self.m_view.displayObject.gameObject)
    if self.timer then
        self.timer:Stop()
    end

    --显示
    local _dt=arg.dt or 1.2

    LeanTween.value(self.m_view.displayObject.gameObject,System.Action_float(function (val)
        _comPop.y=val
    end),_hideY,_showY,0.25):setEaseOutCubic():setOnComplete(System.Action(function ()
        --停留时间
        self.timer=Timer.New(function ()
            --结束
            LeanTween.value(self.m_view.displayObject.gameObject,System.Action_float(function (val)
                _comPop.y=val
            end),_showY,_hideY,0.25):setEaseOutCubic():setOnComplete(System.Action(function ()
                UIManager.EndPopTip()
                UIManager.Hide('ControllerPopTip')
            end))
        end,_dt,1)
        self.timer:Start()
    end))

end

function ControllerPopTip:OnHide()
	self.m_view.visible=false
end
return ControllerPopTip