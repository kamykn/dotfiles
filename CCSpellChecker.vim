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

	for w in a:wordList
		if strlen(w) < 1
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
		if l:wordLength > 3
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

function! OpenSpellFixList()
	let l:cword = expand("<cword>")
	let [l:currentCamelCaseWord, l:colPosInCWord, l:wordStartPosInCWord] = s:searchCurrentWordOnCamelCase(getline('.'), l:cword, col('.'))

	let l:spellSuggestList = spellsuggest(l:currentCamelCaseWord, 50)
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

function! CCSpellCheck()
	" バッファ取得
	let l:currentLine = line('.')

	if abs(l:currentLine) < g:CCSpellBadReadLineNum 
		let l:startLine = 0
		let l:endLine = g:CCSpellBadReadLineNum * 2
	elseif g:CCSpellBadReadLineNum + line('.') > line('$')
		let l:startLine = l:currentLine - (g:CCSpellBadReadLineNum * 2)
		let l:endLine = '$'
	else 
		let l:startLine = l:currentLine - g:CCSpellBadReadLineNum
		let l:endLine = l:currentLine + g:CCSpellBadReadLineNum
	endif

	echo  l:startLine . ':' .  l:endLine

	let l:windowText = getline(l:startLine, l:endLine)
	let l:windowText = join(l:windowText, " ")

	" キャメルケースを全てリスト化
	let l:camelCaseWordList = []
	let l:bulkOutputCamelCaseWordList = []

	while 1
		" キャメルケースとパスカルケースの抜き出し
		let l:matchCamelCaseWord = matchstr(l:windowText, '\v([A-Za-z]@<!)[A-Za-z]+[A-Z][A-Za-z]+\C')
		if l:matchCamelCaseWord == ""
			break
		endif

		call add(l:camelCaseWordList, l:matchCamelCaseWord)
		let l:windowText = s:cutTextWordBefore(l:windowText, l:matchCamelCaseWord)

		" すでに検知されているキャメルケースをinternal-wordlistに追加して、(一時的に)無効にする
		" 数が多くなるとspellgoodが遅くなる模様、初回に全て突っ込むので遅くなる
		" http://vim-jp.org/vimdoc-ja/spell.html#internal-wordlist
		if match(g:internalCCSpellGoodList, l:matchCamelCaseWord) == -1
			let l:execOutput = execute(":silent spellgood! " . l:matchCamelCaseWord . '<CR><CR>')
		
			call add(g:internalCCSpellGoodList, l:matchCamelCaseWord)
		endif
	endwhile

	let l:wordList = s:camelCaseToWords(l:camelCaseWordList)
	let l:spellBadList = s:findSpellBadList(l:wordList)

	if !exists('b:currentMatchedDict')
		let b:currentMatchedDict = {}
	endif

	let l:spellDictForDelete = deepcopy(b:currentMatchedDict)
	let l:currentMatchedSpellList = values(b:currentMatchedDict)

	for s in l:spellBadList
		if strlen(s) > 3 
			let l:lowerSpellBad = tolower(s)

			if match(l:currentMatchedSpellList, l:lowerSpellBad) == -1
				let l:upperMatchID = matchadd('CCSpellBad', '\zs' . l:lowerSpellBad . '\ze\c')
				execute "let b:currentMatchedDict." . l:upperMatchID . " = '" . l:lowerSpellBad . "'"
			else
				let l:spellDictForDelete = s:deleteFromSpellDict(l:spellDictForDelete, l:lowerSpellBad)
			endif
		endif 
	endfor

	for k in keys(l:spellDictForDelete)
		call matchdelete(k)
		call remove(b:currentMatchedDict, k)
	endfor
endfunction

function s:deleteFromSpellDict (spellDictForDelete, search)
	let l:spellDictForDelete = a:spellDictForDelete

	for k in keys(l:spellDictForDelete)
		let l:spellForFind = get(l:spellDictForDelete, k)
		if l:spellForFind == a:search
			call remove(l:spellDictForDelete, k)
			break
		endif
	endfor

	return l:spellDictForDelete
endfunction

function! s:cutTextWordBefore (text, word)
	let l:foundPos = stridx(a:text, a:word)

	if l:foundPos < 0
		return a:text
	endif

	let l:wordLength = len(a:word)
	return strpart(a:text, l:foundPos + l:wordLength)
endfunc


let &cpo = s:save_cpo
unlet s:save_cpo
