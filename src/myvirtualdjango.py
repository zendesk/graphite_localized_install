activate_this = '/data/graphite/current/.pvm/bin/activate_this.py'
execfile(activate_this, dict(__file__=activate_this))

from django.core.handlers.modpython import handler
