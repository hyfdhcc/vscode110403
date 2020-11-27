Include DocBookMac

/// A 'warning' admonition.
Class DocBook.warning Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</DIV>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""warning""><SPAN CLASS=""warning"">", $$$T("Warning:"), "</SPAN> ",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
