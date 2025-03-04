local httpService = game:GetService("HttpService")
local runService = game:GetService("RunService")

local InterfaceManager = {} do
	InterfaceManager.Folder = "FluentRenewedSettings"

    InterfaceManager.Settings = {
        Theme = "Darker",
        EnableFPSCap = false,
		WhiteScreen = false,
        Transparency = true,
        MenuKeybind = Enum.KeyCode.RightControl
    }

    function InterfaceManager:SetFolder(folder)
		self.Folder = folder;
		self:BuildFolderTree()
	end

    function InterfaceManager:SetLibrary(library)
		self.Library = library

		InterfaceManager.Settings = {
			Theme = self.Library.Theme or "Darker",
			EnableFPSCap = self.Library.EnableFPSCap or false,
			WhiteScreen = self.Library.WhiteScreen or false,
			Transparency = self.Library.Transparency or true,
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

    function InterfaceManager:SetFPSCap(Toggle)
        assert(self.Library, "Must set InterfaceManager.Library")
        if not Toggle then return end

        table.foreach(self.Library.Options, print)

        -- repeat task.wait(0.1)
        -- until not Options.InterfaceManager_LockFPSToggle.Value;
    end

    function InterfaceManager:BuildInterfaceSection(tab)
        assert(self.Library, "Must set InterfaceManager.Library")

		local Library = self.Library
        local Settings = InterfaceManager.Settings

        InterfaceManager:LoadSettings()

		local visuals = tab:AddSection("Visuals Settings")

        -- visuals:AddSlider("InterfaceManager_FPSCap", {
        --     Title = "FPS Cap",
        --     Description = "Limits the game's frame rate to improve performance.",
        --     Default = 240,
        --     Min = 0,
        --     Max = 240,
        --     Rounding = 0,
        --     Callback = function(Value)
        --         InterfaceManager:SaveSettings()
        --     end
        -- })

        visuals:AddToggle("InterfaceManager_LockFPSToggle", {
			Title = "Enable FPS Cap",
			Description = "Turn on/off the FPS limiter.",
			Default = Settings.EnableFPSCap,
			Callback = function(Value)
                self:SetFPSCap(Value)
                Settings.EnableFPSCap = Value
                InterfaceManager:SaveSettings()
			end
		})
        
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

	
		section:AddToggle("InterfaceManager_TransparentToggle", {
			Title = "Transparency",
			Description = "Makes the interface transparent.",
			Default = Settings.Transparency,
			Callback = function(Value)
				Library:ToggleTransparency(Value)
				Settings.Transparency = Value
                InterfaceManager:SaveSettings()
			end
		})
	
		local MenuKeybind = section:AddKeybind("InterfaceManager_MenuKeybind", {
			Title = "Minimize Bind", 
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
