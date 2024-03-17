# g0tmk's notes

A collection of notes, stored publicly so others can edit and improve them.

## Todos

- Comb through `config.yaml` and edit the defaults
- Add comments somehow, probably using [gisgus](https://gisgus.app/). 
  - Walkthrough of adding gisgus to hugo [here](https://cdwilson.dev/articles/using-giscus-for-comments-in-hugo/)
  - Comparison of other comment systems [here](https://darekkay.com/blog/static-site-comments/).
- Add a favicon
- Programatically add a "last updated" date to posts
- Figure out best way to host mirrors of my links. Ie run through all external links, download them via something like SingleFile, upload them to the root assets folder, and add a mirror link/icon next to the original links. Need to be careful to not allow it to download if one already exists, to avoid cases where the link dies later and it overwrites the good mirror with a 404 page.

## Make a new post

1. Create a new post

    ```bash
    make new
    # type the title and hit enter, for example zfs-server-setup

    # add some content
    echo "Hello, World!" >> content/posts/zfs-server-setup.md
    ```

1. Serve the site locally

    ```bash
    make server
    # open your browser to http://localhost:1313
    ```

1. Push the latest site to git

    ```bash
    git add content/posts/zfs-server-setup.md
    git commit -m "Add zfs-server-setup"
    git push
    ```

