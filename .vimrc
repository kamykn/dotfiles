" -----------------------------------------------------
"                     kmszk .vimrc
" -----------------------------------------------------
"
" vim8.0+ required
" brew upgrade vim --with-lua --with-python3
"
"------------------------------------------------------
" Common Settings.
"------------------------------------------------------
"
" Font Install
" https://github.com/miiton/Cica

" 文字コード設定
set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix

" 色関連
set t_Co=256

syntax on

" スペルチェック
set spell
set spelllang=en,cjk
" スペルチェック対象
syntax spell toplevel


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
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0
" スワップファイルを作らない
set noswapfile
" undoファイルを作らない(for GVim)
set noundofile
" XXX~を作らない
set nobackup
" カッコのハイライト1表示、0非表示(効いていないっぽい)
let loaded_matchparen = 0
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
set redrawtime=2000

"行番号
set number
:command! Nu set relativenumber
:command! NU set relativenumber!

" MySQLのsyntax highlight
let g:sql_type_default = 'mysql'

" Enable filetype plugins
filetype plugin indent on

if version >= 800
	set completeopt+=noselect,noinsert
endif

"------------------------------------------------------
" misc alias
"------------------------------------------------------
"
" Vimrcへのショートカット
:command! Vrc tabe | e ~/.vimrc
:command! Src source ~/.vimrc
" diff用バッファ
:command! DiffWindo tabnew | vnew | diffthis
:command! Diff diffthis
" grep書式自動挿入
vnoremap <expr> ? ':grep ' . expand('<cword>') . ' ~/project/application -R'
" 連続コピペ
vnoremap <silent> <C-p> "0p<CR>
" 行末空白削除
:command! Sdel s/ *$// | noh
" 雑に打ってもイケるように
" nnoremap ; :
" exモードに入らない
nnoremap Q <Nop>
" recodingしない
nnoremap q <Nop>
" ESCキー2度押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

"------------------------------------------------------
" autocmd
"------------------------------------------------------

"前回閉じたときのカーソルの位置を保存
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END

" grep 後に quickfix勝手に開く
autocmd QuickFixCmdPost grep cope

augroup HighlightTrailingSpaces
  autocmd!
  autocmd VimEnter,WinEnter,ColorScheme * highlight TrailingSpaces term=underline guibg=Red ctermbg=Red
  autocmd VimEnter,WinEnter * match TrailingSpaces /\s\+$/
augroup END

augroup PHP
  autocmd!
  " autocmd FileType php set makeprg=php\ -l\ %
  " set errorformat=%m\ in\ %f\ on\ line\ %l
  " php -lの構文チェックでエラーがなければ「No syntax errors」の一行だけ出力される
  autocmd BufWritePost *.php call PhpLint() | if len(getqflist()) != 0 | copen 1 | endif
augroup END

function! PhpLint()
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

"------------------------------------------------------
" FZF
"------------------------------------------------------
"
" [初回インストールコマンド]
" git clone https://github.com/junegunn/fzf.git ~/.fzf
"
" FYI: http://koturn.hatenablog.com/entry/2015/11/26/000000
" FYI: https://github.com/junegunn/fzf/wiki/Examples-(vim)
"

" :FZFコマンドを使えるように
set rtp+=~/.fzf

nnoremap <C-b> :Fb<CR>
nnoremap <C-p> :FZFFileList<CR>

command! Fq FZFQuickFix
command! Fmru FZFMru
command! Fb FZFBuffer

" [Replace of Ctrl-p] --------------------------------
" 除外したいファイルが有れば
" ! -name [ファイル名]
" を追加すると除外できる

command! FZFFileList call fzf#run({
			\ 'source': 'find . -type d -name .git -prune -o ! -name .DS_Store',
			\ 'sink': 'e'})

" [MRU] ----------------------------------------------
"
command! FZFMru call fzf#run({
			\  'source':  v:oldfiles,
			\  'sink':    'tabe',
			\  'options': '-m -x +s',
			\  'down':    '40%'})

" [Buffer] -------------------------------------------
"
command! FZFBuffer :call fzf#run({
			\   'source':  reverse(<sid>buflist()),
			\   'sink':    function('<sid>bufopen'),
			\   'options': '+m',
			\   'down':    len(<sid>buflist()) + 2
			\ })<CR>


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
			\  'source':  Get_qf_text_list(),
			\  'sink':    function('s:qf_sink'),
			\  'options': '-m -x +s',
			\  'down':    '40%'})

