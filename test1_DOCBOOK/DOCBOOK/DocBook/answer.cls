Include DocBookMac

/// An answer.
Class DocBook.answer Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""answer""><SPAN CLASS=""note"">", $$$T("Answer:"), "</SPAN>"
	Write "<A name=""",..id,"""></A>",!
	Write ..title,"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
