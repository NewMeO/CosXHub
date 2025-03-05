local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")
local teleportService = game:GetService("TeleportService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentRenewedSettings"

    InterfaceManager.Settings = {
        Theme = "Darker",
		WhiteScreen = false,
        Transparency = 0,
        MenuKeybind = Enum.KeyCode.LeftControl
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library
        self.Options = library.Options

		InterfaceManager.Settings = {
			Theme = self.Library.Theme or "Darker",
			WhiteScreen = self.Library.WhiteScreen or false,
			Transparency = self.Library.Transparency or 0,
			MenuKeybind = self.Library.MinimizeKey or Enum.KeyCode.RightControl
		}
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

        section:CreateSlider("InterfaceManager_Transparent", {
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

		Library.MinimizeKeybind = MenuKeybind
    end
end

return InterfaceManager
