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

