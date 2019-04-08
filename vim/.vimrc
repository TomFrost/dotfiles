" Plugins {{{
set nocompatible
filetype off
" Automatically install vim-plug if it does not exist
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')

" Core {{{
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-surround'
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-airline/vim-airline'
Plug 'mbbill/undotree'
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-sleuth'
Plug 'christoomey/vim-tmux-navigator'
Plug 'Valloric/YouCompleteMe'
Plug 'jiangmiao/auto-pairs'
"}}}

" Themes {{{
Plug 'vim-airline/vim-airline-themes'
Plug 'flazz/vim-colorschemes'
Plug 'w0ng/vim-hybrid'
"}}}

" Git {{{
Plug 'tpope/vim-git', { 'for': 'git' }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
"}}}

" Javascript {{{
Plug 'pangloss/vim-javascript'
Plug 'othree/es.next.syntax.vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'mxw/vim-jsx', { 'for': 'jsx' }
Plug 'benmills/vimux', { 'for': 'javascript' }
"}}}

" Rust {{{
Plug 'rust-lang/rust.vim'
"}}}

" CSS (et al) {{{
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
"}}}

" Markdown {{{
"Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
"}}}

call plug#end()
"}}}

" Base Config {{{
" Numbers
set nu
set ruler
" Airline
set encoding=utf-8
set timeoutlen=200 ttimeoutlen=0 "eliminates delay before input mode is updated
set laststatus=2 "https://github.com/vim-airline/vim-airline#configuration
let g:airline_powerline_fonts=1
" Allow ^D completion of commands and file listings
set wildmenu
" Instead of having to hit C-w h and C-w l (and j and k) to
" change split workspaces, map it to C-h and C-l (and j and k).
nmap <C-h> <C-w>h
nmap <C-j> <C-w>j
nmap <C-k> <C-w>k
nmap <C-l> <C-w>l
" Use search highlighting
set hls
" Press Space to clear search highlighting once.
nnoremap <silent> <Space> :nohlsearch<CR>
" Search as you type
set incsearch
" Type :w!! to save with sudo
cmap w!! %!sudo tee > /dev/null %
" \n for NERDTree toggle
nmap <silent> <Leader>n :NERDTreeToggle<CR>
" NERDTree should always show hidden files
let g:NERDTreeShowHidden=1
" \u for UndoTree toggle
nmap <silent> <Leader>u :UndotreeToggle<CR>
" Splits
set splitbelow                  " Open new splits below
set splitright                  " Open new vertical splits to the right
" Misc
set nohidden                    " Don't allow buffers to exist in the background
set ttyfast                     " Indicates a fast terminal connection
set backspace=indent,eol,start  " Allow backspaceing over autoindent, line breaks, starts of insert
set shortmess+=I                " No welcome screen
set exrc                        " enable per-directory .vimrc files
set secure                      " disable unsafe commands in local .vimrc files
set noshowmode                  " Don't show the mode in the last line of the screen, vim-airline takes care of it
set lazyredraw                  " Don't update the screen while executing macros/commands
" My command line autocomplete is case insensitive. Keep vim consistent with
" that. It's a recent feature to vim, test to make sure it's supported first.
if exists("&wildignorecase")
  set wildignorecase
endif
set scrolloff=7                 " Minimal number of screen lines to keep above and below the cursor.
set cursorline                  " Highlight the current line
set wrap                        " Soft wrap at the window width
set textwidth=119               " Lines should be 119 chars long
if exists('+colorcolumn')
  set colorcolumn=+1            " Highlight the column after `textwidth`
endif
" Character meaning when present in 'formatoptions'
" ------ ---------------------------------------
" c Auto-wrap comments using textwidth, inserting the current comment leader automatically.
" q Allow formatting of comments with 'gq'.
" r Automatically insert the current comment leader after hitting <Enter> in Insert mode.
" t Auto-wrap text using textwidth (does not apply to comments)
" n Recognize numbered lists
" 1 Don't break line after one-letter words
" a Automatically format paragraphs
set formatoptions=cqrn1
" Searches
" set ignorecase
set smartcase
" Navigate using displayed lines, not actual lines
nnoremap j gj
nnoremap k gk
"}}}

" YouCompleteMe {{{
" Clear out the documentation preview when we leave insert mode or start typing after an autocompletion.
autocmd CursorMovedI * if pumvisible() == 0|pclose|endif
autocmd InsertLeave * if pumvisible() == 0|pclose|endif
" }}}

" Tabs and indents {{{
filetype plugin indent on
set tabstop=2
set softtabstop=2
set shiftwidth=2
set shiftround
set expandtab
"}}}

" Theme {{{
syntax enable
set background=dark
if &term=~'linux'
  " On a fully headless system, use a 16-color scheme
  colo torte
else
  " Otherwise assume 256 colors
  set t_Co=256
  " Set it in a try/catch just in case this is our first run and Plug isn't installed yet
  try
    colo hybrid
  catch /^Vim\%((\a\+)\)\=:E185/
    colo torte
  endtry
  let g:airline_theme='bubblegum'
endif
" Kill opaque character backgrounds that look awful against a transparent term
hi Normal ctermbg=none
hi NonText ctermbg=none
"}}}

" Javascript {{{
let g:used_javascript_libs = 'underscore,chai' " Configure javascript-libraries-syntax
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2 expandtab
let g:javascript_plugin_jsdoc = 1
map <Leader>tt :call VimuxRunCommand("clear; npm test")<CR>
map <Leader>tm :call VimuxRunCommand("clear; npm run mocha")<CR>
map <Leader>lt :call VimuxRunCommand("clear; lab test")<CR>
map <Leader>lm :call VimuxRunCommand("clear; lab mocha")<CR>
map <Leader>vq :VimuxCloseRunner<CR>
map <Leader>vc :VimuxInterruptRunner<CR>
map <Leader>vi :VimuxInspectRunner<CR>
map <Leader>vz :call VimuxZoomRunner()<CR>
"}}}

" Syntastic {{{
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height = 5
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 1
let g:syntastic_javascript_checkers = ['eslint']

let g:syntastic_error_symbol = '❌'
let g:syntastic_style_error_symbol = '⁉️'
let g:syntastic_warning_symbol = '⚠️'
let g:syntastic_style_warning_symbol = '💩'

highlight link SyntasticErrorSign SignColumn
highlight link SyntasticWarningSign SignColumn
highlight link SyntasticStyleErrorSign SignColumn
highlight link SyntasticStyleWarningSign SignColumn
"}}}

" Fix pasting indented/commented code from clipboard {{{
" https://coderwall.com/p/if9mda/automatically-set-paste-mode-in-vim-when-pasting-in-insert-mode
function! WrapForTmux(s)
  if !exists('$TMUX')
    return a:s
  endif

  let tmux_start = "\<Esc>Ptmux;"
  let tmux_end = "\<Esc>\\"

  return tmux_start . substitute(a:s, "\<Esc>", "\<Esc>\<Esc>", 'g') . tmux_end
endfunction

let &t_SI .= WrapForTmux("\<Esc>[?2004h")
let &t_EI .= WrapForTmux("\<Esc>[?2004l")

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()
" }}}

