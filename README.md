# Code Kata

A plugin to make it easy to write little one off practice programs. It randomly
selects one from a configuration list.

NOTE: At the moment, if you are not me and you attempt to use this, you will
encounter frustration. There are a couple of hard coded paths in there.

## Install

Add this line to your [vim-plug](https://github.com/junegunn/vim-plug)
configuration:

```VimL
Plug 'jacobsimpson/nvim-code-kata'
```

## To Use

```VimL
:BeginKata
```

Begins a code kata, randomly selecting one from the ~/.code-kata-problems
configuration file.

```VimL
:EndKata
```

Ends the code kata. It will look try to populate an end time and the duration
in the right place in the `stats.txt` file in the kata directory.

## Development

```
nvim --cmd "set rtp+=./nvim-code-kata"
```

