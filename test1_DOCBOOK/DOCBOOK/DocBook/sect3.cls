Include DocBookMac

/// A level 3 section.
Class DocBook.sect3 Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""sect3"">"
	Write "<A name=""",..id,"""></A>",!
	Write ##class(DocBook.Renderer).XFormEntity(..title),"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
