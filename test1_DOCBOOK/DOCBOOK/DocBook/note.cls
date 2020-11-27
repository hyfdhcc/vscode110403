Include DocBookMac

/// A note admonition.
Class DocBook.note Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</DIV>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""note""><SPAN CLASS=""note"">", $$$T("Note:"), "</SPAN> ",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
