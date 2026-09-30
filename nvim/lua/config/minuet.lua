-- FIM-capable Ollama models for MacBook M5 Pro 24GB, set via $OLLAMA_COMPLETION_MODEL
-- (verify FIM support: `ollama show --template <model> | grep Suffix`):
--   qwen2.5-coder:1.5b-base            ~1GB, fastest, weaker suggestions
--   qwen2.5-coder:3b-base              ~2GB, good speed/quality balance
--   qwen2.5-coder:7b-base              ~5GB, default, best all-rounder
--   qwen2.5-coder:14b-base             ~9GB, better quality, noticeably slower
--   deepseek-coder-v2:16b-lite-base    ~9GB, MoE (~2.4B active), fast for its size
--   codestral:22b                      ~13GB, strong FIM, heavy, non-commercial license
--   starcoder2:7b / starcoder2:15b     ~4GB / ~9GB, older alternative
--   codegemma:7b-code                  ~5GB, older alternative
require("minuet").setup({
	notify = "warn",
	provider = "openai_fim_compatible",
	context_window = 1024,
	n_completions = 1,
	add_single_line_entry = false,
	provider_options = {
		openai_fim_compatible = {
			api_key = "TERM",
			name = "Ollama",
			end_point = "http://localhost:11434/v1/completions",
			model = vim.env.OLLAMA_COMPLETION_MODEL or "qwen2.5-coder:7b-base",
			optional = {
				max_tokens = 128,
				top_p = 0.9,
				stop = { "\n\n" },
			},
		},
	},
	virtualtext = {
		auto_trigger_ft = { "lua", "go", "python" },
		keymap = {
			accept = "<Tab>",
			accept_line = "<C-l>",
			next = "<C-]>",
			dismiss = "<C-e>",
		},
	},
	throttle = 150,
})
