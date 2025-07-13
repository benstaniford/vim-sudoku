" vim-sudoku: A Vim plugin for solving and generating Sudoku puzzles
" Maintainer: Ben Staniford
" Version: 1.0
" License: MIT

if exists('g:loaded_sudoku') || v:version < 700
    finish
endif
let g:loaded_sudoku = 1

" Save cpo and set it to vim default
let s:save_cpo = &cpo
set cpo&vim

" Global configuration variables
if !exists('g:sudoku_date_format')
    let g:sudoku_date_format = '%m-%d-%Y'
endif

if !exists('g:sudoku_current_level')
    let g:sudoku_current_level = 32
endif

if !exists('g:sudoku_weekly_files')
    let g:sudoku_weekly_files = ['Wiki/index.wiki']
endif

" Commands
command! SudokuSolve call sudoku#solve()
command! SudokuEmpty call sudoku#empty()
command! -nargs=? SudokuGenerate call sudoku#generate(<f-args>)
command! SudokuGiveClue call sudoku#give_clue()
command! SudokuAddWeeklyPuzzle call sudoku#add_weekly_puzzle()
command! SudokuUpdateWeeklyPuzzle call sudoku#update_weekly_puzzle(1)

" Autocommands for weekly Sudoku files
if has('python3')
    augroup SudokuWeeklyFiles
        autocmd!
        for file in g:sudoku_weekly_files
            execute 'autocmd BufReadPost,BufNewFile ' . file . ' call sudoku#update_weekly_puzzle(0)'
        endfor
    augroup END
endif

" Restore cpo
let &cpo = s:save_cpo
unlet s:save_cpo
