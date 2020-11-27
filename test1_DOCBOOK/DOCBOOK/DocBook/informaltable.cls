Include DocBookMac

/// A table without a title.
Class DocBook.informaltable Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

Property colsep As dbint;

Property frame As cdata;

Method HTMLRenderContent() [ Internal ]
{
    Write "<DIV CLASS=""informaltable"">"
    Write "<A name=""",..id,"""></A>",!
    Do ##class(Renderer).RenderTable(..content,..frame,..colsep)
    Write "</DIV>",!
}

Storage Default
{
<Data name="informaltableDefaultData">
<Subscript>"informaltable"</Subscript>
<Value name="1">
<Value>colsep</Value>
</Value>
<Value name="2">
<Value>frame</Value>
</Value>
</Data>
<DefaultData>informaltableDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
