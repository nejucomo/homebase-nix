-- TODO: Make this mac-specific in homebase.
hs.hotkey.bind({"ctrl", "cmd"}, "s", function()
    -- local appName = "Signal"
    -- local app = hs.application.get(appName)

    -- if app then
    --     app:activate()
    --     app:unhide()
    -- else
    hs.application.launchOrFocus("Signal")
    -- end
end)

-- Space labels!
local function refresh_space_label_widget (spid)
    if spid == nil then
        spid = hs.spaces.focusedSpace()
    end

    _G.SpaceLabelWidget:setTitle(_G.SpaceLabels[spid] or string.format("<space %s>", spid))
end

_G.SpaceLabels = {}
_G.SpaceLabelWidget = hs.menubar.new();

_G.SpaceLabelWidget:setClickCallback(function ()
    local button, newlabel = hs.dialog.textPrompt(
      "Rename Space",
      "Enter new space label:",
      _G.SpaceLabels[hs.spaces.focusedSpace()] or "",
      "OK",
      "Cancel"
    )

    if button == "OK" then
        _G.set_space_label(newlabel)
    end
end)

-- Define this for ease of use from the console:
_G.set_space_label = function (name)
    local spid = hs.spaces.focusedSpace();
    _G.SpaceLabels[spid] = name
    refresh_space_label_widget(spid)
end

hs.spaces.watcher.new(function () refresh_space_label_widget(); end):start()

refresh_space_label_widget()
