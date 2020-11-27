Include DocBookMac

/// A container is a specialized block that can contain one or more blocks.
Class DocBook.container Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

/// Blockpos of last child in container
Property lastChildPos As dbint [ InitialExpression = 0 ];

/// SubTitle for this container
Property subtitle As cdata;

ClassMethod %OnDelete(oid As %ObjectIdentity) As %Status [ Internal ]
{
    // delete all of our dependents
    Do ..DeleteDependents($LG(oid,1))
    
    Quit $$$OK
}

/// Delete all dependent blocks
ClassMethod DeleteDependents(cid As cdata, display As %Boolean = 0) [ Internal ]
{
    New %ISCDBCounter
    Set %ISCDBCounter = $INCREMENT(^||DocBook.CursorCount)
    Kill %DocBookCursor(%ISCDBCounter)
#EXECUTE Set %msqlvar = "%DocBookCursor(%ISCDBCounter"

    Set bid = ""
    
    // find child blocks
    &sql(DECLARE DEL1 CURSOR FOR 
         SELECT ID
         INTO :bid
         FROM block
         WHERE container = :cid
    )

    &sql(OPEN DEL1)
    &sql(FETCH DEL1)
    
    While (SQLCODE = 0) {
        Write:display "-"
        // Use concurrency of 0!!!
        Do ##class(DocBook.block).%DeleteId(bid,0)
        &sql(FETCH DEL1)
    }

    &sql(CLOSE DEL1)
#EXECUTE Kill %msqlvar
    
    Quit $$$OK
}

/// Get list of sections in this container:
/// This is used to create the "goto" list dropdown
/// gtl is an array passed by reference
Method GetGotoList(ByRef gtl As cdata) [ Internal ]
{
    // override in subclasses
    Quit
}

/// render this container's children
Method HTMLRender() [ Internal ]
{
    // if this block has a recognized status value, then wrap
    // it with the appropriate DIV.
    // Does not work for netscape

    Set statusmark = ""
    If ((..status'="")&&%ie&&'%ie6)
    {
        If ($TRANSLATE(..status, "L") [ "draft")
        {
            Set statusmark = "draft"
        }
        If ($TRANSLATE(..status, "L") [ "broken")
        {
            Set statusmark = "broken"
        }
    }
    Write:(statusmark'="") "<DIV CLASS=""",statusmark,""">"
    Do ..HTMLRenderPreChildren()
    Do ..HTMLRenderChildren()
    Do ..HTMLRenderPostChildren()
    Write:(statusmark'="") "</DIV>"
    
    // counter keeps track of when to flush
    If ($D(%counter) & $D(%response)) {
        Set %counter = %counter + 1
        If ((%counter # 5) = 0) {
            //Do %response.Flush()
        }
    }
}

/// render any HTML before children
Method HTMLRenderPreChildren() [ Internal ]
{
   // override in subclass
}

/// render any HTML after children
Method HTMLRenderPostChildren() [ Internal ]
{
   // override in subclass
}

/// Render this container's children as HTML.
Method HTMLRenderChildren() [ Internal ]
{
    New %ISCDBCounter
    Set %ISCDBCounter = $INCREMENT(^||DocBook.CursorCount)
    Kill %DocBookCursor(%ISCDBCounter)
#EXECUTE Set %msqlvar = "%DocBookCursor(%ISCDBCounter"

    Set cid = ..%Id()
    Set bid = ""

    // find child blocks
    &sql(DECLARE C1 CURSOR FOR 
         SELECT ID
         INTO :bid
         FROM block
         WHERE container = :cid
         ORDER BY blockpos
    )

    &sql(OPEN C1)
    &sql(FETCH C1)

    If (SQLCODE '= 0) {
        // no children, render content
        Do ..HTMLRenderContent()
    }
    While (SQLCODE = 0) {
        Do ..HTMLRenderId(bid)
        &sql(FETCH C1)
    }

    &sql(CLOSE C1)
#EXECUTE Kill %msqlvar
}

Method XMLRender() [ Internal ]
{
    Do ..XMLRenderPreChildren()
    Do ..XMLRenderChildren()
    Do ..XMLRenderPostChildren()
}

/// render any XML before children
Method XMLRenderPreChildren() [ Internal ]
{
    // assume class name is XML element name

    Set attr = ""
    Set:(..tagattrs '= "") attr = " " _ ..FmtAttrs(..tagattrs)
    If (..HasAttr("id", ..tagattrs) = "") {
        If (..id '= "") {
            Set attr = attr _ " id=""" _ ..id _ """"
        }
    }
    If (..HasAttr("role", ..tagattrs) = "") {
        If (..role '= "") {
            Set attr = attr _ " role=""" _ ..role _ """"
        }
    }
    
    Write "<",..%ClassName(),attr,">",!
    If (..title '= "") {
        Write "<title>", ..title, "</title>",!
    }
    If (..subtitle '= "") {
        Write "<subtitle>", ..subtitle,"</subtitle>",!
    }
}

/// render any XML after children
Method XMLRenderPostChildren() [ Internal ]
{
    // assume class name is XML element name
    Write "</",..%ClassName(),">",!
}

Method XMLRenderChildren() [ Internal ]
{
    New %ISCDBCounter
    Set %ISCDBCounter = $INCREMENT(^||DocBook.CursorCount)
    Kill %DocBookCursor(%ISCDBCounter)
#EXECUTE Set %msqlvar = "%DocBookCursor(%ISCDBCounter"

    Set cid = ..%Id()
    Set bid = ""

    // find child blocks
    &sql(DECLARE C2 CURSOR FOR 
         SELECT ID
         INTO :bid
         FROM block
         WHERE container = :cid
         ORDER BY blockpos
    )

    &sql(OPEN C2)
    &sql(FETCH C2)
    
    If (SQLCODE '= 0) {
        // no children, render content
        Write ..content
    }

    While (SQLCODE = 0) {
        Do ..XMLRenderId(bid)
        &sql(FETCH C2)
    }

    &sql(CLOSE C2)
#EXECUTE Kill %msqlvar
}

Storage Default
{
<Data name="containerDefaultData">
<Subscript>"container"</Subscript>
<Value name="1">
<Value>lastChildPos</Value>
</Value>
<Value name="2">
<Value>subtitle</Value>
</Value>
</Data>
<DefaultData>containerDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
