Include DocBookMac

/// A summary of the topic of a reference page.
Class DocBook.refpurpose Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderContent() [ Internal ]
{
	Write "<DIV CLASS=""para"">",##class(DocBook.Renderer).FilterText(..content),"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
