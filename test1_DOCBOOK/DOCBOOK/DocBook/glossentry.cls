Include DocBookMac

/// An entry in a glossary or glosslist.
Class DocBook.glossentry Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

/// the glossterm associated with this glossentry
Property glossterm As cdata;

Method %OnBeforeSave(insert As %Boolean) As %Status [ Internal, Private ]
{
    Set ..content = ..glossterm
    
	Quit $$$OK
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""glossentry"">"
	Write "<A name=""",..id,"""></A>",!
	If (..glossterm [ "<") {
		// there is inline markup
		Do ##class(Renderer).RenderText(..glossterm)
	}
	Else {
		Write ..glossterm
	}
	Write "</DIV>",!
}

Method XMLRender() [ Internal ]
{
	Do ..XMLRenderPreChildren()
	Do ..XMLRenderChildren()
	Do ..XMLRenderPostChildren()
}

/// render any XML before children
Method XMLRenderPreChildren() [ Internal ]
{
	// assume class name is XML element name

	Set attr = ""
	Set:(..tagattrs '= "") attr = " " _ ..FmtAttrs(..tagattrs)
	If (..HasAttr("id", ..tagattrs) = "") {
		If (..id '= "") {
			Set attr = attr _ " id=""" _ ..id _ """"
		}
	}
	If (..HasAttr("role", ..tagattrs) = "") {
		If (..role '= "") {
			Set attr = attr _ " role=""" _ ..role _ """"
		}
	}
	
	Write "<",..%ClassName(),attr,">",!
	write "<glossterm>", ..glossterm, "</glossterm>", !
	If (..title '= "") {
		Write "<title>", ..title, "</title>",!
	}
}

/// render any XML after children
Method XMLRenderPostChildren() [ Internal ]
{
	// assume class name is XML element name
	Write "</glossentry>",!
}

Method XMLRenderChildren() [ Internal ]
{
	New %ISCDBCounter
	Set %ISCDBCounter = $INCREMENT(^||DocBook.CursorCount)
	Kill %DocBookCursor(%ISCDBCounter)
#EXECUTE Set %msqlvar = "%DocBookCursor(%ISCDBCounter"

	Set cid = ..%Id()
	Set bid = ""

	// find child blocks
	&sql(DECLARE C2 CURSOR FOR 
		 SELECT ID
		 INTO :bid
		 FROM block
		 WHERE container = :cid
		 ORDER BY blockpos
	)

	&sql(OPEN C2)
	&sql(FETCH C2)
	
	If (SQLCODE '= 0) {
		// no children, render content
		Write ..content
	}

	While (SQLCODE = 0) {
		Do ..XMLRenderId(bid)
		&sql(FETCH C2)
	}

	&sql(CLOSE C2)
#EXECUTE Kill %msqlvar

	Quit
}

Storage Default
{
<Data name="containerDefaultData">
<Subscript>"container"</Subscript>
<Value name="1">
<Value>title</Value>
</Value>
<Value name="2">
<Value>subtitle</Value>
</Value>
<Value name="3">
<Value>glossterm</Value>
</Value>
</Data>
<Data name="glossentryDefaultData">
<Subscript>"glossentry"</Subscript>
<Value name="1">
<Value>lastChildPos</Value>
</Value>
</Data>
<DefaultData>glossentryDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
