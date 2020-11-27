Include DocBookMac

/// A formal paragraph: a paragraph with a title.
Class DocBook.formalpara Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPostChildren() [ Internal ]
{
	Quit
}

Method HTMLRenderPreChildren() [ Internal ]
{
	Write "<DIV CLASS=""formalparatitle"">",..title,"</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
