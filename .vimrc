syntax on
colorscheme chris2
set tabstop=4
set shiftwidth=4
set expandtab
set background=light
set statusline=%F
set laststatus=2
set wrap!
set colorcolumn=81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100                   
hi ColorColumn ctermbg=black
filetype indent on
set number
filetype on
autocmd StdinReadPre * let s:std_in=1
set guioptions+=a
set clipboard=unnamedplus

set spell
set spelllang=en_us
" Customize the Error highlighting group (or the chosen group)
highlight Error ctermfg=Red guifg=Red ctermbg=NONE guibg=NONE cterm=bold


" LaTeX


let g:vimtex_compiler_method = 'latexmk'
let g:vimtex_view_program = '/usr/bin/evince'
let g:vimtex_view_general_options = '-reuse-instance'
let g:vimtex_compiler_latexmk = {
    \ 'executable': 'latexmk',
    \ 'options': [
        \ '-pdf',
        \ '-interaction=nonstopmode',
    \ ],
\ }

" Enable Vimtex
let g:vimtex_enabled = 1

" vim-plug install section
call plug#begin('~/.vim/plugged')

" Add vimtex
Plug 'lervag/vimtex'

" List other plugins here...

call plug#end()

set paste



" Define a custom command to compile and open the PDF
command! -nargs=0 Compile call Compile()


" Custom function to trigger compilation through Python
function! Compile()


    " Switch to the top window (document.tex)
    wincmd k

    " Save the current document.tex file
    w

    " Optionally, you can display a message or perform other actions
    echo "Compiling LaTeX..."

	" Get the absolute path to the file name of the current edited TeX document
    let l:tex_file = expand('%:p')

	" Get the absolute path to the current working directory
	let l:cwd = getcwd()
    
    call system('python ~/.vim_server.py ' . l:tex_file . ' ' . l:cwd)

	try
		let logfile = expand('%:r') . '.log'
		call ParseLaTeXLog(logfile)
		resize 4
	catch /E484/
		echo "Log file not created."	
	endtry

    " Optionally, you can display a message or perform other actions
    echo "Compilation Complete."

    " Simulate pressing Enter to return to normal mode
    call feedkeys("\<CR>")

endfunction



function! ParseLaTeXLog(logfile)
    " Clear existing Quickfix List
    cclose

    " Initialize an empty list for Quickfix entries
    let quickfix_list = []

    " Read the contents of the log file into a variable
    let logfile_contents = readfile(a:logfile)

    " Iterate through each line in the log file
    for line in logfile_contents
        call add(quickfix_list, {
                    \ 'text': line
                    \ })
    endfor

    " Populate the Quickfix List with the parsed entries
    call setqflist(quickfix_list)

    " Open the Quickfix Window if there are entries
    if len(quickfix_list) > 0
        copen
    endif
endfunction
