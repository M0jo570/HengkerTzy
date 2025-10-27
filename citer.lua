-- Client: LocalScript (StarterPlayerScripts) atau paste di executor untuk testing private
local WINDUI_URL = "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"

-- Simple HTTP loader (coba beberapa method common). Jika kamu di Studio, ganti dengan require WindUI yang kamu taruh di ReplicatedStorage.
local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and res and res ~= "" then return res end
    -- fallbacks (executor-specific) omitted for studio local testing
    return nil
end

local raw = httpGet(WINDUI_URL)
if not raw then
    warn("[Client] Gagal ambil WindUI. Pastikan URL reachable atau gunakan require dari ReplicatedStorage.")
    return
end

local ok, WindUI = pcall(function() return loadstring(raw)() end)
if not ok or not WindUI then
    warn("[Client] Gagal load WindUI:", WindUI)
    return
end

-- cari RemoteFunction di ReplicatedStorage/Remotes (server script di contoh menaruh di ReplicatedStorage.Remotes.SellAllItems)
local Replicated = game:GetService("ReplicatedStorage")
local Remotes = Replicated:FindFirstChild("Remotes")
local RemoteSell = Remotes and Remotes:FindFirstChild("SellAllItems")

-- jika RemoteFunction nggak ada, kita pake simulated function (local) supaya UI tetap berfungsi di testing client-only
local function simulatedSell()
    print("[Client] Simulated sell executed (no server).")
    -- contoh efek client-side: tampilkan notifikasi kecil
    -- (jangan ubah server state di client)
end

-- Interval (ms) antara panggilan ketika toggle ON
local CALL_INTERVAL = 2 -- detik

local shouldRun = false
local runningCoroutine

-- function yang melakukan invoke (aman dengan pcall)
local function doSell()
    if RemoteSell and RemoteSell.ClassName == "RemoteFunction" then
        local ok, res = pcall(function()
            return RemoteSell:InvokeServer()
        end)
        if ok then
            print("[Client] Remote returned:", res)
        else
            warn("[Client] InvokeServer error:", res)
        end
    else
        simulatedSell()
    end
end

-- buat WindUI window + toggle
local Window = WindUI:CreateWindow({
    Title = "Delta WindUI Example",
    Theme = "Dark",
    Size = UDim2.new(0, 520, 0, 340),
})

local MainTab = Window:CreateTab("Main")

MainTab:CreateLabel({Title = "SellAll Tester (private only)"})

-- Toggle dari docs WindUI
MainTab:CreateToggle({
    Title = "Auto Sell All (safe)",
    Default = false,
    Callback = function(state)
        shouldRun = state
        print("Auto Sell toggled:", state)

        if state then
            -- start loop coroutine jika belum berjalan
            if runningCoroutine and coroutine.status(runningCoroutine) ~= "dead" then return end
            runningCoroutine = coroutine.create(function()
                while shouldRun do
                    doSell()
                    -- sleep with wait to avoid spamming
                    task.wait(CALL_INTERVAL)
                end
            end)
            coroutine.resume(runningCoroutine)
        else
            -- stop loop: will naturally exit
        end
    end
})

-- slider untuk ubah interval jika mau
MainTab:CreateSlider({
    Title = "Interval (seconds)",
    Min = 1,
    Max = 10,
    Default = CALL_INTERVAL,
    Callback = function(val)
        CALL_INTERVAL = math.clamp(math.floor(val), 1, 60)
        print("Interval set to", CALL_INTERVAL)
    end
})

Window:Open()