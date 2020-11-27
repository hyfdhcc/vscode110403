Include DocBookMac

/// A caution admonition.
Class DocBook.caution Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</DIV>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""caution""><SPAN CLASS=""caution"">", $$$T("Caution:"), "</SPAN> ",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
