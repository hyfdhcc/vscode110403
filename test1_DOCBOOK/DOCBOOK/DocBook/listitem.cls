Include DocBookMac

/// Represents an item in a list (ordered or unordered).
Class DocBook.listitem Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</li>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<li>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
