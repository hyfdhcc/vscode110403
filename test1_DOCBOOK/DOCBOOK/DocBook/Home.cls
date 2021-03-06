Include DocBookMac

/// This is a special container that renders the Home page for the Documentation system.
Class DocBook.Home Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
    Set info.title = $$$T("Documentation Home Page")
    Set info.booktitle = $$$T("InterSystems Online Documentation")
    Set info.chap = ""
    Set info.prev = ""
    Set info.next = ""
}

Method HTMLRender() [ Internal ]
{
    // Modern browsers get the new front page:
    Set agent = %request.UserAgent

    // mozilla 5.0+
    Set ver = +$E(agent,$f(agent,"Mozilla")+1,*)
    Set mozilla = (ver '< 5.0)
    
    // opera 6.0.5+
    Set ver = +$E(agent,$f(agent,"Opera")+1,*)
    Set opera = (ver '< 6.05)
    
    //&html<<DIV class="para">#($$$T("Agent:"))# #(agent)#</DIV>>
    //&html<<DIV class="para">#($$$T("IE:"))# #(%ie)#</DIV>>
    //&html<<DIV class="para">#($$$T("IE6:"))# #(%ie6)#</DIV>>
    //&html<<DIV class="para">#($$$T("NS7:"))# #(%ns7)#</DIV>>
    //&html<<DIV class="para">#($$$T("Opera:"))# #(opera)#</DIV>>
    //&html<<DIV class="para">#($$$T("Mozilla:"))# #(mozilla)#</DIV>>
    
    If ('%ie && '%ie6 && '%ns7 && 'opera && 'mozilla) {
        Do ..ShowSetsDirect()
    }
    Else {
        Do ..ShowSetsCompact()
    }
}

/// Produce an array of set names in remap order
Method OrderSETs(ByRef SetList, ByRef SetIds) [ Internal ]
{

    Set setid = $O(^DocBook.blockI("setIdx",""))
    Set keyinx = 0
    While (setid '="") 
    {
        Set set = ##class(DocBook.set).%OpenId(setid)

        If (set '="") 
        {
            Set keyinx = $INCREMENT(keyinx)
            Set sortkey = set.remap
            If (sortkey = "")
            {
                Set sortkey = "~" _ (1000 + keyinx)
            }
            Set SetList(sortkey) = set
            Set SetIds(sortkey) = setid

            Set set = ""
        }
        
        Set setid = $O(^DocBook.blockI("setIdx",setid))
        ;Write "SETID=",setid,!
    }
    
    Quit
}

/// Show list of sets
Method ShowSetsDirect() [ Internal ]
{

    Set inEnsemble = ##class(DocBook.Utils).EnsembleLoaded()
    
    // preface
    &html<<DIV CLASS="para1">>
    Write $$$T("Welcome to the InterSystems online documentation."), !

    // intro text
    &html<<DIV CLASS="para">>
    Write $$$T("Listed below is a wide variety of Cach&eacute; documentation covering"), !
    &html<<A HREF="#SETAppDev">>
    Write $$$T("Application Development"), !
	&html<</A>, >
	&html<<A HREF="#SETLangBind">>
	Write $$$T("Language Bindings"), !
	&html<</A>, >
	&html<<A HREF="#SETTools">>
	Write $$$T("Tools"), !
	&html<</A>, >
	&html<<A HREF="#SETSysAdmin">>
	Write $$$T("System Administration"), !
	&html<</A>, >
	Write $$$T("and "), !
	&html<<A HREF="#SETRelease">>
	Write $$$T("Version Information"), !
	&html<</A> >
	Write $$$T("as well as "), !
	&html<<A HREF="#SETReferences">>
	Write $$$T("Reference Material"), !
	&html<</A>, >
	&html<<A HREF="#SETTutorial">>
	Write $$$T("Tutorials"), !
	&html<</A>, >
	Write $$$T("and "), !
	&html<<A HREF="#KNBASE">>
	Write $$$T("Technical Articles"), !
	&html<</A>.>
	&html<</DIV>>
       
     
    Do ..OrderSETs(.setorder)

    Set setid = $ORDER(setorder(""))
    While (setid '="") {
        Set set = $GET(setorder(setid))
        //Set set = ##class(DocBook.set).%OpenId(setid)
        Set skip = 1
        If (set '="") {
            Set skip = 0

            If ('skip) {
                &html<<A NAME="#(set.id)#"></A><DIV CLASS="set">#(set.title)#</DIV><DIV CLASS="para">#(set.subtitle)#</DIV>>
            }

            If ('skip && (set.id = "SETReferences")) {
                // trick to display link to Documatic
                If ('static) {
                    Set link = "HREF=""/csp/documatic/%25CSP.Documatic.cls"""
                    &html<<DIV CLASS="para"><UL><LI CLASS="SetTOC">>
                    Write "<A CLASS=""TOC""" _ (link) _ " TITLE='" _ $$$T("The Online Class Reference") _ "'>", !
                    &html<<B>>
                    Write $$$T("Cach&eacute; Class Reference"), !
                    &html<</B></A>>
                    &html<</UL></DIV>>
                }
            }
            ElseIf (set.id = "SETRelease") {
                // trick to display link to GettingStarted & Feature Map
                If ('static) {
                    &html<<DIV CLASS="para"><UL><LI CLASS="SetTOC">>
                    Write "<A CLASS=""TOC"" HREF=""DocBook.UI.Page.cls?KEY=GettingStarted"" TITLE='" _ $$$T("The Cach&eacute; Getting Started Page") _ "'>", !
                    &html<<B>>
                    Write $$$T("Getting Started"), !
                    &html<</B></A>>
                    &html<</UL></DIV>>
                }
                If ('static) {
                    &html<<DIV CLASS="para"><UL><LI CLASS="SetTOC">>
                    Write "<A CLASS=""TOC"" HREF=""featuremap.csp"" TITLE='" _ $$$T("The Cach&eacute; Feature Map") _ "'>", !
                    &html<<B>>
                    Write $$$T("Cach&eacute; Feature Map"), !
                    &html<</B></A>>
                    &html<</UL></DIV>>
                }
            }
        }

        Do:'skip ..ShowBooks(set.%Id())

        Set setid = $ORDER(setorder(setid))
        //Set setid = $O(^DocBook.blockI("setIdx",setid))
    }

    // KNBASE
    
    Set link = "HREF=""DocBook.UI.Page.cls?KEY=KNBASE"""

    &html<<A NAME="KNBASE"></A><DIV CLASS="set">>
    Write $$$T("Technical Articles"), !
    &html<</DIV>>
    &html<<DIV CLASS="para">>
    Write $$$T("A compendium of technical articles on various topics."), !
    &html<</DIV>>

    &html<<DIV CLASS="para"><UL><LI CLASS="SetTOC">>
    Write "<A CLASS=""TOC""" _ (link) _ " TITLE='" _ $$$T("Technical Articles") _ "'>", !
    &html<<B>>
    Write $$$T("Technical Articles"), !
    &html<</B></A>>
    &html<</UL></DIV>>

    // CATALOG
    
	Set link = "HREF=""DocBook.UI.Page.cls?KEY=CATALOG"""

	&html<<A NAME="CATALOG"></A><DIV CLASS="set">>
	Write $$$T("Documentation List"), !
	&html<</DIV>>

	&html<<DIV CLASS="para">>
	Write $$$T("A catalog of the titles of the available books and articles in the online documentation."), !
	&html<</DIV>>

	&html<<DIV CLASS="para"><UL><LI CLASS="SetTOC">>
	Write "<A CLASS=""TOC""" _ (link) _ " TITLE='" _ $$$T("List of Titles") _ "'>", !
	&html<<B>>
	Write $$$T("Documentation List"), !
	&html<</B></A>>
	&html<</UL></DIV>>
}

/// Show list of sets (compact format with links to Set pages)
Method ShowSetsCompact() [ Internal ]
{

    Set inEnsemble = ##class(DocBook.Utils).EnsembleLoaded()
    
    // preface
    &html<<DIV CLASS="para1">>
    Write $$$T("Welcome to the InterSystems online documentation."), !
    &html<<BR>>
    Write $$$T("Click on one of the topics below to find more information."), !
    &html<</DIV><BR>>

    &html<<TABLE CLASS="Home" BORDER="0" CELLPADDING="0" CELLSPACING="0" COLS="2">>

    // list sets        
    Set setid = $O(^DocBook.blockI("setIdx",""))
    &html<<TR CLASS="HomeGap"><TD COLSPAN="2">&nbsp;</TD></TR>>
    
    Do ..OrderSETs(.setorder)

    Set setid = $ORDER(setorder(""))
    While (setid '="") {
        Set set = $GET(setorder(setid))

        If (set '="") {
            Set url = "DocBook.UI.Page.cls?KEY=" _ set.id
            &html<<TR CLASS="Home">>
            &html<<TD CLASS="HomeTitle"
                      NOWRAP 
                      onclick="self.document.location='#(url)#';" 
                      onmouseover="this.className = 'HomeTitleHi'; self.document.all.item('#(set.id)#').className = 'HomeSubTitleHi';" 
                      onmouseout="this.className='HomeTitle'; self.document.all.item('#(set.id)#').className = 'HomeSubTitle';">>
            Write "<A HREF="""_url_""" TITLE=""" _ $$$T("Show this set of books.") _ """>" _ (set.title) _ "&nbsp;</A>", !
            &html<</TD>>
            &html<<TD CLASS="HomeSubTitle" ID='#(set.id)#'>#(set.subtitle)#</TD></TR>>
            &html<<TR CLASS="HomeGap"><TD COLSPAN="2">&nbsp;</TD></TR>>

            Set set = ""
        }

        Set setid = $ORDER(setorder(setid))
    }
    
    // extra items:

    Set cnt = 0
    
    Set cnt = $INCREMENT(cnt)
    Set extra(cnt,"title") = $$$T("Technical Articles")
    Set extra(cnt,"subtitle") = $$$T("A compendium of technical articles on various topics of interest.")
    Set extra(cnt,"url") = "DocBook.UI.Page.cls?KEY=KNBASE"
    Set extra(cnt,"attrib") = ""

    set cnt = $INCREMENT(cnt)
    Set extra(cnt,"title") = $$$T("Documentation List")
    Set extra(cnt,"subtitle") = $$$T("A catalog of the titles of the available books and articles in the online documentation.")
    Set extra(cnt,"url") = "DocBook.UI.Page.cls?KEY=CATALOG"
    Set extra(cnt,"attrib") = ""

    Set cnt = $INCREMENT(cnt)
    Set extra(cnt,"title") = $$$T("Cach&eacute; Feature Map")
    Set extra(cnt,"subtitle") = $$$T("A graphical overview of Cach&eacute; with links to relevant documentation.")
    Set extra(cnt,"url") = "featuremapCache.csp"
    Set extra(cnt,"attrib") = ""
    
    If (##class(DocBook.Utils).EnsembleLoaded())
    {
        Set cnt = $INCREMENT(cnt)
        Set extra(cnt,"title") = $$$T("Ensemble Feature Map")
        Set extra(cnt,"subtitle") = $$$T("A graphical overview of Ensemble with links to relevant documentation.")
        Set extra(cnt,"url") = "featuremapEnsemble.csp"
        Set extra(cnt,"attrib") = ""
    }
    
    If (##class(DocBook.Utils).HealthShareLoaded())
    {
        Set cnt = $INCREMENT(cnt)
        Set extra(cnt,"title") = $$$T("HealthShare Feature Map")
        Set extra(cnt,"subtitle") = $$$T("A graphical overview of HealthShare with links to relevant documentation.")
        Set extra(cnt,"url") = "featuremapHealthShare.csp"
        Set extra(cnt,"attrib") = ""
    }

    Set cnt = $INCREMENT(cnt)
    Set extra(cnt,"title") = $$$T("Class Reference Information")
    Set extra(cnt,"subtitle") = $$$T("Online documentation for the classes in the InterSystems Class Library. Also displays documentation for all user-defined classes.")
    Set extra(cnt,"url") = "../documatic/%25CSP.Documatic.cls"
    Set extra(cnt,"attrib") = "TARGET=""_top"""
    
    Set cnt = $INCREMENT(cnt)
    Set extra(cnt,"title") = $$$T("Search Page")
    Set extra(cnt,"subtitle") = $$$T("The main Search Page for the online documentation.")
    Set extra(cnt,"url") = "DocBook.UI.SearchPageZen.cls"
    Set extra(cnt,"attrib") = ""
    
    //AAH791
    /*
    Set cnt = $INCREMENT(cnt)
    Set extra(cnt,"title") = $$$T("Master Index")
    Set extra(cnt,"subtitle") = $$$T("The Master Index page (list of main topics) for the online documentation.")
    Set extra(cnt,"url") = "DocBook.UI.Index.cls"
    Set extra(cnt,"attrib") = ""
    */

    Set x = $O(extra(""))
    While (x '= "") {
        Set url = $G(extra(x,"url"))
        &html<<TR CLASS="Home">>
        &html<<TD CLASS="HomeTitle" NOWRAP onclick="self.document.location='#(url)#';" onmouseover="this.className = 'HomeTitleHi'; self.document.all.item('x_#(x)#').className = 'HomeSubTitleHi';" onmouseout="this.className='HomeTitle'; self.document.all.item('x_#(x)#').className = 'HomeSubTitle';">>
        Write "<A HREF=""" _ url _ """ TITLE=""" _ $$$T("Show this set of books.") _ """ " _ ($G(extra(x,"attrib"))) _ ">" _ ($G(extra(x,"title"))) _ "&nbsp;</A>", !
        &html<</TD>>
        &html<<TD CLASS="HomeSubTitle" ID="x_#(x)#">#($G(extra(x,"subtitle")))#</TD></TR>>
        &html<<TR CLASS="HomeGap"><TD COLSPAN="2">&nbsp;</TD></TR>>
        Set x = $O(extra(x))
    }

    &html<</TABLE>>
}

/// Show list of books for the given set
Method ShowBooks() [ Internal ]
{

    // loop over books
    &sql(DECLARE BookCursor CURSOR FOR
        SELECT ID,blockid,title,subtitle,dbrole,remap
        INTO :id,:bookKey,:title,:desc, :role, :remap
        FROM DocBook.book
        WHERE container = :setid
        ORDER BY remap, title
    )
    
    &sql(OPEN BookCursor)
    &sql(FETCH BookCursor)

    While (SQLCODE = 0) {
        
        // if there is a preface, link to it (tutorial only!)
        If (role = "tutorial" && (##class(DocBook.preface).FindId(bookKey _ "_preface") '= "")) {
            Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(bookKey,"O","URL") _ "_preface"""
        }
        Else {
            // link to TOC
            Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(bookKey,"O","URL") _ """"
        }

        &html<<DIV CLASS="para"><UL><LI CLASS="SetTOC">
        <A CLASS="TOC" #(link)# TITLE='#(desc)#'><B>#(title)#</B></A>
        </UL></DIV>>

        &sql(FETCH BookCursor)
    }
    &sql(CLOSE BookCursor)
}

///  Provide info for the goto list 
Method GetGotoList(ByRef gtl As cdata) [ Internal ]
{

    Set id = ..%Id()

    Quit // !!!!
    
    // list all of the books
    &sql(DECLARE G1Cursor CURSOR FOR
        SELECT ID,blockid,title,remap
        INTO :id,:key,:title,:remap
        FROM DocBook.book
        ORDER BY remap, Title
    )

    &sql(OPEN G1Cursor)
    &sql(FETCH G1Cursor)

    Set num = 1
    // KNBASE
    Set gtl(num) = $LB("KNBASE",$$$T("Technical Articles"))
    Set num = num + 1

    While (SQLCODE = 0) {
        Set gtl(num) = $LB(key,title)
        &sql(FETCH G1Cursor)
        Set num = num + 1
    }
    
    &sql(CLOSE G1Cursor)
    
    Quit
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
