command! -nargs=? -complete=buffer -bang BufClose
    \ :call BufClose(expand('<args>'), expand('<bang>'))

function! BufClose(buffer, bang)
    if a:buffer == ''
		" No buffer provided, use current buffer in the current window.
        let buffer = bufnr('%')
	elseif (a:buffer + 0) > 0
		" A buffer number was provided.
        let buffer = bufnr(a:buffer + 0)
	else
		" A buffer name was provided.
        let buffer = bufnr(a:buffer)
    endif

    if buffer == -1
        echohl ErrorMsg
        echomsg "No matching buffer for" a:buffer
        echohl None
        return
    endif

    let current_window = winnr()
    let buffer_window = bufwinnr(buffer)

    if buffer_window == -1
        echohl ErrorMsg
        echomsg "Buffer" buffer "isn't open in any windows."
        echohl None
        return
    endif

    if a:bang == '' && getbufvar(buffer, '&modified')
        echohl ErrorMsg
        echomsg 'No write since last change for buffer'
            \ buffer '(add ! to override)'
        echohl None
        return
    endif

	" Move to the proper window, if necessary, then open a blank buffer, then
	" move back to the original window...
    if buffer_window >= 0
		if current_window == buffer_window
			exe 'enew' . a:bang
		else
			exe 'norm ' . buffer_window . "\<C-w>w"
			exe 'enew' . a:bang
			exe 'norm ' . current_window . "\<C-w>w"
		endif
    endif

	" ...and delete the specified buffer.
    silent exe 'bdel' . a:bang . ' ' . buffer
endfunction
