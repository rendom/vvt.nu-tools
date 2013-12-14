"Author: vvt.nu - c0r73x
"
".vimrc
"vvt_use_browser  *required
"vvt_browser_command  *optional
"--------------------------------
"Example
"let g:vvt_use_browser = 1
"let g:vvt_browser_command = 'echo "%URL%" | xclip'
"--------------------------------


if exists('g:loaded_vvt')
    finish
endif
let g:loaded_vvt=1

function! s:JSONEncode(string)
    let ret = a:string
    let ret = substitute(ret,'\%x5C','\\\\','g')
    let ret = substitute(ret,'\%x22','\\"','g')
    let ret = substitute(ret,'\%x2F','/','g')
    let ret = substitute(ret,'\%x08','\\b','g')
    let ret = substitute(ret,'\%x0C','\\f','g')
    let ret = substitute(ret,'\%x0A','\\n','g')
    let ret = substitute(ret,'\%x0D','\\r','g')
    let ret = substitute(ret,'\%x09','\\t','g')
    return ret
endfunction

if g:vvt_use_browser == 1
    if !exists('g:vvt_browser_command')
        if exists(':OpenBrowser')
            let g:vvt_browser_command = ":OpenBrowser %URL%"
        elseif has('win32')
            let g:vvt_browser_command = "!start rundll32 url.dll,FileProtocolHandler %URL%"
        elseif has('mac')
            let g:vvt_browser_command = "open %URL%"
        elseif executable('xdg-open')
            let g:vvt_browser_command = "xdg-open %URL%"
        else
            if has("unix")
                if system('uname')=~'Darwin'
                    let g:vvt_browser_command = "open %URL%"
                else
                    let g:vvt_browser_command = "dwb %URL% &"
                end
            else
            endif
        endif
    endif
endif

function! VVT(line1, line2)
    let content = join(getline(a:line1, a:line2), "\n")
    let data = printf('{ "code" : "%s", "hidden" : "%d" }',s:JSONEncode(content),1)
    let url = s:post('http://vvt.nu/api/pastebin.json', data)
    call s:finished(url)
endfunction

function! s:finished(url)
    if a:url !~? '.*http.*'
        echoerr "vvt: an error occurred:" a:url
        return
    endif
    if g:vvt_browser_command == ''
        echo a:url
        return
    endif
    let cmd = substitute(g:vvt_browser_command, '%URL%', a:url, 'g')
    if cmd =~ '^!'
        silent! exec cmd
    elseif cmd =~ '^:[A-Z]'
        exec cmd
    else
        call system(cmd)
    endif
endfunction

function! s:post(url, data)
    let file = tempname()
    call writefile([a:data], file)
    let quote = &shellxquote == '"' ?    "'" : '"'
    let res = system('curl -s -d @'.quote.file.quote.' '.a:url)
    call delete(file)
    return res
endfunction

command! -nargs=? -range=% Paste :call VVT(<line1>, <line2>)

let g:loaded_vvt=2
