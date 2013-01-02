# Canton

Just a simple bootstrap template for frontend dev.  I found myself using this sort of setup for a few different little js/html5 experiments and side-projects, so I'm putting it into a repo.  I hope to someday make it a bit more robust, add some documentation, and see if the world at large is interested in it too.

## Features

- Compile your whole multi-file frontend site to a single html file (useful for throwing demos up on s3)
- Support for scss and coffeescript.  Haml is mandatory.
- Auto-reload everything

## Usage

Getting setup for local development:

    git clone https://github.com/kkuchta/canton.git
    cd canton
    bundle install
    rackup
    open 'http://localhost:9292'
    
Compiling to a single static file:
    
    rake compile\[index.haml\]
    
## File structure

### public/js and public/css

Files in here will be accessible from /js and /css.  If you want coffeescript, just create public/js/whatever.coffee and create a script tag like `<script type='text/javascript' src='js/whatever.js'>` in your html.  Same for scss to css.
  
### index.haml

This is your haml file from which everything else is linked.

### out/out.hml

The output file when you run `rake compile`

## TODO:
- Document better
- Make haml optional
- Actually support coffeescript and scss in the compilation code (only supported in local dev at the moment)
- Make a config file (canton.yaml or something) to specify stuff like the out-file name, some path variables, and the index.haml location so we don't have do the ugle rake argument passing.
