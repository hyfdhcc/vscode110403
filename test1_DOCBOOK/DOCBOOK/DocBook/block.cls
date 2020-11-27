Include DocBookMac

/// The block is the basic content container for the DocBook database.
Class DocBook.block Extends %Library.Persistent [ Abstract, ClassType = persistent, ProcedureBlock, StorageStrategy = Default ]
{

/// Changes the value of the extenstize on table to avoid
/// having the query optimizer call BuildValueArray during searches
Parameter EXTENTSIZE = 10000000;

Index IdIndex On id [ Unique ];

Index bookIndex On book [ Type = bitmap ];

Index bookPos On (book, blockpos);

Index componentIndex On component [ Type = bitmap ];

Index containerIndex On container [ Type = bitmap ];

Index contentIdx On content(KEYS) [ Type = bitmap ];

Index titleIdx On title(KEYS) [ Type = bitmap ];

/// This block's position within its parent container.
Property blockpos As dbfloat;

/// The book this block belongs to.
Property book As book;

/// The component (chapter,refentry, or article) this block belongs to.
Property component As component;

/// The parent container to which this block belongs.
Property container As container;

/// The text content of this block.
Property content As DocBook.IndexedText(MAXLEN = 32000, SELECTIVITY = "20%");

/// This is the block ID
Property id As id [ SqlFieldName = blockid ];

/// The lang attribute for this block
Property lang As cdata [ SqlFieldName = dblang ];

/// Timestamp for this block
Property lastchange As %TimeStamp;

/// The role attribute for this block
Property role As cdata [ SqlFieldName = dbrole ];

/// Used primarily on books as the primary sort key to order them in the list.
Property remap As cdata;

/// The xml source file from where this block was loaded
Property sourcefile As cdata(MAXLEN = 100);

/// Timestamp of the source file for this block
Property sourcetime As %TimeStamp;

/// The status attribute for this block<br>
/// Within the DocBook standard, status is only available 
/// for certain elements. We define it here for consistency.
Property status As cdata [ SqlFieldName = dbstatus ];

/// This is a reconstituted list of the attributes supplied with this block.
Property tagattrs As %Library.List;

/// Title.<br>
/// Strictly speaking a block does not have title, a
/// container does. This is defined here for convenience.
Property title As DocBook.IndexedText(MAXLEN = 1000, SELECTIVITY = "20%");

/// Some blocks may choose to pre-render their content for HTML
/// and place it here.
Property renderedContent As cdata;

Method %OnBeforeSave(insert As %Boolean) As %Status [ Internal, Private ]
{
    #; Set timestamp
    Set ..lastchange = $ZDT($H,3)

    #; make sure search cache is cleared
    If ($D(^DocBook.SearchCache)) {
        Do ##class(DocBook.UI.SearchPageZen).ClearCache()
    }
    Quit $$$OK
}

/// Is there an attribute with this name
ClassMethod HasAttr(AttrName As %Library.String, AttrList As %Library.List) As %Status [ Internal ]
{
    
    set result = ""
    set attrs = AttrList
    set tempname = "/" _ $ZCONVERT(AttrName, "U") _ "/"
    for i = 1 : 5 : $LISTLENGTH(attrs)
    {
        set name = "/" _ $ZCONVERT($LIST(attrs, (i + 1)), "U") _ "/"
        if ($ZCONVERT(name, "U") [ tempname) {
            set result = $$$OK
        }
    }
    
    quit result
}

/// Get value for attribute with this name
ClassMethod GetAttrValue(AttrName As %Library.String, AttrList As %Library.List) As %String [ Internal ]
{
    
    set result = ""
    set attrs = AttrList
    set tempname = $ZCONVERT(AttrName, "U")
    for i = 1 : 5 : $LISTLENGTH(attrs)
    {
        set name = $LIST(attrs, (i + 1))
        if ($ZCONVERT(name, "U") = tempname)
        {
            set result = $LIST(attrs, (i + 4))
        }
    }
    
    quit result
}

/// Render the attributes for this block
ClassMethod FmtAttrs(AttrList As %Library.List, OnlyIds As %Library.List = "") As %String [ Internal ]
{
    
    set attrs = AttrList
    set only = "/"
    for i = 1 : 1 : $LISTLENGTH(OnlyIds)
    {
        set only = only _ $ZCONVERT($LIST(OnlyIds, i), "U") _ "/"
    }
    
    set result = ""
    ; Format of the attribute list
    ; A sequence of 5-element chunks as follows: 
    ; +0 - the uri
    ; +1 - local (unqualified) name
    ; +2 - qualified name
    ; +3 - the type ("CDATA", NMTOKEN", "ENTITY", etc.)
    ; +4 - the attribute value.
    ;
    for i = 1 : 5 : $LISTLENGTH(attrs)
    {
        set name = $LIST(attrs, (i + 1))
        set proceed = 0
        set:(OnlyIds = "") proceed = 1
        set:((OnlyIds '= "") && (only [ ("/" _ $ZCONVERT(name, "U") _ "/"))) proceed = 1
        if (proceed)
        {
            set:(result '= "") result = result _ " "
            set result = result _ name
            if ($LISTDATA(attrs, (i + 4)))
            {
                set val = $LIST(attrs, (i + 4))
                ; we could use $ISVALIDNUM to determine whether to 
                ; quote the value, but in practice it is not necessary
                set result = result _ "=""" _ $ZCONVERT(val, "O", "HTML") _ """"
            }
        }
    }
    
    quit result
}

/// Find a block Object ID froms its block id.
ClassMethod FindId(bid As cdata) As id [ Internal ]
{

    Set id = ""
    &sql(SELECT ID INTO :id FROM block WHERE blockid = :bid)

    If (SQLCODE '= 0) {
        Quit ""
    }
    Quit id
}

/// Return banner info used to render the HTML page
Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
    Set info.title = ""
    Set info.booktitle = ""
    Set info.chap = ""
    Set info.prev = ""
    Set info.next = ""
}

/// Render the contents of this block as HTML
Method HTMLRender() [ Internal ]
{
    Do ..HTMLRenderContent()
}

Method HTMLRenderContent() [ Internal ]
{
    // if this block has a recognized status value, then wrap
    // it with the appropriate DIV.
    // This does not work with NetScape
    //New statusmark
    
    Set statusmark = ""
    If ((..status'="")&&%ie)
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
    Write "<A name=""",..id,"""></A>",!
    Write ##class(DocBook.Renderer).FilterText(..content)
    Write:(statusmark'="") "</DIV>"
}

/// Render the object with object id 
/// <varname>id</varname> as HTML.
ClassMethod HTMLRenderId(id As cdata) [ Internal ]
{
    Set block = ##class(block).%OpenId(id)
    If (block '= "") {
        Do block.HTMLRender()
    }
}

/// Find and open a block instance given its block id
/// (not its object id).
ClassMethod OpenKey(bid As cdata) As block [ Internal ]
{
    Quit ..%OpenId(..FindId(bid))
}

/// Render the contents of this block as DocBook XML
Method XMLRender() [ Internal ]
{
    
    Set tagtext = ..FmtAttrs(..tagattrs)
    Set:(tagtext '= "") tagtext = " " _ tagtext
    Write "<",..%ClassName(),tagtext,">"
    Write ..content
    Write "</",..%ClassName(),">",!
}

/// Render the block with Object Id 
/// <varname>id</varname> as DocBook XML
ClassMethod XMLRenderId(id As cdata) [ Internal ]
{
    Set block = ##class(block).%OpenId(id)
    If (block '= "") {
        Do block.XMLRender()
    }
}

Storage Default
{
<Data name="Content">
<Attribute>content</Attribute>
<Structure>node</Structure>
<Subscript>"content"</Subscript>
</Data>
<Data name="Render">
<Attribute>renderedContent</Attribute>
<Structure>node</Structure>
<Subscript>"render"</Subscript>
</Data>
<Data name="blockDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>blockpos</Value>
</Value>
<Value name="3">
<Value>book</Value>
</Value>
<Value name="4">
<Value>component</Value>
</Value>
<Value name="5">
<Value>container</Value>
</Value>
<Value name="6">
<Value>id</Value>
</Value>
<Value name="7">
<Value>lang</Value>
</Value>
<Value name="8">
<Value>lastchange</Value>
</Value>
<Value name="9">
<Value>role</Value>
</Value>
<Value name="10">
<Value>sourcefile</Value>
</Value>
<Value name="11">
<Value>sourcetime</Value>
</Value>
<Value name="12">
<Value>status</Value>
</Value>
<Value name="13">
<Value>title</Value>
</Value>
<Value name="14">
<Value>attrgiven</Value>
</Value>
<Value name="15">
<Value>tagattrs</Value>
</Value>
<Value name="16">
<Value>remap</Value>
</Value>
</Data>
<DataLocation>^DocBook.blockD</DataLocation>
<DefaultData>blockDefaultData</DefaultData>
<ExtentSize>10000000</ExtentSize>
<IdLocation>^DocBook.blockD</IdLocation>
<IndexLocation>^DocBook.blockI</IndexLocation>
<Property name="blockpos"/>
<Property name="book"/>
<Property name="component"/>
<Property name="container"/>
<Property name="content"/>
<Property name="id"/>
<Property name="lang"/>
<Property name="lastchange"/>
<Property name="remap"/>
<Property name="renderedContent"/>
<Property name="role"/>
<Property name="sourcefile"/>
<Property name="sourcetime"/>
<Property name="status"/>
<Property name="tagattrs"/>
<Property name="title"/>
<StreamLocation>^DocBook.blockS</StreamLocation>
<Type>%CacheStorage</Type>
}

}
