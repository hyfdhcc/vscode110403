Include DocBookMac

/// An XML parser for DocBook.
Class DocBook.DocBookParser Extends %XML.SAX.ContentHandler [ ClassType = "", ProcedureBlock ]
{

///  Pointer to element and element counter stack
Property ElPtr As dbint [ Private ];

///  Element Stack
Property ElStack As cdata [ MultiDimensional ];

///  Object Stack
Property ObjStack As block [ MultiDimensional ];

/// Pointer to object stack.
Property ObjPtr As dbint [ Private ];

/// Current set object
Property CurrSet As set;

/// Current book object
Property CurrBook As book;

/// Current component object
Property CurrComponent As component;

/// Current text being gathered.
Property CurrText As cdata [ Private ];

/// True if we are processing a mixed content element
Property HasInline As %Boolean [ Private ];

/// Name of file being processed.
Property SourceFile As cdata;

/// Timestamp of file being processed.
Property SourceTime As %TimeStamp;

/// Internal element counter
Property ElCount As %Integer [ Private ];

/// Entity flag
Property InEntity As %Boolean [ Private ];

/// In a Block flag; contains name of block element
Property InBlock As %String(TRUNCATE = 1) [ Private ];

/// Comma-separated list of tags we are prepared to handle
Property KnownTags As %String(MAXLEN = 4096, TRUNCATE = 1) [ Private ];

/// Holds names of all elements allowed to have ID attributes
Property IDValid As %String(TRUNCATE = 1) [ Private ];

/// Holds element names which are "block"
Property BlockElements As %String(TRUNCATE = 1) [ Private ];

/// Hold element names which are "container"
Property ContainerElements As %String(TRUNCATE = 1) [ Private ];

/// Hold element names which are "meta"
Property MetaElements As %String(TRUNCATE = 1) [ Private ];

/// Holds entity names not to be used
Property DeprecatedEntities As %String(TRUNCATE = 1) [ Private ];

/// Permitted architecture values
Property Architectures As %String(TRUNCATE = 1) [ Private ];

/// Turns on some tracing info when true
Property TraceValue As %Integer [ Private ];

/// Tracing test values
Property TraceBgnElm As %Integer [ InitialExpression = 1, Private ];

Property TraceEndElm As %Integer [ InitialExpression = 2, Private ];

Property TraceBgnEnt As %Integer [ InitialExpression = 4, Private ];

Property TraceEndEnt As %Integer [ InitialExpression = 8, Private ];

Property TraceIgnore As %Integer [ InitialExpression = 16, Private ];

Property TraceText As %Integer [ InitialExpression = 32, Private ];

Property TraceWork As %Integer [ InitialExpression = 64, Private ];

/// Turns on added checking for PDF production
Property PDFChecking As %Integer [ Private ];

/// Turns on load of reviewer comments and questions into the database
Property InclRemark As %Integer [ Private ];

/// Turns on added checking for entity usage
Property EntityCheck As %Integer [ Private ];

Parameter MAXLINE = 120;

Method %OnClose() As %Status [ Internal ]
{
    // clean up object stack
    While (..ObjPtr > 0) {
        Set i%ObjStack(..ObjPtr) = ""
        Set ..ObjPtr = ..ObjPtr - 1
    }

    Quit $$$OK
}

/// Error handler
Method fatalError(fatalerror As %Library.String) [ Internal ]
{
    Write !,$$$T("SAX Fatal Error (a document could not be loaded): "),fatalerror,!

    Do ##class(ErrorLog).AddError(..SourceFile, "SAX fatal", fatalerror)
}

Method error(error As %Library.String) [ Internal ]
{
    Write !,$$$T("SAX Error (a document could not be loaded): "),error,!

    Do ##class(ErrorLog).AddError(..SourceFile, $$$T("SAX error"), error)
}

/// converts an element name into a "category" type
Method GetElementType(localname As cdata) [ Internal, Private ]
{

    Quit:(localname = "") ""

    Set test = "," _ localname _ ","
    Quit:(..MetaElements [ test) "meta"
    Quit:(..ContainerElements [ test) "container"
    Quit:(..BlockElements [ test) "block"
    Quit ""
}

/// Returns a formatted start tag for the given element and attr values
Method GetTag(localname As cdata, attrs As %Library.List) As cdata [ Internal, Private ]
{

    Set attrstring = ..GetAttrPairs(attrs)
    If (attrstring '= "")
    {
        Set tag = "<" _ localname _ " " _ attrstring _ ">"
    }
    Else
    {
        Set tag = "<" _ localname _ ">"
    }
    Quit tag
}

/// Returns a formatted string of the attribute values
Method GetAttrPairs(attrs As %Library.List) As cdata [ Internal, Private ]
{

    Set result = ""
    For i = 1:5:$LL(attrs) {
        Set:(result '= "") result = result _ " "
        Set name = $LG(attrs, i+1)
        Set value = $ZCONVERT($LG(attrs, i+4), "O", "HTML")
        Set result = result _ name _ "=""" _ value _ """"
    }

    Quit result
}

/// Test if condition is true, else write an error
Method Assert(cond As %Boolean, msg As cdata = "") As %Boolean [ Internal ]
{
    If ('cond)
    {
        Set lin = 0
        Set pos = 0
        Do ..LocatePosition(.lin, .pos)
        Set assertion = $$$T("----- Assertion Check: ")
                      _ msg
                      _ $$$T(" at line ")
                      _ lin
                      _ $$$T(" offset ")
                      _ pos
        Write assertion ,!
        Quit 0
    }
    Quit 1
}

/// Test if condition is true, else write an error
Method Trace(flag As %Integer) As %Boolean [ Internal, Private ]
{
    Quit:($ZBOOLEAN(+(..TraceValue), +(flag), 1)) 1
    Quit 0
}

/// Test if condition is true, else write an error
Method IsKnown(name As %String) As %Boolean [ Internal, Private ]
{
    Set SearchString = "," _ name _ ","
    Quit:(..KnownTags [ SearchString) 1
    Quit 0
}

/// Converts list of attrs into an array keyed by attr name
Method UnpackAttrs(attrs As %List, ByRef array As cdata) [ Internal, Private ]
{

    ;
    ; Format of the attribute list
    ; A sequence of 5-element chunks as follows:
    ; +0 - the uri
    ; +1 - local (unqualified) name
    ; +2 - qualified name
    ; +3 - the type ("CDATA", NMTOKEN", "ENTITY", etc.)
    ; +4 - the attribute value.
    ;
    For i = 1:5:$LL(attrs) {
        If ($LG(attrs,i+1) '= "") {
            Set array($LG(attrs,i+1)) = $LG(attrs,i+4)
        }
    }
}

/// Make sure the ID value is appropriate for the file
Method ValidateID(IDchars As %String, Filename As %String) As %Boolean [ Internal, Private ]
{
    ; empty id values are ok
    Quit:(IDchars = "") 1

    ; SET checks always succeed
    Quit:($ZCONVERT($EXTRACT(Filename, 1, 3), "U") = "SET") 1

    ; check for match up through first "." or "_"
    Set prefix = $PIECE($PIECE(Filename, ".", 1), "_", 1)
    Set len = $LENGTH(prefix)
    Quit ($EXTRACT(IDchars, 1, len) = prefix)
}

/// Check for proper usage of this entity
Method CheckEntity(entityname As %String) As %Boolean [ Internal, Private ]
{
    Set NE = $$$T("Numeric entity")
    Set DE = $$$T("Deprecated entity")

    ; check for numeric entities
    Do ..Assert(($EXTRACT(entityname, 1, 1) '= "#"), (NE _ " - " _ entityname))

    ; check for deprecated entities
    Do ..Assert((..DeprecatedEntities '[ ("," _ entityname _ ",")),
                (DE _ " - " _ entityname))

    Quit
}

/// Check for excessively long strings
Method CheckCharsLen(newchars As %String) [ Internal, Private ]
{
    Set boundary = 28000
    Set newlength = $LENGTH(..CurrText) + $LENGTH(newchars)
    Do ..Assert((newlength <= boundary),
                ($$$T("Aggregate text length may cause translation error: ") _ newlength _ " > " _boundary))
    Quit
}

Method startDocument() [ Internal ]
{
    ; Write !
    Set ..ElPtr = 0
    Set ..ObjPtr = 0

    Set ..CurrText = ""
    Set ..HasInline = 0
    Set ..CurrBook = ""
    Set ..CurrSet = ""
    Set ..CurrComponent = ""
    Set ..ElCount = 0
    Set ..InEntity = 0
    Set ..InclRemark = 0
    Set ..PDFChecking = 0
    Set ..EntityCheck = 0
    Set ..TraceValue = 0
    Set ..InBlock = ""

    ; use of "+" in next line guarantees integer conversion
    Set ..TraceValue = ##class(DocBook.ConfigUtils).GetTRACE()
    if (..TraceValue '= 0)
    {
        Write !, "Tracing: ", ..TraceValue, !
    }
    Set ..PDFChecking = ##class(DocBook.ConfigUtils).GetPDFCHECK()
    ; ignore PDF checking for tutorials
    ; Set:($ZCONVERT($EXTRACT(..SourceFile, 1, 1), "U") = "T") ..PDFChecking = 0

    Set ..InclRemark = ##class(DocBook.ConfigUtils).GetINCLREMARK()

    Set ..EntityCheck = ##class(DocBook.ConfigUtils).GetENTITYCHECK()

    Set ..KnownTags = ",abstract"
                    _ ",anchor"
                    _ ",answer"
                    _ ",appendix"
                    _ ",application"
                    _ ",artheader"
                    _ ",article"
                    _ ",book"
                    _ ",bookinfo"
                    _ ",caution"
                    _ ",chapter"
                    _ ",citation"
                    _ ",citetitle"
                    _ ",classname"
                    _ ",colspec"
                    _ ",command"
                    _ ",emphasis"
                    _ ",entry"
                    _ ",envar"
                    _ ",errorcode"
                    _ ",errorname"
                    _ ",example"
                    _ ",figure"
                    _ ",filename"
                    _ ",firstterm"
                    _ ",formalpara"
                    _ ",function"
                    _ ",glossary"
                    _ ",glossdef"
                    _ ",glossentry"
                    _ ",glosslist"
                    _ ",glosssee"
                    _ ",glossterm"
                    _ ",graphic"
                    _ ",guibutton"
                    _ ",guiicon"
                    _ ",guilabel"
                    _ ",guimenu"
                    _ ",guimenuitem"
                    _ ",guisubmenu"
                    _ ",important"
                    _ ",indexterm"
                    _ ",informaltable"
                    _ ",inlinegraphic"
                    _ ",itemizedlist"
                    _ ",interface"
                    _ ",keycap"
                    _ ",keycode"
                    _ ",link"
                    _ ",listitem"
                    _ ",literal"
                    _ ",literallayout"
                    _ ",methodname"
                    _ ",note"
                    _ ",olink"
                    _ ",orderedlist"
                    _ ",para"
                    _ ",part"
                    _ ",partintro"
                    _ ",preface"
                    _ ",primary"
                    _ ",productname"
                    _ ",programlisting"
                    _ ",prompt"
                    _ ",property"
                    _ ",qandaset"
                    _ ",qandadiv"
                    _ ",qandaentry"
                    _ ",question"
                    _ ",quote"
                    _ ",refdescriptor"
                    _ ",refentry"
                    _ ",refentrytitle"
                    _ ",reference"
                    _ ",refmeta"
                    _ ",refname"
                    _ ",refnamediv"
                    _ ",refpurpose"
                    _ ",refsect1"
                    _ ",refsect2"
                    _ ",refsect3"
                    _ ",refsect4"
                    _ ",refsynopsisdiv"
                    _ ",remark"
                    _ ",replaceable"
                    _ ",row"
                    _ ",secondary"
                    _ ",sect1"
                    _ ",sect2"
                    _ ",sect3"
                    _ ",sect4"
                    _ ",see"
                    _ ",seealso"
                    _ ",set"
                    _ ",subscript"
                    _ ",subtitle"
                    _ ",superscript"
                    _ ",synopsis"
                    _ ",systemitem"
                    _ ",table"
                    _ ",tbody"
                    _ ",term"
                    _ ",tertiary"
                    _ ",tgroup"
                    _ ",thead"
                    _ ",tip"
                    _ ",title"
                    _ ",type"
                    _ ",ulink"
                    _ ",userinput"
                    _ ",varname"
                    _ ",warning"
                    _ ","

    Set ..IDValid = ",article"
                  _ ",anchor"
                  _ ",appendix"
                  _ ",book"
                  _ ",chapter"
                  _ ",example"
                  _ ",figure"
                  _ ",glossary"
                  _ ",glossentry"
                  _ ",part"
                  _ ",preface"
                  _ ",refentry"
                  _ ",reference"
                  _ ",refsect1"
                  _ ",refsect2"
                  _ ",refsect3"
                  _ ",refsect4"
                  _ ",sect1"
                  _ ",sect2"
                  _ ",sect3"
                  _ ",sect4"
                  _ ",set"
                  _ ",table"
                  _ ","

    Set ..BlockElements = ",anchor"
                        _ ",informaltable"
                        _ ",literallayout"
                        _ ",programlisting"
                        _ ",refdescriptor"
                        _ ",refname"
                        _ ",refpurpose"
                        _ ",remark"
                        _ ",synopsis"
                        _ ",table"
                        _ ","

    Set ..ContainerElements = ",abstract"
                            _ ",answer"
                            _ ",artheader"
                            _ ",article"
                            _ ",appendix"
                            _ ",book"
                            _ ",bookinfo"
                            _ ",caution"
                            _ ",chapter"
                            _ ",example"
                            _ ",figure"
                            _ ",formalpara"
                            _ ",glossary"
                            _ ",glossentry"
                            _ ",glossdef"
                            _ ",glosslist"
                            _ ",important"
                            _ ",itemizedlist"
                            _ ",listitem"
                            _ ",note"
                            _ ",orderedlist"
                            _ ",para"
                            _ ",part"
                            _ ",partintro"
                            _ ",preface"
                            _ ",qandaset"
                            _ ",qandadiv"
                            _ ",qandaentry"
                            _ ",question"
                            _ ",refentry"
                            _ ",reference"
                            _ ",refnamediv"
                            _ ",refsect1"
                            _ ",refsect2"
                            _ ",refsect3"
                            _ ",refsynopsisdiv"
                            _ ",sect1"
                            _ ",sect2"
                            _ ",sect3"
                            _ ",sect4"
                            _ ",set"
                            _ ",tip"
                            _ ",warning"
                            _ ","

    Set ..MetaElements = ",glossterm"
                       _ ",refmeta"
                       _ ",refentrytitle"
                       _ ",subtitle"
                       _ ",title"
                       _ ","

    Set ..DeprecatedEntities = ",mldr"
                             _ ","

    Set ..Architectures = ",cache"
                        _ ",ensemble"
                        _ ",hsfoundation"
                        _ ",healthshare"
                        _ ",hsfoundation"
                        _ ",trakcare"
                        _ ",intersystems"
                        _ ",internal"
                        _ ",tutorial"
                        _ ","

    Quit
}

Method endDocument() [ Internal ]
{
    Quit
}

Method characters(chars As %Library.String, length As %Library.Integer) [ Internal ]
{
    // gather up text
    If ('(..InEntity))
    {
        // escape any incoming special characters
        // as SAX has already converted them
        Write:($ZB(..TraceValue, ..TraceText, 1)) !, "GATHER: ", chars
        Set newchars = $ZCVT(chars, "O", "HTML")
        Do ..CheckCharsLen(newchars)
        Set ..CurrText = ..CurrText _ newchars
    }
    Quit
}

Method startEntity(name As %String) [ Internal ]
{
    // add entity to current text
    Set ..InEntity = 1
    Set ElementName = "&" _ name _ ";"
    if (..Trace(..TraceBgnEnt))
    {
        if (ElementName '= "&[dtd];")
        {
            Write:(..Trace(..TraceBgnEnt)) !, "BgnEnt: ", ElementName
        }
    }
    Quit
}

Method endEntity(name As %String) [ Internal ]
{
    // add entity to current text
    Set ..InEntity = 0
    Set ElementName = "&" _ name _ ";"
    if (..Trace(..TraceEndEnt))
    {
        if (ElementName '= "&[dtd];")
        {
            Write:(..Trace(..TraceEndEnt)) !, "EndEnt: ", ElementName
        }
    }
    Do ..CheckCharsLen(ElementName)
    Set ..CurrText = ..CurrText _ ElementName
    Do:(..EntityCheck) ..CheckEntity(name)

    Quit
}

Method startElement(uri As %Library.String, localname As %Library.String, qname As %Library.String, attrs As %Library.List) [ Internal ]
{

    Set $ZT="seERR"

    // feedback
    if (..Trace(..TraceWork))
    {
        If ( (..ElCount # 25) = 0) {
            Write "."
        }
        If ( (..ElCount # (25*60)) = 0) {
            Write !
        }
    }

    ; check the element tag name
    do ..Assert(..IsKnown(localname), ($$$T("Unsupported tag: ") _ "<" _ localname _ ">"))

    Set ..ElCount = ..ElCount + 1

    Write:(..Trace(..TraceBgnElm)) !,?..ElPtr,"<",localname,"> "

    // Check structural issues
    if (..ElPtr > 0)
    {
        Set GrandParentTag = "?"
        Set:(..ElPtr > 1) GrandParentTag = (..ElStack(..ElPtr - 1))

        Set ParentTag = (..ElStack(..ElPtr))
        Set ChildTag = localname
        Set GrandParentMatch = ("/" _ GrandParentTag _ "/")
        Set ParentMatch = ("/" _ ParentTag _ "/")
        Set ChildMatch = ("/" _ ChildTag _ "/")

        If (("/glossdef/" [ GrandParentMatch) && ("/para/" [ ParentMatch) && ("/caution/important/note/warning/" [ ChildMatch))
        {
            // Allow it
        }
        ElseIf ("/itemizedlist/orderedlist/programlisting/literallayout/remark/caution/important/note/warning/" [ ChildMatch)
        {
            Do ..Assert((ParentMatch '[ "/para/"),
                        ($$$T("Tag nesting") _ " - " _ ParentTag _ " / " _ ChildTag))
        }

        If ("/graphic/" [ ChildMatch)
        {
            Do ..Assert(("/figure/entry/para/" [ ParentMatch),
                        ($$$T("Tag nesting") _ " - " _ ParentTag _ " / " _ ChildTag))
        }
    }

    // push element
    Set ..ElPtr = ..ElPtr + 1
    Set ..ElStack(..ElPtr) = localname

    Do ..UnpackAttrs(attrs,.arr)

    // special attribute handling
    If (..ElPtr = 1)
    {
        If ((localname = "book") || (localname = "article"))
        {
            Set product = $G(arr("arch"), "")
            If ($LENGTH(product) = 0)
            {
                Do ..Assert(0, "Attribute ""arch"" missing; 'intersystems' assumed")
                Set product = "intersystems"
                Set attrs = attrs _ $LISTBUILD("", "arch", "arch", "CDATA", product)
                Set arr("arch") = product
            }
            if (..Architectures '[ ("," _ product _ ","))
            {
                Do ..Assert(0, "Attribute ""arch"" invalid: " _ product)
                Set product = "intersystems"
                For i = 1 : 5 : $LISTLENGTH(attrs)
                {
                    If ($LIST(attrs, (i + 1)) = "arch")
                    {
                        Set $LIST(attrs, (i + 4)) = product
                        Quit
                    }
                }
            }
            Else
            {
                Set ^DocBook.Config("ARCHITECTURES", $ZCONVERT(product, "U")) = 1
            }
            Set version = $G(arr("revision"), "")
            Do ..Assert(($LENGTH(version) = 0), ("Revision defined: " _ """" _ version _ """"))
        }
        If ((localname = "book") || (localname = "set"))
        {
            Set remap = $G(arr("remap"), "")
            If ($LENGTH(remap) = 0)
            {
                Do ..Assert(0, "Attribute ""remap"" value missing")
            }
            Else
            {
                If ('(remap?3N1"_"3N1"_"1.E))
                {
                    Do ..Assert(0, "Attribute ""remap"" formatted incorrectly")
                }
            }
        }
    }
    // in case of updates
    Do ..UnpackAttrs(attrs,.arr)

    // get outer elements
    If (..ElPtr > 1) {
        Set outer = $G(..ElStack(..ElPtr - 1))
    }
    Else {
        Set outer = ""
    }

    Set type = ..GetElementType(localname)
    Set outtype = ..GetElementType(outer)

    // Only accept id values for these elements; ignore all others
    Set key = $G(arr("id"))
    Do ..Assert(..ValidateID(key, ..SourceFile),
                ("ID/Filename mismatch: """ _ key _ """ vs " _ ..SourceFile))
    If (..IDValid '[ (","_localname_",")) {
        Set key = ""
    }

    If (..InBlock '= "")
    {
        If ((type = "container") || (type = "block"))
        {
            Do ..Assert(($LENGTH(..CurrText) > 0), ($$$T("Possible text loss in tag ") _ localname))
        }
    }

    If ((..InBlock = "") && (type = "container")) {

        // Create container instance
        // If id matches existing item, update
        Set id = ##class(DocBook.container).FindId(key)
        Set class = "DocBook." _ localname
        Set ReUseElement = 0

        If (id = "") {
            // insert
            Set container = $CLASSMETHOD(class,"%New")
            Set container.id = key
        }
        Else {
            // update
            Set ReUseElement = 1
            Write:(..Trace(..TraceWork)) !,"Updating container: ",key,!

            // first delete contents of container
            Do ##class(DocBook.container).DeleteDependents(id, ..Trace(..TraceWork))

            Write:(..Trace(..TraceWork)) !

            // open existing container
            Set container = ##class(DocBook.container).%OpenId(id)
            // reset counter for container
            Set container.lastChildPos = 0
        }

        Set container.tagattrs = attrs
        Set container.sourcefile = ..SourceFile
        Set container.sourcetime = ..SourceTime
        Set container.lang = $G(arr("lang"))
        Set container.role = $G(arr("role"))
        Set container.remap = $G(arr("remap"))
        Set container.status = $G(arr("status"))

        // set up pointer to parent
        If ((..ObjPtr > 0) && (outtype = "container")) {
            If (localname = "partintro") {
                If (i%ObjStack(..ObjPtr).%ClassName() = "part") {
                    // set up link to partintro
                    Set i%ObjStack(..ObjPtr).intro = container
                }
                Else {
                    Set container.container = i%ObjStack(..ObjPtr)
                    If (container.container '= "") {
                        // set up block pos
                        Set container.blockpos = container.container.lastChildPos
                        Set container.container.lastChildPos = container.container.lastChildPos + 1
                    }
                }
            }
            Else {
                Set container.container = i%ObjStack(..ObjPtr)
                If (container.container '= "") {
                    // set up block pos
                    Set container.blockpos = container.container.lastChildPos
                    Set container.container.lastChildPos = container.container.lastChildPos + 1
                }
            }
        }

        // set up book pointer
        If (localname = "book") {
            // we are the book
            Set ..CurrBook = container
            If (..CurrSet '= "") {
                Set container.set = ..CurrSet
            }
        }
        ElseIf (localname = "set") {
            // we are the set
            Set ..CurrSet = container
        }
        ElseIf (container.book = "") {
            Set container.book = ..CurrBook
        }
        ElseIf (..CurrBook = "") {
            Set ..CurrBook = container.book
        }

        // set up pointer to component
        If ((localname = "chapter")
             || (localname = "appendix")
             || (localname = "refentry")
             || (localname = "preface")
             || (localname = "article")
             || (localname = "reference"))
        {
            // we are the component
            Set ..CurrComponent = container
        }
        Else
        {
            If (ReUseElement = 0)
            {
                Set container.component = ..CurrComponent
            }
        }

        // reset text
        Set ..CurrText = ""

        // push block
        Set ..ObjPtr = ..ObjPtr + 1
        Set i%ObjStack(..ObjPtr) = container
    }
    ElseIf ((..InBlock = "") && (type = "block")) {
        // create block instance
        Set class = "DocBook." _ localname
        Set block = $CLASSMETHOD(class,"%New")
        Set block.id = key
        Set block.tagattrs = attrs
        Set block.sourcefile = ..SourceFile
        Set block.sourcetime = ..SourceTime
        Set block.lang = $G(arr("lang"))
        Set block.role = $G(arr("role"))
        Set block.remap = $G(arr("remap"))
        Set block.status = $G(arr("status"))

        If ((..ObjPtr > 0) && (outtype = "container")) {
            // set up pointer to parent
            Set block.container = i%ObjStack(..ObjPtr)

            // set blockpos
            If (block.container '= "") {
                Set block.blockpos = block.container.lastChildPos
                Set block.container.lastChildPos = block.container.lastChildPos + 1
            }

        }
        If (..CurrBook '= "") {
            Set block.book = ..CurrBook
        }
        If (..CurrComponent '= "") {
            Set block.component = ..CurrComponent
        }

        // special attr handling for tables
        If ((localname = "table") || (localname = "informaltable")) {
            Set block.frame = $G(arr("frame"))
            Set block.colsep = $G(arr("colsep"))
            If ('(##class(DocBook.ConfigUtils).GetSUPPRESSFRAMEWARNING())) {
                Do ..Assert(($LENGTH(block.frame) > 0), ($$$T("Missing value for ""frame"" attribute on ") _ localname _ $$$T(" element")))
            }
        }

        // push block
        Set ..ObjPtr = ..ObjPtr + 1
        Set i%ObjStack(..ObjPtr) = block
        Set ..CurrText = ""

        Set ..InBlock = localname
    }
    ElseIf (type = "meta") {
        Set ..CurrText = ""
    }
    Else {
        // append element to current text
        Set addendum = ..GetTag(localname,attrs)
        Do ..CheckCharsLen(addendum)
        Set ..CurrText = ..CurrText _ addendum
        If ((localname = "graphic") || (localname = "inlinegraphic"))
        {
            Set imagedir = $G(arr("fileref"), "Missing")
        }
    }

    Quit
seERR
    Set $ZT=""
    If $TLEVEL TROLLBACK
    Write $$$T("ERROR in startElement(): "),$ZE,!
    QUIT
}

Method endElement(uri As %Library.String, localname As %Library.String, qname As %Library.String) [ Internal ]
{

    Set $ZT="eeERR"

    ; check the element tag name
    do ..Assert(..IsKnown(localname), ($$$T("Unsupported tag: ") _ "</" _ localname _ ">"))

    If (localname = "entry")
    {
        Set test = ..CurrText
        ;Write $ZCONVERT(test, "O", "HTML"), !
        If ($EXTRACT(test, $LENGTH(test)) = ">") {
            Set tagbgn = $FIND($REVERSE(test), "<")
            Set tagbgn = $LENGTH(test) - tagbgn + 3
            Set tagend = tagbgn + $LENGTH("entry") - 1
            ;Write "Tag:  ", tagbgn, ":", tagend, "<", $LENGTH(test), !
            Set test = $EXTRACT(test, tagbgn, tagend)
            ;Write "Text: ", $ZCONVERT(test, "O", "HTML"), !
            If (test = "entry") {
                // assure cell non-empty
                ;Write "Matched", !
                Do ..CheckCharsLen("&nbsp;")
                Set ..CurrText = ..CurrText _ "&nbsp;"
            }
        }
    }

    // get outer element
    If (..ElPtr > 1)
    {
        Set outer = $G(..ElStack(..ElPtr - 1))
    }
    Else
    {
        Set outer = ""
    }

    Set outtype = ..GetElementType(outer)
    Set type = ..GetElementType(localname)

    If ((localname = "title") && (outtype = "container"))
    {
        If (..ObjPtr > 0 )
        {
            Set obj = i%ObjStack(..ObjPtr)
            Set obj.title = ..CurrText
            Set ..CurrText = ""
        }
    }
    ElseIf ((localname = "subtitle") && (outtype = "container"))
    {
        If (..ObjPtr > 0 )
        {
            Set obj = i%ObjStack(..ObjPtr)
            Set obj.subtitle = ..CurrText
            Set ..CurrText = ""
        }
    }
    ElseIf ((..InBlock = "") && (type = "container"))
    {
        If (..ObjPtr > 0 )
        {
            Set obj = i%ObjStack(..ObjPtr)

            Set obj.content = ..CurrText
            Set ..CurrText = ""
            If (obj.id = "")
            {
                // assign a key to this container
                Set obj.id = $S(..CurrBook'="":..CurrBook.id,1:"NA") _ "_C" _ $I(^DocBook.blockID)
            }
            Set sc = obj.%Save()
            If ($system.Status.IsError(sc))
            {
                Set ErrText = $SYSTEM.Status.GetErrorText(sc)
                Do ..LocatePosition(.lin, .pos)
                Set Location = $$$T("line ")
                               _ lin
                               _ $$$T(" offset ")
                               _ pos
                Write ErrText _ " @" _ Location ,!
            }

            // if needed-clean up local pointer
            If (localname = "book")
            {
                Set ..CurrBook = ""
            }
            ElseIf (localname = "set")
            {
                Set ..CurrSet = ""
            }
            ElseIf ((localname = "chapter") || (localname = "appendix") || (localname = "refentry") || (localname = "article"))
            {
                Set ..CurrComponent = ""
            }

            // pop object stack
            Set i%ObjStack(..ObjPtr) = ""
            Set ..ObjPtr = ..ObjPtr - 1
        }
    }
    ElseIf ((type = "block") && (..InBlock = localname))
    {
        If (..ObjPtr > 0 )
        {
            Set obj = i%ObjStack(..ObjPtr)


            If (localname = "remark")
            {
                Set obj.remarkContent = ..CurrText
                Set obj.InclRemark = ..InclRemark
                Set ..CurrText = ""
            }

            Set obj.content = ..CurrText
            Set ..CurrText = ""

            If (obj.id = "")
            {
                // assign a key to this block
                Set obj.id = $S(..CurrBook'="":..CurrBook.id,1:"NA") _ "_B" _ $I(^DocBook.blockID)
            }

            If (..PDFChecking)
                {
                    If ((localname = "programlisting") || (localname = "literallayout"))
                    {

                        ; check for the presence of tab characters
                        Do ..Assert((obj.content '[ $CHAR(9)), ($$$T("Tab chars found in ") _ localname))

                        ; check for the presence of &nbsp;
                        Do ..Assert((obj.content '[ "&nbsp;"), ($$$T("Non-breaking space entities found in ") _ localname))

                        ; look for lines that are too long
                        Set pos = 0
                        Set i = 1
                        While (i <= $LENGTH(obj.content))
                        {
                            Set ch = $EXTRACT(obj.content, i)
                            ; tab character
                            If (ch = $char(9))
                            {
                                Set oldpos = pos
                                Set pos = pos + 8
                                Set pos = (pos \ 8) * 8
                                ; make temp copy to avoid screwing up the object
                                Set text = obj.content
                                Set $EXTRACT(text, i) = $EXTRACT("          ", 1, (pos - oldpos + 1))
                                Set obj.content = text
                                ;Write "Tab @ ", oldpos, " -> ", pos, !
                            }
                            ; carriage return or line feed (newline)
                            If ((ch = $CHAR(13)) || (ch = $CHAR(10)))
                            {
                                ; check for prior line too long
                                If (pos > ..#MAXLINE)
                                {
                                    quit
                                }
                                Set pos = 0
                            }
                            ; entity
                            If (ch = "&")
                            {
                                For j = 1 : 1 : 9
                                {
                                    Set ch = $EXTRACT(obj.content, (i + j))
                                    If (ch = ";")
                                    {
                                        quit
                                    }
                                }
                                Set i = i + j
                            }
                            ; update position
                            Set i = i + 1
                            Set pos = pos + 1
                        }
                        do ..Assert((pos <= ..#MAXLINE), ($$$T("Long line found in ") _ localname))
                    }
                }

            If (localname = "programlisting")
            {
                // pre-render syntax colored code
                Set errmsg = obj.Colorize()
                If (errmsg '= "") {
                    // log syntax error
                    Do ##class(ErrorLog).AddError(..SourceFile, $$$T("syntax"), errmsg, obj.id)
                }
                Else
                {
                    If (($LENGTH(obj.content) + $LENGTH(obj.renderedContent)) > 29999)
                    {
                        Do ..Assert(0, $$$T("Max length exceeded; programlisting color suppressed"))
                        Set obj.renderedContent = ""
                    }
                }
            }

            If (localname = "anchor")
            {
                Set sc = obj.Interpret()
                If $SYSTEM.Status.IsError(sc)
                {
                    Do ##class(ErrorLog).AddError(..SourceFile, $$$T("normalize"), $SYSTEM.Status.GetErrorText(sc), obj.id)
                }
                Set ref = obj.id
                Set lastchr = $EXTRACT(ref, *)
                Set suffix = "_anchor"
                If ("0123456789" [ lastchr)
                {
                    Set suffix = suffix _ lastchr
                }
                Set reflen = $LENGTH(ref)
                Do ..Assert(($EXTRACT(ref, (reflen - $LENGTH(suffix) + 1), reflen) = suffix),
                             ($$$T("Anchor id is malformed: ") _ ref))
            }

            Set sc = obj.%Save()
            If ($system.Status.IsError(sc))
            {
                Set ErrText = $SYSTEM.Status.GetErrorText(sc)
                Do ..LocatePosition(.lin, .pos)
                Set Location = $$$T("line ")
                               _ lin
                               _ $$$T(" offset ")
                               _ pos
                Write ErrText _ " @" _ Location ,!
            }

            Set ..HasInline = 0

            // pop object stack
            Set i%ObjStack(..ObjPtr) = ""
            Set ..ObjPtr = ..ObjPtr - 1
            Set ..InBlock = ""
        }
    }
    ElseIf ((localname = "refentrytitle") && (outer = "refmeta"))
    {
        If (..ObjPtr > 0 ) {
            Set obj = i%ObjStack(..ObjPtr)
            // !!! place refentry title in 2 places!
            Set obj.title = ..CurrText
            Set obj.refmeta.refentrytitle = ..CurrText
            Set ..CurrText = ""
        }
    }
    ElseIf ((localname = "glossterm") && (outer = "glossentry"))
    {
        If (..ObjPtr > 0 ) {
            Set obj = i%ObjStack(..ObjPtr)
            Set obj.glossterm = ..CurrText
            Set ..CurrText = ""
        }
    }
    ElseIf ((localname = "title") && (outer = "table"))
    {
        // title for a table
        If (..ObjPtr > 0 ) {
            Set obj = i%ObjStack(..ObjPtr)
            Set obj.title = ..CurrText
            Set ..CurrText = ""
        }
    }
   Else
   {
        // append closing tag to currtext\
        Set addendum = "</" _ localname _ ">"
        Do ..CheckCharsLen(addendum)
        Set ..CurrText = ..CurrText _ addendum
    }

    // pop element stack
    Set ..ElPtr = ..ElPtr - 1
    Write:(..Trace(..TraceEndElm)) !,?..ElPtr,"</",localname,"> "
    Quit

eeERR
    Set $ZT=""
    If $TLEVEL TROLLBACK
    Write $$$T("ERROR in endElement(): "),$ZE,!
    QUIT
}

}
