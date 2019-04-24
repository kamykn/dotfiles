" vim: foldmethod=marker
" vim: foldcolumn=3
" vim: foldlevel=0
"
" =========================================
"  __                          __
" |  |--.---.-.--------.--.--.|  |--.-----.
" |    <|  _  |        |  |  ||    <|     |
" |__|__|___._|__|__|__|___  ||__|__|__|__|
"                      |_____|
" =========================================
"
" vim8.0+ required
" brew upgrade vim --with-lua --with-python3
"
" Font Install
" https://github.com/miiton/Cica
"
" # memo
" ## fold
" - za トグルして開く
" - zr 全開き
" - zm 全閉じ

"------------------------------------------------------
" Common Settings.
"------------------------------------------------------
"
" {{{
set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix
scriptencoding utf-8

if has('vim_starting')
	" tmux利用可能な場合は true color を有効化する
	" $TERM は zshrcやbashrcなどにも依存する
	" $COLORTERMはtruecolorが有効なときに慣例的にセットされているが必ずしもあるとは限らない(iTermではセットされていた)
	if !has('gui_running') && exists('&termguicolors') && (exists('$TMUX') && ($TERM == 'xterm-256color')) || ($COLORTERM ==# 'truecolor')
		set termguicolors

		" tmux 等でも強制的に termguicolors を有効化するための設定 (Neovim では不要)
		" https://medium.com/@dubistkomisch/how-to-actually-get-italics-and-true-colour-to-work-in-iterm-tmux-vim-9ebe55ebc2be
		if !has('nvim')
			" http://vim-jp.org/vimdoc-ja/term.html#xterm-true-color
			let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
			let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
		endif
	endif
endif

syntax on

" スペルチェック
set nospell
" set spelllang=en,cjk
" スペルチェック対象
" syntax spell toplevel

" Puttyの「ウインドウ」→「変換」→「CJK文字を…」のcheckを外す
" 三点リーダーとかは崩れるので崩れたらCtrl - lで再描写させる
" macのterminalなら、環境設定->プロファイル->->詳細->Unicode 東アジアA(曖昧)の文字幅をW(広)にするにチェック
" ↑フォントがRictyならこの設定はいらない
set ambiwidth=double

" indent
set smartindent
set autoindent
" ターミナルのタイトルをセットする
set title
" タブの幅
set noexpandtab " タブインデント
" set expandtab " spaceインデント

set tabstop=4
set shiftwidth=4
set softtabstop=0
" スワップファイルを作らない
set noswapfile
" undoファイルを作らない(for GVim)
set noundofile
" XXX~を作らない
set nobackup
" カッコのハイライト1非表示
" let loaded_matchparen = 1
" インクリメンタルサーチ 検索中にハイライトされる
set incsearch
" 検索時に大文字小文字を無視する
set ignorecase
" 検索ヒット文字をハイライト
set hlsearch
" C-vの矩形選択で行末より後ろもカーソルを置ける
set virtualedit=block
" 行の最後+1文字分カーソルを置ける
set virtualedit+=onemore
" バックスペースの挙動を7.2の時のように戻す
set backspace=indent,eol,start
" カーソルの上下に確保する表示行
set so=5
" コマンド履歴
set history=500
" ファイル補完をshellに近く
set wildmode=longest,full
" スクロールスピード改善
set lazyredraw
" 対応カッコ表示
set showmatch
" 100 桁以上はハイライトしない(既定値では 3000)
set synmaxcol=600
" CursorHoldやcrash-recoveryのための待ち時間(default:4000)
set updatetime=300
" シンタックスハイライトつけるためにかかる時間の閾値
set redrawtime=4000
" vsplitでしたに開く
set splitbelow
" 新しいウィンドウを右に開く
set splitright
" *などで検索するときにどの記号を含めてcwordとするか
" phpのアロー演算子まで拾うので
set iskeyword-=-
" ファイル末尾改行
set nofixendofline
" VisualBell
set belloff=all
" ルーラー
set colorcolumn=120
" 不可視文字
" set list
" set listchars=tab:»-,trail:-,eol:↲,extends:»,precedes:«,nbsp:%
" set listchars=tab:»-,trail:-,extends:»,precedes:«,nbsp:%
" リーダー
let mapleader = "\<Space>"
" カレントじゃないウインドウ以外を閉じる
nnoremap <leader>to :only<CR>
" カレントのタブを閉じる(分割が残らない)
nnoremap <leader>tq :tabclose<CR>
" 余計なもの全部消す
nnoremap <leader>tn :Tabnewonly<CR>
:command! Tabnewonly tabe | tabonly

" :qの簡易化
nnoremap <leader>q :quit<CR>

"行番号
set number
:command! Nu set relativenumber
:command! NU set relativenumber!

" モードラインを有効にする
set modeline
" 3行目までをモードラインとして検索する
set modelines=3

if version >= 800 || exists("g:gui_oni")
	" terminalモードから抜ける
	:tnoremap <silent><Esc><Esc> <C-\><C-n>
endif

" MySQLのsyntax highlight
let g:sql_type_default = 'mysql'

" Enable filetype plugins
filetype plugin indent on

if version >= 800 || exists("g:gui_oni")
	set completeopt+=noselect,noinsert
endif

if exists("g:gui_oni")
	set mouse=a
endif
" }}}

"------------------------------------------------------
" misc alias
"------------------------------------------------------
"
" {{{
" Vimrcへのショートカット
:command! Vrc tabe | e ~/.vimrc
:command! Src source ~/.vimrc
" diff用バッファ
:command! DiffWindo tabnew | vnew | diffthis
:command! Diff diffthis
" grep書式自動挿入
nnoremap <expr> ? ':Ag -R ' . expand('<cword>') . ' ~/project/application'
"vnoremap <expr> ? ':grep ' . expand('<cword>') . ' ~/project/application -R'
" 連続コピペ
vnoremap <silent> <C-p> "0p
" 行末空白削除
:command! Sdel %s/[\t ]*$// | noh
" 雑に打ってもイケるように
" nnoremap ; :
" exモードに入らない
nnoremap Q <Nop>
" recodingしない
nnoremap q <Nop>
" さっき挿入した文字を挿入してinsert モードを終了しない
nnoremap <C-@> <Nop>
" ESCキー2度押しでハイライトの切り替え
" nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>
" insert中にC-cでSEGVで死ぬことがあったため
inoremap <C-c> <C-[>
" Session 作成
:command! Mks mks! ~/.vim.session
" Session 復帰
:command! Ss source ~/.vim.session

" Ex-modeのカーソル移動をreadline風に
cnoremap <C-a> <Home>
" 一文字戻る
cnoremap <C-b> <Left>
" カーソルの下の文字を削除
cnoremap <C-d> <Del>
" 行末へ移動
cnoremap <C-e> <End>
" 一文字進む
cnoremap <C-f> <Right>
" コマンドライン履歴を一つ進む
cnoremap <C-n> <Down>
" コマンドライン履歴を一つ戻る
cnoremap <C-p> <Up>
" 前の単語へ移動
cnoremap <M-b> <S-Left>
" 次の単語へ移動
cnoremap <M-f> <S-Right>
" 行削除を一旦何もしないようにしとく
cnoremap <C-u> <Nop>
" 検索語を
nmap n nzz
nmap N Nzz
" 補完候補選択
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" inoremap <expr> <CR> pumvisible() ? "<C-y>" : "\<CR>"
" フルパス表示(C-gの置き換え…)
nnoremap <C-g> :echo expand("%:p")<cr>

" OniVimのC-v C-c有効化
" FYI: https://github.com/onivim/oni/blob/8d08aa109299517c0c6799c66e962563b0fd5fa4/browser/src/Input/KeyBindings.ts#L38
if exists("g:gui_oni")
	nnoremap <M-v> "*p
	inoremap <M-v> <C-R>*
	cnoremap <M-v> <C-R>*
	vnoremap <M-c> "*y
endif

" PHP Lint
nnoremap <leader>ap :CallPhpLint<CR>
command! CallPhpLint call s:CallPhpLint()

function! s:CallPhpLint()
	call s:PhpLint() | if len(getqflist()) != 0 | copen 1 | else | cclose | endif
endfunction

function! s:PhpLint()
	let l:result = system('php -l ' . expand("%"))
	let l:resultList = split(l:result, "\n")

	if (match(l:resultList, 'No syntax errors detected in') != -1)
		call setqflist([], 'r')
		return
	endif

	let l:errors = []
	for r in l:resultList
		let info = {'filename': expand("%")}
		"echo match(r, "\von line ([0-9]+)\C")
		"echo substitute(match(r, "\von line ([0-9]+)\C"), "([0-9]+)", "\n")
		" let info.lnum = substitute(match(r, "\von line ([0-9]+)\C", '\1'), "([0-9]+)", "\n")
		let info.text = r
		call add(errors, info)
		break
	endfor

	call setqflist(l:errors, 'r')
endfunction
" }}}

"------------------------------------------------------
" autocmd
"------------------------------------------------------

" {{{
"前回閉じたときのカーソルの位置を保存
augroup VimrcEx
	autocmd!
	autocmd BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
				\ exe "normal g`\"" | endif
augroup END

augroup Grep
	autocmd!
	" grep 後に quickfix勝手に開く
	autocmd QuickFixCmdPost grep tabe | cope
augroup END

augroup HighlightTrailingSpaces
	autocmd!
	autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
	autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END

autocmd BufRead,BufNewFile *.ts set filetype=typescript
autocmd BufRead,BufNewFile *.ddl set filetype=sql
autocmd BufRead,BufNewFile *.es6 setlocal filetype=javascript
" autocmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript.css


" }}}

"------------------------------------------------------
" FZF
"------------------------------------------------------
"
" {{{
" [初回インストールコマンド]
" plugに移したので基本的には不要
" git clone https://github.com/junegunn/fzf.git ~/.fzf
"
" FYI: http://koturn.hatenablog.com/entry/2015/11/26/000000
" FYI: https://github.com/junegunn/fzf/wiki/Examples-(vim)

" :FZFコマンドを使えるように
set rtp+=~/.fzf

nnoremap <leader>b :Fb<CR>
nnoremap <leader>f :FZFFileList<CR>
nnoremap <leader>d :FZFDirList<CR>
nnoremap <leader>m :FZFMru<CR>
nnoremap <leader>t :FZFTabOpen<CR>
nnoremap <leader>o :FZFOpenFile<CR>
" nnoremap <C-]> :FZFFileList<CR>

command! Fq   FZFQuickFix
command! Fmru FZFMru
command! Fb   FZFBuffer
command! Ft   FZFTagList


" [Replace of Ctrl-p] --------------------------------
" 除外したいファイルが有れば
" ! -name [ファイル名]
" を追加すると除外できる

command! FZFFileList call fzf#run({
			\ 'source': 'find . -type d -name .git -prune -o ! -name .DS_Store',
			\ 'sink':   'e',
			\ 'down':   '40%'})

