return {
	"milanglacier/minuet-ai.nvim",
	lazy = false,
	enabled = vim.env.AI_COMPLETION_PROVIDER == "ollama",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("config.minuet")
	end,
}
