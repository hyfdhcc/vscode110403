Include DocBookMac

/// The name of the contents of a refentry.
Class DocBook.refdescriptor Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

/// Render the contents of this block
Method HTMLRenderContent() [ Internal ]
{
	quit:($LENGTH($ZSTRIP(..content, "<>W")) = 0)
	Write "<DIV CLASS=""refdescriptor"">"
	Write ..content
	Write "</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