command! FZFDirList call fzf#run({
			\ 'source': 'find . -type d',
			\ 'sink':   'e',
			\ 'down':   '40%'})

" [MRU] ----------------------------------------------
"
command! FZFMru call fzf#run({
			\ 'source':  v:oldfiles,
			\ 'sink':    'tabe',
			\ 'options': '-m -x +s',
			\ 'down':    '40%'})

" [Buffer] -------------------------------------------
"
command! FZFBuffer :call fzf#run({
			\ 'source':  reverse(<sid>buflist()),
			\ 'sink':    function('<sid>bufopen'),
			\ 'options': '+m',
			\ 'down':    len(<sid>buflist()) + 2
			\ })

function! s:buflist()
  redir => ls
  silent ls
  redir END
  return split(ls, '\n')
endfunction

function! s:bufopen(e)
  execute 'buffer' matchstr(a:e, '^[ 0-9]*')
endfunction

" [QuickFix] -----------------------------------------
"
command! FZFQuickFix call fzf#run({
			\ 'source':  Get_qf_text_list(),
			\ 'sink':    function('s:qf_sink'),
			\ 'options': '-m -x +s',
			\ 'down':    '40%'})

" QuickFix形式にqfListから文字列を生成する
function! Get_qf_text_list()
	let s:qflist = getqflist()
	let s:textList = []
	for i in s:qflist
		if i.valid
			let s:textList = add(s:textList, printf('%s|%d| %s',
				\		bufname(i.bufnr),
				\		i.lnum,
				\		matchstr(i.text, '\s*\zs.*\S')
				\	))
		endif
	endfor
	return s:textList
