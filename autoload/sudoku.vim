" vim-sudoku autoload functions
" Maintainer: Ben Staniford

" Save cpo and set it to vim default
let s:save_cpo = &cpo
set cpo&vim

function! sudoku#solve()
    let bounds = s:find_bounds()
    if empty(bounds)
        return
    endif
    let start = bounds[0]
    let end = bounds[1]
    python3 << EOF
import vim

def parse_input(lines):
    grid = []
    for line in lines:
        line = line.strip()
        if '-' in line or not line:
            continue
        line = line.replace('| ', '')
        line = line.replace('|', '')
        if len(line) != 18:
            raise ValueError(f"Invalid input, row must 18 characters long, got {len(line)}")
        # Split the line into 9 strings of 2 characters
        numbers = [line[i:i+2] for i in range(0, len(line), 2)]
        numbers = [num.strip() for num in numbers]
        grid.append([int(num) if (num != '.' and num != '') else 0 for num in numbers])
    if len(grid) != 9:
        raise ValueError(f"Invalid input, grid must be 9x9, got {len(grid)} rows")
    if any(len(row) != 9 for row in grid):
        bad_row = next(row for row in grid if len(row) != 9)
        raise ValueError(f"Invalid input, grid must be 9x9, got row with {len(bad_row)} columns")
    return grid

def print_grid(grid):
    output = []
    for i, row in enumerate(grid):
        if (i % 3 == 0 and i != 0):
            output.append('-------------------------')
        output.append('| ' + ' '.join(str(num) if num != 0 else ' ' for num in row[:3]) + ' | ' + ' '.join(str(num) if num != 0 else ' ' for num in row[3:6]) + ' | ' + ' '.join(str(num) if num != 0 else ' ' for num in row[6:]) + ' |')
    return output

def is_valid(grid, row, col, num):
    for x in range(9):
        if grid[row][x] == num or grid[x][col] == num:
            return False
    startRow = row - row % 3
    startCol = col - col % 3
    for i in range(3):
        for j in range(3):
            if grid[i + startRow][j + startCol] == num:
                return False
    return True

def solve_sudoku(grid):
    empty = find_empty_location(grid)
    if not empty:
        return True
    row, col = empty
    for num in range(1, 10):
        if is_valid(grid, row, col, num):
            grid[row][col] = num
            if solve_sudoku(grid):
                return True
            grid[row][col] = 0
    return False

def find_empty_location(grid):
    for i in range(9):
        for j in range(9):
            if grid[i][j] == 0:
                return (i, j)
    return None

start = int(vim.eval('start'))
end = int(vim.eval('end'))
lines = vim.current.buffer[start - 1:end]
if len(lines) != 11:
    raise ValueError(f"Invalid input, expected 11 lines, got {len(lines)}")

grid = parse_input(lines)

if solve_sudoku(grid):
    result = print_grid(grid)
    vim.current.buffer[start - 1:end] = result
else:
    print("No solution exists")
EOF
endfunction

function! sudoku#empty()
    " Insert an empty Sudoku table into the current buffer
    call append(line('.'), [
    \ "|       |       |       |",
    \ "|       |       |       |",
    \ "|       |       |       |",
    \ "-------------------------",
    \ "|       |       |       |",
    \ "|       |       |       |",
    \ "|       |       |       |",
    \ "-------------------------",
    \ "|       |       |       |",
    \ "|       |       |       |",
    \ "|       |       |       |"
    \ ])
endfunction

function! sudoku#generate(...)
    let clues = a:0 > 0 ? a:1 : g:sudoku_current_level
    python3 << EOF
import vim
import random
import copy

def is_valid(grid, row, col, num):
    for x in range(9):
        if grid[row][x] == num or grid[x][col] == num:
            return False
    startRow = row - row % 3
    startCol = col - col % 3
    for i in range(3):
        for j in range(3):
            if grid[i + startRow][j + startCol] == num:
                return False
    return True

def find_empty_location(grid):
    for i in range(9):
        for j in range(9):
            if grid[i][j] == 0:
                return (i, j)
    return None

def fill_grid(grid):
    empty = find_empty_location(grid)
    if not empty:
        return True
    row, col = empty
    numbers = list(range(1, 10))
    random.shuffle(numbers)
    for num in numbers:
        if is_valid(grid, row, col, num):
            grid[row][col] = num
            if fill_grid(grid):
                return True
            grid[row][col] = 0
    return False

def count_solutions(grid, counter, limit=2):
    if counter[0] >= limit:
        return
    empty = find_empty_location(grid)
    if not empty:
        counter[0] += 1
        return
    row, col = empty
    numbers = list(range(1, 10))
    random.shuffle(numbers)
    for num in numbers:
        if is_valid(grid, row, col, num):
            grid[row][col] = num
            count_solutions(grid, counter, limit)
            grid[row][col] = 0
            if counter[0] >= limit:
                return

def remove_numbers(grid, clues):
    cells = [(i, j) for i in range(9) for j in range(9)]
    random.shuffle(cells)
    removed = 0
    total_cells = 81
    to_remove = total_cells - clues
    for (row, col) in cells:
        if removed >= to_remove:
            break
        backup = grid[row][col]
        grid[row][col] = 0
        counter = [0]
        count_solutions(grid, counter, 2)
        if counter[0] != 1:
            grid[row][col] = backup
        else:
            removed += 1

def print_grid(grid):
    output = []
    for i, row in enumerate(grid):
        if (i % 3 == 0 and i != 0):
            output.append('-------------------------')
        output.append('| ' + ' '.join(str(num) if num != 0 else ' ' for num in row[:3]) + ' | ' + ' '.join(str(num) if num != 0 else ' ' for num in row[3:6]) + ' | ' + ' '.join(str(num) if num != 0 else ' ' for num in row[6:]) + ' |')
    return output

