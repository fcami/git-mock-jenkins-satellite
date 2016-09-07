#!/usr/bin/python

import os
import sys
import xmlrpclib
import urllib2
from optparse import OptionParser
import string
import subprocess

def connect(url, login, password):
    myconn = {}
    myconn['client'] = xmlrpclib.Server(url, verbose=0)
    myconn['key'] = myconn['client'].auth.login(login, password)
    return myconn

def logout(conn):
    conn['client'].auth.logout(conn['key'])

def push_single_errata(conn, errata, tchan=None):
    if tchan == None:
        print "Specify target channel !"
        sys.exit(1)
    print conn['client'].errata.cloneAsOriginal(conn['key'],tchan,[errata])

if __name__=="__main__":
    parser = OptionParser("usage: %prog [options]")
    parser.add_option("-H", dest="hostname", type="string", default=None, help="Satellite FQDN.")
    parser.add_option("-l", dest="login", type="string", default=None, help="Satellite login.")
    parser.add_option("-p", dest="password", type="string", default=None, help="Satellite password.")
    parser.add_option("-c", dest="channel", type="string", default=None, help="channel to download.")
    parser.add_option("-d", dest="destpath", type="string", default=None, help="base destination path on localdrive.")
    
    (options, args) = parser.parse_args()

    if options.hostname==None or options.login==None or options.password==None or options.channel==None or options.destpath==None:
        print "Missing arguments, launch with -h for online help."
        sys.exit(1)

    if not os.path.isdir(options.destpath):
        print "%s is not a directory." % (options.destpath)
        sys.exit(1)

    url = "http://"+options.hostname+"/rpc/api"
    session = connect(url, options.login, options.password)
    packages = session['client'].channel.software.listLatestPackages(session['key'], options.channel)
    for p in packages:
        name           = p["name"]
        release        = p["release"]
        version        = p["version"]
        versionrelease = "%s-%s"         % (version,release)
        id             = p["id"]
        arch           = p["arch_label"]
        completename   = "%s-%s.%s.rpm"  % (name,versionrelease,arch)
        p_url = session['client'].packages.getPackageUrl(session['key'], p['id'])
        uo = urllib2.urlopen(p_url)
        f = open(os.path.join(options.destpath, options.channel, completename), 'wb')
        f.write(uo.read())
        f.close()
    logout (session)
    sys.exit(0)

