# Myrmidon

A dead-simple, tiny task executor for Rofi.

## What

Myrmidon executes tasks for you, displaying something similar to modern text editor's command palette. You define the task names and commands, and let myrmidon make a fuzzy search list to select and execute tasks.

## Why

I've been looking for something like this for a while since I started using i3. Sometimes not everything merits yet another keybinding to remember, nor a bunch of shell files laying around.

## Requirements

Myrmidon currently depends on:

- [Rofi](https://github.com/DaveDavenport/rofi)
- [jq](https://stedolan.github.io/jq/)

## How-to

Define your tasks in `.myrmidon-tasks.json` in your home directory.

Each task is comprised of a `name`, `command` and whether or not it needs a confirmation screen (`confirm`):

Example:

```json
[
  {
    "name": "Area screenshot",
    "command": "gnome-screenshot -a"
  },
  {
    "name": "Window screenshot",
    "command": "gnome-screenshot -w"
  },
  {
    "name": "Power off",
    "confirm": true,
    "command": "systemctl poweroff"
  },
  {
    "name": "Reboot",
    "confirm": true,
    "command": "systemctl reboot"
  },
  {
    "name": "Suspend",
    "confirm": true,
    "command": "systemctl suspend"
  }
]
```

After configuring your tasks file, you would have to set up a keybinding, if needed, to make it work.

For example, in `i3`:

```
bindsym $mod+p exec --no-startup-id ~/bin/myrmidon.sh
```

## To-do

- Allow task file to be given via arguments
