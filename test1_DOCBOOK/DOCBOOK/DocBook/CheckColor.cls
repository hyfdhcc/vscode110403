Include DocBookMac

/// Scan the DocBook load for colorization errors
Class DocBook.CheckColor Extends %RegisteredObject
{

Parameter MarkerBgn = "DLLResultCode:";

Parameter MarkerEnd = "-->";

/// Drives the scanning process
ClassMethod Main() As %Status [ Internal ]
{
	
	Write $$$T("Scan programlisting items:"), !
	Do ..CheckStatus(..ScanDocBook())
	Write $$$T("End programlisting scan"), !
	
	Quit $$$OK
}

/// Drives the setup of a new Cache 5.1 install
ClassMethod CheckStatus(Code) [ Internal ]
{
	If ($SYSTEM.Status.IsError(Code))
	{
		Do $SYSTEM.Status.DisplayError(Code)
		Write !
	}
	Quit
}

/// Loads the DocBook application
ClassMethod ScanDocBook(NewDir As %String = "") As %Status [ Internal ]
{
	// build the query to look for errors
	Set SELECT = "SELECT ID, sourcefile, dblang, renderedContent"
	Set FROM = "FROM DocBook.programlisting"
	Set WHERE = "WHERE ($FIND(renderedContent, '" _ ..#MarkerBgn _ "') > 0)"
	Set STMT = SELECT _ " " _ FROM _ " " _ WHERE
	;;Write "Stmt: ", SELECT, !, "..... ", FROM, !, "..... ", WHERE, !
	
	Set RS = ##class(%Library.ResultSet).%New("%DynamicQuery:SQL")
	Set sc = RS.Prepare(STMT)
	If ($$$ISERR(sc))
	{
		Write $$$T("Error attempting to prepare <programlisting> query"), !
		Quit sc
	}
	Set sc = RS.Execute()
	If ($$$ISERR(sc))
	{
		Write $$$T("Error attempting to execute <programlisting> query"), !
		Quit sc
	}
	
	Set ErrorTotal = 0
	While (RS.Next())
	{
		Set ErrorTotal = ErrorTotal + 1
		
		Set ThisID = $GET(RS.Data("ID"))
		Set ThisFile = $GET(RS.Data("sourcefile"))
		Set ThisLang = $GET(RS.Data("dblang"))
		Set ThisText = $GET(RS.Data("renderedContent"))
		
		Set BgnInx = $FIND(ThisText, ..#MarkerBgn)
		Set EndInx = $FIND(ThisText, ..#MarkerEnd) - $LENGTH(..#MarkerEnd)
		Set MarkerData = $ZSTRIP($EXTRACT(ThisText, BgnInx, EndInx), "<>W")
		
		Write ErrorTotal, "//", ThisID, "//", ThisFile, "//", ThisLang, "//", MarkerData, !
	}
	
	If (ErrorTotal '= 0)
	{
		Write $$$T("Items found: "), ErrorTotal, !
	}
	
	Quit $$$OK
}

}
