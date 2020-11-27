Include DocBookMac

/// An 'important' admonition.
Class DocBook.important Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</DIV>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""important""><SPAN CLASS=""important"">", $$$T("Important:"), "</SPAN> ",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
