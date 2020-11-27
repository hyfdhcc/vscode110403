Include DocBookMac

/// The name of the contents of a refentry.
Class DocBook.refname Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

/// Render the contents of this block
Method HTMLRenderContent() [ Internal ]
{
	// supress rendering of this block
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
