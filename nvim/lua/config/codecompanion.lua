local providers = require("codecompanion.providers")

local constants = {
	LLM_ROLE = "llm",
	USER_ROLE = "user",
	SYSTEM_ROLE = "system",
}

local default_adapter
if vim.env.CODECOMPANION_ADAPTER then
	default_adapter = vim.env.CODECOMPANION_ADAPTER
else
	default_adapter = "copilot"
end

require("codecompanion").setup({
	opts = {
		log_level = "DEBUG",
	},
	display = {
		chat = {
			-- show_settings = true,
		},
		action_palette = {
			width = 95,
			height = 10,
			prompt = "Prompt ", -- Prompt used for interactive LLM calls
			provider = "snacks", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
			opts = {
				show_preset_actions = true, -- Show the default actions in the action palette?
				show_preset_prompts = true, -- Show the default prompt library in the action palette?
			},
		},
		diff = {
			-- Default provider: Commands: do/dp (obtain/put), Exit: :diffoff, :q
			-- Mini-diff: Inline changes with colors, Nav: Commands: =a/=A (apply hunk/all)
			-- Use gda to accept, gdr to reject changes (auto-exits when all changes handled)
			enabled = true,
			close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
			layout = "vertical", -- vertical|horizontal split for default provider
			opts = {
				"internal",
				"filler",
				"closeoff",
				"algorithm:histogram",
				"indent-heuristic",
				"followwrap",
				"linematch:120",
			},
			provider = providers.diff,
			-- provider = "mini_diff", -- default|mini_diff
			diff_signs = {
				signs = {
					text = "▌", -- Sign text for normal changes
					reject = "✗", -- Sign text for rejected changes in super_diff
					highlight_groups = {
						addition = "DiagnosticOk",
						deletion = "DiagnosticError",
						modification = "DiagnosticWarn",
					},
				},
				-- Super Diff options
				icons = {
					accepted = " ",
					rejected = " ",
				},
				colors = {
					accepted = "DiagnosticOk",
					rejected = "DiagnosticError",
				},
			},
		},
	},
	strategies = {
		chat = {
			adapter = default_adapter,
		},
		inline = {
			adapter = default_adapter,
			keymaps = {
				accept_change = {
					modes = { n = "gda" }, -- Remember this as DiffAccept
				},
				reject_change = {
					modes = { n = "gdr" }, -- Remember this as DiffReject
				},
				always_accept = {
					modes = { n = "gdy" }, -- Remember this as DiffYolo
				},
			},
		},
	},
	adapters = {
		http = {
			copilot = function()
				return require("codecompanion.adapters.http").extend("copilot", {
					name = "copilot",
					schema = {
						model = {
							default = "claude-sonnet-4.6",
							-- choices = {
							-- 	"gpt-5-mini",
							-- 	"gpt-4.1",
							-- 	"grok-code-fast-1",
							-- 	"claude-3.7-sonnet",
							-- 	"gemini-2.5-pro",
							-- },
						},
					},
				})
			end,
			openrouter = function()
				return require("codecompanion.adapters.http").extend("openai_compatible", {
					env = {
						url = "https://openrouter.ai/api",
						api_key = "OPENROUTER_API_KEY",
						chat_url = "/v1/chat/completions",
					},
					schema = {
						model = {
							default = "xiaomi/mimo-v2.5",
							choices = {
								"minimax/minimax-m3",
								"xiaomi/mimo-v2.5",
								"z-ai/glm-5.2",
								"deepseek/deepseek-v4-flash",
								"anthropic/claude-opus-4.7",
							},
						},
					},
				})
			end,
		},
	},
	prompt_library = {
		["Buffer Chat"] = {
			strategy = "chat",
			description = "Chat with current buffer auto-attached (pinned)",
			opts = {
				mapping = "<Leader>ce",
				modes = { "n" },
				alias = "buf", -- use :CodeCompanion /buf
				-- user_prompt = true, -- ask for your message each time
				auto_submit = false,
			},
			prompts = {
				{
					role = "user",
					content = "#{buffer}{diff} ",
					opts = { contains_code = true },
				},
			},
		},
		["Code Expert"] = {
			strategy = "chat",
			description = "Get some special advice from an LLM",
			opts = {
				mapping = "<LocalLeader>ce",
				modes = { "v" },
				alias = "expert",
				auto_submit = true,
				stop_context_insertion = true,
				user_prompt = true,
			},
			prompts = {
				{
					role = "system",
					content = function(context)
						return "I want you to act as a senior "
							.. context.filetype
							.. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples."
							.. "Don't reply on this message, just wait for the questions."
					end,
				},
				{
					role = "user",
					content = function(context)
						local text =
							require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

						return "I have the following code:\n\n```" .. context.filetype .. "\n" .. text .. "\n```\n\n"
					end,
					opts = {
						contains_code = true,
					},
				},
			},
		},
		["Golang unit tests"] = {
			strategy = "chat",
			description = "Write unit tests for selected code",
			opts = {
				mapping = "<LocalLeader>ct",
				modes = { "v" },
				alias = "gotest",
				auto_submit = true,
				stop_context_insertion = true,
				user_prompt = false,
			},
			prompts = {
				{
					role = constants.SYSTEM_ROLE,
					content = function(context)
						return "I want you to act as a senior Go "
							.. " developer. I will ask you specific questions and I want you to return concise explanations and codeblock examples."
							.. "@mcp Use from memory bank programming/go-test-guidelines.md if available."
							.. "Don't reply on this message, just wait for the questions."
					end,
				},
				{
					role = "user",
					content = function(context)
						local text =
							require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)

						return "@mcp Use go test guidelines from memory bank, try to find go-test-guidelines in memory bank.\n\n"
							.. "I have the following code:\n\n```"
							.. context.filetype
							.. "\n"
							.. text
							.. "\n```\n\n"
					end,
					opts = {
						contains_code = true,
					},
				},
			},
		},
	},
})
