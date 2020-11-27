Include DocBookMac

/// A question and answer division
Class DocBook.qandadiv Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""qandadiv"">"
	Write "<A name=""",..id,"""></A>",!
	Write ..title,"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
