vim.opt.mouse = "" -- disable mouse
-- vim.opt.relativenumber = true
vim.opt.ttyfast = true
vim.opt.lazyredraw = true
-- vim.opt.cursorline = true -- show the cursor line

vim.opt.hidden = true
vim.o.undofile = true -- no undo file
-- vim.opt.cursorcolumn = true -- show the cursor column
vim.opt.colorcolumn = "80"
vim.opt.incsearch = true --Lookahead as search pattern is specified
vim.opt.ignorecase = true -- Ignore case in all searches...
vim.opt.smartcase = true -- ...unless uppercase letters used
vim.opt.hlsearch = true -- ...unless uppercase letters used

-- indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true -- spaces instead of tabs
vim.cmd("autocmd FileType python set tabstop=4|set shiftwidth=4")
vim.cmd("autocmd FileType rust set tabstop=4|set shiftwidth=4")
vim.cmd("autocmd FileType haskell set tabstop=4|set shiftwidth=4")
vim.cmd("autocmd FileType go set tabstop=4|set shiftwidth=4|set noexpandtab")
vim.cmd("autocmd FileType cpp set tabstop=4|set shiftwidth=4")
vim.cmd("autocmd FileType c set tabstop=4|set shiftwidth=4|set noexpandtab")
vim.cmd("autocmd FileType make,nginx set tabstop=4|set shiftwidth=4|set noexpandtab")
-- rust
vim.cmd("autocmd BufRead,BufNewFile Cargo.toml,Cargo.lock,*.rs compiler cargo")

vim.opt.number = true
vim.opt.wrap = true
vim.opt.textwidth = 80
vim.opt.linebreak = true
vim.opt.scrolloff = 10
vim.opt.cmdheight = 2
vim.opt.showmode = false
vim.opt.numberwidth = 5 -- wider gutter
vim.opt.linebreak = true -- don't break words on wrap
vim.opt.spelllang = "en"
vim.opt.smartindent = true
vim.opt.completeopt = "menuone,noselect" -- nvim-compe
vim.opt.signcolumn = "yes" -- always show the signcolumn
vim.opt.termguicolors = true
-- vim.opt.title = true
-- spelling
-- vim.opt.spell = true
vim.opt.spelllang = "en_gb"
vim.opt.mousemodel = "popup"

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3

-- close tags
vim.g.closetag_filenames = "*.html,*.xhtml,*.phtml,*.php,*.jsx,*.js,*.tsx,*.vue"

-- set colour scheme
vim.g.tokyonight_style = "night"
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_sidebars = { "qf", "vista_kind", "terminal", "packer" }
-- vim.g.tokyonight_transparent = true
-- vim.g.tokyonight_dark_sidebar = false

-- Change the "hint" color to the "orange" color, and make the "error" color bright red
vim.cmd([[colorscheme tokyonight]])
vim.g.tokyonight_colors = { hint = "orange", error = "#ff0000" }

-- highlight on yank
vim.cmd([[au TextYankPost * silent! lua vim.highlight.on_yank()]])

-- Vertically center document when entering insert mode
-- vim.cmd [[autocmd InsertEnter * norm zz]]
-- python
-- vim.g.python3_host_prog = "/usr/local/bin/python3"
-- vim.g.python_host_prog = "/usr/bin/python"

-- set nginx file type for nginx highlight plugin "chr4/nginx.vim"
vim.cmd("au BufNewFile,BufRead *.nginx set ft=nginx")
vim.cmd("au BufNewFile,BufRead nginx*.conf set ft=nginx")
vim.cmd("au BufNewFile,BufRead *nginx.conf set ft=nginx")

vim.cmd([[highlight! CursorLineNr ctermfg=NONE ctermbg=NONE cterm=NONE guifg=NONE guibg=NONE gui=NONE]])
-- vim.o.cursorline = true
-- vim.o.cursorlineopt = "number"
-- set clipboard=unnamed,unnamedplus
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
-- Enable debug log only when needed
-- vim.lsp.set_log_level("debug")
vim.lsp.set_log_level("off")
vim.g.copilot_filetypes = { markdown = false, zsh = false }
vim.g.copilot_enabled = vim.env.AI_COMPLETION_PROVIDER == "copilot"

vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function(args)
		pcall(vim.treesitter.start, args.buf)
	end,
})
