" ================================
"
"        kmszk .vimrc
"
" ================================

" 文字コード設定
set encoding=utf-8
set fileencoding=utf-8

" 雑に打っても楽なように
nnoremap ; :

" 編集中のファイル名を表示
set title

" コードの色分け
syntax on

" バックアップを取らないように
set nobackup

" オートインデント
set smartindent

" 行番号
set number

" 改行時に前の行のインデントを継続する
set autoindent

" 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent

" カッコのハイライト1表示、0非表示(効いていないっぽい)
let loaded_matchparen = 0

" 特殊記号の横幅指定
set ambiwidth=double

"インクリメンタルサーチ
set incsearch

"検索時に大文字小文字を無視する
set ignorecase

" タブの幅
set expandtab
set tabstop=4
set shiftwidth=4
set softtabstop=0

" 全角記号の崩れ
set ambiwidth=double

" ctags
" ctags -f ~/.tags -R /path/to/project/ --exclude=.git --exclude=.svn
set tags+=~/.tags

" タブを>---で表示
"set list
"set listchars=tab:>-

" PCのクリップボードと同期
set clipboard=unnamedc



"------------------------------------------------------
" Start Neobundle Settings.
"------------------------------------------------------
"
" [初回インストールコマンド]
"
" mkdir -p ~.vim/bundle
" git clone https://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim
"

" bundleで管理するディレクトリを指定
set runtimepath+=~/.vim/bundle/neobundle.vim/
call neobundle#begin(expand('~/.vim/bundle/'))
  
" neobundle自体をneobundleで管理
NeoBundleFetch 'Shougo/neobundle.vim'


"----------------------------------------------------
" syntastic.vim PHPのシンタックスチェック
"----------------------------------------------------
NeoBundle 'scrooloose/syntastic'

let g:syntastic_check_on_open        = 1
let g:syntastic_enable_signs         = 1
let g:syntastic_echo_current_error   = 1
let g:syntastic_auto_loc_list        = 2
let g:syntastic_enable_highlighting  = 1
let g:syntastic_php_php_args         = '-l'
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*


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

 
" 今後このあたりに追加のプラグインをどんどん書いて行きます！！"
" unite.vim
NeoBundle 'Shougo/unite.vim'
 
call neobundle#end()
 
" Required:
filetype plugin indent on
 
" 未インストールのプラグインがある場合、インストールするかどうかを尋ねてくれるようにする設定
" 毎回聞かれると邪魔な場合もあるので、この設定は任意です。
NeoBundleCheck
 
"-------------------------
" End Neobundle Settings.
"-------------------------


