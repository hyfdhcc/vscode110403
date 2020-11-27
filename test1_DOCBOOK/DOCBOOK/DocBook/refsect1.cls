Include DocBookMac

/// Level 1 section of a reference entry.
Class DocBook.refsect1 Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""refsect1"">"
	Write "<A name=""",..id,"""></A>",!
	Write ..title,"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
