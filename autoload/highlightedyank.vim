function! highlightedyank#hl(regtype, regname) abort
    if v:event.operator !=# 'y' || v:event.regtype ==# ''
        return
    endif

    let colo = "Yank"

    if a:regname == '+' || a:regname == '*'
        let colo = "YankClip"
    endif

    let bnr = bufnr('%')
    let ns = nvim_create_namespace('')
    call nvim_buf_clear_namespace(bnr, ns, 0, -1)

    let [_, lin1, col1, off1] = getpos("'[")
    let [lin1, col1] = [lin1 - 1, col1 - 1]

    let [_, lin2, col2, off2] = getpos("']")
    let [lin2, col2] = [lin2 - 1, col2]

    if a:regtype == 'v' || a:regtype == 'V'
        for l in range(lin1, lin1 + (lin2 - lin1))
            let c1 = (l == lin1) ? (col1 + off1) : 0
            let c2 = (l == lin2) ? (col2 + off2) : -1
            call nvim_buf_add_highlight(bnr, ns, colo, l, c1, c2)
        endfor
    else
        for l in range(lin1, lin1 + (lin2 - lin1))
            let c1 = (col1 + off1)
            let c2 = (col2 + off2)
            echom string(c1) . " " . string(c2)
            call nvim_buf_add_highlight(bnr, ns, colo, l, c1, c2)
        endfor
    endif

    call timer_start(1000, {-> nvim_buf_clear_namespace(bnr, ns, 0, -1)})
endfunc
