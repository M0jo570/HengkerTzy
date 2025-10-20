local WindUI = require(game.ReplicatedStorage:WaitingForChilld("WindUI"))

local Window = WindUI:CreateWindow({
  Title = "MOJO HUB",
  Icon = "lucide:bot",
  Author = "MojoWasTaken",
  Theme = "Dark"
  Size = Udim2.new(0, 400, 0, 300)
  
})

local Tab = Window:CreateTab("Main") -- isi di dalam gui nya.

Tab:CreateButton({
  Title = "Auto Fishing",
  callback = function()
    print("Auto Fishing Is On.")
  end
  
})

Window:Open()