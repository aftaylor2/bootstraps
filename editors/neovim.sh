#!/usr/bin/env bash
# Configures neoVim
# by: Andrew Taylor < aftaylor2@gmail.com >

CONFIG_DIR=~/.config/nvim

install_nvim () {
  pkgs='neovim'
  if [ -x "$(command -v brew)" ]; then brew install $pkgs
  elif [ -x "$(command -v apk)" ]; then sudo apk add --no-cache $pkgs
  elif [ -x "$(command -v apt-get)" ]; then sudo apt-get install -y $pkgs
  elif [ -x "$(command -v pacman)" ]; then sudo pacman -Sy --noconfirm $pkgs
  elif [ -x "$(command -v dnf)" ]; then sudo dnf install $pkgs
  elif [ -x "$(command -v zypper)" ]; then sudo zypper install $pkgs
  else echo "ERROR: Package Manager not found!";
fi
}

cd ~ &&

NVIM_BINARY=$(which nvim)

[ -f "$NVIM_BINARY" ] && echo "NeoVim installation found!" || install_nvim

mkdir -p $CONFIG_DIR

if [[ -f "$CONFIG_DIR/init.vim" ]]; then
    mv "$CONFIG_DIR/init.vim" "$CONFIG_DIR/init.old.vim"
fi

cat <<EOT >> $CONFIG_DIR/init.vim
" neoVim config

set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/pack/plugins/start/Vundle.vim
call vundle#begin()		
    Plugin 'gmarik/Vundle.vim'                           " Vundle
    Plugin 'itchyny/lightline.vim'                       " Lightline statusbar
    Plugin 'suan/vim-instant-markdown', {'rtp': 'after'} " Markdown Preview
    Plugin 'frazrepo/vim-rainbow'                        " Rainbox Brackets
    Plugin 'vifm/vifm.vim'                               " Vifm
    Plugin 'scrooloose/nerdtree'                         " Nerdtree
    Plugin 'tiagofumo/vim-nerdtree-syntax-highlight'     " Nerdtree Highlights
    Plugin 'ryanoasis/vim-devicons'                      " Icons for Nerdtree
    Plugin 'vimwiki/vimwiki'                             " VimWiki 
    Plugin 'jreybert/vimagit'                            " Magit-like plugin
    Plugin 'tpope/vim-surround'                          " Chg surrounding marks
    Plugin 'PotatoesMaster/i3-vim-syntax'                " i3 cfg highlighting
    Plugin 'kovetskiy/sxhkd-vim'                         " sxhkd highlighting
    Plugin 'vim-python/python-syntax'                    " Python highlighting
    Plugin 'ap/vim-css-color'                            " CSS Color previews
    Plugin 'junegunn/goyo.vim'                           " Distraction-free view
    Plugin 'junegunn/limelight.vim'                      " Hyperfocus on range
    Plugin 'junegunn/vim-emoji'                          " Vim needs emojis!
    Plugin 'rust-lang/rust.vim'                          " Rust Support
    Plugin 'prettier/vim-prettier'                       " Code Formatter
    Plugin 'dense-analysis/ale'                          " Linter
    Plugin 'fatih/vim-go'                                " GoLang Support

call vundle#end() " plugins must appear before this line.
filetype plugin indent on
" filetype plugin on " ignore plugin ident changes

" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; 
"                     append `!` to auto-approve removal
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"Remap ESC to ii
:imap ii <Esc>

" Status line lightline.vim theme
let g:lightline = {
      \ 'colorscheme': 'darcula',
      \ }

set laststatus=2 " always show statusline
set colorcolumn=80
highlight ColorColumn ctermbg=darkgrey guibg=lightgrey
set t_Co=256
syntax enable   
set number relativenumber
let g:rehash256 = 1

set noshowmode	" prevent non-normal modes showing in and below powerline
set expandtab	" spaces instead of tabs
set smarttab
set shiftwidth=4 " 1 tab == 4 spaces
set tabstop=4

