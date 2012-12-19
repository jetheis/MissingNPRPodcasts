# The Missing NPR Podcasts

This project includes a simple [Sinatra](http://www.sinatrarb.com/) web
application that consumes the [NPR](http://www.npr.org/)
[API](http://www.npr.org/api/index) for the
[Morning Edition](http://www.npr.org/programs/morning-edition/) and
[All Things Considered](http://www.npr.org/programs/all-things-considered/)
radio news programs and reorganizes it into a podcast format. As stated many
times throughout this document, and throughout the
[NPR API Terms of Use](https://www.npr.org/api/apiterms.php), this software and
its output are **for personal use only**. I am in no way affiliated with NPR or
any NPR program.

Please read the [NPR API Terms of Use](https://www.npr.org/api/apiterms.php)
before using this software.

## Disclaimer

This is not an official podcast! NPR makes a good portion of its money from
licensing programs like Morning Edition and All Things Considered to member
stations. Do not let the existence of this code prevent you from both listening
to these programs from your local NPR member station and contributing to that
station.

If you don't have a "home" NPR member station, feel free to donate to mine:

* [WFYI (Indianapolis)](https://www.wfyi.org/pledgeNew/pledgeForm.php)
* [WFIU (Bloomington, Terre Haute)](http://indianapublicmedia.org/support/radio/)

## Acceptable Use

Please read the [NPR API Terms of Use](https://www.npr.org/api/apiterms.php)
before using this software. As stated in those terms, API content is for
personal use only. While this software can easily be deployed in a publicly
accessible way, it is up to the user to comply with the API's terms and be the
sole, noncommercial user of the content. Anyone using this software must do so
using his own NPR API key, making any actions taken by the software or the users
of the software the responsibility of the registered API key holder.

## Cloning this Site

If you'd like to set up a personal or secondary instance of this site, doing so
is pretty easy. You do have a choice, though, to deploy the cloned site to
[Heroku](http://www.heroku.com/) like I have, or to run it locally from a computer
that you own.

### Deploying on Heroku

Make sure you've got [Git](http://git-scm.com/) or [GitHub for
Mac/Windows](http://mac.github.com/), as well as the [Heroku
Toolbelt](https://toolbelt.heroku.com/) installed. Then just clone and deploy:

    $ git clone https://github.com/jetheis/MissingNPRPodcasts.git
    $ cd MissingNPRPodcasts
    $ heroku apps:create thenameofyournewsite
    $ git push heroku master

If this is your first time using Heroku, you'll have to set up an account and
your public keys to be able to push to the new site.

### Deploying Locally

With [Git](http://git-scm.com/) or
[GitHub for Mac/Windows](http://mac.github.com/) and [RVM](https://rvm.io/)
installed, clone and run:

    $ git clone https://github.com/jetheis/MissingNPRPodcasts.git
    $ cd MissingNPRPodcasts
      # (accept the RVM file)
    $ bundle install
    $ rackup

You can use `rackup --help` to see more options for running the site.

## License

All media content is property of
[NPR: National Public Radio](https://www.npr.org/).

Information about the licensing of the programs can be found on the
[Morning Edition weg page](http://www.npr.org/programs/morning-edition/), as well
as the
[All Things Considered web page](https://www.npr.org/programs/all-things-considered/).

The source code contained in this project is released under the MIT License:

    Copyright (C) 2012 Jimmy Theis
    
    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.

The site icon/logo is a derivative work of [Glyphicons](http://glyphicons.com/),
which I purchased a license for, so it cannot be released under any permissible
license. If you like the logo and would like to make a similar one, I highly
recommend buying a [Glyphicons PRO](http://glyphicons.com/glyphicons-licenses/)
license.