endfunction

" QuickFix形式のstringからtabeに渡す
function! s:qf_sink(line)
	let parts = split(a:line, '\s')
	execute 'tabe ' . parts[0]
endfunction

" [tag] -----------------------------------------
"
function! s:fzf_tag(fzf_tags_file_full_path)
	let s:fzf_tags_file_full_path = a:fzf_tags_file_full_path

	" https://stackoverflow.com/questions/11532157/unix-removing-duplicate-lines-without-sorting
	" sort -u の代わりに awk '!x[$0]++' を使うことで逐次処理を維持
	" awk '!x[$1]++ {print $1}' は awk {'print $1'} | awk '!x[$0]++'と一緒
	command! FZFTagList call fzf#run({
				\ 'source': "cat " . s:fzf_tags_file_full_path . " | awk '!x[$1]++ {print $1}' |  grep -v '^[!\(\=]'",
				\ 'sink':   'tag',
				\ 'down':   '40%'})
endfunction

" [file open] ----------------------------------
"
" ファイルに書かれたパスからマッチするファイル開く
command! FZFOpenFile call FZFOpenFileFunc()
function! FZFOpenFileFunc()
	let s:file_path = expand("<cfile>")

	if s:file_path == ''
		echo '[Error] <cfile> return empty string.'
		return 0
	endif

	call fzf#run({
			\ 'source':  'find . -type d -name .git -prune -o ! -name .DS_Store',
			\ 'sink':    'tabe',
			\ 'options': '-e -x +s --query=' . shellescape(s:file_path),
			\ 'down':    '40%'})
