" .vimrc configuration by Ignas Anikevičius
"
" There are numerous people, whose configs where copied and addapted and it's hard 
" to list everybody, but the main ones are:
"
"   * Amir Salihefendic <amix3k at gmail.com>
"       http://amix.dk/blog/post/19486#The-ultimative-Vim-configuration-vimrc
"
"   * Steve Losh
"       http://stevelosh.com/blog/2010/09/coming-home-to-vim/#
"
" Last edited: 13/08/12 00:25:19

"{{{ General

"Get out of VI's compatible mode..
set encoding=utf-8
set nocompatible

"Sets how many lines of history VIM has to remember
set history=600

"Enable filetype plugin
filetype plugin on
filetype indent on

"Set to auto read when a file is changed from the outside
set autoread

"Set mapleader
let mapleader = ","
let g:mapleader = ","

"Fast saving
nmap <leader>w :w<cr>
nmap <leader>f :find<cr>

"Fast editing and reloading of the .vimrc
map <leader>vs :source ~/.vimrc<cr>
map <leader>ve :e ~/.vimrc<cr>

set runtimepath=~/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim/after

" Create an undofile
set undofile

"}}}
"{{{ PLUGIN: Vundle
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
" required! 
Bundle 'gmarik/vundle'

" My Bundles here:
"
" original repos on github
Bundle 'tpope/vim-fugitive'
Bundle 'scrooloose/nerdtree'
" NOTE: Clang-complete needs Clang to operate properly
Bundle 'Rip-Rip/clang_complete'
Bundle 'josephwecker/neutron.vim'
Bundle 'scrooloose/syntastic'
Bundle 'jnurmine/Zenburn'
Bundle 'vim-pandoc/vim-pandoc'
Bundle 'JuliaLang/julia-vim'
" vim-scripts repos
Bundle 'Gundo'
Bundle 'YankRing.vim'
" non github repos
Bundle 'git://git.code.sf.net/p/atp-vim/code'

" Use git instead of http for fetching git repos
let g:vundle_default_git_proto = 'git'
" ...

" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..
"}}}
"{{{ Colors and Fonts

" remove toolbar and menubar
set go=aeg

"Set font to Droid Sans Mono Slashed 12pt
"set gfn="Inconsolata\ 14"

colorscheme zenburn

"Enable syntax hl
syntax enable

"Some nice mapping to switch syntax (useful if one mixes different languages in one file)
map <leader>1 :set syntax=lua<cr>
map <leader>2 :set syntax=python<cr>
map <leader>3 :set syntax=tex<cr>
map <leader>5 :set syntax=c++<cr>
map <leader>6 :set syntax=ml<cr>

"}}}
"{{{ Fileformats
"
"Favorite filetypes
set ffs=unix,dos,mac

nmap <leader>fd :se ff=dos<cr>
nmap <leader>fu :se ff=unix<cr>

"}}}
"{{{ VIM userinterface
"
"Blinking not allowed in nvc modes
let &guicursor = substitute(&guicursor, 'n-v-c:', '&blinkon0-', '')

"Set 3 lines to the curors - when moving vertical..
set scrolloff=3

"Turn on Wild menu
set wildmenu
set wildmode=longest:full

"The commandbar is 2 high
set cmdheight=2

"Show relative line numbers
set relativenumber

"Do not redraw, when running macros.. lazyredraw
set lazyredraw

"Change buffer - without saving
set hid

"Set backspace
set backspace=eol,start,indent

"Backspace and cursor keys wrap to
set whichwrap+=<,>,h,l

"Ignore case when searching
set ignorecase
set smartcase

"Highlight search results
set incsearch
set hlsearch
set showmatch

"Set magic on
set magic

"No sound on errors.
set noerrorbells
set novisualbell
set t_vb=

"How many tenths of a second to blink
set mat=2

" Create a red column at some position
set colorcolumn=88

" Save when loosing focus
au FocusLost * :wa

"}}}
"{{{ Statusline

"Always hide the statusline
set laststatus=1

function! CurDir()
   let curdir = substitute(getcwd(), '/Users/amir/', "~/", "g")
   return curdir
