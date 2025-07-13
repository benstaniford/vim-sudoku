# Vim Sudoku Plugin

A comprehensive Sudoku plugin for Vim that provides solving, generation, and puzzle management capabilities.

## Screenshot

<img width="664" height="654" alt="image" src="https://github.com/user-attachments/assets/fa216ab7-a501-4ef1-923a-f3390e5283e4" />

## Features

- **Solve Sudoku puzzles** - Automatically solve any valid Sudoku puzzle
- **Generate new puzzles** - Create puzzles with customizable difficulty levels
- **Smart clue system** - Get hints when stuck on a puzzle
- **Weekly puzzle management** - Automatically update weekly puzzles in diary/journal files
- **Auto-detection** - Automatically finds Sudoku grid boundaries
- **Multiple file format support** - Works with markdown and vimwiki files

## Installation

### Prerequisites

- Vim with Python3 support (check with: `vim --version | grep python3`)

### Installation Methods

#### Manual Installation

1. Create the plugin directory structure:
   ```bash
   mkdir -p ~/.vim/pack/plugins/start/vim-sudoku
   ```

2. Copy the plugin files to your Vim directory:
   ```
   ~/.vim/pack/plugins/start/vim-sudoku/
   ├── plugin/sudoku.vim
   ├── autoload/sudoku.vim
   └── doc/sudoku.txt
   ```

#### Vim 8 Packages

1. Clone or download the plugin to your pack directory:
   ```bash
   cd ~/.vim/pack/plugins/start/
   git clone <repository-url> vim-sudoku
   ```

#### Plugin Managers

Add to your plugin manager configuration:

**vim-plug:**
```vim
Plug 'your-username/vim-sudoku'
```

**Vundle:**
```vim
Plugin 'your-username/vim-sudoku'
```

## Usage

### Basic Commands

| Command | Description |
|---------|-------------|
| `:SudokuSolve` | Solve the puzzle under cursor |
| `:SudokuEmpty` | Insert empty grid |
| `:SudokuGenerate [clues]` | Generate new puzzle |
| `:SudokuGiveClue` | Get a single hint |
| `:SudokuAddWeeklyPuzzle` | Add weekly puzzle section |

### Quick Start

1. **Create an empty puzzle:**
   ```vim
   :SudokuEmpty
   ```

2. **Generate a puzzle with 30 clues:**
   ```vim
   :SudokuGenerate 30
   ```

3. **Solve a puzzle:**
   - Position cursor anywhere in the grid
   - Run `:SudokuSolve`

4. **Get a hint:**
   - Position cursor in the grid
   - Run `:SudokuGiveClue`

### Grid Format

The plugin works with ASCII art Sudoku grids:

```
| 5 3   |   7   |       |
| 6     | 1 9 5 |       |
|   9 8 |       |   6   |
-------------------------
| 8     |   6   |     3 |
| 4     | 8   3 |     1 |
| 7     |   2   |     6 |
-------------------------
|   6   |       | 2 8   |
|       | 4 1 9 |     5 |
|       |   8   |   7 9 |
```

## Configuration

### Global Variables

```vim
" Date format for weekly puzzles (default: '%m-%d-%Y')
let g:sudoku_date_format = '%Y-%m-%d'

" Default difficulty level - number of clues (default: 35)
let g:sudoku_current_level = 40

" Files where weekly puzzles auto-update (default: ['*diary*', '*journal*', '*weekly*'])
let g:sudoku_weekly_files = ['*.md', 'diary.txt']
```

### Example Configuration

Add to your `.vimrc`:

```vim
" Sudoku plugin configuration
let g:sudoku_date_format = '%Y-%m-%d'
let g:sudoku_current_level = 45
let g:sudoku_weekly_files = ['diary.md', 'journal.txt', 'weekly-*.md']
```

## Advanced Features

### Weekly Puzzle Management

The plugin automatically manages weekly puzzles in specified files:

1. **Automatic updates** - Weekly puzzles update when you open configured files
2. **Date tracking** - Puzzles are dated and only update when the week changes
3. **Flexible formatting** - Works with both markdown (`##`) and vimwiki (`==`) headings

### Smart Clue System

The `:SudokuGiveClue` command:
- Analyzes the current puzzle state
- Finds cells with only one possible value
- Marks the cell with 'x' to show where the clue applies
- Provides the most helpful hint available

### Auto-Detection

The plugin automatically detects Sudoku grid boundaries:
- Position cursor anywhere within a grid
- No need to select the entire grid
- Works with grids anywhere in the file

## Examples

### Creating and Solving a Puzzle

```vim
" Create empty grid
:SudokuEmpty

" Generate puzzle with 25 clues (hard difficulty)
:SudokuGenerate 25

" Get a hint if stuck
:SudokuGiveClue

" Solve the puzzle
:SudokuSolve
```

### Weekly Puzzle Setup

```vim
" Add weekly puzzle section
:SudokuAddWeeklyPuzzle
```

This creates a section like:
```
## This Week's Sudoku 01-15-2024

| 5 3   |   7   |       |
| 6     | 1 9 5 |       |
...
```

## Troubleshooting

### Common Issues

**"No Python3 support"**
- Ensure Vim was compiled with Python3: `vim --version | grep python3`
- Install Python3 development packages if needed

**"Not inside a Sudoku block"**
- Position cursor within grid lines (starting with `|` or `-`)
- The plugin auto-detects boundaries

**"Invalid input" errors**
- Ensure grid has exactly 9 rows and 9 columns
- Use spaces for empty cells
- Check grid formatting matches the expected pattern

**"No solution exists"**
- Verify puzzle is valid (no duplicate numbers in rows/columns/boxes)
- Check if puzzle is actually solvable

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## License

MIT License - see LICENSE file for details.

## Author

Ben Staniford

---

For detailed documentation, see `:help sudoku` after installation.
