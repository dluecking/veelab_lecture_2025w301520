# Block 1
## Project 1: Phylogenetics of Influenzavirus

## Introduction to the Linux commandline
The Linux command line is a text interface to your computer. Often referred to as the shell, terminal, console, prompt or various other names, it can give the appearance of being complex and confusing to use. But after getting used to the black screen and the keyboard-centric interface, you will quickly understand why its so powerful!

For this course, we need some very fundamental commands. Namely:
| Command | Description |
|----------|--------------|
| `ls` | Lists files and directories in the current directory. |
| `mkdir` | Creates a new directory. |
| `rm` | Removes files or directories (use `-r` for recursive deletion). |
| `rmdir` | Removes an empty directory. |
| `cd` | Changes the current working directory. |
| `cp` | Copy files from A to B. |
| `mv` | Move files from A to B. |
| `pwd` | Prints the current working directory path. |
| `grep` | Searches for a pattern or string in files or input. |
| `uniq` | Filters out or reports repeated lines in sorted input. |
| `sed` | Stream editor for filtering and transforming text. |
| `head` | Displays the first few lines of a file (default: 10). |
| `tail` | Displays the last few lines of a file |
| `tree` | Displays directories and files in a tree-like structure. |
| `cat` | Concatenates and displays file contents. |
| `ssh` | Connects securely to a remote machine via the command line. |
| `scp` | Securely copies files between local and remote machines over SSH. |

The terminal is slightly different than other programs e.g. when it comes to copying and pasting content from the clipboard. Here are a few shortcuts:

| Shortcut | Description |
|-----------|--------------|
| `Ctrl + Shift + C` | Copy selected text (in most Linux terminals). |
| `Ctrl + Shift + V` | Paste copied text. |
| `Ctrl + L` | Clears the terminal screen. |
| `Ctrl + R` | Searches command history interactively. |
| `Tab` | Auto-completes file or directory names (<- this one is your friend!) |
| `↑ / ↓` | Scrolls through previous and next commands in history. |
| `Ctrl + D` | Closes the terminal or logs out of the current shell. |

## Implement the project structure
In your homedirectory (`/lisc/home/user/<USER>` or `~/`), create the folder "2025w301520". 

Then prepare the follwoing folder structure, so we can work in a nice environment:
```
$ tree 2025w301520
├── data
├── processed_HA_NA
└── scripts
```


## Download the correct Influenzavirus segments
