" キャメルケースのスペルチェックを行います
" Version 1.0.0
" Author kmszk
" License VIM LICENSE

if exists('g:isCCSpellCheckLoaded')
	finish
endif
let g:isCCSpellCheckLoaded = 1

let s:save_cpo = &cpo
set cpo&vim

highlight CCSpellBad cterm=reverse ctermfg=yellow gui=reverse guifg=yellow

let g:internalCCSpellGoodList = []

if !exists('g:ccSpellBadReadLineNum')
	let g:CCSpellBadReadLineNum = 50
endif

functio! s:findSpellBadList(wordList) 
	let l:spellBadList = []
	let l:currentPos = 0

	if !exists('g:CCSpellCheckMinWordLength')
		let g:CCSpellCheckMinWordLength = 4
	endif

	for w in a:wordList
		if strlen(w) <= 1
			continue
		endif

		let [l:spellBadWord, l:errorType] = spellbadword(w)
		if empty(l:spellBadWord)
			continue
		endif

		let l:wordLength = len(l:spellBadWord)

		" すでに見つかっているspellBadWordの場合スルー
		if match(l:spellBadList, l:spellBadWord) != -1
			continue
		endif

		" 特定文字数以上のみ検出
		if l:wordLength >= g:CCSpellCheckMinWordLength
			call add(l:spellBadList, l:spellBadWord)
		endif
	endfor

	return l:spellBadList
endfunction

" キャメルケースを単語ごとに分割
function! s:camelCaseToWords(camelCaseWordList)
	let l:splitBy = ' '
	let l:wordsList = []

	for c in a:camelCaseWordList
		let l:splitWord = split(substitute(c, '\v([A-Z][a-z]*)\C', l:splitBy . "\\1", "g"), l:splitBy)

		for s in l:splitWord
			if match(l:wordsList, s) != -1
				continue
			endif

			call add(l:wordsList, s)
		endfor
	endfor

	return l:wordsList
endfunction

function! s:searchCurrentWordOnCamelCase(lineStr, cword, currentColPos)
	" 単語の末尾よりもカーソルが左だった場合、currentColPos-wordIndexが単語内の何番目にカーソルがあったかが分かる
	let [l:wordPos, l:cwordPos] = s:getCamelCaseWordPos(a:lineStr, a:cword, a:currentColPos)

	" 現在のカーソル位置がcwordの中で何文字目か
	let l:colPosInCWord = a:currentColPos - l:wordPos 
	" その単語がcwordの中で何文字目から始まるか
	let l:wordStartPosInCWord = l:wordPos - l:cwordPos

	let l:checkWordsList = s:camelCaseToWords([a:cword])
	let l:lastWordLength = 0
	for w in l:checkWordsList
		if l:colPosInCWord <= strlen(w) + l:lastWordLength
			let [l:wordPos, l:tmp] = s:getCamelCaseWordPos(a:cword, w, l:colPosInCWord)
			return [w, l:colPosInCWord, l:wordPos]
		endif
		let l:lastWordLength += strlen(w)
	endfor

	return [get(l:checkWordsList, 0, a:cword), 0, 0]
endfunction

" 単語の末尾よりもカーソルが左だった場合、currentColPos-wordIndexが単語内の何番目にカーソルがあったかが分かる
" return [キャメルケース上のカーソルがある単語の開始位置, cword全体の開始位置]
function! s:getCamelCaseWordPos(lineStr, cword, currentColPos) 
	let l:wordIndexList = s:findWordIndexList(a:lineStr, a:cword)

	for i in l:wordIndexList
		if i <= a:currentColPos && a:currentColPos <= i + strlen(a:cword)
			return [i, get(l:wordIndexList, 0, 0)]
		endif
	endfor
	
	return [0, 0]
endfunction

" 単語のポジションリストを返して、ポジションスタート + 単語長の中にcurposがあればそこが現在位置
function! s:findWordIndexList(lineStr, cword)
	let l:cwordLength = strlen(a:cword)
	let l:findWordIndexList = []

	let l:lineStr = a:lineStr
	while 1
		let l:tmpCwordPos = stridx(l:lineStr, a:cword)
		if l:tmpCwordPos < 0
			break
		endif

		call add(l:findWordIndexList, l:tmpCwordPos)
		let l:lineStr = strpart(l:lineStr, l:tmpCwordPos + l:cwordLength)
	endwhile

	return l:findWordIndexList
endfunction

function! s:getSpellSuggestList(spellSuggestList, currentCamelCaseWord, cword) 
	" 変換候補選択用リスト
	let l:spellSuggestListForInputList = []
	" 変換候補リプレイス用リスト
	let l:spellSuggestListForReplace = []

	let l:selectIndexStrlen = strlen(len(a:spellSuggestList))

	let i = 1
	for s in a:spellSuggestList
		let l:indexStr = printf("%" . l:selectIndexStrlen . "d", i) . ': '

		" 記号削除
		let s = substitute(s, '\.', " ", "g")

		" 2単語の場合連結
		if stridx(s, ' ') > 0
			let s = substitute(s, '\s', ' ', 'g')
			let l:suggestWords = split(s, ' ')
			let s = ''
			for w in l:suggestWords
				let s = s . toupper(w[0]) . w[1:-1]
			endfor
		endif

		" 先頭大文字小文字
		if stridx(a:cword, a:currentCamelCaseWord) == 0
			let s = tolower(s[0]) . s[1:-1]
		else 
			let s = toupper(s[0]) . s[1:-1]
		endif

		call add(l:spellSuggestListForReplace, s)
		call add(l:spellSuggestListForInputList, l:indexStr . '"' . s . '"')
		let i += 1
	endfor

	return [l:spellSuggestListForInputList, l:spellSuggestListForReplace]