" autocmd vimenter * NERDTree " autostart NERDTree
map <C-n> :NERDTreeToggle<CR>
let g:NERDTreeDirArrowExpandable = '►'
let g:NERDTreeDirArrowCollapsible = '▼'
let NERDTreeShowLineNumbers=1
let NERDTreeShowHidden=1
let NERDTreeMinimalUI = 1
let g:NERDTreeWinSize=38

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Theming
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
highlight LineNr           ctermfg=8    ctermbg=none    cterm=none
highlight CursorLineNr     ctermfg=7    ctermbg=8       cterm=none
highlight VertSplit        ctermfg=0    ctermbg=8       cterm=none
highlight Statement        ctermfg=2    ctermbg=none    cterm=none
highlight Directory        ctermfg=4    ctermbg=none    cterm=none
highlight StatusLine       ctermfg=7    ctermbg=8       cterm=none
highlight StatusLineNC     ctermfg=7    ctermbg=8       cterm=none
highlight NERDTreeClosable ctermfg=2
highlight NERDTreeOpenable ctermfg=8
highlight Comment          ctermfg=4    ctermbg=none    cterm=none
highlight Constant         ctermfg=12   ctermbg=none    cterm=none
highlight Special          ctermfg=4    ctermbg=none    cterm=none
highlight Identifier       ctermfg=6    ctermbg=none    cterm=none
highlight PreProc          ctermfg=5    ctermbg=none    cterm=none
highlight String           ctermfg=12   ctermbg=none    cterm=none
highlight Number           ctermfg=1    ctermbg=none    cterm=none
highlight Function         ctermfg=1    ctermbg=none    cterm=none
" highlight WildMenu         ctermfg=0       ctermbg=80      cterm=none
" highlight Folded           ctermfg=103     ctermbg=234     cterm=none
" highlight FoldColumn       ctermfg=103     ctermbg=234     cterm=none
" highlight DiffAdd          ctermfg=none    ctermbg=23      cterm=none
" highlight DiffChange       ctermfg=none    ctermbg=56      cterm=none
" highlight DiffDelete       ctermfg=168     ctermbg=96      cterm=none
" highlight DiffText         ctermfg=0       ctermbg=80      cterm=none
" highlight SignColumn       ctermfg=244     ctermbg=235     cterm=none
" highlight Conceal          ctermfg=251     ctermbg=none    cterm=none
" highlight SpellBad         ctermfg=168     ctermbg=none    cterm=underline
" highlight SpellCap         ctermfg=80      ctermbg=none    cterm=underline
" highlight SpellRare        ctermfg=121     ctermbg=none    cterm=underline
" highlight SpellLocal       ctermfg=186     ctermbg=none    cterm=underline
" highlight Pmenu            ctermfg=251     ctermbg=234     cterm=none
" highlight PmenuSel         ctermfg=0       ctermbg=111     cterm=none
" highlight PmenuSbar        ctermfg=206     ctermbg=235     cterm=none
" highlight PmenuThumb       ctermfg=235     ctermbg=206     cterm=none
" highlight TabLine          ctermfg=244     ctermbg=234     cterm=none
" highlight TablineSel       ctermfg=0       ctermbg=247     cterm=none
" highlight TablineFill      ctermfg=244     ctermbg=234     cterm=none
" highlight CursorColumn     ctermfg=none    ctermbg=236     cterm=none
" highlight CursorLine       ctermfg=none    ctermbg=236     cterm=none
" highlight ColorColumn      ctermfg=none    ctermbg=236     cterm=none
" highlight Cursor           ctermfg=0       ctermbg=5       cterm=none
" highlight htmlEndTag       ctermfg=114     ctermbg=none    cterm=none
" highlight xmlEndTag        ctermfg=114     ctermbg=none    cterm=none

" Removes pipes | that act as seperators on splits
set fillchars+=vert:\ 

" Vimfm
map <Leader>vv :Vifm<CR>
map <Leader>vs :VsplitVifm<CR>
map <Leader>sp :SplitVifm<CR>
map <Leader>dv :DiffVifm<CR>
map <Leader>tv :TabVifm<CR>

" VimWiki
let g:vimwiki_list = [{'path': '~/.local/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" Vim-Instant-Markdown
let g:instant_markdown_autostart = 0         " Turns off auto preview
let g:instant_markdown_browser = "surf"      " Uses surf for preview
map <Leader>md :InstantMarkdownPreview<CR>   " Previews .md file
map <Leader>ms :InstantMarkdownStop<CR>      " Kills the preview

" Open terminal inside Vim
map <Leader>tt :vnew term://bash<CR>

set mouse=nicr " Mouse scrolling

" Splits and tabbed files
set splitbelow splitright

set path+=**		" Searches current directory recursively.
set wildmenu		" Display all matches when tab complete.
set incsearch
set nobackup
set noswapfile

let g:python_highlight_all = 1

au! BufRead,BufWrite,BufWritePost,BufNewFile *.org 
au BufEnter *.org  call org#SetOrgFileType()

set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=L  "remove left-hand scroll bar

" prettier
let g:prettier#config#tab_width = '2'
let g:prettier#config#use_tabs = 'false'
let g:prettier#config#print_width = '80'
let g:prettier#config#single_quote = 'true'

" Rust Format on Save - :RustFmt to run manually
let g:rustfmt_autosave = 1

" Set ESLint as plugging manager
let g:ale_fixers = {
   \ 'javascript': ['prettier', 'eslint'],
   \ 'rust': ['rustfmt']
   \ }

" Set this variable to 1 to fix files when you save them.
let g:ale_fix_on_save = 1
let g:airline#extensions#ale#enabled = 1

EOT

# Install Plugins using Vundle
nvim -c 'PluginInstall' -c 'qa!'

echo "COMPLETED" && exit 0;
