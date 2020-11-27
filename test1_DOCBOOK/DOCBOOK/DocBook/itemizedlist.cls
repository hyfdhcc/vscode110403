Include DocBookMac

/// Represents a bulleted list.
Class DocBook.itemizedlist Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</ul>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<ul>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
