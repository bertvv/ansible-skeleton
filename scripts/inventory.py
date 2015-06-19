#! /usr/bin/python
# coding=utf8
#
# Inventory script for Ansible skeleton, to be used on Windows host systems

import socket
import sys
from getopt import getopt, GetoptError


#
# Helper functions
#


def usage():
    print ("Usage: %s [OPTION]\n"
           "  --list  list all hosts\n"
           "  --host=HOST  gives extra info"
           "about the specified host\n") % sys.argv[0]


def list_hosts():
    host_name = socket.gethostname()
    print "{ \"all\": { \"hosts\": [\"%s\"] } }" % host_name


def host_info(host):
    print "{}"

#
# Parse command line
#

try:
    opts, args = getopt(sys.argv[1:], "lh:", ['list', 'host='])
except GetoptError as err:
    print str(err)
    usage()
    sys.exit(2)

for opt, opt_arg in opts:
    if opt in ('-l', '--list'):
        list_hosts()
        sys.exit(0)
    if opt in ('-h', '--host'):
        host_info(opt_arg)
    else:
        assert False, "unhandled option: %s" % opt
