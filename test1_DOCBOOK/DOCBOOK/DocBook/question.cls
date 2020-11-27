Include DocBookMac

/// A question.
Class DocBook.question Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""question""><SPAN CLASS=""note"">", $$$T("Question:"), "</SPAN>"
	Write "<A name=""",..id,"""></A>",!
	Write ..title,"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
