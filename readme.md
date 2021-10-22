QueryParam Scanner

* Version:       0.8
* License:       LGPLv3
* Homepage:      https://www.sorcerersisle.com/software/qpscanner
* Documentation: https://docs.sorcerersisle.com/qpscanner
* Repository:    https://code.sorcerersisle.com/qpscanner.git
* Issues:        https://github.com/boughtonp/qpscanner/issues


Description
-----------

QueryParam Scanner (qpScanner) is a tool designed to identify possible SQL
injection risks in CFML queries, by highlighting instances of unparameterised
variables.


Known Issues
------------

QueryParam Scanner does not work with script/function based queries, and - due
to the dynamic nature of CFML - would require a significant overhaul to have
any chance of producing useful output.

Instead, a security tool configured to scan for SQL injection attacks should
be used to protect such software, e.g. OWASP ZAP (https://www.zaproxy.org).


Requirements
------------

qpScanner can scan code written for any CFML engine, but itself requires
at least ColdFusion 9 or Railo 3.x to run.

To run qpScanner on older CFML engines, try v0.7.3 instead - this is available
on branch 0.7.3 or for download from https://code.sorcerersisle.com/qpscanner/tags


Getting Started
---------------

Extract all files to a directory in your webroot, then access that directory in
a browser.

Everything required is contained within the zip file; no mappings nor
datasources need to be setup.


Upon accessing qpScanner you will see a simple form:

	Directory
		The location of the code you wish to scan.
		This can be either an absolute path or a mapping.

	Recurse?
		Select yes if you want qpScanner to look inside sub-directories,
		or no to only scan the files directly in the specified directory.


Once these are set as appropriate, press Scan and qpScanner will get to work.

It will look for queries with CF variables (ie: `#values_in_hashes#`) that are
not inside a cfqueryparam tag, and  - once complete - will list how many were
found out of how many total queries, and provide a list of files and queries.


NOTE: QueryParam Scanner should be used *only* in your development environment,
not on a live/public box. In addition to the security risks, it might have an
adverse affect on performance.


Licensing & Credits
-------------------

This project is available under the terms of the GPLv3 license.
See license.txt to understand your rights and obligations.

QueryParam Scanner was created by Peter Boughton and gratefully makes
use of the third-party software detailed below, each available
individually under their respective licenses.

jQuery v1.2.6 (http://jquery.com)
* Source: https://github.com/jquery/jquery
* License: GPLv2 or MIT (See http://jquery.org/license)
* Files: resources/scripts/jquery-1.2.6.min.js

Framework One v2.2 (http://fw1.riaforge.org)
* Source: http://github.com/seancorfield/fw1/
* License: Apache v2.0 (http://www.apache.org/licenses/LICENSE-2.0)
* Files: framework.cfc


/eof