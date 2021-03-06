## Introduction

jTidy_cfc is a ColdFusion wrapper for the Java port of HTML Tidy, a HTML syntax checker and pretty printer. Currently using the latest jTidy ([jtidy-r938.zip](http://sourceforge.net/projects/jtidy/files))

Read more: [http://jtidy.sourceforge.net/](http://jtidy.sourceforge.net/)

This version is a [fork from mhenke](https://github.com/mhenke/jtidy_cfc)

### Modifications from original

*  Removed javaloader as a hard dependency (jar file access is native to Railo 3.2+, you can still use javaloader for ColdFusion server)
*  Updated javaloader to 1.1 (Feb 2012) for those who choose to use it
*  Allowed struct of options to be passed for runtime configuration
*  Updated to use cfscript only
*  Added full var scoping
*  Added option to fail silently or throw on error
*  Added log path argument of where to write errors
*  Removed auto-stripping of header/footer content, use a config option instead
*  Added a character encoding value to options, defaults to UTF8


## Requirements
* Railo 3.2+
* ColdFusion 9+


## Installation
Put the jtidy\_cfc folder in your web root (recommended for _testing only_) or create a mapping pointing to jtidy.cfc


## Usage

    tidy = new jtidy_cfc.jtidy();

    // Simple usage (default options)
    validxHTML = tidy.makexHTMLValid(strToParse=mystring);

    // Simple usage using javaloader
    validxHTML = tidy.makexHTMLValid(strToParse=mystring, useJavaLoader=true);

    // Setting custom options
    opts = {
        bodyOnly = false,
        spaces = 2
    }
    validxHTML = tidy.makexHTMLValid(strToParse=mystring, options=opts);

## Options

The current options you can pass ([see more on the javadoc page](http://jtidy.sourceforge.net/apidocs/org/w3c/tidy/Configuration.html)):

    jOptions = {
        bodyOnly			= true,
        hideComments		= true,
        indentAttributes	= false,
        indentContent 		= true,
        makeBare			= true,
        quiet 				= false,
        smartIndent 		= true,
        spaces				= 4,
        tidyMark			= false,
        wrapLen 			= 1024,
        xhtml 				= true
    };
    validxHTML = tidy.makexHTMLValid(strToParse=mystring, options=jOptions);
