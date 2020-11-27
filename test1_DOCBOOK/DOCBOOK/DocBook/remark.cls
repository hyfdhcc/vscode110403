Include DocBookMac

/// Represents editorial material usually associated with a document
/// while it is in development
Class DocBook.remark Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

/// Indicate whether this remark should render itself
Property InclRemark As %Integer;

/// The text content of this block
Property remarkContent As cdata(MAXLEN = 32000);

Method HTMLRenderContent() [ Internal ]
{
    //show anything
    if (..InclRemark)
    {
        Write "<DIV CLASS=""remark"">",!
        Write "<SPAN CLASS=""remark"">", $$$T("Comments/Questions for Reviewers of This Draft"), "</SPAN>",!
        Write "<P>"
        do ##class(DocBook.Renderer).RenderText(..remarkContent)
        Write "</DIV>",!
    }
    quit
}

/// Render the contents of this block as DocBook XML
Method XMLRender() [ Internal ]
{
    //show anything
    Quit:(..InclRemark=0)

    set attrs = ..tagattrs
    set class = "normal"
    for i = 1 : 5 : $LISTLENGTH(attrs)
    {
        if ($ZCONVERT($LIST(attrs, (i + 1)), "U") = "CLASS")
        {
            set class = $LIST(attrs, (i + 4))
            quit
        }
    }
    set class = $ZCONVERT(class, "L")
    
    Write "<",..%ClassName(),">",!
    Write ..remarkContent
    Write "</",..%ClassName(),">",!
}

Storage Default
{
<Data name="remarkDefaultData">
<Subscript>"remark"</Subscript>
<Value name="1">
<Value>InclRemark</Value>
</Value>
<Value name="2">
<Value>remarkContent</Value>
</Value>
</Data>
<DefaultData>remarkDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
