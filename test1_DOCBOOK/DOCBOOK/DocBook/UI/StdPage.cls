Import DocBook

Include DocBookMac

/// Superclass for all DocBook pages.
Class DocBook.UI.StdPage Extends %CSP.Page [ Abstract, ProcedureBlock ]
{

Parameter DOMAIN = "DOCBOOK";

ClassMethod Header(title As %String = "", dialog As %Boolean = 0, isHome As %Boolean = 0, stylesheet As %String = "docbookhtml.css") As %Status [ Internal ]
{
    Set inEnsemble = ##class(DocBook.Utils).EnsembleLoaded()

    If (title = "") {
        // default title
        Set title = $$$T("InterSystems Online Documentation")
    }
    
    Set style = ..Link(stylesheet)
        
    &html<<HTML>
        <HEAD>
        <TITLE>#(title)#</TITLE>
        <LINK REL="stylesheet" TYPE="text/css" HREF="#(style)#" TITLE="Standard Style" >
    >

    &html<<SCRIPT LANGUAGE=JavaScript SRC="docbook.js"> </SCRIPT>>

    &html<<STYLE>
      .menuItem { font-family: sans-serif; font-size:8pt; width:100; padding-left:20; background-Color: menu;color:black; 
                    border-color: black; border-width: 1px; border-style: solid; }
      .highlightItem { font-family: sans-serif; font-size: 8pt; width: 100; padding-left: 20; background-Color: highlight; color: white; }
    </STYLE>>
    
    &html<<SCRIPT LANGUAGE=JavaScript>
function doSearch() {
    var form = self.document.QuickSearch;
    var kw = form.KeyWord.value;
    self.document.location = 'DocBook.UI.SearchPageZen.cls?KeyWord=' + escape(kw);
    return true;
}
    </SCRIPT>>

    Do ..ShowScripts()
    &html<</HEAD>>
    Quit
}

/// Generate the title banner for the current page.
/// ClassMethod RenderBanner(doctitle As %String, booktitle As %String = "", chap As %String = "", prev As %String = "", next As %String = "", container As DocBook.container = "")
ClassMethod RenderBanner(info As BannerInfo, isHome As %Boolean = 0) As %Status [ Final, Internal ]
{
    Set inEnsemble = ##class(DocBook.Utils).EnsembleLoaded()

    Set key = $G(%request.Data("KEY",1))
    Set frame = $G(%request.Data("FRAME",1))

    // Internet Explorer flags
    Set %ie = ..isIE()
    Set %ie6 = ..isIE6()
    
    // Netscape Flags
    Set %ns7 = ..isNS7()

    Set helpURL = ""
    Set logXURL = ""
    Set tBookTitle = info.booktitle
    Set tTitle = info.title

    Set ServerName = $zu(110)
    Set InstanceName = $P($zu(86),"*",2)

    Set cmdHome = $$$TH("Home")
    //AAH791
    /*
    */
    Set cmdPortal = $$$TH("Management Portal")
    Set cmdIndex = $$$TH("Index")

    Set cmdSearch = $$$TH("Search")
    Set cmdFrames = $$$TH("Frames")
    
    Set urlHome = ##class(%CSP.Page).Link("DocBook.UI.HomePageZen.cls")
    Set urlPortal = ##class(%CSP.Page).Link("/csp/sys/UtilHome.csp")
    //AAH791
    /*
    */
    Set urlIndex = ##class(%CSP.Page).Link("DocBook.UI.Index.cls")
    Set urlSearch = ##class(%CSP.Page).Link("DocBook.UI.SearchPageZen.cls")

    Set cmdJumpTask = $$$TH("Go to")
    Set msgJumpTask = $$$TH("Go directly to the selected task")
    
    Set msgHome = $$$TH("Go to the Documentation Home Page")
    //AAH791
    /*
    */
    Set msgPortal = $$$TH("Go to the Management Portal")
    Set msgIndex = $$$TH("Go to the Documentation Index Page")

    Set msgSearch = $$$TH("Go to the Search Page")
    Set msgQuickSearch = $$$TH("Search for a word or phrase")
    Set msgFrames = $$$TH("Show / Hide frames")
    
    Set cmdServer = $$$TH("Server")
    Set cmdInstance = $$$TH("Instance")

    Set msgServer = $$$TH("Name of the machine this system is running on")
    Set msgInstance = $$$TH("Configuration name of this system")
    
    //Set cmdComment = $$$TH("Comment")
    //Set urlComment = $GET(^DocBook.Config("CommentURL"),"")
    //Set msgComment = $$$TH("Comment on the content of this page")

    // prev     
    Set tPrev = ""
    If (info.prev'="") {
        If ($E(info.prev,1,1) = ":") {
            // if prev starts with : then it is a JS command
            Set tPrev = "<a class=""buttonStyleON"" href=""javascript"_ info.prev_ """ TITLE="""_ $$$T("Go back to the previous section.")_ """>[" _ $$$T("Back") _ "]</a>"
        }
        Else {  
            Set tPrev = "<a class=""buttonStyleON"" href=""DocBook.UI.Page.cls?KEY="_ ..EscapeParm(info.prev)_ """ TITLE="""_ $$$T("Go back to the previous section.")_ """>[" _ $$$T("Back") _ "]</a>"
        }
    }
    Else {
        Set tPrev = "<span class=""buttonStyleON""></span>"
    }

    // next 
    Set tNext = ""
    If (info.next'="") {
        Set tNext = "<a class=""buttonStyleON"" href=""DocBook.UI.Page.cls?KEY="_ ..EscapeParm(info.next)_ """ TITLE="""_ $$$T("Go to the next section.")_ """>[" _ $$$T("Next") _ "]</a>"
    }
    Else {
        Set tNext = "<span class=""buttonStyleON""></span>"
    }

    &html<<a name="top"></a>>
    &html<
    <table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-size: 10pt;">
    <tr>
    <td nowrap width="205" bgcolor="#FFFAE7" valign="bottom" align="left" style='background-repeat: no-repeat; background-image: url("#(##class(%CSP.Page).Link("/csp/sys/images/logo-topl-intersystems.gif"))#");'>
    <nobr>&nbsp;
    <span style="color: gray;">
    </span></nobr>
    </td>
    
    <td nowrap bgcolor="#FFFAE7" valign="top" align="left" style="padding-left: 20px;">
    <div class="wizardltlabel" style="margin-top:6px;"><span style="font-size:11pt; padding-right:5px;">#(tBookTitle)#</span></div>
    <div style="color: darkblue; margin-top:4px; font-weight: bold; font-size:15pt;">#(tTitle)#</div>
    <div>#(tPrev)#&nbsp;#(tNext)#</div>
    </td>
    
    <td nowrap width="308" height="78" bgcolor="#FFFAE7" valign="bottom" align="left" style='background-repeat: repeat-y; background-image: url("#(##class(%CSP.Page).Link("/csp/sys/images/opposite-pic-intersys.jpg"))#");'>&nbsp;</td>
    
    <td width="2%" bgcolor="#388CCC">&nbsp;</td>
    
    <td bgcolor="#388CCC" valign="bottom">

    <table bgcolor="#388CCC" border="0">
    <tr>
    <td title="#(msgServer)#" class="quote-name" style="text-align: left;" nowrap><span style="color:#FFFAE7; font-size:8pt; padding-right:5px;">#(cmdServer)#:</span><b>#(ServerName)#</b></td>
    </tr>
    <tr>
    <td title="#(msgInstance)#" class="quote-name" style="text-align: left;" nowrap><span style="color:#FFFAE7; font-size:8pt; padding-right:5px;">#(cmdInstance)#:</span><b>#(InstanceName)#</b></td>
    </tr>>

    Do ..DrawUsername()

    &html<</table>>
   
    &html<</td>>
    &html<<td bgcolor="#388CCC">&nbsp;</td>>
    &html<</tr>>
    &html<</tr>>
    
    &html<<table width="100%" border="0" cellpadding="0" cellspacing="0" style="font-size: 10pt;">>
    &html<<tr>>
    &html<<td colspan="8" bgcolor="#D36D00" style="line-height:1px;font-size:0pt;">>
    &html<<img src='#(##class(%CSP.Page).Link("/csp/sys/images/spacer.gif"))#' width="100%" height="2" alt="-" border="0">>
    &html<</td>>
    &html<</tr>>
    
    &html<<tr>>

    #; toggle frames
    If ('$D(%noshowframes)) {
        Set key = $Translate(key,"""<>")
        Set escapedkey = ##class(%CSP.Page).QuoteJS(key)
        &html<<td width="1%" class="LocatorBar" valign="top" nowrap title="#(msgFrames)#">
        <input type="checkbox" #($S(frame'="":"checked",1:""))# onclick="showFrames(#(escapedkey)#);"/></td>
        >
    }

    #; locator
    Set tLocator=1
    Set tLocator(1) = $LB("",$$$T("Home"))
    Set key = $G(%request.Data("KEY",1))
    Set id = ##class(DocBook.block).FindId(key)
    If (id'="") {
        Do ..GetLocatorList(id,.tLocator)
    }
    Set tCount = +$G(tLocator)

    &html<<td class="LocatorBar" colspan="2" valign="middle">>
    &html<<div align="left" class="Locator">>
    &html<&nbsp;>

    If (tCount > 0) {
        For i = 1:1:tCount {

            If ($LG(tLocator(i),1)="") {
                Set tLink = "DocBook.UI.HomePageZen.cls"
            }
            Else {
                Set tLink = "DocBook.UI.Page.cls?KEY="_..EscapeParm($LG(tLocator(i),1))
            }
            Set tCaption = $LG(tLocator(i),2)
            Set tHelp = tCaption
            
            Set SHORTLINKS = 0
            If (SHORTLINKS)
            {
                #; shorten links under some conditions
                If (##class(DocBook.Utils).UsingJapanese()=0) {
                    If ($E(tCaption,1,13)="Cach&eacute; ") {
                        Set $E(tCaption,1,13) = ""
                    }
                    If ($E(tCaption,1,9)="Ensemble ") {
                        Set $E(tCaption,1,9) = ""
                    }
                }
            
                If ($L(tCaption)>35) {
                    #; shorten, break on space
                    Set p = $F(tCaption," ",30)
                    If (p > 0) {
                        Set tCaption = $E(tCaption,1,p-2)_"..."
                    }
                }
            }
            &html<<nobr>>
            &html<[>
            &html<<a target="_top" title="#(tHelp)#" href="#(tLink)#">>
            &html<#(tCaption)#>
            &html<</a>>
            &html<]>
            &html<#($S(i=tCount:"",1:"&nbsp;&gt;&nbsp;"))#>
            &html<</nobr>>
        } 
    }

    &html<</div></td>>
    
    If (info.container '= "") {
        // ask container for its gotolist
        Do info.container.GetGotoList(.gtl)
    }

    // goto list 
    If ($D(gtl)) {
        &html<<td class="LocatorBar" title="#(msgJumpTask)#" nowrap align="right" valign="top" colspan="2">#(cmdJumpTask)#:>
        &html<<SELECT CLASS="QuickLink" NAME="Link" onchange="gotoChoice(this.options[this.selectedIndex].value);">>
        &html<<OPTION VALUE="">>
        
        Set i = ""
        Set i = $O(gtl(""))
        While (i '= "") {
            Write "<OPTION VALUE=""",$LG(gtl(i),1),""">",$LG(gtl(i),2),!
            Set i = $O(gtl(i))
        }       
        
        &html<</SELECT></td>>
    }

    #; quick-search
    &html<<FORM id="QuickSearch" NAME="QuickSearch" ACTION="DocBook.UI.SearchPageZen.cls">>
    &html<<TD ALIGN="RIGHT" valign="top" class="LocatorBar" nowrap>>
    Set escapedkey = ##class(%CSP.Page).EscapeHTML(key)
    &html<<INPUT TYPE="HIDDEN" NAME="KEY" VALUE="#(escapedkey)#">>
    &html<<a target="_top" title="#(msgSearch)#" class="buttonStyleON" href='#(urlSearch)#' onclick="self.document.getElementById('QuickSearch').submit(); return false;">#(cmdSearch)#</a>:>
    &html<<INPUT CLASS="QuickSearch" TYPE="TEXT" NAME="KeyWord" SIZE="30" title="#(msgQuickSearch)#">&nbsp;>
    &html<</TD>>
    &html<</FORM>>

    &html<<td class="LocatorBar" colspan="2">&nbsp;</td>
        </tr>>

    &html<</table>>

    Quit $$$OK
}

/// Draw username or server name depend on setup.
ClassMethod DrawUsername() [ Internal ]
{
    Set msgUser = $$$TH("User")
    Set msgServer = $$$TH("Server")
    Set msgInstance = $$$TH("Instance")
    Set hlpUser = $$$TH("Name of user logged into this session")

    &html<<tr><td title="#(hlpUser)#" class="quote-name" style="text-align: left;">
    <span style="color:#FFFAE7; font-size:8pt; padding-right:5px;">#(msgUser)#:</span><b>#($UserName)#</b></td></tr>
    >
}

/// Get the set of items for the locator bar for this page.
ClassMethod GetLocatorList(id As cdata, ByRef pList) [ Internal ]
{
    &sql(SELECT title, container, x__classname, blockid
            INTO :title, :ctr, :cls, :bid
            FROM DocBook.block
            WHERE id = :id)

    If ($G(ctr) '= "") {
        Do ..GetLocatorList(ctr,.pList)
    }

    Set idx = $I(pList)
    Set pList(idx) = $LB(bid,$G(title,"???"))
}

ClassMethod Footer(showlink As %Integer = 1, modtime As %String = "", isHome As %Boolean = 0, sourcefile As %String = "", info As BannerInfo = "", glo As %Integer = "", elap As %Integer = "") As %Status [ Internal ]
{
    Set inEnsemble = ##class(DocBook.Utils).EnsembleLoaded()

    Set copyright = "copyright.pdf"

    &html<<BR/><HR/><TABLE WIDTH="100%">
        <TR><TD CLASS="Footer" valign="middle">>
    If (showlink) {
        Write "<A  TITLE=""", $$$T("Display the copyright notice."), """ HREF="""_copyright_""">", $$$T("Copyright"), "</A>"
    }
    Else {
        &html<#($$$T("Copyright"))#>
    }
    &html<&nbsp;&copy; 1997-#($P($zd($H,3),"-"))#, >
    Write $$$T("InterSystems Corp.")
    &html<</TD>>
    
    If (info '= "") {
        &html<<TD CLASS="Footer" NOWRAP valign="middle">>
        If (info.prev '= "") {
            If ($E(info.prev,1,1) = ":") {
                // if prev starts with : then it is a javascript command!
                &html<&nbsp;<A class="buttonStyleON" HREF="javascript#(info.prev)#">>
                &html<[#($$$T("Back"))#]</A>&nbsp;>
            }
            Else {
                Write "&nbsp;<A class=""buttonStyleON"" HREF=""DocBook.UI.Page.cls?KEY=", ..EscapeParm(info.prev),""" TITLE=""", $$$T("Go back to the previous section."), """>"
                &html<[#($$$T("Back"))#]</A>&nbsp;>
            }
        }

        // home page button
        Write "&nbsp;<A class=""buttonStyleON"" HREF=""DocBook.UI.Page.cls"" TITLE=""", $$$T("Go to the home page."), """>",!
        &html<[#($$$T("Home"))#]</A>&nbsp;>

        // top of page button
        Write "&nbsp;<A class=""buttonStyleON"" HREF=""#top"" TITLE=""", $$$T("Go to the top of this page."), """>",!
        &html<[#($$$T("Top of Page"))#]</A>&nbsp;>
        
        If (info.next '= "") {
            Write "&nbsp;<A class=""buttonStyleON"" HREF=""DocBook.UI.Page.cls?KEY=", ..EscapeParm(info.next), """ TITLE=""", $$$T("Go to the next section"), """>"
            &html<[#($$$T("Next"))#]</A>&nbsp;>
        }

        // comment button
        Set ref = ""
        Set sysref = ""
        set lclref = ""
        
        Set commentURL = $GET(^%SYSTEM.Config("FeedbackURL"),"")
        If ($LENGTH(commentURL) > 0)
        {
            Set sysref = ..FmtSysCommentRef(commentURL, sourcefile, ^DocBook.BuildInfo)
        }        
        
        Set commentURL = $GET(^DocBook.Config("COMMENTURL"),"")
        If ($LENGTH(commentURL) > 0)
        {
            Set lclref = ..FmtLclCommentRef(commentURL, sourcefile, ^DocBook.BuildInfo)
        }
        
        If ($LENGTH(sysref) > 0)
        {
            Set ref = sysref
        }
        If ($LENGTH(lclref) > 0)
        {
            Set ref = lclref
        }
        
        If ($LENGTH(ref) > 0)
        {
            Write "&nbsp;"
            Write "<A class=""buttonStyleON"" HREF="""
            Write ref
            Write """ TITLE=""", $$$T("Comment on the content of this page"), """>"
            Write "[", $$$T("Feedback"), "]"
            Write "</A>&nbsp;"
            Write !
        }
        
        &html<</TD>>
    }
    
    If ($G(^DocBook.BuildInfo) '= "") {
        &html<<TD ALIGN="RIGHT" valign="middle" CLASS="Footer">#($$$T("Build:"))# <B>#(^DocBook.BuildInfo)#</B></TD>>
    }

    If (modtime '= "") {
        &html<<TD ALIGN="RIGHT" valign="middle" CLASS="Footer">#($$$T("Last updated:"))# <B>#(modtime)#</B></TD>>
    }
    If (sourcefile '= "") {
        &html<<TD ALIGN="RIGHT" valign="middle" CLASS="Footer">#($$$T("Source:"))# <B>#(sourcefile)#</B></TD>>
    }

    If ($D(^DocBook.Statistics) && (glo '= "")) {
        &html<<TD ALIGN="RIGHT" valign="middle" CLASS="Footer">#($$$T("globals:"))# <B>#(glo)#</B></TD>>
    }
    If ($D(^DocBook.Statistics) && (elap '= "")) {
        &html<<TD ALIGN="RIGHT" valign="middle" CLASS="Footer">#($$$T("elapsed:"))# <B>#(elap)#</B></TD>>
    }

    &html<</TR></TABLE>>
    &html<</BODY></HTML>>
}

ClassMethod OnPage() As %Status [ Internal ]
{
    Do ..Header("Table of Contents")
    &html<<BODY>>
    &html<<a id="_top_of_page_"></a>>
    &html<<H1>Cach&eacute; DocBook Server</H1><HR>>
    Do ..Footer()
    QUIT $$$OK
}

ClassMethod FmtLclCommentRef(url As %String, file As %String, build As %String) As %String [ Internal ]
{
    Set result = ""
    Set EMAIL = "mailto:"
    Set WEBNORM = "http:"
    Set WEBSECURE = "htpps:"
    If ($ZCONVERT($EXTRACT(url, 1, $LENGTH(EMAIL)), "L") = EMAIL)
    {
        Set subjecttext = "Comments on "
                        _ file
                        _ " - "
                        _ $ZCONVERT(build, "I", "HTML")
        Set locinfo = "?"
                    _ "subject="
                    _ $ZCONVERT(subjecttext, "O", "URL")
    }
    ElseIf ($ZCONVERT($EXTRACT(url, 1, $LENGTH(WEBNORM)), "L") = WEBNORM)
    {
        Set locinfo = "?"
                    _ "source="
                    _ $ZCONVERT(file, "O", "URL")
                    _ "&"
                    _ "build="
                    _ $ZCONVERT(build, "O", "URL")
    }
    ElseIf ($ZCONVERT($EXTRACT(url, 1, $LENGTH(WEBSECURE)), "L") = WEBSECURE)
    {
        Set locinfo = "?"
                    _ "source="
                    _ $ZCONVERT(file, "O", "URL")
                    _ "&"
                    _ "build="
                    _ $ZCONVERT(build, "O", "URL")
    }
    Else
    {
        Set locinfo = ""
    }
    Set result = url _ locinfo
    //Set result = ..ObfuscateRef(result)
    Quit result
}

ClassMethod FmtSysCommentRef(url As %String, file As %String, build As %String) As %String [ Internal ]
{
    Set result = ""
    Set locinfo = "?"
                _ "origin="
                _ $ZCONVERT("DocBook", "O", "URL")
                _ "&"
                _ "version="
                _ $ZCONVERT($SYSTEM.Version.Format(4), "O", "URL")
                _ "&"
                _ "source="
                _ $ZCONVERT(file, "O", "URL")

    Set result = url _ locinfo
    //Set result = ..ObfuscateRef(result)
    Quit result
}

ClassMethod ObfuscateRef(ref As %String) As %String [ Internal ]
{
    Set result = ""
    For i = 1 : 1 : $LENGTH(ref)
    {
        Set val = $ASCII($EXTRACT(ref, i))
        Set result = result
                   _ "&#"
                   _ val
                   _ ";"
    }
    Quit result
}

ClassMethod ShowScripts() [ Internal ]
{
    // over ride this in subclasses
    &html<<SCRIPT LANGUAGE=JavaScript>
    </SCRIPT>>
}

/// Returns true if we are talking to an IE browser.
ClassMethod isIE() As %Boolean [ CodeMode = expression, Internal ]
{
%request.UserAgent [ "MSIE"
}

ClassMethod isIE6() As %Boolean [ CodeMode = expression, Internal ]
{
%request.UserAgent [ "MSIE 6"
}

ClassMethod isNS7() As %Boolean [ CodeMode = expression, Internal ]
{
%request.UserAgent [ "Netscape/7"
}

ClassMethod EscapeParm(url As %String) As %String [ Internal ]
{
    If $G(%ie6) && $system.Version.IsUnicode() {
        Quit $ZCVT($ZCVT(url,"O","UTF8"),"O","URL")
    }
    Else {
        Quit url
    }
}

}
