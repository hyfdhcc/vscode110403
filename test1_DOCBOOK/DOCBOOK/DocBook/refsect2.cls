Include DocBookMac

/// Level 2 section of a reference entry.
Class DocBook.refsect2 Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""refsect2"">"
	Write "<A name=""",..id,"""></A>",!
	Write ..title,"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
