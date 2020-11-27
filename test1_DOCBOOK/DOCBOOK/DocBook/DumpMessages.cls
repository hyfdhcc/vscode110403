/// This class extracts the text fragments that need to be
/// localized from the DocBook namespace and writes them to
/// an XML file acceptable to the localization tools.
/// 
Class DocBook.DumpMessages Extends %RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// Run the extraction
ClassMethod Run(Path As %Library.String = "C:\DocBookMessages.xml") As %Library.Status
{
	; initialize
	set result = $$$OK
	
	; set up the default output file
	set Out = ##class(%Library.File).%New(Path)
	do Out.Open("WSNK\UTF8\")
	
	; file header
	do Out.WriteLine("<?xml version=""1.0"" encoding=""UTF-8""?>")
	do Out.WriteLine("<!--  ***********************************************************  -->")
	do Out.WriteLine("<!--  In order to work with the Cache build translation mechanism, -->")
	do Out.WriteLine("<!--  this file format must be strictly followed:                  -->")
	do Out.WriteLine("<!--  1. encoding must be ""UTF-8""                                  -->")
	do Out.WriteLine("<!--  2. all tags must have open and close on same line            -->")
	do Out.WriteLine("<!--  ***********************************************************  -->")
	do Out.WriteLine("<MsgFile Language=""en"">")
   	do Out.WriteLine("  <MsgDomain Domain=""DOCBOOK"">")
	
	; loop over the entries in the global
	set key = ""
	set key = $ORDER(^CacheMsg("DOCBOOK", "en", key))
	set cnt = 0
	while (key '= "")
	{
		set text = $GET(^CacheMsg("DOCBOOK", "en", key))
		
		set text = ..Convert(text)
		
		set line = "    "
		set line = line _ "<Message Id=""" _ key _ """>"
		set line = line _ text
		set line = line _ "</Message>"
		do Out.WriteLine(line)
		set cnt = cnt + 1
		set key = $ORDER(^CacheMsg("DOCBOOK", "en", key))
	}
	
	; file trailer
   	do Out.WriteLine("  </MsgDomain>")
	do Out.WriteLine("</MsgFile>")
	
ABORT ;
	do Out.Close()
	write "Message fragments: ", cnt, !
	quit result
}

/// Replace strings
ClassMethod Convert(Text As %Library.String) As %Library.String [ Internal ]
{
	; convert non-standard entities to numeric
	set result = ""
	if (Text [ "&")
	{
		set Text = $ZCONVERT(Text, "I", "HTML")
	}
	
	for i = 1 : 1 : $LENGTH(Text)
	{
		set chr = $EXTRACT(Text, i)
		set val = $ASCII(chr)
		if (chr = "&")
		{
			set result = result _ "&amp;"
			continue
		}
		if (chr = "<")
		{
			set result = result _ "&lt;"
			continue
		}
		if (chr = ">")
		{
			set result = result _ "&gt;"
			continue
		}
		if ((val < 32) || (val > 127))
		{
			set result = result _ "&#" _ val _ ";"
			continue
		}
		set result = result _ chr
	}

	quit result
}

}
