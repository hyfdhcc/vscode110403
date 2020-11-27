Include DocBookMac

/// Represents a numbered list.
Class DocBook.orderedlist Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</ol>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Set typecode = "1"
	If (..HasAttr("numeration", ..tagattrs))
	{
		Set fmt = ..GetAttrValue("numeration", ..tagattrs)
		Set fmt = $ZCONVERT(fmt, "L")
		Set:(fmt = "arabic") typecode = "1"
		Set:(fmt = "loweralpha") typecode = "a"
		//Set:(fmt = "upperalpha") typecode = "A"
		//Set:(fmt = "lowerroman") typecode = "i"
		//Set:(fmt = "upperroman") typecode = "I"
	}
	Write "<ol type=""", typecode, """>", !
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
