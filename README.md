# Jekyll-Atom

A collection of snippets and tools for [Jekyll] in [Atom]

[![Jekyll Logo](http://jekyllrb.com/img/logo-2x.png)](http://jekyllrb.com)

# Configuring

Jekyll-Atom has a couple of settings that can be set through the [Atom] settings.

`Layouts Dir` The path to your layouts, defaults to `_layouts/`

`Layouts Type` The file type of your layouts, defaults to `.html`

`Posts Dir` The path to your posts, defaults to `_posts/`

`Posts Type` The file type of your posts, defaults to `.markdown`

`Includes Dir` The path to your includes, defaults to `_includes/`

# Usage

## Functions

### Open the layout for the current file

When triggered this function looks through your file for `layout: foo` and then opens `LAYOUTS_DIR/foo.LAYOUT_FORMAT`

### Open the include for the cursor position

When triggered this function opens up the include for the current tag. For example if you had `{% include snippet.html %}` Atom would open `INCLUDES_DIR/snippet.html`

### Create a new Post

When triggered this function brings up a popup at the top of the screen for you to type in the title of your new post e.g. `Something Really Cool!` (on the date 2/4/2014). When you submit the form a new file of `POSTSDIR/2014-04-02-something-really-cool.POST_FORMAT` will be created with a very basic front matter and opened on the screen.

### Open Config

Opens `_config.yml`

## Keyboard Shortcuts

`Cmd-Alt-L` Open the layout for the current file

`Cmd-Alt-J` Create a new post

`Cmd-Shift-I` Open include

## Snippets

There are a load of snippets provided by this plugin, please check the settings pane in atom for a full list.

# Contributing

Feel free to fork this repo and submit changes!

When you fork Jekyll-Atom please:

1. Create your feature branch (`git checkout -b my-new-feature`)
2. Commit your changes (`git commit -am 'Add some feature'`)
3. Push to the branch (`git push origin my-new-feature`)
4. Create new Pull Request

[Jekyll]: http://jekyllrb.com
[Atom]: https://atom.io