endfunction

" [tab open] ----------------------------------
"
" 数あるタブから開く
command! FZFTabOpen call s:FZFTabOpenFunc()

function! s:FZFTabOpenFunc()
	call fzf#run({
			\ 'source':  s:GetTabList(),
			\ 'sink':    function('s:TabListSink'),
			\ 'options': '-m -x +s',
			\ 'down':    '40%'})
endfunction

function! s:GetTabList()
	let s:tabList = execute('tabs')
	let s:textList = []
	for tabText	 in split(s:tabList, '\n')
		let s:tabPageText = matchstr(tabText, '^Tab page')
		if !empty(s:tabPageText)
			let s:pageNum = matchstr(tabText, '[0-9]*$')
		else
			let s:textList = add(s:textList, printf('%d %s',
				\ s:pageNum,
				\ tabText,
				\	))
		endif
	endfor
	return s:textList
endfunction

function! s:TabListSink(line)
	let parts = split(a:line, '\s')
	execute 'normal ' . parts[0] . 'gt'
endfunction
" }}}

"------------------------------------------------------
" Vim Plug
"------------------------------------------------------

" {{{
" [DownLoad]
" $ curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" [Install command]
" :PlugInstall

if exists("g:gui_oni")
    call plug#begin('~/.oni/plugins')
else
    call plug#begin('~/.vim/plugged')
endif

" -------------------------------------------------------
Plug 'mhinz/vim-startify'
" -------------------------------------------------------
" Plug 'gorodinskiy/vim-coloresque' " iskを汚染する :verbose set iskeyword?
Plug 'ap/vim-css-color'
" -------------------------------------------------------
Plug 'airblade/vim-gitgutter'
" -------------------------------------------------------
let g:gitgutter_realtime = 0

" -------------------------------------------------------
Plug 'tpope/vim-fugitive'
" -------------------------------------------------------
" コミット履歴から開く
nnoremap <leader>gs :Gstatus <CR>
nnoremap <leader>gl :Glog master..HEAD -n 100 -- <CR>
nnoremap <leader>ga :Gwrite<CR>
nnoremap <leader>gc :Gcommit<CR>

" -------------------------------------------------------
Plug 'junegunn/vim-easy-align'
" -------------------------------------------------------
" 選んだ範囲で整える
" remapで動かない系
xmap <Space> <Plug>(EasyAlign)*<Space>
xmap ,  <Plug>(EasyAlign)*,
" xmap = <Plug>(EasyAlign)*= // インデント直すのに使ってる
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" -------------------------------------------------------
Plug 'tyru/caw.vim'
" -------------------------------------------------------
" コメントアウト
nmap <leader>k <Plug>(caw:hatpos:toggle)
vmap <leader>k <Plug>(caw:hatpos:toggle)

" -------------------------------------------------------
Plug 'tpope/vim-surround'
" -------------------------------------------------------
" -------------------------------------------------------
Plug 'rhysd/clever-f.vim'
" -------------------------------------------------------
let g:clever_f_smart_case = 1

