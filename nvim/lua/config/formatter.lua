-- Examples: https://github.com/mhartington/formatter.nvim/blob/master/CONFIG.md
-- Prettier function for formatter
-- npm install -g prettier
local function prettier()
	return {
		exe = "prettier",
		args = { "--bracket-same-line", "--stdin-filepath", vim.fn.fnameescape(vim.api.nvim_buf_get_name(0)) },
		stdin = true,
	}
end

local function clangd()
	return {
		exe = "clang-format",
		args = { "--assume-filename", vim.api.nvim_buf_get_name(0) },
		stdin = true,
		cwd = vim.fn.expand("%:p:h"), -- Run clang-format in cwd of the file.
	}
end

-- pip install black
local function black()
	return { exe = "black", args = { "--quiet", "-" }, stdin = true }
end

-- pip install isort
local function isort()
	return { exe = "isort", args = { "--quiet", "-" }, stdin = true }
end

local function ruff_format()
	return {
		exe = "ruff",
		args = { "format", "--stdin-filename", vim.api.nvim_buf_get_name(0), "-" },
		stdin = true,
	}
end

local function golines()
	return { exe = "golines", args = { "--max-len=80" }, stdin = true }
end

local function gofmt()
	return { exe = "gofmt", args = { "-s" }, stdin = true }
end

local function gofumpt()
	return { exe = "gofumpt", args = { "-s" }, stdin = true }
end

local function shfmt()
	return { exe = "shfmt", args = { "-i", "2", "-ci" }, stdin = true }
end

local function gogci()
	return {
		exe = "gci",
		args = {
			"print",
			"--skip-generated",
			"-s",
			"standard",
			"-s",
			"default",
			"-s",
			"prefix(github.com/inDriver)",
			"-s",
			"localmodule",
			"--custom-order",
		},
		stdin = true,
	}
end

local function goimports()
	return { exe = "goimports", args = { "-local", "github.com/inDriver" }, stdin = true }
end

local function rustfmt()
	return { exe = "rustfmt", args = { "--emit=stdout", "--edition 2021" }, stdin = true }
end

-- go install github.com/google/yamlfmt/cmd/yamlfmt@latest
local function yamlfmt()
	return { exe = "yamlfmt", args = { "-in" }, stdin = true }
end

local function nixfmt()
	return { exe = "nixfmt", args = {}, stdin = true }
end

-- brew install ghcup
-- stack install stylish-haskell
local function stylish_haskell()
	return { exe = "stylish-haskell", stdin = true }
end

local function ocamlformat()
	return { exe = "ocamlformat", stdin = true }
end

-- zig fmt ships with the zig toolchain
local function zigfmt()
	return { exe = "zig", args = { "fmt", "--stdin" }, stdin = true }
end

local function latexindent()
	return { exe = "latexindent", args = {
		"-g",
		"/dev/null",
	}, stdin = true }
end

local function sleeksql()
	return {
		exe = "sleek",
		args = {},
		stdin = false,
	}
end

local util = require("formatter.util")

require("formatter").setup({
	logging = false,
	filetype = {
		typescriptreact = { prettier },
		javacriptreact = { prettier },
		javascript = { prettier },
		typescript = { prettier },
		svelte = { prettier },
		json = { prettier },
		html = { prettier },
		css = { prettier },
		scss = { prettier },
		markdown = { prettier },
		vue = { prettier },
		yaml = { yamlfmt },
		nix = { nixfmt },
		-- htmldjango = {prettier},
		lua = {
			-- "formatter.filetypes.lua" defines default configurations for the
			-- "lua" filetype
			require("formatter.filetypes.lua").stylua,

			-- You can also define your own configuration
			function()
				-- Supports conditional formatting
				if util.get_current_buffer_file_name() == "special.lua" then
					return nil
				end

				-- Full specification of configurations is down below and in Vim help
				-- files
				return {
					exe = "stylua",
					args = {
						"--search-parent-directories",
						"--stdin-filepath",
						util.escape_path(util.get_current_buffer_file_path()),
						"--",
						"-",
					},
					stdin = true,
				}
			end,
		},
		cpp = { clangd },
		c = { clangd },
		rust = { rustfmt },
		-- python = { black, isort },
		python = { ruff_format },
		go = {
			gofumpt,
			gogci,
			goimports,
			golines,
		},
		perl = {
			-- perltidy
			function()
				return {
					exe = "perltidy",
					args = { "--standard-output" },
					stdin = true,
				}
			end,
		},
		haskell = { stylish_haskell },
		ocaml = { ocamlformat },
		tex = { latexindent },
		sql = { sleeksql },
		sh = { shfmt },
		zig = { zigfmt },
	},
})

-- Runs Prettier on save
vim.api.nvim_exec(
	[[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost *.js,*.ts,*.tsx,*.css,*.scss,*.md,*.lua,.*json,*.vue : FormatWrite
augroup END
]],
	true
)