clues = int(vim.eval("clues"))
if clues < 17 or clues > 81:
    raise ValueError("Invalid number of clues, must be between 17 and 81")

grid = [[0 for _ in range(9)] for _ in range(9)]
fill_grid(grid)
remove_numbers(grid, clues)
result = print_grid(grid)

current_line = int(vim.eval('line("." )'))
vim.current.buffer.append(result, current_line)
EOF
endfunction

function! sudoku#give_clue()
    let bounds = s:find_bounds()
    if empty(bounds)
        return
    endif
    let start = bounds[0]
    let end = bounds[1]
    python3 << EOF
import vim
import copy

def parse_input(lines):
    grid = []
    for line in lines:
        line = line.strip()
        if '-' in line or not line:
            continue
        line = line.replace('| ', '')
        line = line.replace('|', '')
        if len(line) != 18:
            continue
        numbers = [line[i:i+2] for i in range(0, len(line), 2)]
        numbers = [num.strip() for num in numbers]
        grid.append([int(num) if (num != '.' and num != '') else 0 for num in numbers])
    return grid

def get_possibilities(grid, row, col):
    if grid[row][col] != 0:
        return []
    possible = set(range(1, 10))
    for i in range(9):
        possible.discard(grid[row][i])
        possible.discard(grid[i][col])
    startRow = row - row % 3
    startCol = col - col % 3
    for i in range(3):
        for j in range(3):
            possible.discard(grid[startRow + i][startCol + j])
    return list(possible)

def print_grid_with_x(grid, x_row, x_col):
    output = []
    for i, row in enumerate(grid):
        if (i % 3 == 0 and i != 0):
            output.append('-------------------------')
        line = []
        for j, num in enumerate(row):
            if i == x_row and j == x_col:
                val = 'x'
            elif num == 0:
                val = ' '
            else:
                val = str(num)
            line.append(val)
            if j == 2 or j == 5:
                line.append('|')
        output.append('| ' + ' '.join(line[:3]) + ' | ' + ' '.join(line[4:7]) + ' | ' + ' '.join(line[8:11]) + ' |')
    return output

start = int(vim.eval('start'))
end = int(vim.eval('end'))
lines = vim.current.buffer[start - 1:end]
grid = parse_input(lines)

found = False
for i in range(9):
    for j in range(9):
        if grid[i][j] == 0:
            poss = get_possibilities(grid, i, j)
            if len(poss) == 1:
                new_grid = copy.deepcopy(grid)
                new_grid[i][j] = 0
                result = print_grid_with_x(new_grid, i, j)
                vim.current.buffer[start - 1:end] = result
                found = True
                break
    if found:
        break
if not found:
    print("No single clue can be given.")
EOF
endfunction

function! s:find_bounds()
    let lnum = line('.')
    let total = line('$')
    let curline = getline(lnum)
    if curline =~ '^|' || curline =~ '^-'
        let first = lnum
        while first > 1
            let prevline = getline(first - 1)
            if prevline =~ '^|' || prevline =~ '^-'
                let first -= 1
            else
                break
            endif
        endwhile
        let last = lnum
        while last < total
            let nextline = getline(last + 1)
            if nextline =~ '^|' || nextline =~ '^-'
                let last += 1
            else
                break
            endif
        endwhile
        return [first, last]
    else
        echoerr "Not inside a Sudoku block."
        return []
    endif
endfunction

function! sudoku#update_weekly_puzzle(force)
    let heading_re = '^\s*\(#\{1,4}\|=\{1,4}\)'
    let sudoku_heading_re = heading_re . '\s*This Week''s Sudoku'
    let lnum = search(sudoku_heading_re, 'nw')
    let week_start = strftime(g:sudoku_date_format, localtime() - (strftime('%w') == 0 ? 6 : strftime('%w') - 1) * 24 * 60 * 60)

    if lnum > 0
        let sudoku_heading_date_re = sudoku_heading_re . ' \([0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]\)'
        let heading_line = getline(lnum)
        let heading = trim(heading_line)
        let match = matchlist(heading, sudoku_heading_date_re)
        if !empty(match)
            let old_week = match[2]
            if old_week == week_start && !a:force
                return
            endif
        endif

        let heading_style = matchstr(heading, heading_re)
        if heading_style == ''
            let heading_style = '=='
        endif

        let new_heading = heading_style . ' This Week''s Sudoku ' . week_start
        if heading_style =~ '^='
            let new_heading .= ' ' . heading_style
        endif
        call setline(lnum, new_heading)

        let sudoku_start = 0
        for i in range(lnum + 1, lnum + 2)
            if i > line('$')
                break
            endif
            if getline(i) =~ '^|'
                let sudoku_start = i
                break
            endif
        endfor

        if sudoku_start > 0
            call cursor(sudoku_start, 1)
            let bounds = s:find_bounds()
            if !empty(bounds)
                execute bounds[0] . ',' . bounds[1] . 'd'
            endif
        endif

        call cursor(lnum + 1, 1)
        call sudoku#generate(g:sudoku_current_level)
    endif
endfunction

function! sudoku#add_weekly_puzzle()
    let ft = &filetype
    if ft ==# 'markdown'
        let heading = '## This Week''s Sudoku'
    else
        let heading = '== This Week''s Sudoku =='
    endif

    call append(line('.'), heading)
    call append(line('.') + 1, '')
    call cursor(line('.') + 1, 1)
    call sudoku#update_weekly_puzzle(0)
endfunction

" Restore cpo
let &cpo = s:save_cpo
unlet s:save_cpo
