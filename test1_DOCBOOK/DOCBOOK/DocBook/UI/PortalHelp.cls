Include DocBookMac

/// The default when no target for the Portal page help can be found.
Class DocBook.UI.PortalHelp Extends DocBook.UI.StdPage [ ClassType = "", ProcedureBlock ]
{

ClassMethod OnPage() As %Status [ Internal ]
{

    Set info = ##class(BannerInfo).%New()
    Set info.title = $$$T("Default Portal Help Page")
    Set info.booktitle = $$$T("InterSystems Online Documentation")
    
    Do ..Header($$$T("Portal Help Missing"))
    
    &html<<BODY>>
    
    Do ..RenderBanner(info)
    &html<<BR>>
    
    &html<<DIV CLASS="warning">>
    &html<<P>>
    Write $$$T("The help associated with the Management Portal page cannot be found.")
    &html<<P>>
    &html<</DIV>>

    &html<<DIV CLASS="para">>
    &html<<P>>
    Write $$$T("The following information is available:")
    &html<<UL>>

    &html<<P>>
    &html<<LI><A HREF="DocBook.UI.Page.cls">#($$$T("Online documentation Home page"))#</A></LI>>

    &html<<P>>
    &html<<LI><A HREF="DocBook.UI.Page.cls?KEY=GSA_using_portal">#($$$T("Using the Management Portal"))#</A></LI>>

    &html<<P>>
    &html<<LI><A HREF="DocBook.UI.Page.cls?KEY=SETSysAdmin">#($$$T("System administration documents"))#</A></LI>>

    &html<<P>>
    &html<<LI><A HREF="DocBook.UI.Page.cls?KEY=SETRelease">#($$$T("Information related to this release"))#</A></LI>>

    &html<<P>>
    &html<<LI><A HREF="DocBook.UI.Page.cls?KEY=KNBASE">#($$$T("Technical articles"))#</A></LI>>

    &html<<P>>
    &html<</UL>>
    &html<</DIV>>

Done    
    Do ..Footer()

    Quit $$$OK
}

}
