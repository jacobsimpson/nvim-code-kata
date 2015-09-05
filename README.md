# Code Kata

A plugin to make it easy to write little one off practice programs. It randomly
selects one from a configuration list.

## Install

Add this line to your NeoBundle configuration:

```VimL
NeoBundle 'jacobsimpson/nvim-code-kata'
```

## To Use

```VimL
:BeginKata
```

Begins a code kata, randomly selecting one from the ~/.code-kata-problems.json
configuration file.

```VimL
:EndKata
```

Ends the code kata. It will look try to populate an end time and the duration
in the right place in the comments at the top of the file.
