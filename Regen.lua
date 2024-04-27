--11/30/22--
--[[

	HOW TO USE:
	
	--Simply place your model into the "Templates" folder
	--move your model where you would like.

]]

--vars
local debrisService = game:GetService("Debris") --Used for cleanups

local model = script.Parent
local templates = model.Templates

local regenBlock = model.RegenBlock
local VisualTimer = regenBlock.Visual

local setting = {
	WAIT_TIME = 5, --Used to determine how much time the MAX wait time is. ( Change to whatever number you want to wait the longest AFTER using )
	Respawn_TEXT = "RESPAWN", --Used to determine what the pad text says ( Change to whatever you want the button to say before it is pressed. )
	health_required_to_use = 2, --Used to determine how much health you must ATLEAST have in order to use the button. ( Change to whatever number a player must have in health in order to use. )
	
	regenTime = 0, --Used to determine how much time is CURRENTLY left.
	textC = VisualTimer.TextLabel.TextColor, --Used for determining original color of visual timer.
}


-----------------------------------	-------------------------------		-------------------			---------------------------
-----PRE-LOAD:
if regenBlock:GetAttribute("TIMER") == nil then
	regenBlock:SetAttribute("TIMER", -1)
end

if regenBlock:GetAttribute("TIMER_ACTIVE") == nil then
	regenBlock:SetAttribute("TIMER_ACTIVE", false)
end

if VisualTimer:GetAttribute("LISTEN") == nil then
	VisualTimer:SetAttribute("LISTEN", false)
end

--------------------
-------------------------FUNCTIONS:

local debounce = false -- Used to regulate the function below.

regenBlock.Touched:Connect(function(hit) --Each time the regen block gets hit.
	if hit then
		if hit.Parent and debounce == false then --IF the part is a 'MODEL' and this function is NOT already running then
			debounce = true --Indicate that this function is running.
			
			if game.Players:FindFirstChild(hit.Parent.Name) then --IF the touching item can be found in the players list then
				local PLR = hit.Parent

				
				if PLR:FindFirstChild("Humanoid") then --IF this player has a 'humanoid' then
					local humanoid = PLR.Humanoid
		
					
					if humanoid.Health > setting.health_required_to_use and regenBlock:GetAttribute("TIMER") ~= nil then --IF this humanoid is healthy then
						if setting.regenTime == 0 then
							regenBlock.Transparency = 1
							if model:FindFirstChild("ACTIVE") then --IF there are previous monsters already spawned then,
								
								for nam,obj in pairs(model.ACTIVE:GetChildren()) do --Get the children of the active AI monsters.
									debrisService:AddItem(obj, math.random(1,3)) --Slowly remove the monsters. (helps reduce lag?)
								end
								
								model.ACTIVE:Destroy() --Remove the old model.
							end
							
							local newModel = Instance.new("Model") --Create a new model.
							newModel.Name = "ACTIVE"
							newModel.Parent = model
							
							for nam,obj in pairs(templates:GetChildren()) do
								task.wait(math.random(0,1)/10) --Slowly add the monsters (helps reduce lag?)
								
								local newAI = obj:Clone()
								newAI.Parent = newModel
							end
							
							setting.regenTime = setting.WAIT_TIME
							regenBlock:SetAttribute("TIMER_ACTIVE", true)
							
							task.wait(0.7)
							regenBlock.Transparency = 0
						else --ELSE, the timer is not finished counting down.
							
							for i = 1, math.random(4,8) do		--Loop		
								VisualTimer.TextLabel.TextColor = BrickColor.new("Really red") --Change the textcolor to red
								task.wait(0.15)
								VisualTimer.TextLabel.TextColor = BrickColor.new("White") --Change the textcolor to white
								task.wait(0.15)
							end
							
							VisualTimer.TextLabel.TextColor = setting.textC --Change the textcolor back to the original color that the text was.
						end
					end
				end
			end
			
			task.wait(1)
			debounce = false --Indicate that the function is no longer being used.
		end
	end
end)

regenBlock:GetAttributeChangedSignal("TIMER_ACTIVE"):Connect(function() --Each time the TIMER gets activated.
	local val = regenBlock:GetAttribute("TIMER_ACTIVE") --grab the initial value.
	
	if val == true then --IF the initial value was set to true then
		
		while setting.regenTime >= 0 do --Loop until the timer gets to 0
			task.wait(1)
			
			setting.regenTime = setting.regenTime - 1 --update the timer
			
			if setting.regenTime < 0 then --IF the timer is at 0 then
				setting.regenTime = 0 --end the timer
				break; --break the loop
			end
		end
		
		task.wait()
		
		regenBlock:SetAttribute("TIMER_ACTIVE", false) --indicate that this function is done.
	end
end)


VisualTimer:GetAttributeChangedSignal("LISTEN"):Connect(function() --EACH TIME the 
	local val = VisualTimer:GetAttribute("LISTEN")
	
	if val == true then --If the initial value was set to true then
		
	while val == true do --While the value is still true, loop
			task.wait()
			
			if setting.regenTime ~= 0 then --IF the timer is NOT at 0 then
				VisualTimer.TextLabel.Text = (setting.regenTime) --Show the time to the users.
			else --ELSE 
				VisualTimer.TextLabel.Text = setting.Respawn_TEXT --Show the original "Respawn" text
			end
			
			val = VisualTimer:GetAttribute("LISTEN")
			if val == nil or val == false then
				--At this point, the visual timer would need to manually be enabled through game script.
				--Model> RegenBlock> Visual> SetAttribute> LISTEN> true
				break;
			end
		end
	end
end)


---------------
-----POST-LOAD:
templates.Parent = nil
VisualTimer:SetAttribute("LISTEN", true)

---
--
--
