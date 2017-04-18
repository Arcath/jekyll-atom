# Jekyll-Atom [![Build Status](https://travis-ci.org/Arcath/jekyll-atom.svg?branch=master)](https://travis-ci.org/Arcath/jekyll-atom) [![Dependency Status](https://david-dm.org/arcath/jekyll-atom.svg)](https://david-dm.org/arcath/jekyll-atom) [![Join the chat at https://gitter.im/Arcath/jekyll-atom](https://badges.gitter.im/Arcath/jekyll-atom.svg)](https://gitter.im/Arcath/jekyll-atom?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

A collection of snippets and tools for [Jekyll] in [Atom]

[![Jekyll Logo](https://raw.githubusercontent.com/Arcath/jekyll-atom/master/images/jekyll.png)](http://jekyllrb.com)

# Configuring

Jekyll-Atom has a few settings that can be set through the [Atom] settings.

`Server Port` The port used by [static-server](https://github.com/nbluis/static-server), defaults to `3000`

`Build Command` An array containing the default command to build a site, defaults to `jekyll, build`. Can be overridden in your projects `_config.yml`.

 - The `Build Command` will most likely need changing due to some weirdness with $PATH in [Atom].
   - Go into the packages settings (Settings -> Packages -> Jekyll).
   - Change `Build Command` to `/path/to/jekyll, build`.
   - You can get your /path/to/jekyll by using `which jekyll` in your terminal.

## _config.yml

Jekyll Atom can pickup project specific config from your `_config.yml`.

For Example:

```yaml
atom:
  buildCommand:
    - jekyll
    - build
    - --option
    - --this
  buildEnv:
    JEKYLL_ENV: development
  postDirs:
    - _newsletters
  defaultPostDir: _drafts
```

### buildCommand

buildCommand works the same as it does in the Atom settings and is an override for this site.

### buildEnv

The environment used for the build process lets you set any environment variables you desire.

### postDirs

The directories that appear on the new post modal. `_posts` and `_drafts` are added by default.

### defaultPostDir

The default directory to be selected on the new post modal. Defaults to `_posts`.

# Usage

## Server Management

Jekyll-Atom can host a server to preview your site!

The server runs in the background and can be started/stopped from anywhere using the Toggle Server command `Alt-Shift-T`.

Whilst running any time you save in Atom your site will be built and available on the port you set in config.

## Auto Building

If you would prefer jekyll-atom to simply build your site on save instead of serving it on static server you can use the command `Jekyll: Toggle Auto Build` to turn building of your site on save on/off.

## Grammars

Jekyll-Atom adds 3 language grammars to Atom `Jekyll (HTML)`, `Jekyll (XML)` and `Jekyll (JSON)`. All 3 add Liquid and YAML highlighting to their respective format.

> Liquid Highlighting requires the [language-liquid](https://atom.io/packages/language-liquid) package to be installed.

## Functions

### Open the layout for the current file

When triggered this function looks through your file for `layout: foo` and then opens `LAYOUTS_DIR/foo.LAYOUT_FORMAT`

### Open the include for the cursor position

When triggered this function opens up the include for the current tag. For example if you had `{% include snippet.html %}` Atom would open `INCLUDES_DIR/snippet.html`

### Create a new Post

When triggered this function brings up a popup at the top of the screen for you to type in the title of your new post e.g. `Something Really Cool!` (on the date 2/4/2014). When you submit the form a new file of `POSTSDIR/2014-04-02-something-really-cool.POST_FORMAT` will be created with a very basic front matter and opened on the screen.

### Open Config

Opens `_config.yml`

### Open Data File

When Triggered this function looks at the text around your cursor to find the data file to open. For Example triggering Open Data File whilst your cursor is within the `site.data.team` in this `{{ blah site.data.team }}` would result in `DATADIR/team.yml` being opened.

## Keyboard Shortcuts

`Cmd-Alt-L` Open the layout for the current file

`Cmd-Alt-D` Open the Datafile

`Cmd-Shift-I` Open include

`Cmd-Alt-J` Create a new post

`Alt-Shift-T` Turn the server on/off

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
