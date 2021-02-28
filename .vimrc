
set backspace=indent,eol,start
set relativenumber
set number

" Enables syntax highlighting
syntax on

" Enable true colors if available
set termguicolors
colorscheme slate 
" Enable italics, Make sure this is immediately after colorscheme
" https://stackoverflow.com/questions/3494435/vimrc-make-comments-italic
highlight Comment cterm=italic gui=italic
" Automatically install vim-plug if it isn't already.
" vim-plug github: https://github.com/junegunn/vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'chriskempson/base16-vim'

call plug#end()
