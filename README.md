# Canton

Just a simple bootstrap template for frontend dev.  I found myself using this sort of setup for a few different little js/html5 experiments and side-projects, so I'm putting it into a repo.  I hope to someday make it a bit more robust, add some documentation, and see if the world at large is interested in it too.

## Features

- Compile your whole multi-file frontend site to a single html file (useful for throwing demos up on s3)
- Support for scss and coffeescript.  Haml is mandatory.
- Auto-reload everything

## Usage

    git clone https://github.com/kkuchta/canton.git
    cd canton
    bundle install
    rackup
    open 'http://localhost:9292'
    
## File structure

### public/js and public/css

  Files in here will be accessible from /js and /css.  If you want coffeescript, just create public/js/whatever.coffee and create a link like `<script type='text/javascript' src='js/whatever.js'>`.  Same for scss to css.
