function! gofer#get_filtered_line_array() abort
    let l:iskeyword = &iskeyword
    set iskeyword+=.,:,/
    let l:curpos = getcurpos()
    let l:line = line('.')
    let l:non_keywords = []
    " while search( '\<\w\+\>', 'We', l:line )
    " while search( '\(^\|\S\+\)\(\s\|["''~]\|\n\)', 'W', l:line )
    while search( '\<\(\w\|[#./"''~]\)\+\>', 'We', l:line )
                " \ && col('.') < col('$') - 1
                " \ && line('.') == l:line
        let l:synname = synIDattr(synID(line('.'),col('.'),1), 'name' )
        " echo l:synname . ' ' . expand('<cword>')
        if l:synname !~# 'Command\|FuncName'
            call add( l:non_keywords, expand('<cword>') )
        endif
    endwhile
    call setpos( '.', l:curpos)
    let &iskeyword = l:iskeyword
    return l:non_keywords
endfunction
