" -----------------------------------------------------
"                     kmszk .vimrc
" -----------------------------------------------------
"
"------------------------------------------------------
" Common Settings.
"------------------------------------------------------

colorscheme default


" 文字コード設定
set encoding=utf-8
set fileencoding=utf-8
set fileformat=unix

" 雑に打ってもイケるように
nnoremap ; :

" basic settings
set title
set nobackup
set smartindent
set autoindent

" 行番号
set number

" ###重い###
if version >= 703
" set relativenumber
endif

" alias
" nonuにするために一回relativenumberを解除する必要がある
:command! Nu set relativenumber
:command! NU set relativenumber!

" Puttyの「ウインドウ」→「変換」→「CJK文字を…」のcheckを外す
" 三点リーダーとかは崩れるので崩れたらCtrl - lで再描写させる
set ambiwidth=double

" タブの幅
set noexpandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0

" スワップファイルを作らない
set noswapfile

" undoファイルを作らない(for GVim)
set noundofile

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
set so=7

" コマンド履歴
set history=500

" exモードに入らない
nnoremap Q <Nop>

" recodingしない
nnoremap q <Nop>

" ファイル補完をshellに近く
set wildmode=longest,full

" スクロールスピード改善
set lazyredraw

" 対応カッコ表示
set showmatch

" カーソルラインをハイライト
" set cursorline

" ESCキー2度押しでハイライトの切り替え
nnoremap <silent><Esc><Esc> :<C-u>set nohlsearch!<CR>

"前回閉じたときのカーソルの位置を保存
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END

" MySQLのsyntax highlight
let g:sql_type_default = 'mysql'


"------------------------------------------------------
" autocmd
"------------------------------------------------------

" grep 後に quickfix勝手に開く
autocmd QuickfixCmdPost grep cope

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
  autocmd BufWritePost *.php call PhpLint() | if len(getqflist()) != 0 | copen 1 | else | cclose | endif
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
" misc alias
"------------------------------------------------------
"
" Vimrcへのショートカット
:command! Vrc tabe | e ~/.vimrc
:command! Src source ~/.vimrc

" diff用バッファ
:command! Diff tabnew | vnew | diffthis
:command! D diffthis

" grep書式自動挿入
vnoremap <expr> ? ':grep ' . expand('<cword>') . ' ~/project/application -R'

" 連続コピペ
vnoremap <silent> <C-p> "0p<CR>


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

" replace of Ctrl-p
nnoremap <C-p> :FZF<CR>
nnoremap <C-b> :Fb<CR>

" nnoremap <C-q> :FZFQuickfix<CR>

:command! Fq FZFQuickfix
:command! Fmru FZFMru
:command! Fb FZFBuffer

" [MRU] ========================================
"
command! FZFMru call fzf#run({
			\  'source':  v:oldfiles,
			\  'sink':    'tabe',
			\  'options': '-m -x +s',
			\  'down':    '40%'})

" [Buffer] =====================================
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

" [QuickFix] ===================================
"
command! FZFQuickfix call fzf#run({
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
	" echo parts
	execute 'tabe ' . parts[0]
endfunction


"------------------------------------------------------
" Plugin
"------------------------------------------------------

"------------------------------------------------------
" Neobundle settings start .
"------------------------------------------------------
"
" [初回インストールコマンド]
"
" mkdir -p ~/.vim/bundle
" git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
"

" bundleで管理するディレクトリを指定
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))

" neobundle自体をneobundleで管理
NeoBundleFetch 'Shougo/neobundle.vim'


"----------------------------------------------------
" tpope/vim-endwise
"----------------------------------------------------
" shell とかの if-endif とか閉じてくれる

NeoBundle 'tpope/vim-endwise'


"----------------------------------------------------
" vim-easy-align
"----------------------------------------------------

NeoBundle 'junegunn/vim-easy-align'

" 選んだ範囲で整える
xmap <Space> <Plug>(EasyAlign)*<Space>
xmap , <Plug>(EasyAlign)*,
xmap g= <Plug>(EasyAlign)*=

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)


"----------------------------------------------------
" AndrewRadev/switch.vim
"----------------------------------------------------
" true <--> false

NeoBundle 'AndrewRadev/switch.vim'

nmap + :Switch<CR>


"----------------------------------------------------
" Vim Fugitive
"----------------------------------------------------
" Git支援