" QuickFix形式にqfListから文字列を生成する
function! Get_qf_text_list()
	let qflist = getqflist()
	let textList = []
	for i in qflist
		if i.valid
			let textList = add(textList, printf('%s|%d| %s',
				\		bufname(i.bufnr),
				\		i.lnum,
				\		matchstr(i.text, '\s*\zs.*\S')
				\	))
		endif
	endfor
	return textList
endfunction

" QuickFix形式のstringからtabeに渡す
function! s:qf_sink(line)
	let parts = split(a:line, '\s')
	execute 'tabe ' . parts[0]
endfunction


"------------------------------------------------------
" Vim Plug
"------------------------------------------------------
" [DownLoad]
" $ curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
"
" [Install command]
" :PlugInstall

call plug#begin('~/.vim/plugged')

" -------------------------------------------------------
Plug 'sickill/vim-monokai'
Plug 'sjl/badwolf'
Plug 'tomasr/molokai'
" -------------------------------------------------------
" カラースキーム
" -------------------------------------------------------
Plug 'airblade/vim-gitgutter'
" -------------------------------------------------------
" -------------------------------------------------------
Plug 'tpope/vim-fugitive'
" -------------------------------------------------------
" -------------------------------------------------------
Plug 'junegunn/vim-easy-align'
" -------------------------------------------------------
" 選んだ範囲で整える
xmap <Space> <Plug>(EasyAlign)*<Space>
xmap ,  <Plug>(EasyAlign)*,
xmap g= <Plug>(EasyAlign)*=
" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)
" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" -------------------------------------------------------
Plug 'tyru/caw.vim'
" -------------------------------------------------------
" コメントアウト
nmap <C-K> <Plug>(caw:hatpos:toggle)
vmap <C-K> <Plug>(caw:hatpos:toggle)

" -------------------------------------------------------
Plug 'tpope/vim-surround'
" -------------------------------------------------------
" -------------------------------------------------------
Plug 'tpope/vim-endwise'
" -------------------------------------------------------
" shell とかvimscriptとかrubyの if-endif とか閉じてくれる

" -------------------------------------------------------
Plug 'flyinshadow/php_localvarcheck.vim', {'for': ['php']}
" -------------------------------------------------------
let g:php_localvarcheck_enable = 1
let g:php_localvarcheck_global = 0

" -------------------------------------------------------
Plug 'tobyS/vmustache'
Plug 'tobyS/pdv', {'for': ['php']}
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets' " Snippets are separated from the engine(ultisnips).
" -------------------------------------------------------
" tobyS/pdv
let g:pdv_template_dir = $HOME ."/.vim/plugged/pdv/templates_snip"
nnoremap <C-@> :call pdv#DocumentWithSnip()<CR>

" SirVer/ultisnips
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"

" -------------------------------------------------------
Plug 'osyo-manga/vim-brightest'
" -------------------------------------------------------
" 画面内のカーソル下の単語と同じ単語をハイライト
let g:brightest#enable_on_CursorHold = 1
let g:brightest#pattern = '\k\+'
let g:brightest#enable_filetypes = {
\   "_"   : 0,
\   "vim" : 1,
\   "php" : 1,
\}

" -------------------------------------------------------
Plug 'w0rp/ale'
" -------------------------------------------------------
" g:ale_lint_on_saveはデフォルトでon
let g:ale_lint_on_text_changed = 'never'
" let g:ale_set_loclist = 0
" let g:ale_set_quickfix = 1
" ruleset
let g:ale_php_phpcs_standard = $HOME.'/.phpconf/phpcs/ruleset.xml'
let g:ale_php_phpmd_ruleset  = $HOME.'/.phpconf/phpmd/ruleset.xml'
" [phpmdメモ]
" codesize      ： 循環的複雑度などコードサイズ関連部分を検出するルール
" controversial ： キャメルケースなど議論の余地のある部分を検出するルール
" design        ： ソフトの設計関連の問題を検出するルール
" naming        ： 長すぎたり、短すぎたりする名前を検出するルール
" unusedcode    ： 使われていないコードを検出するルール


if version >= 800
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
	let g:deoplete#enable_at_startup = 1
	let g:deoplete#enable_smart_case = 1
	let g:deoplete#auto_complete_start_length = 4
	let g:deoplete#disable_auto_complete=1
	let g:auto_complete_delay = 2000
	let g:deoplete#omni_patterns = {
	  \ 'php': '\h\w*\|[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
	  \ }
