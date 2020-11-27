Include DocBookMac

/// A definition within a glossentry.
Class DocBook.glossdef Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Write "</DIV>",!
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""glossdef"">",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
