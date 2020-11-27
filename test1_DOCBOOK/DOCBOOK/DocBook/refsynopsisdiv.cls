Include DocBookMac

/// A container for the synopsis of a reference entry.
Class DocBook.refsynopsisdiv Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
    Write "<DIV CLASS=""refsynopsisdiv"">", $$$T("Synopsis"), "</DIV>",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