NeoBundle 'tpope/vim-fugitive'

" alias
:command! Gs   Gstatus
:command! Gadd Gwrite
:command! Gmv  Gmove
:command! Grm  Gremove
:command! Gbl  Gblame


"----------------------------------------------------
" vim gitgutter
"----------------------------------------------------

NeoBundle 'airblade/vim-gitgutter'


"----------------------------------------------------
" StatusBar Plugin
"----------------------------------------------------
NeoBundle 'itchyny/lightline.vim'

set laststatus=2
if !has('gui_running')
	  set t_Co=256
endif

" For Powerline
let g:airline_theme='PaperColor'
let g:lightline = {
	\ 'colorscheme': 'PaperColor' ,
    \ 'active': {
    \   'left': [ [ 'mode', 'paste' ],
    \             [ 'fugitive', 'readonly', 'filename', 'modified' ] ]
    \ },
    \ 'separator': { 'left': '⮀', 'right': '⮂' },
    \ 'subseparator': { 'left': '⮁', 'right': '⮃' },
    \ 'component_function': {
    \   'fugitive': 'LightlineFugitive',
    \   'readonly': 'LightlineReadonly',
    \   'modified': 'LightlineModified'
    \ },
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


"----------------------------------------------------
" コメントアウトプラグイン
"----------------------------------------------------

NeoBundle "tyru/caw.vim.git"
nmap <C-K> <Plug>(caw:hatpos:toggle)
vmap <C-K> <Plug>(caw:hatpos:toggle)


"----------------------------------------------------
" Surround.Vim
"----------------------------------------------------

NeoBundle 'tpope/vim-surround'


"----------------------------------------------------
" splitjoin.vim
"----------------------------------------------------
"
" gS 1行 -> 改行
" gJ 改行 -> 1行

NeoBundle 'AndrewRadev/splitjoin.vim'



"----------------------------------------------------
" vim-scripts/AutoComplPop
"----------------------------------------------------
" neo complete重い
" Vimのデフォルトの補完を利用し、ポップアップを自動化しているこちらを採用
"
" <C-e>でキャンセルして続きをタイピング
" ざっくり打っても候補がでる
"
NeoBundle 'vim-scripts/AutoComplPop'

" タブで第一候補を選択
inoremap <expr><TAB>  pumvisible() ? "\<C-y>" : "\<TAB>"
set completeopt-=preview


"----------------------------------------------------
" Vim Neosnippet
"----------------------------------------------------
" dotfilesのphp.snipを適応するには
" ln -s ~/dotfiles/.vim/bundle/vim-snippets/snippets/php.snip .vim/bundle/vim-snippets/snippets/php.snip 
"
" 編集中に
" :NeoSnippetEdit
" で現在開いているファイルタイプのスニペットを編集できる

" デフォルト通りなので<C-k>で利用可能

NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/neosnippets'


"------------------------------------------------------
" Language settings start.
"------------------------------------------------------

" [Common settings] =================================

" " [Golang] ==========================================
"
" "----------------------------------------------------
" " setting for go
" "----------------------------------------------------
" " 使い方
" " http://qiita.com/koara-local/items/6c886eccfb459159c431
" " NeoBundleインストール後に下記を実行
" " :GoInstallBinaries
" " filetype plugin indent on の記述がNeoBundle関連の記述の下に必要
"
" NeoBundle 'fatih/vim-go'
"
" let g:go_highlight_functions = 1
" let g:go_highlight_methods = 1
" let g:go_highlight_fields = 1
" let g:go_highlight_types = 1
" let g:go_highlight_operators = 1
" let g:go_highlight_build_constraints = 1
"
"
" " オムニ補完 : <C-x><C-o>
" " buffer for completion : <C-x><C-n>
" NeoBundle 'roxma/SimpleAutoComplPop'
"
" " scratchウインドウが開かないように
" set completeopt=menu
"
" " おせっかいすぎる自動補完選択をOff
" let g:sacpEnable = 0



" [PHP] ===============================================
"
"----------------------------------------------------
"  ale シンタックスチェック
"----------------------------------------------------

NeoBundle 'w0rp/ale.git'

" ErrorをQuickFixに流す
" let g:ale_set_loclist = 0
" let g:ale_set_quickfix = 1

" 編集中にale走らないように
" g:ale_lint_on_saveはデフォルトでon
let g:ale_lint_on_text_changed = 'never'

" 開いたときにale走らないように
" let g:ale_lint_on_enter = 0

" ruleset
let g:ale_php_phpcs_standard = $HOME.'/.phpconf/phpcs/ruleset.xml'
let g:ale_php_phpmd_ruleset  = $HOME.'/.phpconf/phpmd/ruleset.xml'

" [phpmdメモ]
" codesize：循環的複雑度などコードサイズ関連部分を検出するルール
" controversial：キャメルケースなど議論の余地のある部分を検出するルール
" design：ソフトの設計関連の問題を検出するルール
" naming：長すぎたり、短すぎたりする名前を検出するルール
" unusedcode：使われていないコードを検出するルール


"----------------------------------------------------
" syntastic.vim PHPのシンタックスチェック
"----------------------------------------------------
"
" ErrorsでQuickFixにエラーが一覧表示
"

" NeoBundle 'scrooloose/syntastic'
"
" command! Err Errors
"
" " phpmd/phpcsだけのエラーリストを表示
" command! Phpmd  SyntasticCheck phpmd
" command! Phpmdl SyntasticCheck phpmd | Errors
"
" command! Phpcs  SyntasticCheck phpcs
" command! Phpcsl SyntasticCheck phpcs | Errors
"
" let g:syntastic_mode_map = {
"   \ 'mode': 'active',
"   \ 'active_filetypes': ['php']
"   \}
"
" let g:syntastic_php_checkers=['php', 'phpcs', 'phpmd']
"
" " phpcs
" let g:syntastic_php_phpcs_args='--standard=$HOME/.phpconf/phpcs/ruleset.xml'
"
" let g:syntastic_php_phpmd_post_args='$HOME/.phpconf/phpmd/ruleset.xml'
"
" " Githubに書かれているrecommended設定
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*
"
" let g:syntastic_always_populate_loc_list = 1 "エラーリスト更新
" let g:syntastic_auto_loc_list = 2 " 1:エラーの際にQuickFixが立ち上がる 2: 立ち上がらない
" let g:syntastic_check_on_open = 1
" let g:syntastic_check_on_wq = 0
"
" let g:syntastic_enable_signs        = 1
" let g:syntastic_echo_current_error  = 1
" let g:syntastic_enable_highlighting = 1
" let g:syntastic_php_php_args        = '-l'
" " set statusline+=%#warningmsg#
" " set statusline+=%{SyntasticStatuslineFlag()}
" " set statusline+=%*


"----------------------------------------------------
" phpcomplete
" omni補完強化
"----------------------------------------------------
" Better class detection:
" Recognize /* @var $yourvar YourClass */ type mark comments
" Recognize $instance = new Class; class instantiations
" Recognize $instance = Class::getInstance(); singleton instances
" Recognize $date = DateTime::createFromFormat(...) built-in class return types
" Recognize type hinting in function prototypes
" Recognize types in @param lines in function docblocks
" Recognize $object = SomeClass::staticCall(...) return types from docblocks
" Recognize array of objects via docblock like $foo[42]-> or for variables created in foreach

" 但しautoComplPopには上手く入ってこない
" C-x oを利用すること

NeoBundle 'shawncplus/phpcomplete.vim'

" composerなど使っている場合
" phpcomplete-extendedもいれると幸せになれるらしい

let g:phpcomplete_parse_docblock_comments = 1
let g:phpcomplete_search_tags_for_variables = 1

set omnifunc=phpcomplete#CompletePHP

"----------------------------------------------------
" php_localvarcheck
" PHPの未定義変数アラート
"----------------------------------------------------

NeoBundle 'flyinshadow/php_localvarcheck.vim'

let g:php_localvarcheck_enable = 1
let g:php_localvarcheck_global = 0


"----------------------------------------------------
" Vim PHPDoc
"----------------------------------------------------
" PHPDoc形式のコメントを生成

NeoBundle 'PDV--phpDocumentor-for-Vim'
" autocmd BufReadPost *.php source ~/php-doc.vim

nnoremap <C-@> :call PhpDocSingle()<CR>


" [Language Settings end] ===========================


"----------------------------------------------------
" tagbar
"----------------------------------------------------
" 関数のアウトライン表示

NeoBundle 'majutsushi/tagbar'  " Neobundleでインストール

nmap <C-l> :TagbarToggle<CR>

" tagbar の設定
let g:tagbar_width = 50        " 初期設定はwidth=40
let g:tagbar_autoshowtag = 1   ":TagbarShowTag を叩かなくても有効にする

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


"----------------------------------------------------
" Ctags コマンド自動化
"----------------------------------------------------
" Vimからタグ作り直せる
" :TagsGenerate!
" 大きめのプロジェクトでは生成に少し時間がかかる

NeoBundle 'szw/vim-tags'

" Universal Ctagsをインストール
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

" 実行コマンド
" ~/projectが設定されている前提
" コマンドの引数はファイルの回数の指定までのところまでしか読まない謎仕様(@Mac)
" -Vでデバッグ用情報を付与してくれる。(http://stackoverflow.com/questions/7736656/vim-and-ctags-ignoring-certain-files-while-generating-tags)
" 例：ctags -V --exclude=*.html --exclude=*.js ./*

" for Fish対応
let g:vim_tags_project_tags_command = "ctags --languages=php -f ~/.tags -R --exclude=.git --exclude=.svn --exclude='*.js' --exclude='*.phtml' --exclude='*.sh' ~/project/application 2>/dev/null"

" 新しいタブでジャンプ
" FYI:http://at-grandpa.hatenablog.jp/entry/2015/10/28/224920

" # 分割 チラチラするけど…
" nnoremap <C-]> :vs<CR> :exe("tjump ".expand('<cword>'))<CR><C-W>x

" # 別タブ
nnoremap <C-]> :tab sp<CR> :exe("tjump ".expand('<cword>'))<CR>
"
" [メモ]
" :tn	（タグが重複している場合）次のタグへ
" :tp	（タグが重複している場合）前のタグへ
" :tselect	現在のタグの一覧を表示


