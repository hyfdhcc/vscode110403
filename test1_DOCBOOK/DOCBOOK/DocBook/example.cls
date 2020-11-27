Include DocBookMac

/// A formal example, with a title.
Class DocBook.example Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""exampletitle"">"
	Write "<A name=""",..id,"""></A>",!
	Write "&mdash;",..title,"&mdash;"
	Write "</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