endfunction

"Format the statusline
set statusline=\ %F%m%r%h\ %w\ \ CWD:\ %r%{CurDir()}%h\ \ \ Line:\ %l/%L:%c

"}}}
"{{{ Moving around and tabs

" Disable some keys
nnoremap <up> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

" quicker exit
inoremap jj <ESC>

"Smart way to move between windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"Actually, the tab does not switch buffers, but my arrows
"Bclose function can be found in "Buffer related" section
noremap <right> :bn<cr>
noremap <left> :bp<cr>
nnoremap <down> :bd<cr>

"Tab configuration
map <leader>tn :tabnew 
map <leader>td :tabclose<cr>
map <leader>te :tabedit

"}}}
"{{{ General Autocommands

"Switch to current dir
map <leader>cd :cd %:p:h<cr>

"If the directory in which we want to save a file is not there, create it
augroup BWCCreateDir
  au!
  autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) | execute "silent! !mkdir -p ".shellescape(expand('%:h'), 1) | redraw! | endif
augroup END

"}}}
"{{{ General Abbrevs
"
"My information
iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>
iab xname Ignas Anikevičius
"}}}
"{{{ Command-line config

func! Cwd()
  let cwd = getcwd()
  return "e " . cwd 
endfunc

func! DeleteTillSlash()
  let g:cmd = getcmdline()
  let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
  if g:cmd == g:cmd_edited
    let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
  endif
  return g:cmd_edited
endfunc

func! CurrentFileDir(cmd)
  return a:cmd . " " . expand("%:p:h") . "/"
endfunc

"Smart mappings on the command line
cno $q <C-\>eDeleteTillSlash()<cr>
cno $c e <C-\>eCurrentFileDir("e")<cr>
cno $tc <C-\>eCurrentFileDir("tabnew")<cr>

"Bash like
cnoremap <C-A>    <Home>
cnoremap <C-E>    <End>
cnoremap <C-K>    <C-U>

"}}}
"{{{ Buffer related
"
"Fast open a buffer by search for a name
map <C-q> :sb

"Open a dummy buffer for paste
map <leader>q :e ~/buffer<cr>

"Restore cursor to file position in previous editing session
set viminfo='10,\"100,:20,%,n~/.viminfo
au BufReadPost * if line("'\"") > 0|if line("'\"") <= line("$")|exe("norm '\"")|else|exe "norm $"|endif|endif

" Buffer - reverse everything ... :)
map <F9> ggVGg?

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()

function! <SID>BufcloseCloseIt()
   let l:currentBufNum = bufnr("%")
   let l:alternateBufNum = bufnr("#")

   if buflisted(l:alternateBufNum)
     buffer #
   else
     bnext
   endif

   if bufnr("%") == l:currentBufNum
     new
   endif

   if buflisted(l:currentBufNum)
     execute("bdelete! ".l:currentBufNum)
   endif
endfunction

"}}}
"{{{ Files and backups
"
"Turn backup and swap on
set backupdir=~/.vim/tmp,/tmp
set directory=~/.vim/swp
set backupcopy=yes
"}}}
"{{{ Folding
"
"Enable folding, I find it very useful
set foldenable
set foldlevel=1
"}}}
"{{{ Text options

set expandtab
set shiftwidth=4
set tabstop=4

map <leader>t2 :set shiftwidth=2<cr>
map <leader>t4 :set shiftwidth=4<cr>
au FileType html,php,python,vim,javascript setl shiftwidth=2
au FileType html,php,python,vim,javascript setl tabstop=2

set smarttab
set lbr
set tw=88

"Paste toggle - when pasting something in, don't indent.
set pastetoggle=<S-F3>

"Remove indenting on empty lines
map <F2> :%s/\s*$//g<cr>:noh<cr>''

"Smart C-style indent
set smartindent
set cindent

"Wrap lines
set wrap

"}}}
"{{{ Spell checking

" Defaults
set nospell

