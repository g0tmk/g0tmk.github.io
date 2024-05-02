---
title: "Adding comments to Hugo wish Gisgus"
description: ""
tags: [hugo, web, gisgus, github]
date: 2024-03-23T21:45:12-07:00
draft: true
author: "g0tmk"
cover:
    image: "<image path/url>" # image path/url
    alt: "<alt text>" # alt text
    caption: "<text>" # display caption under cover
    relative: false # when using page bundles set this to true
    hidden: true # only hide on current single page
---

This page runs on Hugo, which generates a static site - so its not capable of handling comments natively. To add comments, I'm using [gisgus](https://gisgus.app/).

Gisgus uses GitHub issues as a backend for comments. This means that comments are stored in your repository, and you can moderate them using the GitHub interface.

This is a walkthrough of how I added gisgus to this site.

## Add gisgus to the Hugo template

1. Go to the [gisgus website](https://gisgus.app/) and sign in with your GitHub account.
1. Click "Add a new repository" and select the repository you want to add comments to.
1. Click "Add gisgus to this repository" and follow the instructions.
1. Copy the code snippet that gisgus gives you.
1. Open your Hugo theme's `single.html` file and paste the code snippet at the bottom of the file.

    ```bash
    echo "<!-- gisgus comments -->" >> themes/PaperMod/layouts/_default/single.html
    ```

1. Commit the changes and push them to your repository.
