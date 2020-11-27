Include DocBookMac

/// A level 2 section.
Class DocBook.sect2 Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""sect2"">"
	Write "<A name=""",..id,"""></A>",!
	Write ##class(DocBook.Renderer).XFormEntity(..title),"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
