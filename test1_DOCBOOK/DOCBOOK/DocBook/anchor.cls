Include DocBookMac

/// Provides a target for page-level help from the management portal
Class DocBook.anchor Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

/// The normalied value of the anchor target
Property target As cdata(MAXLEN = 32000);

Method Interpret() As %Status [ Internal ]
{

    set attrs = ..tagattrs
    
    set text = ""
    for i = 1 : 5 : $LISTLENGTH(attrs)
    {
        if ($ZCONVERT($LIST(attrs, (i + 1)), "U") = "XREFLABEL")
        {
            set text = $LIST(attrs, (i + 4))
            quit
        }
    }
    
    if (text = "")
    {
        Quit $$$ERROR($$$GeneralError,$$$T("Missing xreflabel value"))
    }
    
    set ..target = ##class(DocBook.PortalUtils).Normalize(text)
    set ..content = $$$T("Help follows for the Management Portal page: ")
                  _ ##class(DocBook.PortalUtils).Display(..target)
    quit $$$OK
}

Method HTMLRenderContent() [ Internal ]
{

    Write "<!-- --------------------------------------- -->", !
    Write "<A name=""", $TRANSLATE(..target, ", ", "-_"), """>", "</A>", !

    ;Write "<BR CLEAR=""ALL"">", !
    ;Write "<DIV CLASS=""anchor"">", !
    ;Write "<TABLE CELLSPACING=0 CELLPADDING=3 ALIGN=""RIGHT"">", !
    ;Write "<TBODY>", !
    ;Write "<TR>", !
    ;Write "<TD CLASS=""anchor"" ALIGN=""LEFT"">", !
    ;Write "<NOBR>", $$$T("Help follows for the Management Portal page: ") "</NOBR>", !
    ;Write "<BR>", !
    ;Write "<NOBR>", "&nbsp;&nbsp;", ##class(DocBook.PortalUtils).Display(..target), "&nbsp;&nbsp;", "</NOBR>", !
    ;Write "</TD>", !
    ;Write "</TR>", !
    ;Write "</TBODY>", !
    ;Write "</TABLE>", !
    ;Write "</DIV>"
    ;Write "<BR CLEAR=""ALL"">", !
    
    Write "<!-- --------------------------------------- -->", !
    quit
}

/// Render the contents of this block as DocBook XML
Method XMLRender() [ Internal ]
{

    set attrs = ..tagattrs
    set displayattrs = ..FmtAttrs(attrs)
    
    Write "<", ..%ClassName(), " ", displayattrs, "/>",!
}

Storage Default
{
<Data name="anchorDefaultData">
<Subscript>"anchor"</Subscript>
<Value name="1">
<Value>target</Value>
</Value>
</Data>
<DefaultData>anchorDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
