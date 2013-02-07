/**
* ColdFusion port of jTidy (http://jtidy.sourceforge.net/)
*
* @hint="Takes a string returns parsed and valid xHTML"
* This function reads in a string, checks and corrects any invalid HTML.
* By Greg Stewart
*
* @param strToParse The string to parse (will be written to file).
* accessible from the web browser
* @return returnPart
* @author Greg Stewart (gregs(at)tcias.co.uk)
* @version 1, August 22, 2004
*
* @version 1.1, September 09, 2004
* with the help of Mark Woods this UDF no longer requires temp files and only accepts
* the string to parse
*
* @version 1.2, January 01, 2010
* slightly modified version by Mike Henke
* added javaloader
*
* @version 1.3, July 09, 2012
* Modified by Michael Sharman (michael[at]chapter31.com)
* @param options Struct of options to define runtime behaviour
* @param path Path to the jTidy jar file
* @param throwOnError Boolean to halt if an error was thrown
* @param logFile Which log file to write exceptions to
* @param useJavaLoader Use javaloader to load the jar file
*  Removed hard javaloader dependency (jar access is native to Railo 3.2+, you can use javaloader for CF)
*  Allowed struct of options to be passed for runtime configuration
*  Updated to use cfscript only
*  Added full var scoping
*  Added option to fail silently
*  Added log path argument of where to write errors
*  Currently using the latest jTidy (jtidy-r938.zip from http://sourceforge.net/projects/jtidy/files)
* Usage:
* 	tidy = new jtidy_cfc.jtidy();
*
* 	// Simple usage (default options)
* 	validxHTML = tidy.makexHTMLValid(strToParse=mystring)
*
* 	// Simple usage using javaloader
* 	validxHTML = tidy.makexHTMLValid(strToParse=mystring, useJavaLoader=true)
*
* 	// Setting custom options
* 	opts = {
*		bodyOnly = false,
* 		spaces = 2
* 	}
* 	validxHTML = tidy.makexHTMLValid(strToParse=mystring, options=opts)
*/
component name="jtidy" hint="clean out invalid html"
{

	public string function makexHTMLValid(required string strToParse, struct options = {}, string path = "", boolean throwOnError = false, string logFile = "", boolean useJavaLoader = false)
	{
		var readBuffer	= "";
		var inP			= "";
		var outx		= "";
		var outstr		= "";
		var javaloader	= "";
		var logTo		= (len(trim(arguments.logFile))) ? arguments.logFile : application.applicationName;
		var parseData	= trim(arguments.strToParse);
		var jarPath		= (len(trim(arguments.path))) ? arguments.path : getdirectoryfrompath(getcurrenttemplatepath()) & "jtidy.jar";
		var jOptions	= {		// default options
			bodyOnly			= true,
			hideComments		= true,
			indentAttributes	= false,
			indentContent		= true,
			makeBare			= true,
			quiet				= false,
			smartIndent 		= true,
			spaces				= 4,
			tidyMark			= false,
			wrapLen			= 1024,
			xhtml				= true,
			encoding			= "UTF8",
			numEntities		= true,
			quoteNbsp			= false,
			word2000			= true,
			xmlOut				= true
		};

		// Simply return the string if it's empty
		if (!len(trim(parseData)))
		{
			return parseData;
		}

		try
		{
			// Override the default options if passed as an argument
			if (isValid("struct", arguments.options) && !structIsEmpty(arguments.options))
			{
				structAppend(jOptions, arguments.options, true);
			}

			try
			{
				if (arguments.useJavaLoader)
				{
					javaloader = createObject("component", "javaloader.JavaLoader").init([jarPath]);
					jTidy = javaloader.create("org.w3c.tidy.Tidy").init();
				}
				else
				{
					jTidy = createObject("java", "org.w3c.tidy.Tidy", jarPath).init();
				}
			}
			catch (any e)
			{
				throw(type="tidy.invalidpath", message="Cannot find jTidy in #jarPath#");
			}

			// Set configuration options (see more http://jtidy.sourceforge.net/apidocs/org/w3c/tidy/Configuration.html)
			jTidy.setErrfile(logTo);
			jTidy.setHideComments(jOptions.hideComments);
			jTidy.setIndentAttributes(jOptions.indentAttributes);
			jTidy.setIndentContent(jOptions.indentContent);
			jTidy.setMakeBare(jOptions.makeBare);
			jTidy.setPrintBodyOnly(jOptions.bodyOnly);
			jTidy.setQuiet(jOptions.quiet);
			jTidy.setSmartIndent(jOptions.smartIndent);
			jTidy.setSpaces(jOptions.spaces);
			jTidy.setShowWarnings(arguments.throwOnError);
			jTidy.setTidyMark(jOptions.tidyMark);
			jTidy.setWraplen(jOptions.wrapLen);
			jTidy.setXHTML(jOptions.xhtml);
			jTidy.setNumEntities(jOptions.numEntities);
			jTidy.setInputEncoding(javaCast("string", jOptions.encoding));
			jTidy.setOutputEncoding(javaCast("string", jOptions.encoding));
			jTidy.setQuoteNbsp(jOptions.quoteNbsp);
			jTidy.setWord2000(jOptions.word2000);
			jTidy.setXmlOut(jOptions.xmlOut);

			// create the in and out streams for jTidy
			readBuffer = createObject("java","java.lang.String").init(parseData).getBytes(jOptions.encoding);
			inP = createobject("java","java.io.ByteArrayInputStream").init(readBuffer);
			outx = createObject("java", "java.io.ByteArrayOutputStream").init();

			// do the parsing
			jTidy.parse(inP,outx);
			outstr = outx.toString(jOptions.encoding);

			// close the stream(s)
			inP.close();
			outx.close();

			if (!len(trim(outstr)))
			{
				throw(type="tidy.noresults", message="Output from jtidy empty");
			}

			return outstr;
		}
		catch (any err)
		{
			if (arguments.throwOnError)
			{
				dump(var=err);
				abort;
			}
			else
			{
				trace type="warning" text="jtidy_cfc: #err.message#";
				writeLog(text="jtidy_cfc.makexHTMLValid() #err.message# #err.type#", file="#logTo#", type="error");
				return parseData; // Return original string on error
			}
		}
	}

}
