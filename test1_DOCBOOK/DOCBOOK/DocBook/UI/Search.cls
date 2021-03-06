Include DocBookMac

/// The Search page for the DocBook viewer application.
Class DocBook.UI.Search Extends DocBook.UI.StdPage [ ProcedureBlock ]
{

ClassMethod OnPage() As %Status [ Internal ]
{

    Set glo = $zu(67,9,$J)
    Set elap = $zh

    Set info = ##class(BannerInfo).%New()
    Set info.title = $$$T("Key Word Search")
    Set info.booktitle = $$$T("InterSystems Online Documentation")

    // max rows shown
    Set maxRows = 100

    Do ..Header("Search")

    &html<<BODY>>

    Do ..RenderBanner(info)
    &html<<BR>>

    Set keyword = $G(%request.Data("KeyWord",1))
    Set include = $G(%request.Data("Include",1),"All")
    Set heading = "Search for all documents containing a specific word or phrase by entering it in the field below:"

    // search form
    &html<<TABLE CCELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%">>
    &html<<TR><TD WIDTH="10%">&nbsp;</TD>>
    &html<<TD>>
    &html<<FORM NAME="SearchForm">>
    &html<<TABLE CLASS="SearchForm" CELLPADDING="5" BGCOLOR="silver" CELLSPACING="0" BORDER="0">>
    &html<<TR><TD COLSPAN="2"><DIV CLASS="SearchForm">#(heading)#</DIV></TD></TR>>
    &html<<TR><TD><DIV CLASS="SearchForm"><B>#($$$T("Search for:"))#</B></DIV></TD>>
    &html<<TD>>
    &html<<INPUT CLASS="SearchInput" TYPE="TEXT" SIZE="40" NAME="KeyWord" VALUE="#((..EscapeHTML(keyword)))#">&nbsp;>
    &html<<INPUT CLASS="SearchButton" TYPE="SUBMIT" NAME="Search" VALUE="Search">>
    &html<</TD></TR>>

    &html<<TR><TD>#($$$T("Search includes:"))#</TD>>
    &html<<TD>>
    &html<<INPUT CLASS="SearchRadio" TYPE="RADIO" NAME="Include" VALUE="All" #($S(include="All":"CHECKED",1:""))#>#($$$T("All"))#&nbsp;>
    &html<<INPUT CLASS="SearchRadio" TYPE="RADIO" NAME="Include" VALUE="Text" #($S(include="Text":"CHECKED",1:""))#>#($$$T("Text"))#&nbsp;>
    &html<<INPUT CLASS="SearchRadio" TYPE="RADIO" NAME="Include" VALUE="Title" #($S(include="Title":"CHECKED",1:""))#>#($$$T("Titles"))#&nbsp;>
    &html<<INPUT CLASS="SearchRadio" TYPE="RADIO" NAME="Include" VALUE="ProgramListing" #($S(include="ProgramListing":"CHECKED",1:""))#>#($$$T("Program Listings"))#&nbsp;>
    &html<<INPUT CLASS="SearchRadio" TYPE="RADIO" NAME="Include" VALUE="GlossTerm" #($S(include="GlossTerm":"CHECKED",1:""))#>#($$$T("Glossary Terms"))#>
    &html<</TD>>
    &html<</TR>>
    &html<</TABLE>>
    &html<</FORM>>
    &html<</TD></TR></TABLE>>

    // show list of results:
    If (((include = "Title") || (include = "All")) && (keyword '= "")) {
        &html<<HR>>

        Set k = $zcvt(keyword,"U")

        // search titles
        &sql(DECLARE TitleCursor CURSOR FOR 
            SELECT  count(*), title, blockid, component->blockid,
                    book->blockid, book->title
            INTO    :count, :title, :paraKey, :docKey,
                    :bookKey, :bookTitle
            FROM DocBook.container
            WHERE %SQLUPPER(title) [ :k)

        &sql(OPEN TitleCursor)

        &html<<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0" WIDTH="100%">>

        &sql(FETCH TitleCursor)
        If (SQLCODE '= 0) {
            // No data
            &html<<TR><TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">
                <DIV CLASS="SearchNumber">#($$$T("Titles"))#&nbsp;</DIV></TD>
                <TD>#($$$T("No matches found."))#</TD></TR>>
        }
        Else {
            // show count
            If (count = 1) {
                &html<<TR>>
                &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Titles "))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B> >
                &html<#($$$T("match found."))#>
            }
            Else {
                &html<<TR><TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Titles "))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B> >
                &html<#($$$T("matches found."))#>
            }
            If (count > maxRows) {
                &html<&nbsp;>
                &html<#($$$T("The first"))#>
                &html< #(maxRows)# >
                &html<#($$$T("are shown below."))#>
            }
            &html<<HR></TD></TR>>
        }

        Set i = 1
        While ((SQLCODE = 0) && (i < maxRows)) {
            If (docKey = "") {
                // we are probably a book or chapter
                Set docKey = paraKey
                Set paraKey = ""
            }   
            
            Do ..ShowResult(i,paraKey,docKey,bookTitle,"",title,keyword)

            &sql(FETCH TitleCursor)
            Set i = i + 1
            If ((i#6) = 0) {
                Do %response.Flush()
            }
        }
        &sql(CLOSE TitleCursor)
        &html<</TABLE>>
    }

    If (((include = "Text") || (include = "All")) && (keyword '= "")) {
        &html<<HR>>

        Set k = $zcvt(keyword,"U")

        // search text
        &sql(DECLARE TextCursor CURSOR FOR 
            SELECT  count(*), content, blockid, 
                    component->blockid, component->title, 
                    book->blockid, book->title
            INTO    :count, :text, :paraKey, 
                    :docKey, :title, 
                    :bookKey, :bookTitle
            FROM DocBook.block
            WHERE %SQLUPPER(content) [ :k)

        &sql(OPEN TextCursor)

        &html<<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0" WIDTH="100%">>

        &sql(FETCH TextCursor)
        If (SQLCODE '= 0) {
            // No data
            &html<<TR>>
            &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
            &html<<DIV CLASS="SearchNumber">>
            &html<#($$$T("Text"))#&nbsp;>
            &html<</DIV></TD>>
            &html<<TD>>
            &html<#($$$T("No matches found."))#>
            &html<</TD></TR>>
        }
        Else {
            // show count
            If (count = 1) {
                &html<<TR>>
                &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Text"))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B> >
                &html<#($$$T("match found."))#>
            }
            Else {
                &html<<TR>>
                &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Text"))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B>>
                &html<#($$$T("matches found."))#>
            }
            If (count > maxRows) {
                &html<&nbsp;>
                &html<#($$$T("The first"))#>
                &html< #(maxRows)# >
                &html<#($$$T("are shown below."))#>
            }
            &html<<HR></TD></TR>>
        }

        Set i = 1
        While ((SQLCODE = 0) && (i < maxRows)) {
            Do ..ShowResult(i,paraKey,docKey,bookTitle,title,text,keyword)

            &sql(FETCH TextCursor)
            Set i = i + 1
            If ((i#6) = 0) {
                Do %response.Flush()
            }
        }
        &sql(CLOSE TextCursor)
        &html<</TABLE>>
    }

    If ((include = "ProgramListing") && (keyword '= "")) {
        &html<<HR>>

        Set k = $zcvt(keyword,"U")

        // search text
        &sql(DECLARE PLCursor CURSOR FOR 
            SELECT  count(*), content, blockid, 
                    component->blockid, component->title, 
                    book->blockid, book->title
            INTO    :count, :text, :paraKey, 
                    :docKey, :title, 
                    :bookKey, :bookTitle
            FROM DocBook.programlisting
            WHERE %SQLUPPER(content) [ :k)

        &sql(OPEN PLCursor)

        &html<<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0" WIDTH="100%">>

        &sql(FETCH PLCursor)
        If (SQLCODE '= 0) {
            // No data
            &html<<TR>>
            &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
            &html<<DIV CLASS="SearchNumber">>
            &html<#($$$T("Text"))#&nbsp;>
            &html<</DIV></TD>>
            &html<<TD>>
            &html<#($$$T("No matches found."))#>
            &html<</TD></TR>>
        }
        Else {
            // show count
            If (count = 1) {
                &html<<TR>>
                &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Text"))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B> >
                &html<#($$$T("match found."))#>
            }
            Else {
                &html<<TR>>
                &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Text"))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B> >
                &html<#($$$T("matches found."))#>
            }
            If (count > maxRows) {
                &html<&nbsp;>
                &html<#($$$T("The first"))#>
                &html<#(maxRows)# >
                &html<#($$$T("are shown below."))#>
            }
            &html<<HR></TD></TR>>
        }

        Set i = 1
        While ((SQLCODE = 0) && (i < maxRows)) {
            Do ..ShowResult(i,paraKey,docKey,bookTitle,title,text,keyword,1)

            &sql(FETCH PLCursor)
            Set i = i + 1
            If ((i#6) = 0) {
                Do %response.Flush()
            }
        }
        &sql(CLOSE PLCursor)
        &html<</TABLE>>
    }

    If ((include = "GlossTerm") && (keyword '= "")) {
        &html<<HR>>

        Set k = $zcvt(keyword,"U")

        // search text
        &sql(DECLARE GTCursor CURSOR FOR 
            SELECT  count(*), glossterm, blockid, 
                    component->blockid, component->title, 
                    book->blockid, book->title
            INTO    :count, :text, :paraKey, 
                    :docKey, :title, 
                    :bookKey, :bookTitle
            FROM DocBook.glossentry
            WHERE %SQLUPPER(glossterm) [ :k)

        &sql(OPEN GTCursor)

        &html<<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0" WIDTH="100%">>

        &sql(FETCH GTCursor)
        If (SQLCODE '= 0) {
            // No data
            &html<<TR>>
            &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
            &html<<DIV CLASS="SearchNumber">>
            &html<#($$$T("Text"))#&nbsp;>
            &html<</DIV></TD>>
            &html<<TD>>
            &html<#($$$T("No matches found."))#>
            &html<</TD></TR>>
        }
        Else {
            // show count
            If (count = 1) {
                &html<<TR>>
                &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Text"))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B> >
                &html<#($$$T("match found.")#>
            }
            Else {
                &html<<TR>>
                &html<<TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT">>
                &html<<DIV CLASS="SearchNumber">>
                &html<#($$$T("Text"))#&nbsp;>
                &html<</DIV></TD>>
                &html<<TD><B>#(+count)#</B> >
                &html<#($$$T("matches found."))#>
            }
            If (count > maxRows) {
                &html<&nbsp;>
                &html<#($$$T("The first"))#>
                &html<#(maxRows)# >
                &html<#($$$T("are shown below."))#>
            }
            &html<<HR></TD></TR>>
        }

        Set i = 1
        While ((SQLCODE = 0) && (i < maxRows)) {
            Do ..ShowResult(i,paraKey,docKey,bookTitle,title,text,keyword,1)

            &sql(FETCH GTCursor)
            Set i = i + 1
            If ((i#6) = 0) {
                Do %response.Flush()
            }
        }
        &sql(CLOSE GTCursor)
        &html<</TABLE>>
    }

    Do ..Footer(1,$ZDT($H,3),,,,$zu(67,9,$J)-glo,$zh-elap)

    Quit $$$OK
}

ClassMethod ShowResult(num As dbint, paraKey As cdata, docKey As cdata, bookTitle As cdata, docTitle As cdata, text As cdata, keyword As cdata, listing As dbint = 0) [ Internal ]
{

    If (paraKey '= "") {
        Set srch = "&KEYWORD=" _ keyword _ "&SEARCH=" _  paraKey _ "#" _ paraKey
    }
    Else {
        Set srch = ""
    }
     
    If (bookTitle '= "") {
        Set title = bookTitle _ ": " _ docTitle
    }
    Else {
        Set title = "untitled"
    }

    // display a search result
    &html<<TR>
        <TD WIDTH="10%" VALIGN="TOP" ALIGN="RIGHT"><DIV CLASS="SearchNumber">#(num)#&nbsp;</DIV></TD>
        <TD>
        <DIV CLASS="SearchTitle">
        <A  HREF='DocBook.UI.Page.cls?KEY=#(..EscapeURL(docKey))##(srch)#'>#(title)#</A></DIV>
        <DIV CLASS="SearchText">>

        If (listing) {
            Write "<PRE>",text,"</PRE>",!
        }
        Else {
            Do ##class(DocBook.Renderer).RenderText(text,keyword)
        }

        &html<</DIV><HR></TD></TR>>
}

ClassMethod ShowScripts() [ Internal ]
{
    &html<<SCRIPT LANGUAGE=JavaScript>
        function pageOnLoad()
        {
            // set focus to the first search field and select it
            var form = self.document.SearchForm;
            var control = form.KeyWord;
            control.focus();
            control.select();
            return true;
        }
        </SCRIPT>>
}

}