" Some mapping for spell checking
map <leader>se :setlocal spell spelllang=en_gb<CR>
map <leader>sl :setlocal spell spelllang=lt<CR>
map <leader>ss :setlocal spell<CR>
map <leader>sn :setlocal nospell<CR>
"}}}
"{{{ Gzipped files
augroup gzip
  autocmd!
  autocmd BufReadPre,FileReadPre *.gz set bin
  autocmd BufReadPost,FileReadPost   *.gz '[,']!gunzip
  autocmd BufReadPost,FileReadPost   *.gz set nobin
  autocmd BufReadPost,FileReadPost   *.gz execute ":doautocmd BufReadPost " . expand("%:r")
  autocmd BufWritePost,FileWritePost *.gz !mv <afile> <afile>:r
  autocmd BufWritePost,FileWritePost *.gz !gzip <afile>:r
  autocmd FileAppendPre      *.gz !gunzip <afile>
  autocmd FileAppendPre      *.gz !mv <afile>:r <afile>
  autocmd FileAppendPost     *.gz !mv <afile> <afile>:r
  autocmd FileAppendPost     *.gz !gzip <afile>:r
augroup END
"}}}

" Plugin configuration

"{{{ Gist
let g:gist_clip_command = 'xclip -selection clipboard'
let g:gist_detect_filetype = 1
let g:gist_browser_command = 'luakit %URL%'
"}}}
"{{{ Yank Ring
map <leader>y :YRShow<cr>
let g:yankring_history_dir = '$HOME/.vim'
"}}}
"{{{ File explorer
"
"Split vertically
let g:explVertical=1

"Window size
let g:explWinSize=35

let g:explSplitLeft=1
let g:explSplitBelow=1

"Hide some files
let g:explHideFiles='^\.,.*\.class$,.*\.swp$,.*\.pyc$,.*\.swo$,\.DS_Store$'

"Hide the help thing..
let g:explDetailedHelp=0
"}}}
"{{{ Minibuffer

let g:miniBufExplModSelTarget = 1
let g:miniBufExplorerMoreThanOne = 2
let g:miniBufExplModSelTarget = 0
let g:miniBufExplUseSingleClick = 1
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplVSplit = 25
let g:miniBufExplSplitBelow=1

let g:bufExplorerSortBy = "name"

autocmd BufRead,BufNew :call UMiniBufExplorer
"}}}
""{{{ Automatic LaTeX Plugin

au FileType tex set sw=4
au FileType tex set iskeyword+=:

let g:tex_flavor='latex'

au FileType tex let b:atp_Viewer="zathura"
au FileType tex let b:atp_TexCompiler = "lualatex"
au FileType tex let b:atp_TexOptions = "--shell-escape,--synctex=1"

au FileType tex let g:atp_Compiler = "bash"
au FileType tex let g:atp_python = "/usr/bin/python2"
"au FileType tex let g:LatexBox_latexmk_options="-pvc"

""}}}
"{{{ Vim LaTeX suite
"au FileType tex set sw=4
"au FileType tex set iskeyword+=:
"
"let g:tex_flavor='latex'
"
"let g:Tex_MultipleCompileFormats='pdf'
"let g:Tex_DefaultTargetFormat='pdf'
"let g:Tex_CompileRule_pdf='lualatex --shell-escape --synctex=1 --interaction=nonstopmode $*'
""let g:Tex_CompileRule_pdf='pdflatex -interaction=nonstopmode $*'
"let g:Tex_ViewRule_pdf='zathura -s'
"
"let g:Tex_Env_figure_graphicx = "\\begin{figure}[<+htpb+>]\<cr>\\centering\<cr>\\includegraphics[<+options+>]{<+file+>}\<cr>\\caption{<+caption text+>}\<cr>\\label{fig:<+label+>}\<cr>\\end{figure}<++>"
"let g:Tex_Env_picture = "\\begin{tikzpicture}[<+options+>]\<cr><+commands+>\<cr>\\end{tikzpicture}<++>"
"
"let g:Tex_Leader = '#'
"let g:Tex_Leader2 = '`'
"
""call s:Tex_EnvMacros('EEA', '&Math.', 'align')
""call s:Tex_EnvMacros('*EEA',    '&Math.', 'align*')
"
"}}}

