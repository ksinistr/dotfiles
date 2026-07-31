" Sets UTF-8 encoding
set enc=utf-8
set fenc=utf-8
set termencoding=utf-8
set encoding=UTF-8
set fileformat=unix
set textwidth=79
set noexpandtab      " Use actual tabs instead of spaces
set copyindent       " Copy indent structure from previous line
set preserveindent   " Preserve indent structure when reindenting
set softtabstop=0    " Disable soft tabs (matches tabstop when 0)
set shiftwidth=4     " Number of spaces for each indentation level
set tabstop=4        " Number of spaces that a tab character represents

set number " Show current line number

set nocompatible
set autoindent
set smartindent
set nocindent        " Disable C-style indenting
filetype indent off
set colorcolumn=80

" set 2 space tabs for specific files with long lines
au BufNewFile,BufRead *.js,*.tsx,*.ts,*.jsx,*.css,*.html
    \ set tabstop=2 |
    \ set softtabstop=2 |
    \ set shiftwidth=2 |
    \ set expandtab

" Don't redraw while executing macros (good performance config)
set ttyfast
set lazyredraw
set cursorline

" Use space as leader (matches nvim); guarded for vim.tiny which lacks +eval
if 1
  let mapleader = " "
endif

" jk | Escaping!
imap jk <Esc>

" Disable entering Ex mode
nnoremap Q <Nop>

"====[ Set up smarter search behaviour ]=======================

set incsearch       "Lookahead as search pattern is specified
set ignorecase      "Ignore case in all searches...
set smartcase       "...unless uppercase letters used

set hlsearch        "Highlight all matches
nmap <silent> // :nohlsearch<CR>
noremap <leader>hl :set hlsearch! hlsearch?<CR>

"====[ Portable shortcuts mirrored from nvim ]==================

" Close only the active buffer, keeping the window layout
nnoremap <leader>q :bdelete<CR>

" Yank to the system clipboard
nnoremap <leader>y "+y
nnoremap <leader>Y gg"+yG
vnoremap <leader>y "+y

" Search the word under the cursor across the project with Vim's built-in grep
nnoremap <leader>s :vimgrep /\<<C-r><C-w>\>/ **/*<CR>:copen<CR>

" Ultra-minimal grayscale color scheme for vim-tiny,
" which lacks +syntax and +termguicolors
set background=dark
highlight clear
hi Normal ctermfg=252 ctermbg=235
hi LineNr ctermfg=240

" vim-tiny skips this entire block because it lacks +eval
if 1
  set termguicolors
  colorscheme habamax
  syntax on

  " Light, subtle line numbers (dim gray reads as thin in the terminal)
  hi LineNr guifg=#332f2b ctermfg=237
  hi CursorLineNr guifg=#5a5048 ctermfg=240 cterm=NONE gui=NONE

  " Auto-install plugins via Vim's native package system on first launch
  let s:plugins = [
    \ 'preservim/nerdtree',
    \ 'prabirshrestha/vim-lsp',
    \ 'mattn/vim-lsp-settings',
    \ 'prabirshrestha/asyncomplete.vim',
    \ 'prabirshrestha/asyncomplete-lsp.vim',
    \ 'sheerun/vim-polyglot',
    \ 'tpope/vim-commentary',
    \ 'easymotion/vim-easymotion',
    \ ]
  let s:pack_dir = expand('~/.vim/pack/plugins/start/')
  let s:installed = 0
  for s:repo in s:plugins
    let s:dest = s:pack_dir . split(s:repo, '/')[-1]
    if empty(glob(s:dest)) && executable('git')
      echo 'Installing ' . s:repo . '...'
      call system('git clone --depth 1 https://github.com/' . s:repo . ' ' . shellescape(s:dest))
      let s:installed = 1
    endif
  endfor
  if s:installed
    packloadall
    silent! helptags ALL
  endif

  " Open NERDTree on the right side of the window
  let g:NERDTreeWinPos = 'right'

  " NERDTree keybindings (matching nvim: <C-n> toggle, <leader>n find file)
  nnoremap <C-n> :NERDTreeToggle<CR>
  nnoremap <leader>n :NERDTreeFind<CR>

  " EasyMotion: label every target on screen and jump to it (mirrors hop.nvim)
  let g:EasyMotion_do_mapping = 0       " Only use the explicit maps below
  let g:EasyMotion_smartcase = 1
  let g:EasyMotion_keys = 'etovxqpdygfblzhckisuran'
  nmap f <Plug>(easymotion-bd-w)
  xmap f <Plug>(easymotion-bd-w)
  omap f <Plug>(easymotion-bd-w)
  nmap F <Plug>(easymotion-bd-jk)
  xmap F <Plug>(easymotion-bd-jk)
  nmap <leader>, <Plug>(easymotion-bd-f)
  xmap <leader>, <Plug>(easymotion-bd-f)

  " Show diagnostics in the cmdline at cursor instead of an ugly floating window
  let g:lsp_diagnostics_echo_cursor = 1
  let g:lsp_diagnostics_float_cursor = 0

  " LSP keybindings, active only in buffers with a language server attached
  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gh <plug>(lsp-references)
    nmap <buffer> K  <plug>(lsp-hover)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> <leader>p <plug>(lsp-document-format)
    xmap <buffer> <leader>p <plug>(lsp-document-range-format)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
  endfunction
  augroup lsp_install
    autocmd!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  augroup END

  " Completion popup (asyncomplete)
  set completeopt=menuone,noinsert,noselect
  set shortmess+=c
  " Tab / Shift-Tab to cycle the popup, Enter to confirm
  inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
  inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  inoremap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"
endif
