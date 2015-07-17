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
set noexpandtab
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