"------------------------------------------------------
" CamelCase Spell Checker
"------------------------------------------------------

NeoBundle 'kmszk/CCSpellCheck.vim'

augroup CCSpellCheck
	autocmd!
	autocmd BufWinEnter,BufWritePost * call CCSpellCheck#check()
augroup END


"------------------------------------------------------
" Neobundle settings end.
"------------------------------------------------------
" 未インストールのプラグインがある場合、インストールするかどうかを尋ねてくれるようにする設定
call neobundle#end()
NeoBundleCheck


"----------------------------------------------------
" Vim neosnippet settings
" ----------------------------------------------------

" neosnipets用のセッティング
" Plugin key-mappings.
imap <C-k>     <Plug>(neosnippet_expand_or_jump)

" SuperTab like snippets behavior.
"imap <expr><TAB>
" \ pumvisible() ? "\<C-n>" :
" \ neosnippet#expandable_or_jumpable() ?
" \    "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
\ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"

" For conceal markers.
if has('conceal')
  set conceallevel=2 concealcursor=niv
endif

"------------------------------------------------------
" Common settings.
"------------------------------------------------------

" NeoBundleの前に書くと効かないらしい
syntax on

" スペルチェック
set spell
set spelllang=en,cjk

" Enable filetype plugins
filetype plugin indent on