endif

" -------------------------------------------------------
Plug 'majutsushi/tagbar'
" -------------------------------------------------------
nmap <C-^> :TagbarToggle<CR>
let g:tagbar_width = 50
let g:tagbar_autoshowtag = 1
let g:tagbar_type_php  = {
	\ 'ctagstype' : 'php',
	\ 'kinds'     : [
	\ 	'i:interfaces',
	\ 	'c:classes',
	\ 	'd:constant definitions',
	\ 	'f:functions',
	\ 	'j:javascript functions:1'
	\ ]
	\ }

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
command! Tagrm !rm ~/.tags
command! Tag TagsGenerate!
set tags+=~/.tags
" 保存時に裏で自動でctagsを作成する
let g:vim_tags_auto_generate = 0
" tag保存メインファイル名
let g:vim_tags_main_file = '.tags'
" tagファイルのパス
let g:vim_tags_extension = '~'
" 細かいオプションは.ctagsにて
let g:vim_tags_project_tags_command = "ctags -f ~/.tags -R ~/project"
" # 別タブ
nnoremap <C-]> :tab sp<CR> :exe("tjump ".expand('<cword>'))<CR>

" -------------------------------------------------------
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale'
" -------------------------------------------------------
" airlineは色々機能付きすぎて重い
set laststatus=2

" For Powerline
let g:lightline = {
	\ 'colorscheme': 'powerline' ,
	\ 'active' : {
	\   'left' : [ [ 'mode', 'paste' ],
	\              [ 'fugitive', 'readonly', 'filename', 'modified' ] ],
	\   'right': [ [ 'linter_errors', 'linter_warnings' ,'linter_ok' ],
	\              [ 'lineinfo' ],
	\              [ 'percent' ],
	\              [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex' ] ]
	\ },
	\ 'separator'         : { 'left': '⮀', 'right': '⮂' },
	\ 'subseparator'      : { 'left': '⮁', 'right': '⮃' },
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
		return "⭤"
	else
		return ""
	endif
endfunction

function! LightlineFugitive()
	if exists("*fugitive#head")
		let branch = fugitive#head()
		return branch !=# '' ? '⭠ '.branch : ''
	endif
	return ''
endfunction


" maximbaz/lightline-ale
let g:lightline#ale#indicator_warnings = "⚠ "
let g:lightline#ale#indicator_errors   = "☓"
let g:lightline#ale#indicator_ok       = ""

" -------------------------------------------------------
Plug 'kmszk/CCSpellCheck.vim'
" -------------------------------------------------------

call plug#end()

"------------------------------------------------------
" colorscheme
"------------------------------------------------------
colorscheme badwolf

hi clear SpellBad
hi SpellBad cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE
hi clear MatchParen
hi link MatchParen Statement
hi clear SpellCap " & ALE
hi SpellBad cterm=underline ctermfg=NONE ctermbg=NONE gui=underline guifg=NONE guibg=NONE
hi clear Directory " netrwのDirectory
hi Directory ctermfg=81 gui=italic guifg=#66d9ef
hi clear Search
hi Search ctermfg=0 ctermbg=yellow guibg=#000000 guibg=yellow

hi clear String
hi String ctermfg=186 guifg=#e6db74
hi clear SpecialChar
hi SpecialChar ctermfg=208 guifg=#ff8c00
hi clear PreProc
hi link PreProc SpecialChar
hi clear vimNotation
hi link vimNotation SpecialChar

hi clear Statement
hi Statement ctermfg=197 guifg=#f92672
hi clear Type
hi link Type Statement
hi clear Conditional
hi link Conditional Statement
hi clear Structure
hi link Structure Statement


" カーソル下のhighlight情報を表示する {{{
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

" [memo]
" なにかのプラグインが内部的に<C-m>を使っているっぽい？
" <C-m>はReturnだが、normalモードだとjと変わらないと思って
" <C-m>にキーバインドするとナチュラルに死ぬパターンある
"
" 自動で括弧やendxxx系を閉じるプラグインが悪さしてクリップボードからペーストしたものの履歴が区切られてしまう。これはvimの入力中の移動は履歴が区切られてしまう仕様による。
" 履歴の単位を正しくすることと、確実にコピペするためにも:a!を利用すること。

" [便利コマンド]
" tag [検索したい名前]
"   tag検索->ファイルオープン(XXXっていうクラスがさーって言われたら検索する用)
"   (FazzyFinderで探したい)
