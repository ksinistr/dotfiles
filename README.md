# Vim (neovim) config for C/C++ projects in 42 school
## Requirements
* Mac or Linux
* [Neovim](https://neovim.io/)
* [Silver Searcher (ag)](https://github.com/ggreer/the_silver_searcher)
## Step by step configuration
#### 0. Install nodejs >= 10.12 for Coc.nvim plugin:
```bash
curl -sL install-node.now.sh/lts | bash
```
#### 1. Clone this repo to `~/dotfiles`
```bash
git clone https://github.com/sun604/dotfiles ~/dotfiles
```
#### 2. Symlinking init.vim to .vimrc
```bash
ln -s ~/dotfiles/.vimrc ~/.config/nvim/init.vim
```
#### 3. Replacing `vi` and `vim` commands with neovim
Add this aliases in your `.profile`, for zsh this will be `.zshrc`
```bash
alias vim="nvim"
alias vi="nvim"
alias oldvim="/usr/bin/vim"
```
#### 4. Replace default ctags in macos with [universal ctags](https://github.com/universal-ctags/ctags)
Install universal ctags:
```bash
brew install ctags
```
Add this alias in your `.profile` (for zsh this will be `.zshrc`):
```bash
alias ctags="`brew --prefix`/bin/ctags  -R --exclude=.git"
```
To generate `tags` file for vim (neovim), run in project folder:
```bash
ctags .
```
#### 5. Install [cscope](http://cscope.sourceforge.net/)
```bash
brew install cscope
```
To generate `cscope.out` file for vim (neovim), run in project folder:
```bash
cscope -R -b .
```
#### 6. Install [Silver Searcher (Ag)](https://github.com/ggreer/the_silver_searcher)
```bash
brew install the_silver_searcher
```
Your can add bellow command to `~/.zshrc`
```bash
export FZF_DEFAULT_COMMAND='ag -g ""'
```
#### 7. Open vim and run `:PlugInstall` to install all plugins
#### 8. Install [coc.nvim](https://github.com/neoclide/coc.nvim) plugin dependencies
>	Coc.vim used for:
>	* language and project specific autocompletion and suggestions;
>	* error markups;
>	* functions and structures documentation.
##### 8.1 Install [clangd](https://github.com/clangd/clangd)
1. Download latest stable release https://github.com/clangd/clangd/releases/tag/10.0.0
2. Unpack it to ~/clangd/bin ~/clangd/lib
3. Add to `~/.zshrc`:
```bash
export PATH="/Users/<name>/clangd/bin:/Users/<name>/clangd/lib:$PATH"
```
4. Open vim, run `:CocConfig` and place this config:
```json
{
    "languageserver": {
        "clangd": {
            "command": "clangd",
            "rootPatterns": ["compile_flags.txt", "compile_commands.json"],
            "filetypes": ["c", "cpp", "objc", "objcpp"]
        }
    }
}
```
##### 8.2 Install [Bear](https://github.com/rizsotto/Bear)
Bear can make project setup for clangd.
It can be installed via homebrew:
```bash
brew install bear
```
Below command in project folder will generate file `compile_commands.json` for clangd:
```bash
make clean; bear make
```
#### 9 clang-format
Add into project `.clang-format` with following content. 
This will disable autoformatting code with coc.nvim.
```
DisableFormat: true
```

## Useful links
* https://wiki.archlinux.org/index.php/Neovim
* https://guides.hexlet.io/vim/
* https://www.youtube.com/watch?v=79OWQ1qJwto
* https://github.com/mokevnin/dotfiles/blob/master/files/vimrc
* https://vimawesome.com/
* https://github.com/mcchrish/vim-no-color-collections
* https://medium.com/@galea/getting-started-with-ctags-vim-on-macos-87bcb07cf6d
