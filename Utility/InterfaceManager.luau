local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")
local guiService = game:GetService("GuiService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentRenewedSettings"

    InterfaceManager.Ignore = {}
    InterfaceManager.Options, InterfaceManager.Library = {} :: { [string]: {Type: string, Value: any, SetValues: (self: any, NewValue: { [any]: any }) -> nil, SetValue: (self: any, NewValue: any, ...any) -> nil, SetValueRGB: (self: any, NewValue: Color3, Transparency: number?) -> nil} }, {}
    InterfaceManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt } 
			end,
			Load = function(idx, data)
				if InterfaceManager.Options[idx] then 
					InterfaceManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if InterfaceManager.Options[idx] then 
					InterfaceManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if InterfaceManager.Options[idx] then 
					InterfaceManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if InterfaceManager.Options[idx] then 
					InterfaceManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if InterfaceManager.Options[idx] then 
					InterfaceManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if InterfaceManager.Options[idx] and type(data.text) == "string" then
					InterfaceManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

    InterfaceManager.Settings = {
        Theme = "Darker",
		WhiteScreen = false,
        Transparency = 0,
        MenuKeybind = Enum.KeyCode.LeftControl
    }

    function InterfaceManager:SetIgnoreIndexes(list)
		for _, key in next, list do
			self.Ignore[key] = true
		end
	end

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library
        self.Options = library.Options
	end

    function InterfaceManager:BuildFolderTree()
		local paths = {}

		local parts = self.Folder:split("/")

		for idx = 1, #parts do
			paths[#paths + 1] = table.concat(parts, "/", 1, idx)
		end
		
		paths[#paths + 1] = self.Folder
		paths[#paths + 1] = `{self.Folder}/settings`

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

    function InterfaceManager:Save()
		local fullPath = `{self.Folder}/settings/{game.Players.LocalPlayer.Name}.json`

		local data = {
			objects = {}
		}

		for idx, option in next, InterfaceManager.Options do
			if not self.Parser[option.Type] then continue end
			if self.Ignore[idx] then continue end

			data.objects[#data.objects + 1] = self.Parser[option.Type].Save(idx, option)
		end

		table.sort(data.objects, function(v1: { Timestamp: number }, v2: { Timestamp: number })
			return v1.Timestamp < v2.Timestamp
		end)

		local success, encoded = pcall(httpService.JSONEncode, httpService, data)
		if not success then
			return false, "Failed to JSON-Encode data"
		end

		writefile(fullPath, encoded)
		return true
	end

    function InterfaceManager:Load()
		local file = `{self.Folder}/settings/{game.Players.LocalPlayer.Name}.json`
		if not isfile(file) then return false, "invalid file" end

		local success, decoded = pcall(httpService.JSONDecode, httpService, readfile(file))
		if not success then return false, "decode error" end

		for _, option in next, decoded.objects do
			if self.Parser[option.type] then
				task.spawn(self.Parser[option.type].Load, option.idx, option) -- task.spawn() so the config loading wont get stuck.
			end
		end

		self.Library:SetTheme(self.Library.Theme)

		return true
	end

    function InterfaceManager:SaveSettings()
        writefile(`{self.Folder}/options.json`, httpService:JSONEncode(InterfaceManager.Settings))
    end

    function InterfaceManager:LoadSettings()
        local path = `{self.Folder}/options.json`

        if isfile(path) then
            local data = readfile(path)
            local success, decoded = pcall(httpService.JSONDecode, httpService, data)

            if success then
                for i, v in next, decoded do
                    InterfaceManager.Settings[i] = v
                end
            end
        end
    end

    function InterfaceManager:LoadAutoloadConfig()
        if isfile(`{self.Folder}/settings/{game.Players.LocalPlayer.Name}.json`) then
            local success, err = self:Load()
            if not success then
                return self.Library:Notify({
                    Title = "Interface",
                    Content = "Config loader",
                    SubContent = `Failed to load autoload config: {err}`,
                    Duration = 7
                })
            end
        end

		return nil
	end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")

		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

		local visuals = tab:AddSection("Visuals Settings")

		visuals:AddToggle("InterfaceManager_WhiteScreenToggle", {
			Title = "White Screen",
			Description = "Enable a white overlay to potentially reduce CPU usage by disabling 3D rendering.",
			Default = Settings.WhiteScreen,
			Callback = function(Value)
				runService:Set3dRenderingEnabled(not Value)
				Settings.WhiteScreen = Value
                InterfaceManager:SaveSettings()
			end
		})

        local servers = tab:AddSection("Server")

        servers:AddInput("InterfaceManager_JobID", {
            Title = "Join by Job ID",
            Default = "",
            Placeholder = "Enter Server Job ID",
            Numeric = false,
            Finished = false,
            Callback = function(Value)
                Settings.JobId = Value
            end
        })

        servers:AddButton({
            Title = "Join Server",
            Description = "Join to the server with the entered Job ID.",
            Callback = function()
                local jobId = Settings.JobId
                if jobId and jobId ~= "" then
                    local success, result = pcall(function()
                        teleportService:TeleportToPlaceInstance(game.PlaceId, jobId, game:GetService("Players").LocalPlayer)
                    end)

                    if not success then
                        Library:Notify({
                            Title = "Error Joining Server",
                            Content = "Could not join the server: " .. tostring(result),
                            Duration = 5,
                        })
                    else
                        Library:Notify({
                            Title = "Joining Server",
                            Content = "Attempting to join server " .. tostring(jobId) .. ".",
                            Duration = 5,
                        })
                    end
                else
                    Library:Notify({
                        Title = "Invalid Job ID",
                        Content = "Please enter a valid Job ID.",
                        Duration = 5,
                    })
                end
            end
        })

        servers:AddButton({
            Title = "Copy Current Job ID",
            Description = "Copies the current server's Job ID to your clipboard.",
            Callback = function()
                setclipboard(game.JobId)
                Library:Notify({
                    Title = "Copied Job ID",
                    Content = "The current server's Job ID has been copied to your clipboard.",
                    Duration = 5,
                })
            end
        })

		local section = tab:AddSection("Interface")

		local InterfaceTheme = section:AddDropdown("InterfaceManager_InterfaceTheme", {
			Title = "Theme",
			Description = "Changes the interface theme.",
			Values = Library.Themes,
			Default = Settings.Theme,
			Callback = function(Value)
				Library:SetTheme(Value)
                Settings.Theme = Value
                InterfaceManager:SaveSettings()
			end
		})

        InterfaceTheme:SetValue(Settings.Theme)

        section:AddSlider("InterfaceManager_Transparent", {
            Title = "Background Transparency",
            Description = "Adjusts the transparency of the interface background.",
            Default = Settings.Transparency,
            Min = 0,
            Max = 1,
            Rounding = 2,
            Callback = function(Value)
				Library.CreatedWindow.AcrylicPaint.Frame.Background.BackgroundTransparency = Value
                Settings.Transparency = Value
                InterfaceManager:SaveSettings()
			end
        })
	
		local MenuKeybind = section:AddKeybind("InterfaceManager_MenuKeybind", {
			Title = "Minimize Bind",
            Description = "Set the key to toggle the interface's visibility.",
			Default = Settings.MenuKeybind,
			ChangedCallback = function(Value)
				Settings.MenuKeybind = Value
                InterfaceManager:SaveSettings()
			end
		})

        self:SetIgnoreIndexes({"InterfaceManager_InterfaceTheme", "InterfaceManager_TransparentToggle", "InterfaceManager_MenuKeybind", "InterfaceManager_JobID", "InterfaceManager_WhiteScreenToggle"})
		Library.MinimizeKeybind = MenuKeybind
    end

    function saveConfigBeforeGameLeave()
        InterfaceManager:Save();
    end

    guiService.NativeClose:Connect(saveConfigBeforeGameLeave)
    guiService.MenuOpened:Connect(saveConfigBeforeGameLeave)

    game.Players.LocalPlayer.OnTeleport:Connect(function(state)
        if (state ~= Enum.TeleportState.Started and state ~= Enum.TeleportState.RequestedFromServer) then return end;
        saveConfigBeforeGameLeave();
    end);
end

return InterfaceManager
