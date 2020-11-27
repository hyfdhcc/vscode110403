Include DocBookMac

/// A tip admonition.
Class DocBook.tip Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</DIV>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""tip""><SPAN CLASS=""tip"">", $$$T("Tip:"), "</SPAN> ",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
