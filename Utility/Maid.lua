local Signal = loadstring(game:HttpGet('https://raw.githubusercontent.com/NewMeO/CosXHub/refs/heads/main/Utility/Signal.lua'))()

local Maid = {}
Maid.ClassName = "Maid"

function Maid.new()
	return setmetatable({
		_tasks = {}
	}, Maid)
end

function Maid.__index(self, index)
	if Maid[index] then
		return Maid[index]
	else
		return self._tasks[index]
	end
end

function Maid:__newindex(index, newTask)
	if Maid[index] ~= nil then
		error(("'%s' is reserved"):format(tostring(index)), 2)
	end

	local tasks = self._tasks
	local oldTask = tasks[index]

	if oldTask == newTask then
		return
	end

	tasks[index] = newTask

	if oldTask then
		if type(oldTask) == "function" then
			oldTask()
		elseif typeof(oldTask) == "RBXScriptConnection" then
			oldTask:Disconnect();
		elseif typeof(oldTask) == 'table' then
			oldTask:Remove();
		elseif (Signal.isSignal(oldTask)) then
			oldTask:Destroy();
		elseif (typeof(oldTask) == 'thread') then
			task.cancel(oldTask);
		elseif oldTask.Destroy then
			oldTask:Destroy();
		end
	end
end

function Maid:GiveTask(task)
	if not task then
		error("Task cannot be false or nil", 2)
	end

	local taskId = #self._tasks+1
	self[taskId] = task

	return taskId
end

return Maid;
