Include DocBookMac

/// Represents a chunk of text that must be rendered as is.
Class DocBook.literallayout Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderContent() [ Internal ]
{

	Set mt = ""
	//Set:(%ie||%ie6) mt = " oncontextmenu=""if (!event.ctrlKey){showContextMenu();return false;} else {menu1.style.display='none'}"""

	set attrs = ..tagattrs
	set class = "normal"
	for i = 1 : 5 : $LISTLENGTH(attrs)
	{
		if ($ZCONVERT($LIST(attrs, (i + 1)), "U") = "CLASS")
		{
			set class = $LIST(attrs, (i + 4))
			quit
		}
	}
	set class = $ZCONVERT(class, "U")
	
	Write "<DIV CLASS=""literallayout""",mt,">",!
	Write "<A name=""",..id,"""></A>",!
	Write "<PRE CLASS=""", class, """>",..content,"</PRE>",!
	Write "</DIV>",!
}

/// Render the contents of this block as DocBook XML
Method XMLRender() [ Internal ]
{

	set attrs = ..tagattrs
	set class = "normal"
	for i = 1 : 5 : $LISTLENGTH(attrs)
	{
		if ($ZCONVERT($LIST(attrs, (i + 1)), "U") = "CLASS")
		{
			set class = $LIST(attrs, (i + 4))
			quit
		}
	}
	set class = $ZCONVERT(class, "L")
	
	Write "<",..%ClassName()
	Write:(class '= "") " class=""", class, """"
	Write ">"
	Write ..content
	Write "</",..%ClassName(),">",!
}

Storage Default
{
<Data name="literallayoutDefaultData">
<Subscript>"literallayout"</Subscript>
<Value name="1">
<Value>syntaxError</Value>
</Value>
</Data>
<DefaultData>literallayoutDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