endfunction

function! s:getWindowTextList()
	let l:currentLine = line('.')
	let l:currentWindowToatlLines = winheight(0)
	let l:currentWindowLine = winline()

	let l:startLine = l:currentLine - l:currentWindowLine + 1
	let l:endLine = l:currentLine + (l:currentWindowToatlLines - l:currentWindowLine)

	if l:startLine < 1 
		let l:startLine = 1
	endif
	
	if l:endLine > line('$')
		let l:endLine = '$'
	endif

	return [getline(l:startLine, l:endLine), l:startLine]
endfunc

function! s:getSpellBadPos(text, currentLineNum)
	let l:spellBadPos = []
	let l:lineForFindCamelCase = a:text

	while 1
		" キャメルケースとパスカルケースの抜き出し
		let l:matchCamelCaseWord = matchstr(l:lineForFindCamelCase, '\v([A-Za-z]@<!)[A-Za-z]+[A-Z][A-Za-z]+\C')
		if l:matchCamelCaseWord == ""
			break
		endif

		" すでに検知されているキャメルケースをinternal-wordlistに追加して、(一時的に)無効にする
		" 数が多くなるとspellgoodが遅くなる模様、初回に全て突っ込むので遅くなる
		" http://vim-jp.org/vimdoc-ja/spell.html#internal-wordlist
		if match(g:internalCCSpellGoodList, l:matchCamelCaseWord) == -1
			call execute(":silent spellgood! " . l:matchCamelCaseWord)
			call add(g:internalCCSpellGoodList, l:matchCamelCaseWord)
		endif

		let l:lineForFindCamelCase = s:cutTextWordBefore(l:lineForFindCamelCase, l:matchCamelCaseWord)

		let l:wordList = s:camelCaseToWords([l:matchCamelCaseWord])
		let l:spellBadList = s:findSpellBadList(l:wordList)
" echo l:spellBadList
		for s in l:spellBadList
			if strlen(s) > 3 
				let l:startSpellBadPos = stridx(a:text, s)
				if l:startSpellBadPos != -1
					call add(l:spellBadPos, [a:currentLineNum, l:startSpellBadPos + 1, strlen(s)])
				endif
			endif 
		endfor

		" matchaddposの仕様で8箇所までしか指定できない
		if len(l:spellBadPos) >= 8
			break
		endif
	endwhile

	return l:spellBadPos
endfunction

function! s:cutTextWordBefore (text, word)
	let l:foundPos = stridx(a:text, a:word)

	if l:foundPos < 0
		return a:text
	endif

	let l:wordLength = len(a:word)
	return strpart(a:text, l:foundPos + l:wordLength)
endfunc

function! CCSpellCheck()
	if &readonly
		return
	endif

	" for enable spellbadword() function.
	setlocal spell

	let l:currentLine = line('.')

	if exists('b:currentLine')
		if b:currentLine == l:currentLine
			return
		endif
	endif

echo 'DEBUG: process'

	let b:currentLine = l:currentLine

	" バッファ取得
	let [l:windowTextList, l:startLine] = s:getWindowTextList()

	if !exists('b:lineAndMatchIDDict')
		let b:lineAndMatchIDDict = {}
	endif

	let l:lineListForDelete = keys(b:lineAndMatchIDDict)

	let l:currentLine = l:startLine
	for w in l:windowTextList

		let l:foundLineKey = match(l:lineListForDelete, l:currentLine)

		if l:foundLineKey != -1
			" すでに処理済みの行
			call remove(l:lineListForDelete, l:foundLineKey)
		else
			let l:spellBadPos = s:getSpellBadPos(w, l:currentLine)
			let l:matchID = matchaddpos('CCSpellBad', l:spellBadPos)
			execute 'let b:lineAndMatchIDDict.' . l:currentLine . ' = ' . l:matchID
		endif

		let l:currentLine += 1
	endfor

	for l in l:lineListForDelete
		let l:deleteMatchID = get(b:lineAndMatchIDDict, l, 0)
		if l:deleteMatchID > 0
			call matchdelete(l:deleteMatchID)
			call remove(b:lineAndMatchIDDict, l)
		endif
	endfor
endfunction

function! OpenCCSpellFixList()
	let l:cword = expand("<cword>")

	if match(l:cword, '\v[A-Za-z]')
		echo "It does not match [A-Za-z]."
		return
	endif

	let [l:currentCamelCaseWord, l:colPosInCWord, l:wordStartPosInCWord] = s:searchCurrentWordOnCamelCase(getline('.'), l:cword, col('.'))

	let l:spellSuggestList = spellsuggest(l:currentCamelCaseWord, 50)

	if len(l:spellSuggestList) == 0
		echo "No suggested words."
		return
	endif

	let [l:spellSuggestListForInputList, l:spellSuggestListForReplace] = s:getSpellSuggestList(l:spellSuggestList, l:currentCamelCaseWord, l:cword)

	let l:selected = inputlist(l:spellSuggestListForInputList)
	let l:selectedWord = l:spellSuggestListForReplace[l:selected - 1]

	let l:replace = strpart(l:cword, 0, l:wordStartPosInCWord) 
	let l:replace .= l:selectedWord
	let l:replace .= strpart(l:cword, l:wordStartPosInCWord + strlen(l:currentCamelCaseWord), strlen(l:cword))

	" 書き換えてカーソルポジションを直す
	execute "normal ciw" . l:replace
	execute "normal b" . l:colPosInCWord . "l"
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
