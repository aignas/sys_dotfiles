"mix - http://amix.dk/
"
" Inspired by: Amir Salihefendic <amix3k at gmail.com>
" Maintainer: Ignas Anikevicius
"

"{{{ General

"Get out of VI's compatible mode..
set encoding=utf-8
set nocompatible

"Define MySys variable
function MySys()
  return "linux"
endfunction

"Sets how many lines of history VIM has to remember
set history=600

"Enable filetype plugin
filetype plugin on
filetype indent on

"Set to auto read when a file is changed from the outside
set autoread

"Have the mouse enabled all the time:
set mouse=r

"Set mapleader
let mapleader = ","
let g:mapleader = ","

"Fast saving
nmap <leader>w :w!<cr>
nmap <leader>f :find<cr>

"Fast reloading of the .vimrc
map <leader>vs :source ~/.vimrc<cr>
"Fast editing of .vimrc
map <leader>ve :tabnew! ~/.vimrc<cr>
"When .vimrc is edited, reload it
autocmd! bufwritepost vimrc source ~/.vimrc

set runtimepath=~/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,~/.vim/after
"}}}
"{{{ Colors and Fonts

"Enable syntax hl
syntax enable

"Set font to Droid Sans Mono Slashed 12pt
if MySys() == "linux"
"  set gfn="Anonymous\ Pro\ 14"
  set gfn="Inconsolata\ 14"
"  set gfn="Droid\ Sans\ Mono\ Slashed\ 12"
endif

" remove toolbar and menubar
set go=aeg

colorscheme zenburn
map <leader>= :colorscheme zenburn<cr>
map <leader>- :colorscheme proton<cr>
map <leader>0 :colorscheme less<cr>
map <leader>9 :colorscheme print_bw<cr>

"Some nice mapping to switch syntax (useful if one mixes different languages in one file)
map <leader>1 :set syntax=lua<cr>
map <leader>2 :set syntax=python<cr>
map <leader>3 :set syntax=tex<cr>
map <leader>5 :set syntax=c++<cr>
map <leader>6 :set syntax=ml<cr>

"Omni menu colors
hi Pmenu guibg=#333333
hi PmenuSel guibg=#555555 guifg=#ffffff
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

"Set 7 lines to the curors - when moving vertical..
set so=7

"Turn on WiLd menu
set wildmenu

"Always show current position
set ruler

"The commandbar is 2 high
set cmdheight=2

"Show line number
set nu

"Do not redraw, when running macros.. lazyredraw
set lz

"Change buffer - without saving
set hid

"Set backspace
set backspace=eol,start,indent

"Backspace and cursor keys wrap to
set whichwrap+=<,>,h,l

"Ignore case when searching
"set ignorecase
set incsearch

"Set magic on
set magic

"No sound on errors.
set noerrorbells
set novisualbell
set t_vb=

"show matching bracets
set showmatch

"How many tenths of a second to blink
set mat=1

"Highlight search things
set hlsearch

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
"{{{ Visual

