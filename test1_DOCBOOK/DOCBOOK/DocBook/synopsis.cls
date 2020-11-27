Include DocBookMac

/// A block containing a function synposis
Class DocBook.synopsis Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderContent() [ Internal ]
{
	Write "<DIV CLASS=""synopsis""><PRE>",..content,"</PRE></DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
