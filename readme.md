# Myrmidon

A dead-simple, tiny task executor for Rofi.

## What

Myrmidon executes tasks for you, displaying something similar to modern text editor's command palette. You define the task names and commands, and let myrmidon make a fuzzy search list to select and execute tasks.

<img align="center" alt="demo" src="https://user-images.githubusercontent.com/4857535/50374333-3d82e800-05cb-11e9-8f14-1338cac3d290.gif"/>

## Why

I've been looking for something like this for a while since I started using i3. Sometimes not everything merits yet another keybinding to remember, nor a bunch of shell files laying around.

## Requirements

Myrmidon currently depends on:

- [Rofi](https://github.com/DaveDavenport/rofi)
- [jq](https://stedolan.github.io/jq/)

## Installation / defining tasks

Copy both shell scripts in the same directory (e.g: ~/bin)

Define your tasks in a json file. The default location of the json file will be `$HOME/.myrmidon-tasks.json`, but you can pass an optional argument as a custom path for the configuration file (e.g: `./myrmidon.sh ~/my-custom-path/tasks.json`).

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
### Add notificatoin

This is an attempt to integrate notification proposed in issue [#8](https://github.com/moustacheful/myrmidon/issues/8)

This solution depends on [notify-send](https://manpages.ubuntu.com/manpages/xenial/man1/notify-send.1.html) and gnome icons.

```json
[
  {
    "name": "Area screenshot",
    "command": "gnome-screenshot -a",
    "notification": {
        "text":"Area screenshot",
        "icon":"xscreensaver",
        "urgency":"low"
          }
  }
]
```

One could add all options accepted by notify-send, just take care that the key must be **exactly** the long option.
```
$ notify-send --help
Usage:
  notify-send [OPTION…] <SUMMARY> [BODY] - create a notification

Help Options:
  -?, --help                        Show help options

Application Options:
  -u, --urgency=LEVEL               Specifies the urgency level (low, normal, critical).
  -t, --expire-time=TIME            Specifies the timeout in milliseconds at which to expire the notification.
  -a, --app-name=APP_NAME           Specifies the app name for the icon
  -i, --icon=ICON[,ICON...]         Specifies an icon filename or stock icon to display.
  -c, --category=TYPE[,TYPE...]     Specifies the notification category.
  -h, --hint=TYPE:NAME:VALUE        Specifies basic extra data to pass. Valid types are int, double, string and byte.
  -v, --version                     Version of the package.
```

## Multiple config files

As it is possible to provide an optional location of the config file, you can keep multiple keys for different task "categories", for example:

```
bindsym $mod+p exec --no-startup-id ~/bin/myrmidon.sh ~/common-tasks.json
bindsym $mod+Esc exec --no-startup-id ~/bin/myrmidon.sh ~/power-tasks.json
bindsym $mod+Print exec --no-startup-id ~/bin/myrmidon.sh ~/screenshot-tasks.json
```

This way, for example, $mod+Esc will now only show tasks related to power (Power off, restart, suspend, etc), as to not pollute the task pool.

## Contribute

If you feel there's any missing feature you'd like to see in Myrmidon, feel free to propose it or open a pull request!
