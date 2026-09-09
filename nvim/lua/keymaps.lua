local function register_mappings(mappings, default_options)
	for mode, mode_mappings in pairs(mappings) do
		for _, mapping in pairs(mode_mappings) do
			-- mapping formats supported:
			-- { lhs, rhs }
			-- { lhs, rhs, opts }
			-- { lhs, rhs, "Description" }               -- convenience: pass desc as 3rd string
			-- { lhs, rhs, { desc = "Description", ...}} -- full opts with desc
			local lhs, rhs, third = mapping[1], mapping[2], mapping[3]
			local opts = vim.deepcopy(default_options or {})

			if type(third) == "string" then
				opts.desc = third
			elseif type(third) == "table" then
				for k, v in pairs(third) do
					opts[k] = v
				end
			end

			pcall(vim.keymap.set, mode, lhs, rhs, opts)
		end
	end
end

local mappings = {
	i = {
		-- Insert mode
		{ "jk", "<ESC>" },
		-- Terminal window navigation
		{ "<C-h>", "<C-\\><C-N><C-w>h" },
		{ "<C-j>", "<C-\\><C-N><C-w>j" },
		{ "<C-k>", "<C-\\><C-N><C-w>k" },
		{ "<C-l>", "<C-\\><C-N><C-w>l" },
	},
	n = {
		-- Normal mode
		-- remap ; to C-w
		{ ";", "<C-w>" },
		{ ";;", "<C-w>w" },
		-- Better window movement
		{ "<C-h>", "<C-w>h" },
		{ "<C-j>", "<C-w>j" },
		{ "<C-k>", "<C-w>k" },
		{ "<C-l>", "<C-w>l" },
		-- resize with arrows
		{ "<C-Up>", ":resize -2<CR>" },
		{ "<C-Down>", ":resize +2<CR>" },
		{ "<C-Left>", ":vertical resize -2<CR>" },
		{ "<C-Right>", ":vertical resize +2<CR>" },
		-- tab navigation
		-- {"<leader>nt", ":tabnew<cr>"},
		-- {"<leader>pp", ":tabprevious<cr>"},
		-- {"<leader>nn", ":tabnext<cr>"},
		-- {"<C-j>", "<C-w>j", {silent = true}},
		-- {"<C-k>", "<C-w>k", {silent = true}},

		-- Resize with arrows
		-- {"<C-Up>", ":resize -2<CR>"},
		-- {"<C-Down>", ":resize +2<CR>"},
		-- {"<C-Left>", ":vertical resize -2<CR>"},
		-- {"<C-Right>", ":vertical resize +2<CR>"},
		-- Telescope
		-- Ctrl + p fuzzy files
		-- { "<C-p>", ":Telescope find_files<cr>" },
		-- { "<leader>ff", ":Telescope find_files<cr>" },
		-- { "<leader>fb", ":Telescope buffers<cr>" },
		-- { "<leader>b", ":Telescope buffers<cr>" },
		-- { "<leader>fs", ":Telescope live_grep<cr>" },
		-- { "<leader>k", ":Telescope keymaps<cr>" },
		-- Escape clears highlight after search
		{ "<esc>", ":noh<cr><esc>" },
		-- lsp
		{ "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>" },
		{ "<leader>gd", "<cmd>lua vim.lsp.buf.definition()<CR>" },
		{ "<leader>gr", "<cmd>lua vim.lsp.buf.references()<CR>" },
		{ "<leader>gi", "<cmd>lua vim.lsp.buf.implementation()<CR>" },
		{ "<leader>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>" },
		{ "<leader>e", "<cmd>lua vim.lsp.buf.show_line_diagnostics()<CR>" },
		{ "<leader>k", "<cmd>lua vim.lsp.buf.signature_help()<CR>" },
		{ "K", "<cmd>lua vim.lsp.buf.hover()<CR>" },
		-- {"<leader>p", "<cmd>lua vim.lsp.buf.formatting()<CR>"},
		{ "<leader>p", ":Format<CR>" },
		-- lspsaga
		{ "gh", ":Lspsaga finder<cr>" },
		{ "<leader>ca", ":Lspsaga code_action<cr>" },
		-- {"K", ":Lspsaga hover_doc<cr>"},
		{ "<C-f>", ':lua require("lspsaga.action").smart_scroll_with_saga(1)<cr>' },
		{ "<C-b>", ':lua require("lspsaga.action").smart_scroll_with_saga(-1)<cr>' },
		-- { "<leader>sh", ":Lspsaga signature_help<cr>" },
		{ "gr", ":Lspsaga rename<cr>" },
		{ "gD", ":Lspsaga preview_definition<cr>" },
		{ "gl", ":Lspsaga show_line_diagnostics<cr>" },
		{ "C-f", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>" },
		{ "C-b", "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>" },
		{ "]e", ":Lspsaga diagnostic_jump_next<CR>" },
		{ "[e", ":Lspsaga diagnostic_jump_prev<CR>" },
		-- reload
		{ "<leader>vl", ":vsp $MYVIMRC<cr>" },
		{ "<leader>vk", ":vsp $HOME/.config/nvim/lua/keymaps.lua<cr>" },
		{ "<leader>vp", ":vsp $HOME/.config/nvim/lua/plugins.lua<cr>" },
		{ "<leader>vs", ":vsp $HOME/.config/nvim/lua/settings.lua<cr>" },
		{ "<leader>vf", ":vsp $HOME/.config/nvim/lua/plugin/formatter.lua<cr>" },
		{ "<leader>vr", ":Reload<cr>" },
		-- Disable entering Ex mode
		{ "Q", "<Nop>" },
		-- highlight search
		{ "//", ":nohlsearch<CR>" },
		{ "<leader>hl", ":set hlsearch! hlsearch?<CR>" },
		-- Tab switch buffer
		{ "<TAB>", ":bnext<CR>" },
		{ "<S-TAB>", ":bprevious<CR>" },
		-- Other
		{ "<leader>q", ":bdelete<CR>" },
		{ "<leader>Q", ":BufOnly<CR>" },
		-- Flutter Developement
		{ "<leader>Fa", "<cmd>FlutterRun<CR>" },
		{ "<leader>Fq", "<cmd>FlutterQuit<CR>" },
		{ "<leader>Fr", "<cmd>FlutterReload<CR>" },
		{ "<leader>FR", "<cmd>FlutterRestart<CR>" },
		{ "<leader>FD", "<cmd>FlutterVisualDebug<CR>" },
		{ "<leader>FF", "<cmd>FlutterCopyProfilerUrl<CR>" },
		{ "<leader>y", '"+y' }, -- Copy to clipboard
		{ "<leader>Y", 'gg"+yG' }, -- Copy whole document to clipboard
		{ "<localleader>t", ':echo "Hello, world!"<cr>' },
		{ "<leader>cl", ":CodeCompanion<CR>" },
		{ "<leader>cc", ":CodeCompanionChat<CR>" },
		{ "<leader>ct", ":CodeCompanionAction<CR>" },
		{
			"<leader>td",
			function()
				require("neotest").run.run({ suite = false, strategy = "dap" })
			end,
			desc = "Debug nearest test",
		},
	},
	t = {
		-- Terminal mode
		-- Tejrminal window navigation
		{ "<C-h>", "<C-\\><C-N><C-w>h" },
		{ "<C-j>", "<C-\\><C-N><C-w>j" },
		{ "<C-k>", "<C-\\><C-N><C-w>k" },
		{ "<C-l>", "<C-\\><C-N><C-w>l" },
		-- map escape to normal mode in terminal
		{ "<Esc>", [[ <C-\><C-n> ]] },
		{ "jk", [[ <C-\><C-n> ]] },
	},
	v = {
		-- Visual/Select mode
		-- Better indenting
		{ "<", "<gv" },
		{ ">", ">gv" },
		-- hop words
		{ "f", "<cmd>lua require'hop'.hint_words()<cr>" },
		-- lspsago
		{ "<leader>ca", "<C-U>Lspsaga range_code_action<cr>" },
		-- hop
		{ "<leader><leader>", ":HopChar1Visual<cr>" },
		-- Buffer Copy & Paste
		{ "<leader>cy", ":w! ~/.vimbuf<cr>" },
		{ "<leader>cp", ":r ~/.vimbuf<cr>" },
		{ "<leader>y", '"+y' }, -- Copy to clipboard
		{ "<localleader>ce", ":CodeCompanion /expert<cr>" },
		{ "<localleader>ct", ":CodeCompanion /gotest<cr>" },
	},
	x = {
		-- Move selected line / block of text in visual mode
		{ "K", ":move '<-2<CR>gv-gv" },
		{ "J", ":move '>+1<CR>gv-gv" },
	},
}

register_mappings(mappings, { silent = true, noremap = true })

local mappings_not_silent = {
	n = {
		-- Rip grep search
		{ "<leader>s", ":Rg<space>" },
		-- Buffer Copy
		{ "<leader>cy", ":.w! ~/.vimbuf" },
		{ "<leader>cp", ":r ~/.vimbuf<cr>" },
	},
}
register_mappings(mappings_not_silent, { silent = false, noremap = true })

vim.api.nvim_set_keymap("n", "<leader>ta", ":$tabnew<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tc", ":tabclose<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>to", ":tabonly<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tn", ":tabn<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>tp", ":tabp<CR>", { noremap = true })
-- move current tab to previous position
vim.api.nvim_set_keymap("n", "<leader>tmp", ":-tabmove<CR>", { noremap = true })
-- move current tab to next position
vim.api.nvim_set_keymap("n", "<leader>tmn", ":+tabmove<CR>", { noremap = true })
