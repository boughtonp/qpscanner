QueryParam Scanner v0.7.5


DESCRIPTION
===========

QueryParam Scanner (qpScanner) is a tool designed to identify possible SQL 
injection risks in CFML queries, by highlighting instances of unparameterised 
variables.



STATUS
======

**This is a dev version of qpScanner, see master branch for stable release.**

Version: v0.7.5
Released: 2013-01-08

To check latest release, visit http://sorcerersisle.com/projects:qpscanner.html



REQUIREMENTS
============

qpScanner can scan code written for any CFML engine, but itself requires 
at least ColdFusion 9 or Railo 3.x to run.

To run qpScanner on older CFML engines, try v0.7.3 instead - this is available
on branch 0.7.3 or for download from https://github.com/boughtonp/qpscanner/tags  



INSTALLATION
============

Extract all files to a directory in your webroot, then access that directory in 
a browser.

Everything required is contained within the zip file; no mappings nor 
datasources need to be setup.



ECLIPSE PLUGIN INSTALLATION
===========================

There is a separately available plugin for the Eclipse IDE, allowing qpScanner 
to be executed against specific files or directories.

For more details on this plugin, check the info provided at:

  http://sorcerersisle.com/projects:qpscanner.html#EclipsePlugin



USAGE
=====

Upon accessing qpScanner you will see a Quick Start form:

	Select Config
		This allows you to choose between "default" or "paranoid" configs.
		The default config should be fine for most people.

	Starting Directory
		Where you put the location of the project(s) you wish to scan.
		This can be either an absolute path or a mapping.

	Recursive
		Indicates if you want qpScanner to look inside directories, or remain
		at the current directory level.


Once these are set as appropriate, press Scan and qpScanner will get to work.

As it finds queries with CF variables (ie: `#values_in_hashes#`) that are not
inside a cfqueryparam tag, it will list that file. The positions of the queries 
are displayed when clicking on a file, and clicking on each of those reveals the 
actual contents of the query.

When complete, it will list how many were found out of how many total queries.


NOTE: QueryParam Scanner should be used *only* in your development environment,
not on a live/public box. In addition to the security risks, it might have an
adverse affect on performance.



KNOWN ISSUES
============

There is one known issue with this release:

* qpScanner does not work with queries in cfscript. For more details see:
  https://github.com/boughtonp/qpscanner/issues/7#issuecomment-11916582

Visit the Issue Tracker for details of any issues that might since have been 
raised, to report any issues that you find, or to request new functionality:

  https://github.com/boughtonp/qpscanner/issues



CREDITS, VERSIONS & LICENSING
=============================

QueryParam Scanner is a project created and maintained by Peter Boughton, 
licensed under the GPLv3 (read license.txt for details).

The project gratefully makes use of the third-party software detailed below, 
each available individually under their respective licenses.

cfRegex v0.1.003-qp (http://cfregex.net)
* Source: https://github.com/boughtonp/qpscanner
* License: GPLv3 or LGPLv3
* Files: cfcs/cfregex.cfc

jQuery v1.2.6 (http://jquery.com)
* Source: https://github.com/jquery/jquery
* License: GPLv2 or MIT (See http://jquery.org/license)
* Files: resources/scripts/jquery-1.2.6.min.js

Fusebox v5.5.1 (http://fusebox.org)
* Source: https://github.com/fusebox-framework/Fusebox-ColdFusion
* License: Apache v2.0 (http://www.apache.org/licenses/LICENSE-2.0) 
* Files: fusebox5/*


/eof