" From an idea by Michael Naumann
function! VisualSearch(direction) range
  let l:saved_reg = @"
  execute "normal! vgvy"
  let l:pattern = escape(@", '\\/.*$^~[]')
  let l:pattern = substitute(l:pattern, "\n$", "", "")
  if a:direction == 'b'
    execute "normal ?" . l:pattern . "^M"
  else
    execute "normal /" . l:pattern . "^M"
  endif
  let @/ = l:pattern
  let @" = l:saved_reg
endfunction

"Basically you press * or # to search for the current selection !! Really useful
vnoremap <silent> * :call VisualSearch('f')<CR>
vnoremap <silent> # :call VisualSearch('b')<CR>

"}}}
"{{{ Moving around and tabs

"Map space to / and c-space to ?
map <space> /
map <C-space> ?

map <C-p> gT
map <C-n> gt

"Smart way to move btw. windows
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

"Actually, the tab does not switch buffers, but my arrows
"Bclose function can be found in "Buffer related" section
map <leader>bd :Bclose<cr>
map <down> :bd<cr>
"Use the arrows to something usefull
map <right> :bn<cr>
map <left> :bp<cr>
"Tab configuration
map <leader>tn :tabnew 
map <leader>td :tabclose<cr>
map <leader>te :tabedit
try
  set switchbuf=usetab
  set stal=2
catch
endtry

"Moving fast to front, back and 2 sides ;)
"imap <m-$> <esc>$a
"imap <m-0> <esc>0i
"imap <D-$> <esc>$a
"imap <D-0> <esc>0i
"}}}
"{{{ General Autocommands
"
"Switch to current dir
map <leader>cd :cd %:p:h<cr>
"If the directory in which we want to save a file is not there, create it
augroup BWCCreateDir
  au!
  autocmd BufWritePre * if expand("<afile>")!~#'^\w\+:/' && !isdirectory(expand("%:h")) | execute "silent! !mkdir -p ".shellescape(expand('%:h'), 1) | redraw! | endif
augroup END
"}}}
"{{{ Parenthesis/bracket expanding

vnoremap $1 <esc>`>a)<esc>`<i(<esc>
")
vnoremap $2 <esc>`>a]<esc>`<i[<esc>
vnoremap $3 <esc>`>a}<esc>`<i{<esc>
vnoremap $$ <esc>`>a"<esc>`<i"<esc>
vnoremap $q <esc>`>a'<esc>`<i'<esc>
vnoremap $w <esc>`>a"<esc>`<i"<esc>

au BufNewFile,BufRead *.\(vim\)\@! inoremap " ""<esc>:let leavechar='"'<cr>i
au BufNewFile,BufRead *.\(txt\)\@! inoremap ' ''<esc>:let leavechar="'"<cr>i

imap <m-l> <esc>:exec "normal f" . leavechar<cr>a
"}}}
"{{{ General Abbrevs
"
"My information
iab xdate <c-r>=strftime("%d/%m/%y %H:%M:%S")<cr>
iab xname Ignas Anikevičius
"}}}
"{{{ Editing mappings etc.

"Remap VIM 0
map 0 ^

"Move a line of text using control
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

func! DeleteTrailingWS()
  exe "normal mz"
  %s/\s\+$//ge
  exe "normal `z"
endfunc
autocmd BufWrite *.py :call DeleteTrailingWS()

set completeopt=menu
"}}}
"{{{ Command-line config

func! Cwd()
  let cwd = getcwd()
  return "e " . cwd 
endfunc

func! DeleteTillSlash()
  let g:cmd = getcmdline()
  if MySys() == "linux"
    let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*", "\\1", "")
  else
    let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\]\\).*", "\\1", "")
  endif
  if g:cmd == g:cmd_edited
    if MySys() == "linux"
      let g:cmd_edited = substitute(g:cmd, "\\(.*\[/\]\\).*/", "\\1", "")
    else
      let g:cmd_edited = substitute(g:cmd, "\\(.*\[\\\\\]\\).*\[\\\\\]", "\\1", "")
    endif
  endif
  return g:cmd_edited
endfunc

func! CurrentFileDir(cmd)
  return a:cmd . " " . expand("%:p:h") . "/"
endfunc

"Smart mappings on the command line
cno $h e ~/
cno $d e ~/desktop/
cno $j e ./
cno $l tabnew ~/repos/LaTeX-project/

cno $q <C-\>eDeleteTillSlash()<cr>

cno $c e <C-\>eCurrentFileDir("e")<cr>

cno $tc <C-\>eCurrentFileDir("tabnew")<cr>
cno $th tabnew ~/
cno $td tabnew ~/Desktop/

"Bash like
cnoremap <C-A>    <Home>
cnoremap <C-E>    <End>
cnoremap <C-K>    <C-U>

"}}}
"{{{ Buffer realted
"
"Fast open a buffer by search for a name
map <c-q> :sb

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
"Turn backup off
set backupdir=./.backup,/tmp
"set nobackup
"set nowb
set noswapfile
"}}}
"{{{ Folding
"
"Enable folding, I find it very useful
set nofen
set fdl=1
"}}}
"{{{ Text options

set expandtab
set shiftwidth=4
set tabstop=4

map <leader>t2 :set shiftwidth=2<cr>
map <leader>t4 :set shiftwidth=4<cr>
au FileType html,python,vim,javascript setl shiftwidth=2
au FileType html,python,vim,javascript setl tabstop=2
au FileType java setl shiftwidth=4
au FileType java setl tabstop=4

set smarttab
set lbr
set tw=500

   "{{{{ Indent
   "
   "Auto indent
   "   set ai

   "Smart indet
   set si

   "C-style indeting
   set cindent

   "Wrap lines
   set wrap
   "}}}}

"}}}
"{{{ Spell checking

" Defaults
set nospell

" Some mapping for spell checking
map <leader>se :setlocal spell spelllang=en_gb<CR>
map <leader>sl :setlocal spell spelllang=lt<CR>
map <leader>ss :setlocal spell<CR>
map <leader>sn :setlocal nospell<CR>

" Old stuff. The default keybindings are better :)
"map <leader>sn ]s
"map <leader>sp [s
"map <leader>sa zg
"map <leader>sua zug
"map <leader>s? z=
"}}}
"{{{ Plugin configuration
"
   "{{{{ Gist

   let g:gist_clip_command = 'xclip -selection clipboard'
   let g:gist_detect_filetype = 1
   let g:gist_browser_command = 'luakit %URL%'
   "}}}}
   "{{{{ Yank Ring
   map <leader>y :YRShow<cr>
   "}}}}
   "{{{{ File explorer
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
   "}}}}
   "{{{{ Minibuffer

   let g:miniBufExplModSelTarget = 1
   let g:miniBufExplorerMoreThanOne = 2
   let g:miniBufExplModSelTarget = 0
   let g:miniBufExplUseSingleClick = 1
   let g:miniBufExplMapWindowNavVim = 1
   let g:miniBufExplVSplit = 25
   let g:miniBufExplSplitBelow=1

   let g:bufExplorerSortBy = "name"

   autocmd BufRead,BufNew :call UMiniBufExplorer
   "}}}}
   "{{{{ Tag list (ctags) - not used
   "
   "let Tlist_Ctags_Cmd = "/sw/bin/ctags-exuberant"
   "let Tlist_Sort_Type = "name"
   "let Tlist_Show_Menu = 1
   "map <leader>t :Tlist<cr>
   "}}}}
   "{{{{ Automatic LaTeX Plugin

   au FileType tex set sw=4
   au FileType tex set iskeyword+=:

   let g:tex_flavor='latex'

   au FileType tex map <leader>ll :TEX<cr>
   au FileType tex map <leader>lb :Bibtex<cr>
   au FileType tex map <leader>lv :View<cr>
   au FileType tex map <leader>ls :SyncTex<cr>
   au FileType tex let b:atp_Viewer="mupdf"
   au FileType tex let b:atp_TexOptions = "-shell-escape,-synctex=1"
   au FileType tex let g:atp_folding = 1
   au FileType tex let g:atp_fold_environments = 1
   "au FileType tex let g:LatexBox_latexmk_options="-pvc"
   
   "{{{{ LaTeX Suite things
"
"   " IMPORTANT: grep will sometimes skip displaying the file name if you
"   " search in a singe file. This will confuse Latex-Suite. Set your grep
"   " program to always generate a file-name.
"   set grepprg=grep\ -nH\ $*
"
"   let g:Tex_DefaultTargetFormat="pdf"
"   let g:Tex_ViewRule_pdf='evince2'
"   "let g:Tex_ViewRule_pdf='mupdf'
"
"   "Auto complete some things ;)
"   autocmd FileType tex inoremap $n \indent
"   autocmd FileType tex inoremap $* \cdot
"   autocmd FileType tex inoremap $i \item
"   autocmd FileType tex noremap ,lq /%<cr>
"
"   " TIP: if you write your \label's as \label{fig:something}, then if you
"   " type in \ref{fig: and press <C-n> you will automatically cycle through
"   " all the figure labels. Very useful!
"   set iskeyword+=:
"
"   function! Tex_ForwardSearchLaTeX()
"     let cmd = 'evince_forward_search ' . fnamemodify(Tex_GetMainFileName(), ":p:r") .  '.pdf ' . line(".") . ' ' . expand("%:p")
"     let output = system(cmd)
"   endfunction
"
"   let g:Tex_GotoError='1'
"   let g:Tex_CompileRule_dvi='latex -shell-escape -interaction=nonstopmode $*'
"   let g:Tex_CompileRule_ps='dvips -Ppdf -o $*.ps $*.dvi'
"   let g:Tex_FormatDependency_ps = 'dvi,ps'
"   let g:Tex_CompileRule_pdf='pdflatex -shell-escape -synctex=1 -interaction=nonstopmode $*'
"
"   let g:Tex_AutoFolding='1'
"
"   let g:Tex_MultipleCompileFormats='ps,pdf'
"
"   "Customizing what to fold
"   " Default list
"   let g:Tex_FoldedSections='part,chapter,section,%%fakesection,subsection,subsubsection,paragraph' 
"   " Added sideways in order to fold all the sideways stuff
"   let g:Tex_FoldedEnvironments='frame,lstlisting,verbatim,comment,eq,gather,align,figure,table,sideways,wrap,thebibliography,keywords,abstract,titlepage'
"}}}}
"}}}
"{{{ Filetype generic
   "{{{{ Todo
   au BufNewFile,BufRead *.todo so ~/vim_local/syntax/amido.vim
   "}}}}
   "{{{{ Conkyrc
   au BufNewFile,BufRead *conkyrc set filetype=conkyrc
   "}}}}
   "{{{{ VIM
   autocmd FileType vim map <buffer> <leader><space> :w!<cr>:source %<cr>
   autocmd FileType vim set nofen
   "}}}}
   "{{{{ HTML related

   " HTML entities - used by xml edit plugin
   let xml_use_xhtml = 1
   "let xml_no_auto_nesting = 1

   "To HTML
   let html_use_css = 1
   let html_number_lines = 0
   let use_xhtml = 1

   au FileType html,cheetah set ft=xml
   au FileType html,cheetah set syntax=html
   "au FileType html,cheetah imap <F5> <C-Y>,
   "}}}}
   "{{{{ Ruby & PHP section
   autocmd FileType ruby map <buffer> <leader><space> :w!<cr>:!ruby %<cr>
   autocmd FileType php compiler php
   autocmd FileType php map <buffer> <leader><space> <leader>cd:w<cr>:make %<cr>
   "}}}}
   "{{{{ Python section
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
   "}}}}
   "{{{{ C++ mappings
   autocmd FileType cc map <buffer> <leader><space> :w<cr>:!g++ %<cr>
   "}}}}
   "{{{{ mail
   au FileType mail set tw=72
   au FileType mail set spell
   au FileType mail set spelllang=en_gb
   au FileType mail set title titlestring=Thunderbird\ Compose\ Message
   "}}}}
   "{{{{ Scheme bidings

   autocmd BufNewFile,BufRead *.scm map <buffer> <leader><space> <leader>cd:w<cr>:!petite %<cr>
   autocmd BufNewFile,BufRead *.scm inoremap <buffer> <C-t> (pretty-print )<esc>i
   autocmd BufNewFile,BufRead *.scm vnoremap <C-t> <esc>`>a)<esc>`<i(pretty-print <esc>
   "}}}}
"{{{ Snippets
   "You can use <c-j> to goto the next <++> - it is pretty smart ;)
   "{{{{ Python

   autocmd FileType python inorea <buffer> cfun <c-r>=IMAP_PutTextWithMovement("def <++>(<++>):\n<++>\nreturn <++>")<cr>
   autocmd FileType python inorea <buffer> cclass <c-r>=IMAP_PutTextWithMovement("class <++>:\n<++>")<cr>
   autocmd FileType python inorea <buffer> cfor <c-r>=IMAP_PutTextWithMovement("for <++> in <++>:\n<++>")<cr>
   autocmd FileType python inorea <buffer> cif <c-r>=IMAP_PutTextWithMovement("if <++>:\n<++>")<cr>
   autocmd FileType python inorea <buffer> cifelse <c-r>=IMAP_PutTextWithMovement("if <++>:\n<++>\nelse:\n<++>")<cr>
   
   "}}}}
   "{{{{ HTML

   autocmd FileType cheetah,html inorea <buffer> cahref <c-r>=IMAP_PutTextWithMovement('<a href="<++>"><++></a>')<cr>
   autocmd FileType cheetah,html inorea <buffer> cbold <c-r>=IMAP_PutTextWithMovement('<b><++></b>')<cr>
   autocmd FileType cheetah,html inorea <buffer> cimg <c-r>=IMAP_PutTextWithMovement('<img src="<++>" alt="<++>" />')<cr>
   autocmd FileType cheetah,html inorea <buffer> cpara <c-r>=IMAP_PutTextWithMovement('<p><++></p>')<cr>
   autocmd FileType cheetah,html inorea <buffer> ctag <c-r>=IMAP_PutTextWithMovement('<<++>><++></<++>>')<cr>
   autocmd FileType cheetah,html inorea <buffer> ctag1 <c-r>=IMAP_PutTextWithMovement("<<++>><cr><++><cr></<++>>")<cr>

   "}}}}
"}}}
"{{{ Cope
"
"For Cope
map <silent> <leader><cr> :noh<cr>

"Orginal for all
map <leader>n :cn<cr>
map <leader>p :cp<cr>
map <leader>c :botright cw 10<cr>
map <c-u> <c-l><c-j>:q<cr>:botright cw 10<cr>
"}}}
"{{{ MISC
"
"Paste toggle - when pasting something in, don't indent.
set pastetoggle=<F3>

"Remove indenting on empty lines
map <F2> :%s/\s*$//g<cr>:noh<cr>''

"A function that inserts links & anchors on a TOhtml export.
" Notice:
" Syntax used is:
" Link
" Anchor
function! SmartTOHtml()
   TOhtml
   try
    %s/&quot;\s\+\*&gt; \(.\+\)</" <a href="#\1" style="color: cyan">\1<\/a></g
    %s/&quot;\(-\|\s\)\+\*&gt; \(.\+\)</" \&nbsp;\&nbsp; <a href="#\2" style="color: cyan;">\2<\/a></g
    %s/&quot;\s\+=&gt; \(.\+\)</" <a name="\1" style="color: #fff">\1<\/a></g
   catch
   endtry
   exe ":write!"
   exe ":bd"
endfunction
"}}}

" vim: foldmethod=marker
