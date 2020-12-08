if exists("g:loaded_highlightedyank")
    finish
endif

let g:loaded_highlightedyank = 1

function! s:default_highlight() abort
    highlight default link Yank WarningMsg
    highlight default link YankClip MoreMsg
endfunction

call s:default_highlight()

augroup highlightedyank
    autocmd!
    autocmd ColorScheme * call s:default_highlight()
    autocmd TextYankPost * call highlightedyank#hl(v:event.regtype, v:event.regname)
augroup END