" 全体対象にスペルチェック
syntax spell toplevel
" syntax spell notoplevel

" ハイライト再セット
hi clear SpellBad
hi SpellBad cterm=underline

if version >= 800
	set completeopt+=noselect,noinsert
endif

" [memo]
" 内部的に<C-mを使っているっぽい？><C-m>はReturnだが、normalモードだとjと変わらないと思って
" <C-m>にキーバインドすると動かなくなる
"
" 2017/05/21
" noecomplete+vimprocが大きいプロジェクトだとvimが段々と重たくなる為、AutoComplPopでvim本来の機能利用方向にシフト
" Uniteも大層な使い方してないので高速で寄り若干リッチなFZFに関連機能を寄せた(vim-script/FuzzyFinderだと好きじゃない感じなのでvim-scriptで実装した)
" 関数のアウトラインもunite-outlineではなくtagbarへ
" 自動で括弧やendxxx系を閉じるプラグインが悪さしてクリップボードからペーストしたものの履歴が区切られてしまう。これはvimの入力中の移動は履歴が区切られてしまう仕様による。
" 履歴の単位を正しくすることと、確実にコピペするためにも:a!を利用すること。

" [便利コマンド]
"
" tag検索->ファイルオープン(XXXっていうクラスがさーって言われたら検索する用)
" tag [検索したい名前]
" (FazzyFinderで探したい)

