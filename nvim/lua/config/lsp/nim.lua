local function strip_json_null(value)
	if value == vim.NIL then
		return nil
	end

	if type(value) ~= "table" then
		return value
	end

	if vim.islist(value) then
		local list = {}
		for _, item in ipairs(value) do
			list[#list + 1] = strip_json_null(item)
		end
		return list
	end

	local map = {}
	for key, item in pairs(value) do
		map[key] = strip_json_null(item)
	end
	return map
end

local sanitized_methods = {
	["textDocument/completion"] = true,
	["completionItem/resolve"] = true,
}

local function sanitize_responses(client)
	local request = client.request

	client.request = function(self, method, params, handler, bufnr)
		if not (handler and sanitized_methods[method]) then
			return request(self, method, params, handler, bufnr)
		end

		return request(self, method, params, function(err, result, ctx, config)
			return handler(err, strip_json_null(result), ctx, config)
		end, bufnr)
	end
end

return {
	on_init = sanitize_responses,
}
