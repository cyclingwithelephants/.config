
set backspace=indent,eol,start
set relativenumber
set number

" Enables syntax highlighting
syntax on

" sets syntax highlighting profile
colorscheme hue 

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