" -------------------------------------------------------
Plug 'LeafCage/yankround.vim'
" -------------------------------------------------------
nmap p <Plug>(yankround-p)
xmap p <Plug>(yankround-p)
nmap P <Plug>(yankround-P)
nmap gp <Plug>(yankround-gp)
xmap gp <Plug>(yankround-gp)
nmap gP <Plug>(yankround-gP)
nmap <C-p> <Plug>(yankround-prev)
nmap <C-n> <Plug>(yankround-next)

" -------------------------------------------------------
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets' " Snippets are separated from the engine(ultisnips).
Plug 'tobyS/vmustache', {'for': ['php']}
Plug 'tobyS/pdv', {'for': ['php']}
" -------------------------------------------------------
" SirVer/ultisnips
let g:UltiSnipsExpandTrigger       = "<Tab>"
let g:UltiSnipsJumpForwardTrigger  = "<Tab>"
let g:UltiSnipsJumpBackwardTrigger = "<S-Tab>"

" tobyS/pdv
let g:pdv_template_dir = $HOME ."/.vim/plugged/pdv/templates_snip"
nnoremap <C-@> :call pdv#DocumentWithSnip()<CR>

" -------------------------------------------------------
Plug 'rking/ag.vim'
" -------------------------------------------------------
" -------------------------------------------------------
Plug 'w0rp/ale'
" -------------------------------------------------------
" g:ale_lint_on_saveはデフォルトでon
let g:ale_linters = {
      \ 'php': ['phpmd', 'phpcs', 'php']
      \}

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_save = 1
let g:ale_lint_on_enter = 1
nnoremap <leader>al <Plug>(ale_next_wrap)

" let g:ale_set_loclist = 0
" let g:ale_set_quickfix = 1
" ruleset
let g:ale_php_phan_executable = 'phan'
let g:ale_php_phpcs_standard  = $HOME.'/.phpconf/phpcs/ruleset.xml'
let g:ale_php_phpmd_ruleset   = $HOME.'/.phpconf/phpmd/ruleset.xml'
" [phpmdメモ]
" codesize      ： 循環的複雑度などコードサイズ関連部分を検出するルール
" controversial ： キャメルケースなど議論の余地のある部分を検出するルール
" design        ： ソフトの設計関連の問題を検出するルール
" naming        ： 長すぎたり、短すぎたりする名前を検出するルール
" unusedcode    ： 使われていないコードを検出するルール

if version >= 800 || exists("g:gui_oni")
	" -------------------------------------------------------
	" Plug 'Shougo/deoplete.nvim'
	" -------------------------------------------------------
	" pip3が必要。そしてneovimのPython3 interfaceが必要(?)
	" FYI: http://kaworu.jpn.org/vim/deoplete
	" pip install neovim # or
	" pip3 install neovim

	if has('nvim')
		Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
	else
		Plug 'Shougo/deoplete.nvim'
		Plug 'roxma/nvim-yarp'
		Plug 'roxma/vim-hug-neovim-rpc'
	endif

	augroup Deoplete
		autocmd!
		" 上部に保管した際のDocstringを表示しない
		autocmd FileType * setlocal completeopt-=preview
	augroup END

	let g:deoplete#enable_at_startup = 1
	let g:deoplete#enable_smart_case = 1
	let g:deoplete#auto_complete_start_length = 2
	let g:deoplete#disable_auto_complete = 0
	let g:auto_complete_delay = 2000

	" 重い
	" let g:deoplete#omni_patterns = {
	"   \ 'php': '\h\w*\|[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
	"   \ }

	" PHP Complete Daemon
	" Plug 'lvht/phpcd.vim', { 'for': 'php', 'do': 'composer install' }
	" let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
	" let g:deoplete#ignore_sources.php = ['phpcd', 'omni']
	" let g:phpcd_autoload_path = 'path/to/autoload_file.php'
endif

" -------------------------------------------------------
Plug 'majutsushi/tagbar'
" -------------------------------------------------------
" nnoremap <C-^> :TagbarToggle<CR>
" Hyper.appがC-^潰してるっぽい
nnoremap <leader>^ :TagbarToggle<CR>
let g:tagbar_width = 50
let g:tagbar_autoshowtag = 1
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1

let g:tagbar_type_php  = {
	\ 'ctagstype' : 'php',
	\ 'kinds'     : [
	\ 	'i:interfaces',
	\ 	'c:classes',
	\ 	'd:constant definitions',
	\ 	'f:functions',
	\ 	't:traits',
	\ 	'j:javascript functions:1'
	\ ]
	\ }

