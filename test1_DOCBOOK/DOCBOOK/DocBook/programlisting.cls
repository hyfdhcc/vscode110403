Include DocBookMac

/// Represents a programming example.
Class DocBook.programlisting Extends DocBook.block [ ClassType = persistent, ProcedureBlock ]
{

/// If there is a syntax error in this programlisting, this is true
Property syntaxError As %Boolean;

/// This is the value of $ZERROR is the coloring failed
Property errorInfo As cdata;

/// This is the value of "lang" when an error is reported
Property errorLang As cdata;

Method HTMLRenderContent() [ Internal ]
{

    Set mt = ""
    //Set:(%ie||%ie6) mt = "oncontextmenu=""if (!event.ctrlKey){showContextMenu();return false;} else {menu1.style.display='none'}"""

    Set lang = $ZCVT($P(..lang,":",1),"U")
    If (lang = "COS") {
        Set lang = "ObjectScript"
    }
    ElseIf (lang = "BAS") {
        Set lang = "Basic"
    }
    ElseIf (lang = "JAVASCRIPT") {
        Set lang = "JavaScript"
    }
    ElseIf (lang = "CSP") {
        Set lang = "CSP"
    }
    ElseIf (lang = "XML") {
        Set lang = "XML"
    }
    ElseIf (lang = "XML!FRAGMENT") {
        Set lang = "XML!FRAGMENT"
    }
    ElseIf (lang = "HTML") {
        Set lang = "HTML"
    }
    ElseIf (lang = "SQL") {
        Set lang = "SQL"
    }
    ElseIf (lang = "TSQL") {
        Set lang = "TSQL"
    }
    ElseIf (lang [ "CLS") {
        Set lang = "Cache Class Definition Syntax"
    }
    ElseIf (lang [ "JAVA") {
        Set lang = "Java"
    }
    Else {
        Set lang = ""
    }
    
    Set:lang'="" lang = "This example uses " _ lang _ "."
    // neuter hover text
    Set lang=""

    Write "<DIV CLASS=""programlisting"" TITLE=""",lang,""" TEXTID=""",..id,""" ",mt,">"
    Write "<A name=""",..id,"""></A>",!
    If (..renderedContent = "") {
        Write "<PRE>",..content,"</PRE>",!
    }
    Else {
        Write "<PRE>",..renderedContent,"</PRE>",!
    }
    
    /*
    Write "<P>"
    Write ..id
    Write "<P>"
    Write "<BR">
    */
    If (($ZCVT($P(..lang,":",2),"U")="RUN") && $ZUTIL(90, 10, "SAMPLES")) {
        // if run flag is set, and SAMPLES exists, show button
        Write "<DIV ALIGN=""right"">"
        Write "<FORM>"
        Write "<INPUT CLASS=""runitbutton"" TYPE=""BUTTON"" VALUE=""", $$$T("Run It"), """ onclick=""executeExample('", ..id, "');"">"
        Write "&nbsp;"
        Write "</FORM>"
        Write "</DIV>", !
    }
    Write "</DIV>",!
}

/// Generate, if appropriate, a syntax-colored 
/// version of this program listing.<BR>
/// Returns an error message (or "")
Method Colorize() As %String [ Internal ]
{

    ; Format of the attribute list
    ; A sequence of 5-element chunks as follows: 
    ; +0 - the uri
    ; +1 - local (unqualified) name
    ; +2 - qualified name
    ; +3 - the type ("CDATA", NMTOKEN", "ENTITY", etc.)
    ; +4 - the attribute value.
    ;
    Set ColorizerDebug = 0
    Set attrs = ..tagattrs
    For i = 1:5:$LL(attrs) {
        Set attrname = $LG(attrs,i+1)
        If (attrname '= "") {
            If (attrname = "condition") {
                Set attrvalue = $LG(attrs,i+4)
                Set:(attrvalue = "DEBUG") ColorizerDebug = 1
                }
            }
        }

    Set errmsg = ""

    // get lang name    
    Set lang = $ZCVT($P(..lang,":",1),"U")

    If (lang = "CACHE") {
        Set lang = "COS"
    }

    Set ..renderedContent = ""
    Set errString = ""
    Set ..errorLang = lang
    
    // strip out leading/trailing CRLFs (control chars)
    // Don't strip tabs
    // Set ..content = $ZSTRIP(..content,"<>C",,$C(9))

    If ((lang '= "") && (lang '= "NONE")) {
        Set cont = $ZCVT(..content,"I","HTML")
        
        Set streamIn = ##class(%GlobalCharacterStream).%New()

        // convert to CR/LF
        Set cont = $TR(cont,$C(13),"")
        For i=1:1:$L(cont,$C(10)) {
            Do streamIn.Write($P(cont,$C(10),i) _ $C(13,10))
        }
        
        Do streamIn.Rewind()
        
        Set streamOut = ##class(%GlobalCharacterStream).%New()

        Set errors = 0
        Set errString = ""
        Do ..RenderCode(..id,streamIn,lang,ColorizerDebug,streamOut,.errors,.errString)
        
        Set ..syntaxError = 0
        Set ..errorInfo = errString
        Set:(errors) ..syntaxError = 1
    
        Do streamOut.Rewind()
        Set ..renderedContent = streamOut.Read(32000)
        
        // strip again, just in case!
        Set ..renderedContent = $ZSTRIP(..renderedContent,"<>C")
    }
    Quit errmsg
}

Method RenderCode(progname As %String, streamIn As %CharacterStream, lang As %String, debugdll As %Boolean, streamOut As %AbstractStream, ByRef errors As %Boolean, ByRef errorinfo As %String) [ Internal ]
{

    Set $ZT="TrapColor"
    Set flags = "ESFNUJ"

    If (lang = "COSX") {
        // special EXACT coloring mode
        Set lang = "COS"
        Set flags = "ESF"
    }

    If lang="NONE" Goto LangNone
    
    If (debugdll)
    {
        Write $$$T("Invoking Colorizer in debug mode"),!
        Set flags = flags _ "I"
        Write $$$T("Lang: "), lang, "; ", $$$T("Flags: "), flags, !
    }

    Set synColor=##class(%Library.SyntaxColor).%New()
    Set streamHtmlOut=##class(%GlobalCharacterStream).%New()
    
    #; This will generate the colored output, if it fails (returns FALSE) then display output in plain text
    Set errors = 0
    Set errorinfo = ""
    Set colored = synColor.Color(streamIn,streamHtmlOut,lang,flags,,,.langs,.errors,.errorinfo)
    Goto:('colored) EchoInput
    
    Do streamOut.CopyFrom(streamHtmlOut)
    Goto CheckErrors
    
    #; If we get an error coloring the routine just display the plain text instead
    #; so this will handle cases where color does not work or is not installed on this platform
TrapColor      Set $ZT=""
    Write $$$T("Fault occurred in colorizer DLL"), !
    Set colored = synColor.DLLResultCode
    Write $$$T("DLLResultCode: "), $SELECT((colored'=""):colored, 1:$$$T("[not supplied]")), !
    Set errors = 1

EchoInput
    Do streamOut.Write("<!-- DLLResultCode: " _ $ZCVT(synColor.DLLResultCode, "O", "HTML") _ " -->")
    Do streamOut.Write($CHAR(13, 10))
    Do streamOut.Write("<!-- ErrorInfo: " _ $ZCVT(errorinfo, "O", "HTML") _ " -->")
    Do streamOut.Write($CHAR(13, 10))
    If ($ZCONVERT(synColor.DLLResultCode, "U") [ "ZF6 FAILED")
    {
        Goto LangNone
    }
    Do streamOut.Write("<!-- input echo -->")
    Do streamOut.Write("<PRE>")
    Do streamOut.Write($CHAR(13, 10))
    Do streamIn.Rewind()
    Do streamOut.Write(..content)
    Do streamOut.Write($CHAR(13, 10))
    Do streamOut.Write("</PRE>")
    Do streamOut.Write($CHAR(13, 10))
    
CheckErrors
    If ('(##class(DocBook.ConfigUtils).GetIGNORECOLORERROR()))
    {
        If 'colored,'errors {
            Write $$$T("Fault occurred in colorizer DLL"), !
            Set colored = synColor.DLLResultCode
            Write $$$T("DLLResultCode: "), $SELECT((colored'=""):colored, 1:$$$T("[not supplied]")), !
        }
        ElseIf (errors) 
        {
            Set errmsg = $$$T("BAD SYNTAX in programlisting: ") _ progname
            Write errmsg,!
            Write $$$T("Language: "), lang, !
            Set RetCode = synColor.DLLResultCode
            //Set DispPfx = $$$T("ERROR: ")
            Set DispPfx = $$$T("WARN: ")
            Set:((RetCode = "") || ( RetCode = "OK")) DispPfx = ""
            Write DispPfx, $$$T("DLLResultCode: ") _ RetCode, !
            Write $$$T("ErrorInfo: ") _ errorinfo, !
            // display part of bad syntax
            Write "----------------------------------",!
            write $$$T("Input stream:"), !
            Do streamIn.Rewind()
            Write $ZCVT(streamIn.Read(streamIn.Size),"O","HTML"),!
            Write "----------------------------------",!
            write $$$T("Output stream:"), !
            Do streamOut.Rewind()
            Write $ZCVT(streamOut.Read(streamOut.Size),"O","HTML"),!
            Write !
        }
    }
    Do streamIn.Rewind()
    Do streamOut.Rewind()
    Quit
    
LangNone
    Quit
}

Storage Default
{
<Data name="programlistingDefaultData">
<Subscript>"programlisting"</Subscript>
<Value name="1">
<Value>syntaxError</Value>
</Value>
<Value name="2">
<Value>errorInfo</Value>
</Value>
<Value name="3">
<Value>errorLang</Value>
</Value>
</Data>
<DefaultData>programlistingDefaultData</DefaultData>
<Property name="blockpos"/>
<Property name="book"/>
<Property name="component"/>
<Property name="container"/>
<Property name="content"/>
<Property name="errorInfo"/>
<Property name="errorLang"/>
<Property name="id"/>
<Property name="lang"/>
<Property name="lastchange"/>
<Property name="remap"/>
<Property name="renderedContent"/>
<Property name="role"/>
<Property name="sourcefile"/>
<Property name="sourcetime"/>
<Property name="status"/>
<Property name="syntaxError"/>
<Property name="tagattrs"/>
<Property name="title"/>
<Type>%Library.CacheStorage</Type>
}

}
