My graphite localized install.  That means each cap deploy installs a
localized Graphite with Python and dependancies into the release
directory.

## Instructions:
1. git clone
2. bundle install --path vendor/bundle
3. bundle exec cap deploy:setup
4. bundle exec cap deploy
5. bundle exec cap deploy:database
6. http://graphite

## TODO:
* Warn when system packages are not installed.
* [StatsD](https://github.com/etsy/statsd) stats aggregator.
* [Diamond](http://opensource.brightcove.com/project/Diamond/) system
* stats collector.

## References:
http://graphite.readthedocs.org/en/latest/install.html

http://agiletesting.blogspot.com/2011/04/installing-and-configuring-graphite.html

