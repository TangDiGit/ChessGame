-- 大厅的提示
local ControllerHallTips = class("ControllerHallTips")

function ControllerHallTips:Init()
    self.m_view = UIPackage.CreateObject('hall', 'hallTipsView').asCom
    UIManager.normal:AddChild(self.m_view)
    self.m_view:SetSize(GRoot.inst.width, GRoot.inst.height)
    self.m_view.visible = false

    self.m_confirm = nil

    self.m_btn_confirm = self.m_view:GetChild('btn_confirm')

    self.m_tips_title = self.m_view:GetChild('tips_title')
    self.m_tips_cont = self.m_view:GetChild('tips_cont')

    self.m_view:GetChild("btnBg").onClick:Add(function ()
        UIManager.Hide('ControllerHallTips')
    end)

    -- 取消
    self.m_view:GetChild("btn_cancel").onClick:Add(function ()
        UIManager.Hide('ControllerHallTips')
    end)

    -- 确定
    self.m_btn_confirm.onClick:Add(function ()
        -- 输入框
        if self.m_has_input then
            if #self.m_input_num.text ~= 11 then
                UIManager.AddPopTip({ strTit = '您输入的号码不正确' })
                return
            end
        end

        -- 输入框
        if self.m_confirm then
            if self.m_has_input then
                self.m_confirm(self.m_input_num.text)
            else
                self.m_confirm()
            end
        end

        UIManager.Hide('ControllerHallTips')
    end)

    self:InitInputTips()
end

function ControllerHallTips:InitInputTips()
    self.m_has_input = false
    self.m_comInput = self.m_view:GetChild('comInput')
    self.m_input_num = self.m_comInput:GetChild('input')
    self.m_comInput.visible = false
end

function ControllerHallTips:Show(arg)
    --保持在前面
    UIManager.normal:AddChild(self.m_view)
    self.m_view.visible = true
    self.m_tips_title.text = arg.title
    self.m_tips_cont.text = arg.content
    self.m_confirm = arg.confirm
    self.m_has_input = arg.input and true or false
    self.m_input_num.text = ""
    self.m_comInput.visible = self.m_has_input
end

function ControllerHallTips:OnHide()
    self.m_view.visible = false
end

return ControllerHallTips

