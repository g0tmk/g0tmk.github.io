---
title: "Deploy a static website with Hugo"
description: ""
tags: [hugo, web, github]
date: 2024-03-16T23:43:14-07:00
draft: false
author: "g0tmk"
cover:
    image: "hugo-logo-wide.png" # image path/url
    alt: "Hugo Logo" # alt text
    caption: "<text>" # display caption under cover
    relative: true # when using page bundles set this to true
    hiddenInSingle: false
---

This site is generated using [Hugo][hugo]. Configuration is done using yaml and posts are markdown files. Very simple and easy to track in git.

## Create a blank site

1. Install hugo

    ```bash
    # snaps are the easiest way to get an updated version of hugo
    sudo snap install hugo
    ```

1. Create a site (this creates a new folder with the site's name)

    ```bash
    hugo new site hugo-demo
    cd hugo-demo
    ```

1. Add a theme, I picked PaperMod

    ```bash
    git init

    # install theme
    git submodule add --depth=1 https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
    
    # needed when you reclone your repo (submodules may not get cloned automatically)
    git submodule update --init --recursive
    ```

1. Replace your existing config.yaml with boilerplate from [the PaperMod wiki][papermod-wiki].

1. Create a new post

    ```bash
    # create a new post
    hugo new posts/my-first-post.md
    # add some content
    echo "Hello, World!" >> content/posts/my-first-post.md
    ```

1. Serve the site locally

    ```bash
    # serve the site, -D enables drafts
    hugo server -D
    ```

1. Open your browser to [http://localhost:1313](http://localhost:1313)

## Publishing to GitHub Pages

Note that there are two URL formats for GitHub Pages:
 - `<username>.github.io` for user or organization sites
 - `<username>.github.io/<repo>` for project sites

If you want to use the first format, the repository you create on GitHub must be named `<username>.github.io`.

Follow [this guide on the Hugo website][hugo-gh] to set up GitHub Pages.

## Maintenence

1. Update the theme

    ```bash
    git submodule update --remote --merge
    ```

<!-- links -->
[hugo]: https://gohugo.io/ "Hugo"
[papermod-wiki]: https://github.com/adityatelange/hugo-PaperMod/wiki/Installation#sample-configyml "PaperMod Wiki"
[hugo-gh]: https://gohugo.io/hosting-and-deployment/hosting-on-github/ "Hugo GitHub Pages"

