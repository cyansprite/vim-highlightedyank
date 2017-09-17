" highlighted-yank: Make the yanked region apparent!
" Last Change: 16-Mar-2017.
" Maintainer : Masaaki Nakamura <mckn@outlook.com>

" License    : NYSL
"              Japanese <http://www.kmonos.net/nysl/>
"              English (Unofficial) <http://www.kmonos.net/nysl/index.en.html>

if exists("g:loaded_highlightedyank")
  finish
endif
let g:loaded_highlightedyank = 1

" highlight group
function! s:default_highlight() abort
  highlight default link HighlightedyankRegion IncSearch
endfunction
call s:default_highlight()
augroup highlightedyank-event-ColorScheme
  autocmd!
  autocmd ColorScheme * call s:default_highlight()
augroup END

augroup highlightedyank
  autocmd!
  autocmd TextYankPost * silent call highlightedyank#autocmd_highlight()
augroup END
