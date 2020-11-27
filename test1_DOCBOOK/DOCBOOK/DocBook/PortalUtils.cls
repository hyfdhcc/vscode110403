Include DocBookMac

/// Utilities for manipulating system management portal references
Class DocBook.PortalUtils Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

ClassMethod substitute(text As %String, lookfor As %String, replacewith As %String) As %String [ Internal ]
{
	set result = text
	set looklen = $LENGTH(lookfor)
	
	set inx = $FIND(result, lookfor)
	while(inx > 0)
	{
		set $extract(result, (inx - looklen), (inx - 1)) = replacewith
		set inx = $FIND(result, lookfor)
	}

	Quit result
}

/// Convert the INTERFACE reference to a comma-separated list of item
/// with extraneous spaces and commas removed.
ClassMethod Normalize(text As cdata) As cdata [ Internal ]
{
	
	set text = ..substitute(text, $CHAR(9), " ")
	set text = ..substitute(text, $CHAR(10), " ")
	set text = ..substitute(text, $CHAR(13), " ")
	set text = ..substitute(text, """", " ")
	set text = $ZSTRIP(text, "*C")
	set text = $ZSTRIP(text, "<>W")
	set text = ..substitute(text, "  ", " ")
	set text = ..substitute(text, ", ", ",")
	set text = ..substitute(text, " ,", ",")
	set text = ..substitute(text, ",,", ",")
	if ($extract(text, 1)) = ","
	{
		set $EXTRACT(text, 1) = ""
	}
	if ($extract(text, $LENGTH(text))) = ","
	{
		set $EXTRACT(text, $LENGTH(text)) = ""
	}
	
	// JMD665
	// Convert System to Home for compatibility
	Set p1 = $P(text,",",1)
	If ($$$UPPER(p1)="SYSTEM") {
		Set $P(text,",",1) = "Home"
	}
	
	quit text
}

/// Convert the INTERFACE value from a comma-separated list 
/// to the form it has on the Management Portal address bar.
ClassMethod Display(text As cdata) As cdata [ Internal ]
{
	Set result = ""
	Set piececnt = $LENGTH(text, ",")
	For i = 1:1:piececnt
	{
		Set:($LENGTH(result) > 0) result = result _ " &gt; "
		Set result = result _ "[" _ $PIECE(text, ",", i) _ "]"
	}
	Quit result
}

/// Take a canonicalized portal reference and form the
/// appropriate subscript for use in a global reference.
ClassMethod FormatSubscript(canonref As cdata) As cdata [ Internal ]
{
	Set subs = ""
	Set piececnt = $LENGTH(canonref, ",")
	For i = 1:1:piececnt
	{
		Set:($LENGTH(subs) > 0) subs = subs _ ","
		Set subs = subs _ """" _ $PIECE(canonref, ",", i) _ """"
	}
	Quit subs
}

/// Take a canonicalized portal reference and attempt to obtain
/// a URL for it using ^%MgtPortal.Index.
ClassMethod GetPortalURL(canonref As cdata) As cdata [ Internal ]
{
	Set result = ""
	
	Set global = "^%qMgtPortal.Index"

	#; JMD665
	#; convert "Home" reference to "System"
	#;If ($P($$$UPPER(canonref),",",1)="HOME") {
	#;	Set $P(canonref,",",1) = "System"
	#;}

	Set ref = global _ "(" _ ..FormatSubscript(canonref) _ ")"
	#;Write canonref, " ::= ", ref,!
	Set result = $GET(@ref, "")
	Quit result
}

/// Convert a block number into a URL.
/// Liberally cribbed from method, ShowResult in DocBook.UI.SearchBM
ClassMethod IdToRef(id As cdata) As cdata [ Internal ]
{
	Set result = ""

	&sql(SELECT blockid,
			    component->blockid,
			    x__classname
		INTO :paraKey, :docKey, :cls
		FROM DocBook.block
		WHERE ID = :id
	)

	If (SQLCODE '= 0) 
	{
		Quit "/csp/docbook/DocBook.UI.PortalHelp.cls"
	}

	If (docKey = "") 
	{
		Set docKey = paraKey
		Set paraKey = ""
	}

	Set srch = ""
	If (paraKey '= "") 
	{
		Set srch = "#" _ paraKey
	}

	Set result = "/csp/docbook/DocBook.UI.Page.cls?KEY=" _ $$$URLENCODE(docKey) _ srch

	Quit result
}

}
