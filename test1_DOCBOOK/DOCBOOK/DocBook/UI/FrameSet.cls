Include DocBookMac

/// FrameSet page for showing DocBook within a FrameSet.
Class DocBook.UI.FrameSet Extends %CSP.Page [ ProcedureBlock ]
{

ClassMethod OnPage() As %Status [ Internal ]
{
    
    Set bookKey = $G(%request.Data("KEY",1))
    Set key = ""
    Set:bookKey'="" key = "KEY="_bookKey
    
    &html<<html>
    <head>
    <title>Cach&eacute; DocBook</title>
    </head>
    <frameset rows="*" cols="25%,*">
        <frame name="TOCFrame" src="DocBook.UI.IndexFrame.cls?#((..EscapeHTML(key)))#" border="1">
        <frame name="PageFrame" src="DocBook.UI.Page.cls?FRAME=PAGE&#((..EscapeHTML(key)))#">
    </frameset>
    </html>>

    Quit $$$OK
}

}
