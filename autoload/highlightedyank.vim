" FIXME: Highlight region is incorrect when an input ^V[count]l ranges
"        multiple lines.

function! highlightedyank#hl(regtype) abort
  if v:event.operator !=# 'y' || v:event.regtype ==# ''
    return
  endif

  " TODO
  " if a:regtype ==# 'v'
  " elseif a:regtype ==# 'V'
  " elseif a:regtype[0] ==# "\<C-v>"

  let bnr = bufnr('%')
  let ns = nvim_create_namespace('')
  call nvim_buf_clear_namespace(bnr, ns, 0, -1)

  let [_, lin1, col1, off1] = getpos("'[")
  let [lin1, col1] = [lin1 - 1, col1 - 1]
  let [_, lin2, col2, off2] = getpos("']")
  let [lin2, col2] = [lin2 - 1, col2]
  for l in range(lin1, lin1 + (lin2 - lin1))
    let is_first = (l == lin1)
    let is_last = (l == lin2)
    let c1 = is_first ? (col1 + off1) : 0
    let c2 = is_last ? (col2 + off2) : -1
    call nvim_buf_add_highlight(bnr, ns, 'Yank', l, c1, c2)
  endfor
  call timer_start(1000, {-> nvim_buf_clear_namespace(bnr, ns, 0, -1)})
endfunc


" vim:set foldmethod=marker commentstring="%s ts=2 sts=2 sw=2
