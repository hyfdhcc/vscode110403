Include DocBookMac

/// A level 4 section.
Class DocBook.sect4 Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""sect4"">"
	Write "<A name=""",..id,"""></A>",!
	Write ##class(DocBook.Renderer).XFormEntity(..title),"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