" カレントディレクトリがgitのbranch上でのみTagを有効化
" gitのrootディレクトリの.gitにタグファイルを入れてしまう
let s:is_on_git_branch = system('git rev-parse &>/dev/null; echo $?')
if s:is_on_git_branch == 0
	" -------------------------------------------------------
	Plug 'szw/vim-tags'
	" -------------------------------------------------------
	" :TagsGenerate!
	"
	" # Universal Ctagsをインストール
	" brew tap universal-ctags/universal-ctags
	" brew install --HEAD universal-ctags
	"
	" かつてのctagsにはおさらば(Macにはデフォルトで入ってる)
	" brew uninstall ctags
	"
	" [旧メモ]
	" Macの場合には最初から入っているctagsだと-Rオプションがないと怒られる
	" FYI:https://gist.github.com/nazgob/1570678
	"
	" https://git-scm.com/docs/git-worktree#git-worktree-list
	" "The main worktree is listed first,"
	let s:git_root_dir = substitute(system("git worktree list | head -n 1 | awk {'print $1'}"), '\n\+$', '', '')
	let s:git_ignore_dir = ".git"
	let s:tags_file_name = ".tags"
	let s:tags_file_full_path = s:git_root_dir . "/" . s:git_ignore_dir . "/" . s:tags_file_name

	execute "set tags+=" . s:tags_file_full_path
	" 保存時に裏で自動でctagsを作成する
	let g:vim_tags_auto_generate = 0
	" tag保存ファイル名
	let g:vim_tags_main_file = s:tags_file_name
	" tagファイルのパス
	let g:vim_tags_extension = s:git_root_dir . '/' . s:git_ignore_dir
	" 細かいオプションは.ctagsにて
	let g:vim_tags_project_tags_command = "ctags -f " .  s:tags_file_full_path . " -R " . s:git_root_dir
	" 別タブで開けるようにremap
	nnoremap <C-]> :tab sp<CR> :exe("tjump ".expand('<cword>'))<CR>

	command! Tagrm execute("!rm -i " . s:tags_file_full_path)
	command! Tag   silent TagsGenerate!

	" FZFとのタグ連携
	call s:fzf_tag(s:tags_file_full_path)
else
	let s:err_msg = 'You are currently on not Git top level dir.'
	command! Tagrm echo s:err_msg
	command! Tag   echo s:err_msg
endif

" -------------------------------------------------------
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
" -------------------------------------------------------
" airlineは色々機能付きすぎて重い
set laststatus=2

