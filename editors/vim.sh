#!/usr/bin/env bash
# Configures VIM 8
# by: Andrew Taylor < aftaylor2@gmail.com >

PLUGINS=(https://github.com/dense-analysis/ale.git
https://github.com/chrisbra/Colorizer.git
https://github.com/dracula/vim.git
https://github.com/itchyny/lightline.vim
https://github.com/junegunn/limelight.vim
https://github.com/preservim/nerdtree.git
https://github.com/rust-lang/rust.vim.git
https://github.com/jreybert/vimagit
https://github.com/ryanoasis/vim-devicons.git
https://github.com/vim-airline/vim-airline
https://github.com/junegunn/vim-emoji
https://github.com/airblade/vim-gitgutter.git
https://github.com/fatih/vim-go.git
https://github.com/pangloss/vim-javascript.git
https://github.com/tiagofumo/vim-nerdtree-syntax-highlight
https://github.com/prettier/vim-prettier.git
https://github.com/frazrepo/vim-rainbow
https://github.com/tpope/vim-surround
https://github.com/vimwiki/vimwiki.git
https://github.com/VundleVim/Vundle.vim.git
https://github.com/Yggdroot/indentLine.git)

PLUGINS_DIR=~/.vim/pack/plugins/start
THEMES_DIR=~/.vim/pack/themes/start

mkdir -p $PLUGINS_DIR && mkdir -p $THEMES_DIR

cd $THEMES_DIR; cd .. ; ln -s start opt; cd ~

for plugin in ${PLUGINS[@]}; do
  DIR=$(echo $plugin | sed 's/.*\///' | sed 's/.git//g')
  echo Cloning $DIR ...
  git clone $plugin $PLUGINS_DIR/$DIR
done

git clone https://github.com/dracula/vim.git $THEMES_DIR/dracula


mv .vimrc .vimrc.old
cat <<EOT >> .vimrc
packadd! dracula
syntax on
colorscheme dracula
filetype plugin on
" filetype plugin indent on

set background=dark
set colorcolumn=80
set encoding=UTF-8
set cm=blowfish2
" set mouse=a
set number
set relativenumber
set runtimepath^=~/.vim/pack/plugins/start
set t_Co=256
set textwidth=80
" GitGutter Status + ~ - status bar counts
set statusline+=%{GitStatus()}

au BufEnter *.js,*.php,*.rs,*.css,*.h,*.html :ColorHighlight<CR>
au BufRead,BufNewFile *.md,*.js,*.php,*.rs,*.vim,*.vimrc setlocal textwidth=80
au BufRead,BufNewFile *.hbs,*.handlebars setlocal textwidth=120

" Transparent editing of gpg encrypted files.
augroup encrypted
   au!
   autocmd BufReadPre,FileReadPre *.gpg set viminfo=
   autocmd BufReadPre,FileReadPre *.gpg set noswapfile
   autocmd BufReadPre,FileReadPre *.gpg set bin
   autocmd BufReadPre,FileReadPre *.gpg let ch_save = &ch|set ch=2
   autocmd BufReadPost,FileReadPost *.gpg '[,']!gpg --decrypt 2> /dev/null
   autocmd BufReadPost,FileReadPost *.gpg set nobin
   autocmd BufReadPost,FileReadPost *.gpg let &ch = ch_save|unlet ch_save
   autocmd BufReadPost,FileReadPost *.gpg execute ":doautocmd BufReadPost " . expand("%:r")
   autocmd BufWritePre,FileWritePre *.gpg '[,']!gpg --default-recipient-self -ae 2>/dev/null
   autocmd BufWritePost,FileWritePost *.gpg u
augroup END

" https://github.com/jamessan/vim-gnupg ( .gpg .pgp .asc )
autocmd User GnuPG setl textwidth=72

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif


let g:airline_theme='dracula'
let g:ale_fixers = {
  \ 'javascript': ['prettier', 'eslint'],
  \ 'rust': ['rustfmt']
  \ }

let g:ale_fix_on_save = 1
let g:DevIconsEnableFolderExtensionPatternMatching = 1
let g:prettier#config#print_width = '80'
let g:prettier#config#single_quote = 'true'
let g:prettier#config#tab_width = '2'
let g:prettier#config#use_tabs = 'false'

let g:rustfmt_autosave = 1 " :RustFtm to run manually
let g:vimwiki_list = [{'path': '~/.local/vimwiki/',
                      \ 'syntax': 'markdown',
                      \ 'ext': '.md'}]

let g:webdevicons_enable = 1
let g:webdevicons_enable_airline_tabline = 1
let g:webdevicons_enable_ctrlp = 1
let g:webdevicons_enable_flagship_statusline = 1
let g:webdevicons_enable_nerdtree = 1

map <C-n> :NERDTreeToggle<CR>

function! GitStatus()
    let [a.m,r] = GitGutterGetHunkSummary()
    return printf('+%d ~%d -%d', a, m, r)
endfunction
EOT

# Install Go Binaries for GoLang development in VIM
vim -c GoInstallBinaries -c 'qa!'
