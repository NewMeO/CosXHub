local httpService = game:GetService("HttpService")

local SaveManager = {} do
	SaveManager.Folder = "FluentSettings"
	SaveManager.Ignore = {}
	SaveManager.Options, SaveManager.Library = {} :: { [string]: {Type: string, Value: any, SetValues: (self: any, NewValue: { [any]: any }) -> nil, SetValue: (self: any, NewValue: any, ...any) -> nil, SetValueRGB: (self: any, NewValue: Color3, Transparency: number?) -> nil} }, {}
	SaveManager.Parser = {
		Toggle = {
			Save = function(idx, object) 
				return { type = "Toggle", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt } 
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Slider = {
			Save = function(idx, object)
				return { type = "Slider", idx = idx, value = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Dropdown = {
			Save = function(idx, object)
				return { type = "Dropdown", idx = idx, value = object.Value, mutli = object.Multi, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.value)
				end
			end,
		},
		Colorpicker = {
			Save = function(idx, object)
				return { type = "Colorpicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
				end
			end,
		},
		Keybind = {
			Save = function(idx, object)
				return { type = "Keybind", idx = idx, mode = object.Mode, key = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] then 
					SaveManager.Options[idx]:SetValue(data.key, data.mode)
				end
			end,
		},

		Input = {
			Save = function(idx, object)
				return { type = "Input", idx = idx, text = object.Value, Timestamp = object.Instance.CreatedAt }
			end,
			Load = function(idx, data)
				if SaveManager.Options[idx] and type(data.text) == "string" then
					SaveManager.Options[idx]:SetValue(data.text)
				end
			end,
		},
	}

	function SaveManager:Save()
		local fullPath = `{self.Folder}/settings/{game.Players.LocalPlayer.Name}.json`

		local data = {
			objects = {}
		}

		for idx, option in next, SaveManager.Options do
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

	function SaveManager:Load()
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

	function SaveManager:BuildFolderTree()
		local paths = {
			self.Folder,
			`{self.Folder}/settings`
		}

		for i = 1, #paths do
			local str = paths[i]
			if not isfolder(str) then
				makefolder(str)
			end
		end
	end

	function SaveManager:LoadAutoloadConfig(library, folder)
		self.Library = library
        self.Options = library.Options
        self.Folder = folder;

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

	SaveManager:BuildFolderTree()
end

return SaveManager