" Filetype generic

"{{{ VIM
autocmd FileType vim map <buffer> <leader><space> :w!<cr>:source %<cr>
autocmd FileType vim set nofen
"}}}
"{{{ Python section
"
"Run the current buffer in python - ie. on leader+space
"au FileType python so ~/vim_local/syntax/python.vim
autocmd FileType python map <buffer> <leader>ll :w!<cr>:!./%<cr>
autocmd FileType pyrex  map <buffer> <leader>ll :w!<cr>:!python setup.py build_ext --inplace<cr>
"autocmd FileType python so ~/vim_local/plugin/python_fold.vim

"Set some bindings up for 'compile' of python
autocmd FileType python set makeprg=python\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
autocmd FileType python set efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m

"Python iMaps
au FileType python set cindent
au FileType python inoremap <buffer> $r return
au FileType python inoremap <buffer> $s self
au FileType python inoremap <buffer> $c ##<cr>#<space><cr>#<esc>kla
au FileType python inoremap <buffer> $i import
au FileType python inoremap <buffer> $p print
au FileType python inoremap <buffer> $d """<cr>"""<esc>O

"Run in the Python interpreter
function! Python_Eval_VSplit() range
 let src = tempname()
 let dst = tempname()
 execute ": " . a:firstline . "," . a:lastline . "w " . src
 execute ":!python " . src . " > " . dst
 execute ":pedit! " . dst
endfunction
au FileType python vmap <F7> :call Python_Eval_VSplit()<cr>
"}}}
"{{{ C++ mappings
autocmd FileType cc map <buffer> <leader><space> :w<cr>:!make %<cr>
"}}}
"{{{ mail
au FileType mail set tw=72
au FileType mail set spell
au FileType mail set spelllang=en_gb
"}}}
"{{{ LilyPond
au FileType lilypond nmap <leader>ll :!lilypond "%"<cr>
au FileType lilypond nmap <leader>lv :!zathura "%<.pdf" &<cr>
"}}}
"{{{ Git
au FileType gitcommit set tw=72
"}}}

"Snippets

"You can use <c-j> to goto the next <++> - it is pretty smart ;)
"{{{ Python

autocmd FileType python inorea <buffer> cfun <c-r>=IMAP_PutTextWithMovement("def <++>(<++>):\n<++>\nreturn <++>")<cr>
autocmd FileType python inorea <buffer> cclass <c-r>=IMAP_PutTextWithMovement("class <++>:\n<++>")<cr>
autocmd FileType python inorea <buffer> cfor <c-r>=IMAP_PutTextWithMovement("for <++> in <++>:\n<++>")<cr>
autocmd FileType python inorea <buffer> cif <c-r>=IMAP_PutTextWithMovement("if <++>:\n<++>")<cr>
autocmd FileType python inorea <buffer> cifelse <c-r>=IMAP_PutTextWithMovement("if <++>:\n<++>\nelse:\n<++>")<cr>

"}}}
"{{{ HTML

autocmd FileType cheetah,html,php inorea <buffer> cahref <c-r>=IMAP_PutTextWithMovement('<a href="<++>"><++></a>')<cr>
autocmd FileType cheetah,html,php inorea <buffer> cbold <c-r>=IMAP_PutTextWithMovement('<b><++></b>')<cr>
autocmd FileType cheetah,html,php inorea <buffer> cimg <c-r>=IMAP_PutTextWithMovement('<img src="<++>" alt="<++>" />')<cr>
autocmd FileType cheetah,html,php inorea <buffer> cpara <c-r>=IMAP_PutTextWithMovement('<p><++></p>')<cr>
autocmd FileType cheetah,html,php inorea <buffer> ctag <c-r>=IMAP_PutTextWithMovement('<<++>><++></<++>>')<cr>
autocmd FileType cheetah,html,php inorea <buffer> ctag1 <c-r>=IMAP_PutTextWithMovement("<<++>><cr><++><cr></<++>>")<cr>

"}}}

" vim: foldmethod=marker
