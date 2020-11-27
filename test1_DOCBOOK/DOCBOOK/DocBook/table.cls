Include DocBookMac

/// A table with a title.
Class DocBook.table Extends DocBook.informaltable [ ClassType = persistent, ProcedureBlock, SqlTableName = db_table ]
{

Method HTMLRenderContent() [ Internal ]
{
    Write "<DIV CLASS=""table-title"">",..title,"</DIV>",!
    Write "<DIV CLASS=""table"">"
    Write "<A name=""",..id,"""></A>",!
    Do ##class(Renderer).RenderTable(..content,..frame,..colsep)
    Write "</DIV>",!
}

/// Render the contents of this block as DocBook XML
Method XMLRender() [ Internal ]
{

    Set attrtext = ..FmtAttrs(..tagattrs)
    Set gensym = "label=" _ """" _ ..id _ """"
    
    If (attrtext '[ "label=")
    {
        Set attrtext = attrtext _ " " _ gensym
    }

    Write "<",..%ClassName()," ",attrtext,">"
    
    Write "<title>", ..title, "</title>", !
    Write ..content
    Write "</",..%ClassName(),">",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
