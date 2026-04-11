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

_G.SpaceNames = {}
_G.SpaceLabel = hs.menubar.new();

hs.spaces.watcher.new(
    function (sp)
        local spid = hs.spaces.focusedSpace()
        _G.SpaceLabel:setTitle(_G.SpaceNames[spid] or string.format("<space %s>", spid))
    end
).start()