" For Powerline
let g:lightline = {
	\ 'colorscheme': 'material_vim' ,
	\ 'active' : {
	\   'left' : [ [ 'mode', 'paste' ],
	\              [ 'fugitive', 'readonly', 'filename', 'modified' ] ],
	\   'right': [ [ 'linter_errors', 'linter_warnings' ,'linter_ok' ],
	\              [ 'lineinfo' ],
	\              [ 'percent' ],
	\              [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]
	\ },
	\ 'separator'         : { 'left': "", 'right': "" },
	\ 'subseparator'      : { 'left': "", 'right': "" },
	\ 'component_function': {
	\     'fugitive':       'LightlineFugitive',
	\     'readonly':       'LightlineReadonly',
	\     'modified':       'LightlineModified',
	\ },
	\ 'component_expand': {
	\     'linter_warnings': 'lightline#ale#warnings',
	\     'linter_errors'  : 'lightline#ale#errors',
	\     'linter_ok'      : 'lightline#ale#ok',
	\ },
	\ 'component_type':{
	\     'linter_warnings': 'warning',
	\     'linter_errors'  : 'error',
	\ }
	\ }


function! LightlineModified()
	if &filetype == "help"
		return ""
	elseif &modified
		return "+"
	elseif &modifiable
		return ""
	else
		return ""
	endif
endfunction

function! LightlineReadonly()
	if &filetype == "help"
		return ""
	elseif &readonly
		return "\ue0a2"
	else
		return ""
	endif
endfunction

function! LightlineFugitive()
	if exists("*fugitive#head")
		let branch = fugitive#head()
		return branch !=# '' ? branch : ''
	endif
	return ''
endfunction


" maximbaz/lightline-ale
let g:lightline#ale#indicator_warnings  = "⚠ "
let g:lightline#ale#indicator_errors   = "☓"
let g:lightline#ale#indicator_ok       = ""

" -------------------------------------------------------
" Plug 'flyinshadow/php_localvarcheck.vim', {'for': ['php']}
" -------------------------------------------------------
" let g:php_localvarcheck_enable = 1
" let g:php_localvarcheck_global = 0
"
" -------------------------------------------------------
Plug 't9md/vim-quickhl'
" -------------------------------------------------------
"
nmap <leader>hm <Plug>(quickhl-manual-this)
xmap <leader>hm <Plug>(quickhl-manual-this)

nmap <leader>hw <Plug>(quickhl-manual-this-whole-word)
xmap <leader>hw <Plug>(quickhl-manual-this-whole-word)

nmap <leader>hc <Plug>(quickhl-manual-clear)
vmap <leader>hc <Plug>(quickhl-manual-clear)

nmap <leader>hr <Plug>(quickhl-manual-reset)
xmap <leader>hr <Plug>(quickhl-manual-reset)

nmap <leader>hj <Plug>(quickhl-cword-toggle)
" nmap <leader>] <Plug>(quickhl-tag-toggle)
" map H <Plug>(operator-quickhl-manual-this-motion)

let g:quickhl_manual_colors = [
			\ "cterm=bold ctermfg=154 gui=bold guifg=#afff00",
			\ "cterm=bold ctermfg=197 gui=bold guifg=#ff005f",
			\ "cterm=bold ctermfg=123 gui=bold guifg=#87ffff",
			\ "cterm=bold ctermfg=226 gui=bold guifg=#ffff00",
			\ "cterm=bold ctermfg=208 gui=bold guifg=#ffaf00",
			\ "cterm=bold ctermfg=33  gui=bold guifg=#0087ff",
			\ "cterm=bold ctermfg=141 gui=bold guifg=#af87ff"]

" C-j は hi Search を利用している

" -------------------------------------------------------
" shell とかvimscriptとかrubyの if-endif とか閉じてくれる
Plug 'tpope/vim-endwise'
" Plug 'alvan/vim-closetag'
" Plug 'kana/vim-smartinput'
" -------------------------------------------------------
Plug 'rust-lang/rust.vim', {'for': ['rust']}
" -------------------------------------------------------
Plug 'fatih/vim-go', { 'for': ['go'], 'do': ':GoInstallBinaries' }
" ctagsのままでよいので
let g:go_def_mapping_enabled = 0
nnoremap <leader>g f :GoDecls<CR>
nnoremap <leader>g d :GoDeclsDir<CR>

" -------------------------------------------------------
Plug 'posva/vim-vue'
" -------------------------------------------------------
" Plug 'kamykn/spelunker.vim'
Plug 'trsdln/spelunker.vim'
let g:spelunker_white_list_for_user = ['kamykn', 'vimrc']
let g:spelunker_disable_auto_group = 1
augroup spelunker
  autocmd!
  autocmd BufWinEnter,BufWritePost *.vim,*.js,*.jsx,*.json,*.md,*.go,*.html,*.ts,*.php call spelunker#check()
augroup END
" let g:spelunker_min_char_len = 1
" -------------------------------------------------------
Plug 'kamykn/skyhawk'
Plug 'kamykn/skyknight'
Plug 'joshdick/onedark.vim'
Plug 'freeo/vim-kalisi'
Plug 'colepeters/spacemacs-theme.vim'
Plug 'connorholyday/vim-snazzy'
Plug 'srcery-colors/srcery-vim'
let g:srcery_italic = 1
Plug 'kaicataldo/material.vim'


" Plug 'dikiaap/minimalist'
" -------------------------------------------------------
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" -------------------------------------------------------
Plug 'luochen1990/rainbow'
let g:rainbow_active = 1 " 0 if you want to enable it later via :RainbowToggle
	let g:rainbow_conf = {
	\	'guifgs': ['#87d7ff', 'white'],
	\	'ctermfgs': ['117', '15',],
	\}

" -------------------------------------------------------
Plug 'vim-scripts/TeTrIs.vim'
" -------------------------------------------------------
call plug#end()
" }}}
" " 行末スペース
" " TODO
" call smartinput#define_rule({
" 			\   'at': '\s\+\%#',
" 			\   'char': '<CR>',
" 			\   'input': "<C-o>:call setline('.', substitute(getline('.'), '\\s\\+$', '', ''))<CR><CR>",
" 			\   })
" " アロー演算子
" " TODO
" call smartinput#define_rule({
" 			\   'at': '\s\+\%#',
" 			\   'char': '-',
" 			\   'input': ">",
" 			\   'filetype' : ['php'],
" 			\   })
" -------------------------------------------------------
" Language settings
" -------------------------------------------------------

" {{{
let g:sql_type_default = 'mysql'
" 文字列の中のSQLをハイライト
let php_sql_query = 1
" HTMLもハイライト
let php_htmlInStrings = 1
" ] や ) の対応エラーをハイライト
let php_parent_error_close = 1
let php_parent_error_open = 1

" Phan
" Macのローカルに環境構築する場合はこちら
" https://github.com/phan/phan/wiki/Getting-Started-With-Homebrew
" }}}

" -------------------------------------------------------
" colorscheme
" -------------------------------------------------------

" {{{

:command! Bglight call s:bglight()
function! s:bglight()
	set background=light
	colorscheme kalisi
endfunction

:command! Bgdark call s:bgdark()
function! s:bgdark()
	set background=dark
    " colorscheme skyhawk
	" colorscheme skyknight
    " colorscheme onedark
    " colorscheme snazzy
	" colorscheme srcery
	colorscheme material
	let g:material_theme_style = 'palenight'
	let g:material_terminal_italics = 1

	" hyper用に背景色を無効にしてみる
	" hi Normal ctermfg=250 ctermbg=NONE cterm=NONE guifg=#bcbcbc guibg=NONE gui=NONE
endfunction

call s:bgdark()
" call s:bglight()

hi clear SpellBad
hi SpellBad cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE
hi clear SpellCap " & ALE
hi SpellCap cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE

hi Search ctermfg=45 ctermbg=NONE cterm=NONE guifg=#00d7ff guibg=NONE gui=NONE
hi IncSearch ctermfg=45 ctermbg=NONE cterm=NONE guifg=#00d7ff guibg=NONE gui=NONE


" カーソル下のhighlight情報を表示する
function! s:get_syn_id(transparent)
    let synid = synID(line('.'), col('.'), 1)
    return a:transparent ? synIDtrans(synid) : synid
endfunction
function! s:get_syn_name(synid)
    return synIDattr(a:synid, 'name')
endfunction
function! s:get_highlight_info()
    execute "highlight " . s:get_syn_name(s:get_syn_id(0))
    execute "highlight " . s:get_syn_name(s:get_syn_id(1))
endfunction
command! HighlightInfo call s:get_highlight_info()
" }}}

" -------------------------------------------------------
" for debug
" -------------------------------------------------------
" usage)
" TimerStart
" なんか処理
" TimerEnd
"
command! -bar TimerStart    let start_time = reltime()
command! -bar TimerEndEcho  echo reltimestr(reltime(start_time))
command! -bar TimerEndEchom echom reltimestr(reltime(start_time))

" -------------------------------------------------------
" memo
" -------------------------------------------------------

" {{{
" なにかのプラグインが内部的に<C-m>を使っているっぽい？
" <C-m>はReturnだが、normalモードだとjと変わらないと思って
" <C-m>にキーバインドするとナチュラルに死ぬパターンある
"
" 自動で括弧やendxxx系を閉じるプラグインが悪さしてクリップボードからペーストしたものの履歴が区切られてしまう。
" これはvimの入力中の移動は履歴が区切られてしまう仕様による。
" 履歴の単位を正しくすることと、確実にコピペするためにも:a!を利用すること。
"
" session もfzfで複数から絞りたい

" [便利コマンド]
" tag [検索したい名前]
"   tag検索->ファイルオープン(XXXっていうクラスがさーって言われたら検索する用)
"   (FazzyFinderで探したい)
" -> :Ftを実装した
"
"  tagを選択した後のファイル選択もfzf化したい

" 重いメモ
" ## カーソル下の変数をハイライトする機能が重い
" - ファイルが長すぎてmatchを探す時間が長すぎるのかと
" ## スペルチェック
" - ハイライトされない問題
" - redrawtimeを突き抜ける
"
" -------------------------------------------------------
" oni vim (neo vim)
" -------------------------------------------------------
" :terminalから親のnvimでファイル編集を開く
" pip3 install neovim-remote
" }}}
"
