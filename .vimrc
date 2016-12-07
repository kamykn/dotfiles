" -----------------------------------------------------
"                     kmszk .vimrc                    
" -----------------------------------------------------

"------------------------------------------------------
" Common Settings.
"------------------------------------------------------

" vim-indent-guides の利用で必要
colorscheme default

" 文字コード設定
set encoding=utf-8	
set fileencoding=utf-8
set fileformat=unix

" 雑に打っても楽なように
nnoremap ; :

" basic settings 
set title
set nobackup
set smartindent		
set autoindent

" 行番号
set number

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

" exモードに入らない
nnoremap Q <Nop>


" misc alias 
" Vimrcへのショートカット
:command! Vrc e ~/.vimrc
:command! Src source ~/.vimrc

" diff用バッファ
:command! Diff tabnew | vnew | diffthis
:command! D diffthis


"前回閉じたときのカーソルの位置を保存
augroup vimrcEx
  au BufRead * if line("'\"") > 0 && line("'\"") <= line("$") |
  \ exe "normal g`\"" | endif
augroup END


" grep 後に quickfix勝手に開く
autocmd QuickfixCmdPost grep cope

" grep書式自動挿入
nnoremap <expr> <Space>G ':grep ' . expand('<cword>') . ' ~/project/application -R'

"------------------------------------------------------
" FZF 
"------------------------------------------------------
"
" [初回インストールコマンド]
" git clone https://github.com/junegunn/fzf.git ~/.fzf
"
" :FZFコマンドを使えるように
set rtp+=~/.fzf
nnoremap <C-p> :FZF<CR>

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
" Vim Fugitive
"----------------------------------------------------
" Git支援

NeoBundle 'tpope/vim-fugitive'

" alias
:command! Gs Gstatus
:command! Gadd Gwrite
:command! Gmv Gmove
:command! Grm Gremove
:command! Gbl Gblame


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
nmap <C-K> <Plug>(caw:i:toggle)
vmap <C-K> <Plug>(caw:i:toggle)


"----------------------------------------------------
" Surround.Vim
"----------------------------------------------------

NeoBundle 'tpope/vim-surround'


"----------------------------------------------------
" splitjoin.vim
"----------------------------------------------------

NeoBundle 'AndrewRadev/splitjoin.vim'


"----------------------------------------------------
" Vim Neosnippet
"----------------------------------------------------
" dotfilesのphp.snipを適応するには
" ln -s ~/dotfiles/.vim/bundle/vim-snippets/snippets/php.snip .vim/bundle/vim-snippets/snippets/php.snip 
"
" 編集中に
" :NeoSnippetEdit
" で現在開いているファイルタイプのスニペットを編集できる

" 依存モジュール
NeoBundle 'Shougo/neocomplcache'

NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1

" Tell Neosnippet about the other snippets
let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/neosnippets'


" "----------------------------------------------------
" " vim-indent-guides
" "----------------------------------------------------
" " インデントの色が256colorじゃないとキレイに出ない
" " mv ~/.bashrc ~/.bashrc.orig
" " ln -s ~/dotfiles/.bashrc ~/.bashrc
" " ln -s ~/dotfiles/.tmux.conf ~/.tmux.conf
"
" " インデントに色を付けて見やすくする
" NeoBundle 'nathanaelkane/vim-indent-guides'
"
" " vimを立ち上げたときに、自動的にvim-indent-guidesをオンにする
" let g:indent_guides_enable_on_vim_startup=1
"
" let g:indent_guides_auto_colors = 0
"
" " setting for Black Background
" " autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=234
" " autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=233
"
" " setting for iTerms Solarized
" autocmd VimEnter,Colorscheme * :hi IndentGuidesOdd  ctermbg=black
" autocmd VimEnter,Colorscheme * :hi IndentGuidesEven ctermbg=none

" メモ
" iTerm用おすすめカラー
" [ベース設定]
" Dark Solarized
"
" [Basic Colors]
" Background #131212
" Foreground #FFFFFF
"
" [Cursor Colors]
" Cursor #45ACB9
"
" [ANSI Colors]
" Black (Normal) #191716
" Magenta (Bright) #FF62AE
"
" Minimum Contrast 30%
" CursorBoost20%ずつ


"----------------------------------------------------
" ctrlp
"----------------------------------------------------
" ファイル名検索 git使ってるとgitのルートディレクトリを勝手に検知

" NeoBundle "ctrlpvim/ctrlp.vim"

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
" syntastic.vim PHPのシンタックスチェック
"----------------------------------------------------
NeoBundle 'scrooloose/syntastic'

let g:syntastic_check_on_open		 = 1
let g:syntastic_enable_signs		 = 1
let g:syntastic_echo_current_error	 = 1
let g:syntastic_auto_loc_list		 = 2
let g:syntastic_enable_highlighting	 = 1
let g:syntastic_php_php_args		 = '-l'
" set statusline+=%#warningmsg#
" set statusline+=%{SyntasticStatuslineFlag()}
" set statusline+=%*

"----------------------------------------------------
" php_localvarcheck
" PHPの未定義変数アラート
"----------------------------------------------------

NeoBundle 'flyinshadow/php_localvarcheck.vim'

let g:php_localvarcheck_enable = 1
let g:php_localvarcheck_global = 0


"----------------------------------------------------
" Unite
"----------------------------------------------------

NeoBundle 'Shougo/unite.vim'

" 最近開いたファイル表示用の必須の拡張
NeoBundle 'Shougo/neomru.vim'

" alias
:command! Uf Unite file
:command! Ufm Unite file_mru
:command! Ub Unite buffer

NeoBundle 'sgur/unite-qf'
:command! Uqf Unite qf

"----------------------------------------------------
" 関数のアウトライン表示
"----------------------------------------------------

" h1mesuke/unite-outlineが使えなくなっていたので、Shougoさんのunite-outlineに差し替え
" NeoBundle 'h1mesuke/unite-outline' "# こっちは使わない
NeoBundle 'Shougo/unite-outline'

" let g:unite_split_rule = 'right'
nnoremap <C-l> <ESC>:Unite -vertical -winwidth=40 outline<Return><C-W>x<C-w>l

"----------------------------------------------------
" Vim PHPDoc
"----------------------------------------------------
" PHPDoc形式のコメントを生成

NeoBundle 'PDV--phpDocumentor-for-Vim'
" autocmd BufReadPost *.php source ~/php-doc.vim

nnoremap <C-@> :call PhpDocSingle()<CR>


" [Language Settings end] ===========================


"----------------------------------------------------
" Ctags コマンド自動化
"----------------------------------------------------
" :TagsGenerate
" 大きめのプロジェクトでは生成に少し時間がかかる
NeoBundle 'szw/vim-tags'

" ctagsをインストールし、下記のコマンドを実行
" ctags -f ~/.tags -R ~/project/ --exclude=.git --exclude=.svn
"
" それか、Vimからタグ作り直せる
" :TagsGenerate!
"
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
let g:vim_tags_project_tags_command = "ctags --languages=php -f ~/.tags -R --exclude=.git --exclude=.svn --exclude=*.js --exclude=*.phtml --exclude=*.sh ~/project/application 2>/dev/null"

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

" Go用のセッティング。これがないとvim-goが動かない
filetype plugin indent on

" スペルチェック
set spell
set spelllang+=en,cjk

hi clear SpellBad
hi SpellBad cterm=underline


" [memo]
" 内部的に<C-mを使っているっぽい？><C-m>はReturnだが、normalモードだとjと変わらないと思って
" <C-m>にキーバインドすると動かなくなる
