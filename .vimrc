scriptencoding utf-8

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" C++ の設定
" (https://github.com/osyo-manga/cpp-vimrc/blob/master/vimrc)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" 保存時にsudo権限で無理やり保存 (http://qiita.com/yuu_ta/items/30c69798b00560de3b06)
cnoremap w!! w !sudo tee > /dev/null %<CR> :e!<CR>

" クリップボードを連携
set clipboard=unnamed

"shell のパスを設定
if has("gui_win32")
    set shell=C:\WINDOWS\system32\cmd.exe
endif

" neobundle.vim がインストールするプラグインへのパス
" neobundle.vim もこのディレクトリにインストールが行われる
" default : ""
"let $VIM_NEOBUNDLE_PLUGIN_DIR = ""

" C++ の標準ライブラリへのパス
" $VIM_CPP_INCLUDE_DIR とは別に設定しておく
" default : ""
"let $VIM_CPP_STDLIB = ""

" C++ のインクルードディレクトリ
" 複数の場合は , 区切りで設定
" default : ""
"let $VIM_CPP_INCLUDE_DIR = ""

" filetype=cpp の設定はこの関数内で行う
" set ではなくて setlocal を使用する
function! CppVimrcOnFileType_cpp()
    "タブ文字の長さ
    "setlocal tabstop=4
    setlocal tabstop=2
    setlocal shiftwidth=4

    " 空白文字ではなくてタブ文字を使用する
    "setlocal noexpandtab

    " 自動インデントを行わない
    "setlocal nocindent

    " 最後に定義された include 箇所へ移動してを挿入モードへ
    nnoremap <buffer><silent> <Space>ii :execute "?".&include<CR> :noh<CR> o
endfunction

" プラグインの設定前に呼ばれる関数
" プラグインを無効にしたい場合など時に使用する
function! CppVimrcPrePlugin()
    " プラグインを無効にする場合
    " 	NeoBundleDisable neocomplete.vim
endfunction


"" 一番最後に呼ばれる関数
"" 設定などを上書きしたい場合に使用する
"function! CppVimrcOnFinish()
"    if !exists('g:quickrun_config')
"        let g:quickrun_config = {}
"    endif
"
"    let g:quickrun_config.runner = "wandbox"
"endfunction

"" vimrc の読み込み
"" (Cpp用にここまでの内容を分離した場合，下記コマンドで残りの設定を読み込む)
"source <sfile>:h/vimrc

"""""""""""""""""""""""""""""""

" FileType_cpp() 関数が定義されていれば最後にそれを呼ぶ
function! s:cpp()
    " インクルードパスを設定する
    " gf などでヘッダーファイルを開きたい場合に影響する
    let &l:path = join(filter(split($VIM_CPP_STDLIB . "," . $VIM_CPP_INCLUDE_DIR, '[,;]'), 'isdirectory(v:val)'), ',')

    " 括弧を構成する設定に <> を追加する
    " template<> を多用するのであれば
    setlocal matchpairs+=<:>

    " BOOST_PP_XXX 等のハイライトを行う
    syntax match boost_pp /BOOST_PP_[A-z0-9_]*/
    highlight link boost_pp cppStatement

    " quickrun.vim の設定
    let b:quickrun_config = {
                \		"hook/add_include_option/enable" : 1
                \	}

    if exists("*CppVimrcOnFileType_cpp")
        call CppVimrcOnFileType_cpp()
    endif
endfunction

"" 括弧を入力した時にカーソルが移動しないように設定
set matchtime=0

"" CursorHold の更新間隔
set updatetime=1000

let c_comment_strings=1
let c_no_curly_error=1


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" プラグインのセットアップ
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has('vim_starting')
    set nocompatible
endif

"" プラグインのインストールディレクトリ
let s:neobundle_plugins_dir = expand(exists("$VIM_NEOBUNDLE_PLUGIN_DIR") ? $VIM_NEOBUNDLE_PLUGIN_DIR : '~/.vim/bundle')
"" インクルードディレクトリ
let s:cpp_include_dirs = expand(exists("$VIM_CPP_INCLUDE_DIR") ? $VIM_CPP_INCLUDE_DIR : '')

"" shell の設定
if has('win95') || has('win16') || has('win32')
	set shell=C:\WINDOWS\system32\cmd.exe
endif

"" プラグインの読み込み
if !executable("git")
    echo "Please install git."
    finish
endif

if !isdirectory(s:neobundle_plugins_dir . "/neobundle.vim")
    echo "Please install neobundle.vim."
    function! s:install_neobundle()
        if input("Install neobundle.vim? [Y/N] : ") =="Y"
            if !isdirectory(s:neobundle_plugins_dir)
                call mkdir(s:neobundle_plugins_dir, "p")
            endif

            execute "!git clone git://github.com/Shougo/neobundle.vim "
                        \ . s:neobundle_plugins_dir . "/neobundle.vim"
            echo "neobundle installed. Please restart vim."
        else
            echo "Canceled."
        endif
    endfunction
    augroup install-neobundle
        autocmd!
        autocmd VimEnter * call s:install_neobundle()
    augroup END
    finish
endif


" neobundle.vim でプラグインを読み込む
" https://github.com/Shougo/neobundle.vim
if has('vim_starting')
	execute "set runtimepath+=" . s:neobundle_plugins_dir . "/neobundle.vim"
endif

"" Required:
"call neobundle#rc(s:neobundle_plugins_dir)
"call neobundle#begin(expand('~/.vim/bundle/'))
call neobundle#begin(s:neobundle_plugins_dir)

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" ファイルオープンを便利に
NeoBundle 'Shougo/unite.vim'
" Unite.vimで最近使ったファイルを表示できるようにする
NeoBundle 'Shougo/neomru.vim'
" ファイルをtree表示してくれる
NeoBundle 'scrooloose/nerdtree'
" Gitを便利に使う
NeoBundle 'tpope/vim-fugitive'

" コメントON/OFFを手軽に実行
NeoBundle 'tomtom/tcomment_vim'
" シングルクオートとダブルクオートの入れ替え等
NeoBundle 'tpope/vim-surround'

" インデントに色を付けて見やすくする
NeoBundle 'nathanaelkane/vim-indent-guides'
" ログファイルを色づけしてくれる
NeoBundle 'vim-scripts/AnsiEsc.vim'
" 行末の半角スペースを可視化(うまく動かない？)
NeoBundle 'bronson/vim-trailing-whitespace'
" less用のsyntaxハイライト
NeoBundle 'KohPoll/vim-less'

"" 汎用的なコード補完プラグイン +lua な環境であれば neocomplete.vim を利用する
"" 余談: neocompleteは合わなかった。ctrl+pで補完するのが便利
"if has("lua")
"    NeoBundle "Shougo/neocomplete.vim"
"else
"    NeoBundle "Shougo/neocomplcache"
"endif

"" YouCompleteMe for ROS (should make Sougl/neocomplete.vim disable?)
"NeoBundle "Valloric/YouCompleteMe"

" 定型構文を素早く挿入する
" (スニペットの基本的な定義ファイルをneosnippet-snippetsから取得)
NeoBundle 'Shougo/neosnippet'
NeoBundle 'Shougo/neosnippet-snippets'

" CompileをVim上で実行
NeoBundle 'thinca/vim-quickrun'

" StatusLineの色付け
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'airblade/vim-gitgutter'

"Texに対応
NeoBundle 'lervag/vimtex'

" Left & right margin justification tool
NeoBundle 'vim-scripts/Align'

" ROSプログラミング用プラグイン
" コマンドの使い方については下記サイトにまとめられている
" http://myenigma.hatenablog.com/entry/20141129/1417248480
" NeoBundle 'taketwo/vim-ros'

" Tmux - vim 関係なくウィンドウの移動をC-h,.. にて行えるようにする．
" http://qiita.com/izumin5210/items/92fd7425999980f9516d
NeoBundle 'christoomey/vim-tmux-navigator'

"*******************
" C++ コーディング用プラグイン(https://github.com/osyo-manga/cpp-vimrc/blob/master/vimrc)

" コメントアウト
NeoBundle "tyru/caw.vim"

" アウトラインの出力
NeoBundle "Shougo/unite-outline"

" C++ のシンタックス
NeoBundle "vim-jp/cpp-vim"

" wandbox
NeoBundle "rhysd/wandbox-vim"

" コード補完
NeoBundle "osyo-manga/vim-marching"

" quickfix の該当箇所をハイライト
NeoBundle "jceb/vim-hier"

" quickfix の該当箇所の内容をコマンドラインに出力
NeoBundle "dannyob/quickfixstatus"

" シンタックスチェッカー
NeoBundle "osyo-manga/vim-watchdogs"
NeoBundle "osyo-manga/shabadou.vim"

" ハイライト
NeoBundle "t9md/vim-quickhl"

" vimproc.vim を使用する場合は自前でビルドする必要あり
" kaoriya 版 vim では vimproc.vim が同梱されているので必要ない
if !has("kaoriya")
    NeoBundle 'Shougo/vimproc.vim', {
                \ 'build' : {
                \     'windows' : 'make -f make_mingw32.mak',
                \     'cygwin' : 'make -f make_cygwin.mak',
                \     'mac' : 'make -f make_mac.mak',
                \     'unix' : 'make -f make_unix.mak',
                \    },
                \ }
endif

if exists("*CppVimrcOnNeoBundle")
    call CppVimrcOnNeoBundle()
endif
"*******************

"*******************
" solarized カラースキーム
  NeoBundle 'altercation/vim-colors-solarized'
" mustang カラースキーム
  NeoBundle 'croaker/mustang-vim'
" wombat カラースキーム
  NeoBundle 'jeffreyiacono/vim-colors-wombat'
" jellybeans カラースキーム
  NeoBundle 'nanotech/jellybeans.vim'
" lucius カラースキーム
  NeoBundle 'vim-scripts/Lucius'
" zenburn カラースキーム
  NeoBundle 'vim-scripts/Zenburn'
" mrkn256 カラースキーム
  NeoBundle 'mrkn/mrkn256.vim'
" railscasts カラースキーム
  NeoBundle 'jpo/vim-railscasts-theme'
" pyte カラースキーム
  NeoBundle 'therubymug/vim-pyte'
" molokai カラースキーム
  NeoBundle 'tomasr/molokai'

" カラースキーム一覧表示に Unite.vim を使う
" NeoBundle 'Shougo/unite.vim'
  NeoBundle 'ujihisa/unite-colorscheme'
" C++の補完機能を有効にできる 14.04のみらしいが
" Ctrl+nで補完一覧をだせる
" 補完一覧内はCtrl-nもしくはtabキーで移動できる
  NeoBundle 'justmao945/vim-clang'
"*******************

call neobundle#end()

filetype plugin indent on
syntax enable

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 各種オプションの設定
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" タグファイルの指定(でもタグジャンプは使ったことがない)
set tags=~/.tags
" スワップファイルは使わない(ときどき面倒な警告が出るだけで役に立ったことがない)
set noswapfile
" カーソルが何行目の何列目に置かれているかを表示する
set ruler
" コマンドラインに使われる画面上の行数
set cmdheight=1
" エディタウィンドウの末尾から2行目にステータスラインを常時表示させる
set laststatus=2
"" ステータス行に表示させる情報の指定(どこからかコピペしたので細かい意味はわかっていない)
"set statusline=%<%f\ %m%r%h%w%{'['.(&fenc!=''?&fenc:&enc).']['.&ff.']'}%=%l,%c%V%8P
"" ステータス行に現在のgitブランチを表示する
"set statusline+=%{fugitive#statusline()}
" ウインドウのタイトルバーにファイルのパス情報等を表示する
set title
" コマンドラインモードで<Tab>キーによるファイル名補完を有効にする
set wildmenu
" 入力中のコマンドを表示する
set showcmd
" バックアップディレクトリの指定(でもバックアップは使ってない)
"set backupdir=$HOME/.vimbackup
" バッファで開いているファイルのディレクトリでエクスクローラを開始する(でもエクスプローラって使ってない)
set browsedir=buffer
" 小文字のみで検索したときに大文字小文字を無視する
set smartcase
" 検索結果をハイライト表示する
set hlsearch
" 暗い背景色に合わせた配色にする
"set background=dark
" タブ入力を複数の空白入力に置き換える
set expandtab
" 検索ワードの最初の文字を入力した時点で検索を開始する
set incsearch
" 保存されていないファイルがあるときでも別のファイルを開けるようにする
set hidden
" 不可視文字を表示する
set list
" タブと行の続きを可視化する
set listchars=tab:>\ ,extends:<
" 行番号を表示する
set number
" 行番号の色を見やすく
highlight LineNr ctermfg=darkyellow ctermbg=None
" 対応する括弧やブレースを表示する
set showmatch
" 改行時に前の行のインデントを継続する
set autoindent
" 改行時に入力された行の末尾に合わせて次の行のインデントを増減する
set smartindent
" タブ文字の表示幅
set tabstop=2
" Vimが挿入するインデントの幅
set shiftwidth=4
set softtabstop=4
" 行頭の余白内で Tab を打ち込むと、'shiftwidth' の数だけインデントする
set smarttab
" カーソルを行頭、行末で止まらないようにする
set whichwrap=b,s,h,l,<,>,[,]
" 構文毎に文字色を変化させる
syntax on
" 文字化け対策
set encoding=utf-8
set fileencodings=utf-8,euc-jp,sjis,cp932,iso-2022-jp
set fileformats=unix,dos,mac
" カラースキーマの指定
colorscheme jellybeans
set t_Co=256
let g:jellybeans_use_lowcolor_black = 0
highlight Normal ctermbg=none
highlight NonText ctermbg=none

" vimを立ち上げたときに、自動的にvim-indent-guidesをオンにする
let g:indent_guides_enable_on_vim_startup = 1
" grep検索の実行後にQuickFix Listを表示する
autocmd QuickFixCmdPost *grep* cwindow
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 全角スペースの表示
" http://inari.hatenablog.com/entry/2014/05/05/231307
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! ZenkakuSpace()
    highlight ZenkakuSpace cterm=underline ctermfg=lightblue guibg=darkgray ctermbg=None
endfunction

if has('syntax')
    augroup ZenkakuSpace
        autocmd!
        autocmd ColorScheme * call ZenkakuSpace()
        autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('ZenkakuSpace', '　')
    augroup END
    call ZenkakuSpace()
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 最後のカーソル位置を復元する
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd")
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
endif
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 自動的に閉じ括弧を入力
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
imap { {}<LEFT>
imap [ []<LEFT>
imap ( ()<LEFT>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 括弧入力後Enterを押すと改行を含む括弧補間を行う
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
inoremap {<Enter> {}<Left><CR><ESC><S-o>
inoremap [<Enter> []<Left><CR><ESC><S-o>
inoremap (<Enter> ()<Left><CR><ESC><S-o>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



" Plugin settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shougo/unite.vim setting
" http://blog.remora.cx/2010/12/vim-ref-with-unite.html
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("unite.vim")
function! s:hooks.on_source(bundle)
    " 入力モードで開始する
    let g:unite_enable_start_insert=1
    " バッファ一覧
    noremap <C-P> :Unite buffer<CR>
    " ファイル一覧
    noremap <C-N> :Unite -buffer-name=file file<CR>
    " 最近使ったファイルの一覧
    noremap <C-Z> :Unite file_mru<CR>
    " sourcesを「今開いているファイルのディレクトリ」とする
    noremap :uff :<C-u>UniteWithBufferDir file -buffer-name=file<CR>
    " ウィンドウを分割して開く
    au FileType unite nnoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
    au FileType unite inoremap <silent> <buffer> <expr> <C-J> unite#do_action('split')
    " ウィンドウを縦に分割して開く
    au FileType unite nnoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
    au FileType unite inoremap <silent> <buffer> <expr> <C-K> unite#do_action('vsplit')
    " ESCキーを2回押すと終了する
    au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
    au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
endfunction
unlet s:hooks
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""Shougo/neocmplete setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let s:hooks = neobundle#get_hooks("neocomplete.vim")
"function! s:hooks.on_source(bundle)
"    " Disable AutoComplPop.
"    let g:acp_enableAtStartup = 0
"    " Use neocomplete.
"    let g:neocomplete#enable_at_startup = 1
"    " Use smartcase.
"    let g:neocomplete#enable_smart_case = 1
"    " Set minimum syntax keyword length.
"    let g:neocomplete#sources#syntax#min_keyword_length = 3
"    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'
"    " Define dictionary.
"    let g:neocomplete#sources#dictionary#dictionaries = {
"                \ 'default' : '',
"                \ 'vimshell' : $HOME.'/.vimshell_hist',
"                \ 'scheme' : $HOME.'/.gosh_completions'
"                \ }
"    " Define keyword.
"    if !exists('g:neocomplete#keyword_patterns')
"        let g:neocomplete#keyword_patterns = {}
"    endif
"    let g:neocomplete#keyword_patterns['default'] = '\h\w*'
"    " Plugin key-mappings.
"    inoremap <expr><C-g>     neocomplete#undo_completion()
"    inoremap <expr><C-l>     neocomplete#complete_common_string()
"    " Recommended key-mappings.
"    " <CR>: close popup and save indent.
"    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
"    function! s:my_cr_function()
"        return neocomplete#close_popup() . "\<CR>"
"        " For no inserting <CR> key.
"        "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
"    endfunction
"    " <TAB>: completion.
"    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
"    " <C-h>, <BS>: close popup and delete backword char.
"    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
"    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
"    inoremap <expr><C-y>  neocomplete#close_popup()
"    inoremap <expr><C-e>  neocomplete#cancel_popup()
"    " Close popup by <Space>.
"    "inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"
"    " AutoComplPop like behavior.
"    "let g:neocomplete#enable_auto_select = 1
"    " Shell like behavior(not recommended).
"    "set completeopt+=longest
"    "let g:neocomplete#enable_auto_select = 1
"    "let g:neocomplete#disable_auto_complete = 1
"    "inoremap <expr><TAB>  pumvisible() ? "\<Down>" :
"    " \ neocomplete#start_manual_complete()
"    " Enable omni completion.
"    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
"    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
"    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
"    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
"    " Enable heavy omni completion.
"    if !exists('g:neocomplete#sources#omni#input_patterns')
"        let g:neocomplete#sources#omni#input_patterns = {}
"    endif
"    if !exists('g:neocomplete#force_omni_input_patterns')
"        let g:neocomplete#force_omni_input_patterns = {}
"    endif
"    "let g:neocomplete#sources#omni#input_patterns.php =
"    "\ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
"    "let g:neocomplete#sources#omni#input_patterns.c =
"    "\ '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?'
"    "let g:neocomplete#sources#omni#input_patterns.cpp =
"    "\ '[^.[:digit:] *\t]\%(\.\|->\)\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
"    " For perlomni.vim setting.
"    " https://github.com/c9s/perlomni.vim
"    let g:neocomplete#sources#omni#input_patterns.perl =
"                \ '[^. \t]->\%(\h\w*\)\?\|\h\w*::\%(\h\w*\)\?'
"    " For smart TAB completion.
"    "inoremap <expr><TAB>  pumvisible() ? "\<C-n>" :
"    "        \ <SID>check_back_space() ? "\<TAB>" :
"    "        \ neocomplete#start_manual_complete()
"    "  function! s:check_back_space() "{{{
"    "    let col = col('.') - 1
"    "    return !col || getline('.')[col - 1]  =~ '\s'
"    "  endfunction"}}}
"endfunction
"unlet s:hooks
"
"
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Shougo/neocomplcache setting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let s:hooks = neobundle#get_hooks("neocomplcache")
"function! s:hooks.on_source(bundle)
"    " 補完を有効にする
"    let g:neocomplcache_enable_at_startup=1
"endfunction
"unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Shougo/neosnippet setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let s:hooks = neobundle#get_hooks("neosnippet.vim")
"function! s:hooks.on_source(bundle)
    "" Plugin key-mappings.
    imap <C-k>     <Plug>(neosnippet_expand_or_jump)
    smap <C-k>     <Plug>(neosnippet_expand_or_jump)
    xmap <C-k>     <Plug>(neosnippet_expand_target)

    " スニペットを展開するキーマッピング
    " <Tab> で選択されているスニペットの展開を行う
    " 選択されている候補がスニペットであれば展開し、
    " それ以外であれば次の候補を選択する
    " また、既にスニペットが展開されている場合は次のマークへと移動する
    imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: pumvisible() ? "\<C-n>" : "\<TAB>"
    smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
                \ "\<Plug>(neosnippet_expand_or_jump)"
                \: "\<TAB>"

    "let g:neosnippet#snippets_directory = "~/.neosnippet"

    " 現在の filetype のスニペットを編集する為のキーマッピング
    " こうしておくことでサッと編集や追加などを行うことができる
    " 以下の設定では新しいタブでスニペットファイルを開く
    nnoremap <Space>ns :execute "tabnew\|:NeoSnippetEdit ".&filetype<CR>

    " For snippet_complete marker.
    if has('conceal')
        set conceallevel=2 concealcursor=niv
    endif

"endfunction
"unlet s:hooks


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"" Valloric/YouCompleteMe
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let s:hooks = neobundle#get_hooks("YouCompleteMe")
"function! s:hooks.on_source(bundle)
"    " from vim-ros tips (https://github.com/taketwo/vim-ros)
"    let g:ycm_semantic_triggers = {
"                \   'roslaunch' : ['="', '$(', '/'],
"                \   'rosmsg,rossrv,rosaction' : ['re!^', '/'],
"                \ }
"endfunction
"unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" tyru/caw.vim setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("caw.vim")
function! s:hooks.on_source(bundle)
	" コメントアウトを切り替えるマッピング
	" <leader>c でカーソル行をコメントアウト
	" 再度 <leader>c でコメントアウトを解除
	" 選択してから複数行の <leader>c も可能
	nmap <leader>c <Plug>(caw:I:toggle)
	vmap <leader>c <Plug>(caw:I:toggle)

	" <leader>C でコメントアウトを解除
	nmap <Leader>C <Plug>(caw:I:uncomment)
	vmap <Leader>C <Plug>(caw:I:uncomment)

endfunction
unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" dannyob/quickfixstatus setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("quickfixstatus")
function! s:hooks.on_post_source(bundle)
    QuickfixStatusEnable
endfunction
unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" t9md/vim-quickhl setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("vim-quickhl")
function! s:hooks.on_source(bundle)
    " <Space>m でカーソル下の単語、もしくは選択した範囲のハイライトを行う
    " 再度 <Space>m を行うとカーソル下のハイライトを解除する
    " これは複数の単語のハイライトを行う事もできる
    " <Space>M で全てのハイライトを解除する
    nmap <Space>m <Plug>(quickhl-manual-this)
    xmap <Space>m <Plug>(quickhl-manual-this)
    nmap <Space>M <Plug>(quickhl-manual-reset)
    xmap <Space>M <Plug>(quickhl-manual-reset)
endfunction
unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" osyo-manga/vim-marching setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("vim-marching")
function! s:hooks.on_post_source(bundle)
    if !empty(g:marching_clang_command) && executable(g:marching_clang_command)
        " 非同期ではなくて同期処理で補完する
        let g:marching_backend = "sync_clang_command"
    else
        " clang コマンドが実行できなければ wandbox を使用する
        let g:marching_backend = "wandbox"
        let g:marching_clang_command = ""
    endif

    " オプションの設定
    " これは clang のコマンドに渡される
    let g:marching#clang_command#options = {
                \	"cpp" : "-std=gnu++1y"
                \}

    if !neobundle#is_sourced("neocomplete.vim")
        return
    endif

    " neocomplete.vim と併用して使用する場合
    " neocomplete.vim を使用すれば自動補完になる
    let g:marching_enable_neocomplete = 1

    if !exists('g:neocomplete#force_omni_input_patterns')
        let g:neocomplete#force_omni_input_patterns = {}
    endif

    let g:neocomplete#force_omni_input_patterns.cpp =
                \ '[^.[:digit:] *\t]\%(\.\|->\)\w*\|\h\w*::\w*'

    " TODO:STL is not recognized...
    " Need to define Include file path explicitly for Linux (https://github.com/osyo-manga/vim-marching/issues/4)
    " For ROS include files, the follwoing should be listed '/opt/ros/*/include/*' .
    let g:marching_include_paths = filter(
                \ split(glob('/usr/include/c++/*'), '\n') +
                \ split(glob('/usr/include/*/c++/*'), '\n') +
                \ split(glob('/usr/include/*/'), '\n') ,
                \ 'isdirectory(v:val)')
    "execute "set path+=" . join(g:marching_include_paths, ',')
    "let &l:path = join(g:marching_include_paths, ',')
endfunction
unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" thinca/vim-quickrun setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("vim-quickrun")
function! s:hooks.on_source(bundle)
    let g:quickrun_config = {
                \		"_" : {
                \			"runner" : "vimproc",
                \			"runner/vimproc/sleep" : 10,
                \			"runner/vimproc/updatetime" : 500,
                \			"outputter" : "error",
                \			"outputter/error/success" : "buffer",
                \			"outputter/error/error"   : "quickfix",
                \			"outputter/quickfix/open_cmd" : "copen",
                \			"outputter/buffer/split" : ":botright 8sp",
                \		},
                \
                \		"cpp/wandbox" : {
                \			"runner" : "wandbox",
                \			"runner/wandbox/compiler" : "clang-head",
                \			"runner/wandbox/options" : "warning,c++1y,boost-1.55",
                \		},
                \
                \		"cpp/g++" : {
                \			"cmdopt" : "-std=c++11 -Wall",
                \		},
                \
                \		"cpp/clang++" : {
                \			"cmdopt" : "-std=c++11 -Wall",
                \		},
                \
                \		"cpp/watchdogs_checker" : {
                \			"type" : "watchdogs_checker/clang++",
                \		},
                \
                \		"watchdogs_checker/_" : {
                \			"outputter/quickfix/open_cmd" : "",
                \		},
                \
                \		"watchdogs_checker/g++" : {
                \			"cmdopt" : "-Wall",
                \		},
                \
                \		"watchdogs_checker/clang++" : {
                \			"cmdopt" : "-Wall",
                \		},
                \	}

    let s:hook = {
                \	"name" : "add_include_option",
                \	"kind" : "hook",
                \	"config" : {
                \		"option_format" : "-I%s"
                \	},
                \}

    function! s:hook.on_normalized(session, context)
        " filetype==cpp 以外は設定しない
        if &filetype !=# "cpp"
            return
        endif
        let paths = filter(split(&path, ","), "len(v:val) && v:val !='.' && v:val !~ $VIM_CPP_STDLIB")

        if len(paths)
            let a:session.config.cmdopt .= " " . join(map(paths, "printf(self.config.option_format, v:val)")) . " "
        endif
    endfunction

    call quickrun#module#register(s:hook, 1)
    unlet s:hook


    let s:hook = {
                \	"name" : "clear_quickfix",
                \	"kind" : "hook",
                \}

    function! s:hook.on_normalized(session, context)
        call setqflist([])
    endfunction

    call quickrun#module#register(s:hook, 1)
    unlet s:hook

endfunction
unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" osyo-manga/vim-watchdogs setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("vim-watchdogs")
function! s:hooks.on_source(bundle)
    "let g:watchdogs_check_BufWritePost_enable = 1
    let g:watchdogs_check_BufWritePost_enables = {}
    let g:watchdogs_check_BufWritePost_enables.cpp = 1
    let g:watchdogs_check_BufWritePost_enables.haskell = 0
endfunction
unlet s:hooks

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" scrooloose/nerdtree setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:hooks = neobundle#get_hooks("nerdtree")
function! s:hooks.on_source(bundle)
    " 隠しファイルをデフォルトで表示させる
    let g:NERDTreeShowHidden = 1
    " ブックマークを最初から表示
    let g:NERDTreeShowBookmarks=1
    " 以下のファイルは vim からは見たくない
    "let NERDTreeIgnore = ['.[oa]$', '.cm[aiox]$', '.cmxa$', '.(aux|bbl|blg|dvi|log)$', '.(tgz|gz|zip)$', 'Icon' ]
    " book mark file
    "let g:NERDTreeBookmarksFile=$DROPBOX . '/lib/vim/user/nerdtree-bookmarks'
    " NERDTreeでルートを変更したらchdirする
    "let g:NERDTreeChDirMode = 2

    " Type <C-e> to launch
    nnoremap <silent><C-e> :NERDTreeToggle<CR>
endfunction
unlet s:hooks


""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" itchyny/lightline.vim setting
" http://itchyny.hatenablog.com/entry/20130828/1377653592
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:lightline = {
            \ 'colorscheme': 'wombat',
            \ 'mode_map': {'c': 'NORMAL'},
            \ 'active': {
            \   'left': [ [ 'mode', 'paste' ], [ 'fugitive', 'filename' ] ]
            \ },
            \ 'component_function': {
            \   'modified': 'LightLineModified',
            \   'readonly': 'LightLineReadonly',
            \   'fugitive': 'LightLineFugitive',
            \   'filename': 'LightLineFilename',
            \   'fileformat': 'LightLineFileformat',
            \   'filetype': 'LightLineFiletype',
            \   'fileencoding': 'LightLineFileencoding',
            \   'mode': 'LightLineMode'
            \ }
            \ }

function! LightLineModified()
    return &ft =~ 'help\|vimfiler\|gundo' ? '' : &modified ? '+' : &modifiable ? '' : '-'
endfunction

function! LightLineReadonly()
    return &ft !~? 'help\|vimfiler\|gundo' && &readonly ? 'x' : ''
endfunction

function! LightLineFilename()
    return ('' != LightLineReadonly() ? LightLineReadonly() . ' ' : '') .
                \ (&ft == 'vimfiler' ? vimfiler#get_status_string() :
                \  &ft == 'unite' ? unite#get_status_string() :
                \  &ft == 'vimshell' ? vimshell#get_status_string() :
                \ '' != expand('%:t') ? expand('%:t') : '[No Name]') .
                \ ('' != LightLineModified() ? ' ' . LightLineModified() : '')
endfunction

function! LightLineFugitive()
    if &ft !~? 'vimfiler\|gundo' && exists('*fugitive#head')
        return fugitive#head()
    else
        return ''
    endif
endfunction

function! LightLineFileformat()
    return winwidth(0) > 70 ? &fileformat : ''
endfunction

function! LightLineFiletype()
    return winwidth(0) > 70 ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileencoding()
    return winwidth(0) > 70 ? (&fenc !=# '' ? &fenc : &enc) : ''
endfunction

function! LightLineMode()
    return winwidth(0) > 60 ? lightline#mode() : ''
endfunction



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" vmail setting
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"let s:hooks = neobundle#get_hooks("vim-wtatchdogs")
"let g:vmail_flagged_color = "ctermfg=yellow ctermbg=black cterm=bold"
"" in ~/.vmail/default/.vmailrc
""username: xxxxx@gmail.com
""password: yyyyy
""name: Shuji Oishi
""signature: |
""  --
""    Shuji Oishi
""    Assistant professor at Active Intelligent Systems Laboratory (Miura Laboratory)
""    Department of Computer Science and Engineering, Toyohashi University of Technology
""    Email: oishi@cs.tut.ac.jp
""    http://www.aisl.cs.tut.ac.jp/~oishi
"unlet s:hooks
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if exists("*CppVimrcOnPrePlugin")
    call CppVimrcOnPrePlugin()
endif


call neobundle#call_hook('on_source')


if exists("*CppVimrcOnFinish")
    call CppVimrcOnFinish()
endif


augroup vimrc-cpp
    autocmd!
    " filetype=cpp が設定された場合に関数を呼ぶ
    autocmd FileType cpp call s:cpp()
augroup END

"" ESCやCtrl+[入力時にアルファベット入力に戻る
function! ImInActivate()
  call system('fcitx-remote -c')
endfunction
inoremap <silent> <ESC>:call ImInActivate()<CR>
