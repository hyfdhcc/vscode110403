Include DocBookMac

/// A Zen-based search page for DocBook that uses SQL text searching.
Class DocBook.UI.SearchPageZen Extends %ZEN.Component.page
{

/// Class name of application this page belongs to.
Parameter APPLICATION;

/// Displayed name of this page.
Parameter PAGENAME = "Docbook Search";

Parameter CSSINCLUDES = "docbookhtml.css";

/// Domain used for localization.
Parameter DOMAIN = "DOCBOOK";

/// Initial search string.
Property KeyWord As %String(ZENURL = "KeyWord");

/// Book Id for limited search
Property BookId As %String(ZENURL = "Book");

/// Search key made up of book:KeyWord
Property SearchKey As %String [ Calculated ];

/// Ordinal position of first result to display.
Property Num As %Integer(ZENURL = "Num");

/// Localized searching message.
Property msgSearching As %ZEN.Datatype.caption [ InitialExpression = "Searching..." ];

Method SearchKeyGet() As %String
{
   Quit i%BookId_":"_..EscapeHTML(i%KeyWord)
}

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">

.ZResult,.ZResultIndex {
    border-bottom: 2px solid gray;
    font-family: arial;
    margin-left: 60px;
    margin-right: 60px;
    padding-top: 5px;
    padding-bottom: 15px;
}

.ZResultIndex {
    background:#FFFFD0;
}

.ZResult a,.ZResultIndex a {
    color: blue;
}

/* sample text for result */
.ZResult .sample, .ZResultIndex .sample {
    color: black;
    padding-left: 10px;
    padding-top: 5px;
    padding-bottom: 5px;
    max-height: 10.0em;
    overflow: auto;
}

.ZResult .sample {
    border-bottom: 1px dashed lightgray;
}

.ZResult .sample a,.ZResultIndex .sample a {
    color: darkgreen;
}

.ZResult .subhead,.ZResultIndex .subhead {
    padding-top: 3px;
    padding-bottom: 3px;
}

.ZResult .rank {
    font-size: 0.6em;
}

.ZDebugText {
    font-family: arial;
    font-size: 10pt;
    font-weight: bold;
    color: black;
    background: white;
    border: 1px solid gray;
    width: 100%;
}


.ZDebugTable {
    background: #F0F0F0;
    border: 1px solid gray;
    width: 100%;
}

.ZDebugTable td {
    padding-left: 5px;
    padding-right: 5px;
    border-right: 1px solid black;
    border-bottom: 1px solid black;
}

.zTiming {
    font-family: arial;
    font-size: 10pt;
    background: #489CCC;
    text-align: right;
    width: 100%;
    margin-bottom: 5px;
    border-top: 1px solid #202060;
    border-bottom: 1px solid #8080FF;
}

.zTiming a {
    color: black;
    text-decoration: none;
}

.ElLabel {
    font-size: 0.9em;
    font-style: italic;
    color: #202020;
}

.ZMsg {
    font-family: arial;
    padding-left: 40px;
}

.ZRecent {
    font-family: arial;
    padding-left: 40px;
}

.ZCount {
    font-size: 0.9em;
    font-style: italic;
    color: #202020;
}

</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" title="DocBook Search Page">
<html id="title" OnDrawContent="DrawTitle"/>
<vgroup width="100%" cellVAlign="top">
<spacer height="10"/>
<form id="searchForm" layout="horizontal" labelPosition="left" cellVAlign="middle">
<spacer width="20px"/>
<html><div  style="font-size:222%;padding-right:10px;"><span style="color:blue;">D</span><span style="color:red;">o</span><span style="color:green;">c</span><span style="color:purple;">B</span><span style="color:blue;">o</span><span style="color:red;">o</span><span style="color:green;">k</span></div></html>
<text size="40" id="search" name="KeyWord" value="#(%page.KeyWord)#"
onkeydown="return zenPage.keyHandler(zenEvent);"/>
<spacer width="10px"/>
<submit caption="Search" title="Search DocBook for the search word(s)"/>
<spacer width="10px"/>
<button caption="Reset" title="Reset the search words" onclick="zenPage.resetSearch();"/>
<spacer width="10px"/>
<button caption="Search the Web" title="Search the web for the search word(s) using Google" onclick="zenPage.webSearch();"/>
<spacer width="10px"/>
<button caption="Help" title="See details on using this page" onclick="window.open('DocBook.UI.Page.cls?KEY=GDOC_search','docbookChildWindow')"/>
</form>
<html id="results" OnDrawContent="DrawResults" seed="#(%page.SearchKey)#" />
<html><hr/></html>
</vgroup>
</page>
}

ClientMethod onloadHandler() [ Internal, Language = javascript ]
{
   zenPage.getComponentById('search').focus();
}

/// key Handler for text box.
ClientMethod keyHandler(evt) [ Internal, Language = javascript ]
{
    if (zenENTER == evt.keyCode) {
        zenPage.getComponentById('searchForm').submit();
        return false;
    }
    return true;
}

/// resetSearch
ClientMethod resetSearch() [ Internal, Language = javascript ]
{
   self.document.location = 'DocBook.UI.SearchPageZen.cls'
}

/// Search the web.
ClientMethod webSearch() [ Internal, Language = javascript ]
{
    var phrase = zenPage.getComponentById('search').getValue();
    phrase = cspEncodeUTF8(phrase);
    self.document.location = 'http://www.google.com/search?q=' + phrase;
}

/// search for the given phrase.
ClientMethod search(phrase, bookid) [ Internal, Language = javascript ]
{
    phrase = cspEncodeUTF8(phrase);
    self.document.location = 'DocBook.UI.SearchPageZen.cls?KeyWord=' + escape(phrase) + ((bookid==null || bookid=='') ? '' : '&Book=' + escape(bookid));
}

/// search for the given phrase.
ClientMethod research(phrase, bookid) [ Internal, Language = javascript ]
{
    phrase = cspEncodeUTF8(phrase);
    self.document.location = 'DocBook.UI.SearchPageZen.cls?KeyWord=' + phrase + ((bookid==null || bookid=='') ? '' : '&Book=' + escape(bookid));
}

/// doSearch (deprecated)
ClientMethod doSearch() [ Internal, Language = javascript ]
{
    var search = zenPage.getComponentById('search').getValue();
    var html = zenPage.getComponentById('results');
    if (search == html.getProperty('seed')) {
        // force change in value
        search += ' ';
    }
    html.setProperty('content','');
    html.setProperty('seed',search);
    html.setProperty('content','<div class="ZResult">'+zenPage.msgSearching+'</div>');
}

/// Escape only HTML characters
ClassMethod escHTML(StrIn As %String) As %String [ Internal ]
{
    Set StrOt = ""
    For i = 1 : 1 : $LENGTH(StrIn) {
        Set c = $EXTRACT(StrIn, i)
        If ((c = "&") || (c = "<") || (c = ">") || (c = "'")) {
            Set c = $ZCVT(c, "O", "HTML")
        }
        Set StrOt = StrOt _ c
    }
    Quit StrOt
}

/// Draw contents of HTML title component.
ClassMethod DrawTitle(pSeed As %ZEN.Datatype.string) As %Status [ Internal ]
{
    Set info = ##class(DocBook.UI.BannerInfo).%New()
    Set info.title = $$$T("Key Word Search")
    Set info.booktitle = $$$T("InterSystems Online Documentation")
        New %noshowframes
        Set %noshowframes = 1
    Do ##class(DocBook.UI.StdPage).RenderBanner(info)
    Quit $$$OK
}

/// Draw contents of HTML component with query results.
/// <var>pSeed</var> is of the form "BookId:phrase"
ClassMethod DrawResults(pSeed As %ZEN.Datatype.string) As %Status [ Internal ]
{
    &html<<a name="top"></a>>
    Set tSC = $$$OK
    Set tMatches = 0
    Set pSeed = $ZSTRIP(pSeed,"<>W")

    #; special case for eacute and ntilde
    Set pSeed = $TR(pSeed,$C(233,241),"en")

    Set tBookId = $P(pSeed,":",1)
    Set tPhrase = $P(pSeed,":",2)

    If (tPhrase = "") {
        #; if no search phrase *and* there is a cache, show recent items
        If ($D(^DocBook.SearchCacheIndex)) {
            Set msgHome = ""
            &html<<table class="ZTiming"><tr><td align="left">&nbsp;<a href="DocBook.UI.Page.cls">#(msgHome)#</a></td><td>&nbsp;</td></tr></table>>
            Set msgRecent = $$$TH("Recent searches:")
            &html<<br/><div class="ZMsg"><i>#(msgRecent)#</i></div><br/>>
            Set tSC = ..DrawRecentSearches()
        }
        Quit tSC
    }

    Set tDebug = +$G(^SearchDebug)
    If (tDebug > 1) {
        Do ..ClearCache()
    }
    
    Set tMax = 20   // items displayed per page
    Set tFirstItem = +$G(%request.Data("Num",1),1)

    Write:tDebug "<table class=""ZDebugTable"" border=""0"" cellpadding=""3"" cellspacing=""0"">"
    Set tStart = $ZH

    #; exec search, results will be in ^||results
    Set tSC = ..ExecSearch(pSeed,.tMatches,tDebug)
    If $$$ISERR(tSC) Quit tSC

    Set tSearchTime = $ZH - tStart
    Write:tDebug "</table>"

    Set tIndexedEntries = ..CountIndexedEntries(tPhrase)
    If (tIndexedEntries > 0)
    {
        Set msgTitles = $$$TH("Matches in titles")
        &html<<table class="ZTiming">>
        &html<<tr>>
        &html<<td>#(msgTitles)#: #(tIndexedEntries)#&nbsp;&nbsp;</td>>
        &html<</tr>>
        &html<</table>>
        
        Do ..ShowIndexedEntries(tPhrase)
    }

    Set msgResults = $$$TH("Matches in text")
    Set msgHome = ""
    Set dispPhrase = ..escHTML(tPhrase)
    
    If (tMatches > 0)
    {
        Set msgMatches = $$$FormatText($$$T("<b>%1</b> - <b>%2</b> of <b>%3</b> for <b>%4</b>. (%5s)"),(tFirstItem),$S(tMatches<(tFirstItem+tMax-1):tMatches,1:(tFirstItem+tMax-1)),tMatches,dispPhrase,tSearchTime)
        &html<<table class="ZTiming">>
        &html<<tr><td align="left">&nbsp;<a href="DocBook.UI.Page.cls">#(msgHome)#</a></td>>
        &html<<td>#(msgResults)#: #(msgMatches)#&nbsp;&nbsp;</td>>
        &html<</tr>>
        &html<</table>>
    }    

    If (tMatches <= 0) {
        Set msgPfx = $$$TH("No matches were found in text for ")
        Set:(tIndexedEntries = 0) msgPfx = $$$TH("No matches were found for ")
        Set msgNada = msgPfx _ dispPhrase _ " (" _ tSearchTime _ "s)"
        &html<<br/><div class="ZMsg">#(msgNada)#</div>>

        Set tGuess = ..DidYouMean(tPhrase)
        Set tDoGuessLang = (##class(DocBook.Utils).UsingJapanese()=0)
        Set tDoGuessTerms = (tGuess '= "")
        Set tNoTitleItems = (tIndexedEntries = 0)
        
        If (0 && tDoGuessLang && tDoGuessTerms && tNoTitleItems) {
            If (tDoGuessTerms) {
                Set msgMean = $$$TH("Did you mean:")
                &html<<br/><div class="ZMsg">#(msgMean)#&nbsp;<a href="DocBook.UI.SearchPageZen.cls?KeyWord=#($ZCVT(tGuess,"O","URL"))#">#(tGuess)#?</a></div>>
            }
        }
        Else {
            Set msgRefine = $$$TH("Please try searching for related terms.")
            &html<<br/><div class="ZMsg">#(msgRefine)#&nbsp;</div>>
        }
        Quit $$$OK
    }

    Set:tDebug tStart = $ZH
    Set msgRanking = $$$TH("Ranking")
    Set tMore = 0
    Set tCount = 0
    Set tRank = $O(^||results(""))
    If (tRank '= "") {
        While (tRank '= "") {
            Set tKey = $O(^||results(tRank,""))
            While (tKey '= "") {
                Set tCount = tCount + 1
                If (tCount>=tFirstItem) {
                    If (tCount>(tFirstItem+tMax)) {
                        Set tMore = 1
                        Quit
                    }
    
                    Set tSampleId = $O(^||results(tRank,tKey,""))

                    &sql(SELECT x__classname INTO :tClass
                        FROM DOCBOOK.block WHERE ID = :tKey)
    
                    Set tContainerKey = ""
                    Set tPath = ..GetCompPath(tKey,.tContainerKey)

                    &html<<div class="ZResult">#(tPath)#>
                    If (tSampleId = "") {
                        
                        #; TODO: The following test can never be true because
                        #; we don't have any idea what el is; its value is never
                        #; set inside this method and is not passed to it. Presumably
                        #; it's the name of the element where the phrase is found.
                        
                        If (",book,chapter,appendix,reference," [ (","_el_",")) {
                            &sql(SELECT subtitle INTO :tSubTitle
                                FROM DOCBOOK.container WHERE ID = :tKey)
                            If (tSubTitle '= "") {
                                Write "<div class=""sample""><i>"
                                Write tSubTitle
                                Write "</i></div>"
                            }
                        }
                        
                        #; TODO: The following test can never be true because
                        #; we don't have any idea what el is; its value is never
                        #; set inside this method and is not passed to it. Presumably
                        #; it's the name of the element where the phrase is found.
                        
                        ElseIf (",refentry," [ (","_el_",")) {
                            &sql(SELECT refmeta_refentrytitle INTO :tSubTitle
                                FROM DOCBOOK.refentry WHERE ID = :tKey)
                            If (tSubTitle '= "") {
                                Write "<div class=""sample""><i>"
                                Write tSubTitle
                                Write "</i></div>"
                            }
                        }
                    }
                    Else {
                        #; show sample entry for this item
                        While (tSampleId '= "") {
                            Do ..ShowItem(tSampleId,tContainerKey)
                            Set tSampleId = $O(^||results(tRank,tKey,tSampleId))
                        }
                    }

                    If (tDebug) {
                        &html<<div class="rank">#(msgRanking)#: #(-tRank)#</div>>
                    }
                    &html<</div>>
                }
                Set tKey = $O(^||results(tRank,tKey))
            }
            Set tRank = $O(^||results(tRank))
        }
    }

    &html<<br/><div class="ZResults" style="text-align:center;">>
    If (tMore || (tFirstItem>1)) {
        If (tFirstItem>1) {
            Set href = "DocBook.UI.SearchPageZen.cls?KeyWord=" _ $ZCVT($ZCVT(tPhrase,"O","UTF8"),"O","URL") _ $S(tBookId="":"",1:"&Book="_$ZCVT(tBookId,"O","URL")) _ "&Num=" _ (tFirstItem - tMax)
            Set msgPrev = $$$TH("Previous")
            &html<&nbsp;<a href="#(href)#">#(msgPrev)#</a>>
        }
        If (tMore) {
            Set href = "DocBook.UI.SearchPageZen.cls?KeyWord=" _ $ZCVT($ZCVT(tPhrase,"O","UTF8"),"O","URL") _ $S(tBookId="":"",1:"&Book="_$ZCVT(tBookId,"O","URL")) _ "&Num=" _ (tFirstItem + tMax)
            Set msgNext = $$$TH("Next")
            &html<&nbsp;<a href="#(href)#">#(msgNext)#</a>>
        }
    }
    Write "&nbsp;<A HREF=""#top"">", $$$T("Top of Page"), "</A>", !
    &html<</div>>

    Write:tDebug "<table class=""ZDebugTable"" border=""0"" cellpadding=""3"" cellspacing=""0"">"
    Write:tDebug "<tr><td>","Output (total):</td><td>",$ZH-tStart,"s</td><td>&nbsp;</td></tr>"
    Write:tDebug "</table>"

    #; test if cache needs to be purged
    Do ..PurgeCache()
    Quit $$$OK
}

/// Given an element name, such as "chapter", return an appropriate text label
/// to use when displaying the entry in the Search results.
/// Why is there not one universal utility to get text labels for both Search and Index?
/// The reason is that the display of Index results is formatted differently
/// than the display of Search results. Most importantly, the Index results page
/// serves a different purpose for the reader. That is why
/// there is one set of text labels for the Search class (encapsulated in this method) 
/// and a different convention in the DocBook.UI.Index.OnPage() method,
/// which displays the Index results. Note that this method currently generates
/// text labels for some items that currently do not show up in the Search results: book, reference, and article.
ClassMethod GetElementLabel(el As %String) As %String [ CodeMode = expression, Internal ]
{
$CASE(el,   "article" : $$$T("Article Title"),
            "book" : $$$T("Book Title"),
            "chapter" : $$$T("Chapter Title"),
            "sect1" : $$$T("Section Title"),
            "sect2" : $$$T("Section Title"),
            "sect3" : $$$T(""),
            "preface" : $$$T("Preface"),
            "refentry" : $$$T("Reference Page"),
            "reference" : $$$T("Reference Section"),
            "appendix" : $$$T("Appendix Title"),
            "glossentry" : $$$T("Definition"),
            "programlisting" : $$$T("Program Listing"),
            "figure" : $$$T("Figure"),
            "table" : $$$T("Table"),
            "informaltable" : $$$T("Table"),
            "block" : $$$T("Index Entry"),
             : "")
}

/// Count the number ofindexed entries
ClassMethod CountIndexedEntries(pPhrase As %String) As %Integer [ Internal ]
{
    Set pPhrase = $TR(pPhrase," ","")
    Set tKey = " " _ $ZCVT(pPhrase,"U")
    Set tCnt = 0
    
    If $D(^DocBook.Index(tKey)) {
        Set n = $O(^DocBook.Index(tKey,""))
        While (n'="") {
        Set tCnt = tCnt + 1
            Set n = $O(^DocBook.Index(tKey,n))
        }
    }
    Quit tCnt
}

/// See if the given phrase is in the *real* index.
/// If so, draw links.
ClassMethod ShowIndexedEntries(pPhrase As %String) [ Internal ]
{
    Set pPhrase = $TR(pPhrase," ","")
    Set tKey = " " _ $ZCVT(pPhrase,"U")
    
    If $D(^DocBook.Index(tKey)) {
        Set n = $O(^DocBook.Index(tKey,""))
        While (n'="") {
            Set caption = $LG(^DocBook.Index(tKey,n),1)
            Set link = $LG(^DocBook.Index(tKey,n),2)
            Set ctitle = $LG(^DocBook.Index(tKey,n),4)
            Set source = ..GetElementLabel($LG(^DocBook.Index(tKey,n),3))

            Set sample = ""
            If (ctitle '="") {
                Set sample = ctitle
            }
            If (source '= "") {
                Set sample = sample _ $S(sample="":"",1:"&nbsp;")_ "<span class=""ElLabel"">(" _ source _ ")</span>"
            }

            &html<<div class="ZResultIndex"><a href="DocBook.UI.Page.cls?#(link)#">#(caption)#</a><div class="sample">#(sample)#</div></div>>
            Set n = $O(^DocBook.Index(tKey,n))
        }
    }
}

/// Make a guess at next best phrase.
ClassMethod DidYouMean(pPhrase As %String) As %String [ Internal ]
{
    Set tResult = ""
    Set gcount = 0
    #; split phrase, test if each word is in the index.
    Set tTermList = ..MakeSearchTerms(pPhrase)
    For i=1:1:$LL(tTermList) {
        Set tWord = $LG(tTermList,i)
        Set tKey = " " _ $ZCVT(tWord,"U")
        Set tKey = $TR(tKey,"""$~!@#^&*()_+-=<>,.?/","")
        If $D(^DocBook.blockI("contentIdx",tKey)) {
            Set tResult = tResult _ $S(tResult="":"",1:" ")_tWord
        }
        Else {
            #; not in index
            Set gcount = gcount + 1

            #; first try permutations
            Set tGuess = ""
            Do ..Permute($E(tKey,2,*),.tPerms)
            Set k = $O(tPerms(""))
            While (k '= "") {
                If $D(^DocBook.blockI("contentIdx",(" "_k))) {
                    Set tGuess = (" "_k)
                    Quit
                }
                Set k = $O(tPerms(k))
            }

            If (tGuess = "") {
                #; else next item in index
                Set tGuess = $O(^DocBook.blockI("contentIdx",$E(tKey,1,$L(tKey)-1)))
                Set:tGuess["&#39;" tGuess = ""
            }
            Set tResult = tResult _ $ZCVT(tGuess,"l")
        }
    }

    Quit $S(gcount:$Zstrip(tResult,"<>W"),1:"")
}

/// Return set of permutations for the given word.
ClassMethod Permute(pWord As %String, Output pOut) [ Internal ]
{
    Kill pOut
    #; swap
    For p = 1:1:$L(pWord)-1 {
        Set temp = pWord
        Set $E(temp,p)=$E(pWord,p+1)
        Set $E(temp,p+1)=$E(pWord,p)
        Set:temp'="" pOut(temp) = ""
    }
    #; drop
    For p = 1:1:$L(pWord) {
        Set temp = pWord
        Set $E(temp,p)=""
        Set:temp'="" pOut(temp) = ""
    }
}

/// Execute the word search, place the results into the private 
/// global, ^||results(rank,id) = "".
ClassMethod ExecSearch(pPhrase As %String, Output pMatches As %Integer, pDebug As %Integer = 0) As %Status [ Internal ]
{
    Set tSearchKey = $E($ZCVT(pPhrase,"U"),1,250)

    Set tSC = $$$OK
    Set pMatches = 0

    Try {
        #; look in cache
        If ((tSearchKey '= "")&&($D(^DocBook.SearchCache(tSearchKey)))) {
            Merge ^||results =  ^DocBook.SearchCache(tSearchKey)
            Set pMatches = +$G(^||results)
            #; update time in index
            Do ..UpdateCacheIndex(tSearchKey)
            Quit
        }

        #; search
        Set tSC = ..GetRankedMatches(pPhrase,pDebug)
        If $$$ISERR(tSC) Quit

        #; now sort answers by rank
        Set:pDebug tStart = $ZH
        Set tID = $O(^||ids(""))
        While (tID '= "") {
            Set pMatches = pMatches + 1
            Set tRank = ^||ids(tID)
            Merge ^||results(tRank,tID) = ^||sample(tID)
            Set tID = $O(^||ids(tID))
        }
        
        #; count after merging in case of duplicates
        Set pMatches = 0
        Set xRank = ""
        Set xRank = $O(^||results(xRank))
        While (xRank '= "")
        {
            Set xKey = ""
            Set xKey = $O(^||results(xRank,xKey))
            While (xKey '= "")
            {
                Set pMatches = pMatches  + 1
                Set xKey = $O(^||results(xRank,xKey))
            }
            Set xRank = $O(^||results(xRank))
        }

        #; cache results
        If (tSearchKey '= "") {
            Set ^||results = pMatches
            Kill ^DocBook.SearchCache(tSearchKey)
            Merge ^DocBook.SearchCache(tSearchKey) = ^||results
            Do ..UpdateCacheIndex(tSearchKey)
        }
    }
    Catch(ex) {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}

/// Show list of recent searches.
ClassMethod DrawRecentSearches() As %Status [ Internal ]
{
    Set tSC = $$$OK
    Set tCols = 3

    Set tCount = 0
    Set tTime = $O(^DocBook.SearchCacheIndex("byTime",""),-1)
    While (tTime'="") {
        Set tKey = $O(^DocBook.SearchCacheIndex("byTime",tTime,""))
        While (tKey'="") {
            Set tMatches = +$G(^DocBook.SearchCache(tKey))
            If (tMatches > 0) {
                Set tBookId = $P(tKey,":",1)
                Set tPhrase = $P(tKey,":",2)
                Set tVal = $ZCVT($ZCVT(tPhrase,"l"),"O","HTML")
                Set:tBookId'="" tVal = tVal _ "&nbsp;(<i>" _ tBookId _ "</i>)"
                Set tCount = tCount + 1
                Set tArgPhrase = $ZCVT($ZCVT(tPhrase,"O","HTML"),"O","JS")
                ;Set tArgPhrase = tPhrase
                Set tArgBookId = $ZCVT($ZCVT(tBookId,"O","HTML"),"O","JS")
                &html<<div class="ZRecent"><a href="javascript:zenPage.research('#(tPhrase)#','#(tArgBookId)#')">#(tVal)#</a> <span class="ZCount">(#(tMatches)#)</span></div>>
            }
            Set tKey = $O(^DocBook.SearchCacheIndex("byTime",tTime,tKey))
        }
        Set tTime = $O(^DocBook.SearchCacheIndex("byTime",tTime),-1)
    }

    Quit tSC
}

/// Return the id of the document that contains the given id.
ClassMethod GetDocumentId(id As %String) As %String [ Internal ]
{
    &sql(SELECT container, x__classname
            INTO :ctr, :cls
            FROM DocBook.block
            WHERE id = :id)

    If (ctr = "") {
        #; we have no container
        Quit id
    }
    Else {
        Set el = ..GetElementName(cls)
        If (",book,chapter,refentry,reference,appendix,"[(","_el_",")) {
            Quit id
        }
        Else {
            Quit ..GetDocumentId(ctr)
        }
    }
}

/// Get the full component path for the given block.
ClassMethod GetCompPath(id As %String, Output pContainerKey) As %String [ Internal ]
{
    Set href = "DocBook.UI.Page.cls?KEY="
    Set component = ""
    &sql(SELECT title, container, x__classname,blockid
            INTO :title, :ctr, :cls, :blockid
            FROM DocBook.block
            WHERE id = :id)

    If (ctr = "") {
        If (title = "") {
            Quit ""
        }
        Set pre = ""
        If (cls [ "article") {
            Set pre = "<nobr><a href="""_href_"KNBASE"">" _ $$$T("Technical Articles") _ "</a></nobr> &raquo; "
        }
        Set:pContainerKey="" pContainerKey=blockid
        Quit pre _ "<nobr><a href="""_href_blockid_""">" _ title _ "</a></nobr>"
    }
    Else {
        Set:pContainerKey="" pContainerKey=blockid
        Set path = ..GetCompPath(ctr,.pContainerKey)
        Quit path _ $S(title'="":$S(path'= "":" &raquo; ",1:"") _ "<nobr><a href="""_href_blockid_""">"_title_"</a></nobr>",1:"")
    }
}

/// Display an individual search result.
/// <var>id</var> is the sample to display for the item.
/// <var>pContainerKey</var> is the key of the container for the item (used to make a link).
ClassMethod ShowItem(id As %String, pContainerKey As %String) [ Internal ]
{
    Set keyword = ""
    &sql(SELECT blockid,content,title,x__classname,container
        INTO :paraKey, :text, :ttl,:cls, :cid
        FROM DocBook.block
        WHERE ID = :id
    )
    
    If (SQLCODE '= 0) {
        Quit
    }

    #; if this block has a title, then it is the container
    If (ttl'="") {
        Set ckey = paraKey
        Set ctitle = ttl
        Set ccontent = text
        Set ccls = cls
    }
    Else {
        #; find reasonable container for the block
        Set found = 0
        While ('found) {
            &sql(SELECT blockid,title,content,x__classname,container
                INTO :ckey, :ctitle, :ccontent,:ccls,:pcid
                FROM DocBook.container
                WHERE ID = :cid
            )
            If ((ctitle'="")||(ccontent'="")||(pcid="")) {
                Set found = 1
            }
            Else {
                Set cid = pcid
            }
        }
    }

    #; special cases for rendering the contents of found items
    Set listing = 0
    Set hidden = 0
    Set rtext = ""
    If (cls [ "programlisting") {
        Set listing = 1
        Set rtext = ""
        &sql(SELECT renderedContent
            INTO :rtext
            FROM DocBook.programlisting
            WHERE ID = :id
        )
    }
    ElseIf (cls [ "anchor") {
        #; Don't display it
        Set hidden = 1
    }
    ElseIf (cls [ "sect2")||(cls [ "sect3") {
        #; Allow lower sections to display in their full context 
        #; (include the full surrounding chapter in the display)
        Set ckey = pContainerKey
    }

    #; display the search result
    If ((text'="")||(rtext'="")||(ttl'="")) {
        &html<<div class="sample">>

        Set tLbl = ""
        
        #; Get the name of the element that contains the search term.
        #; Get name for important things that don't have titles
        If ((cls [ "programlisting")||(cls [ "informaltable")) {
            Set el = ..GetElementName(cls)
        }
        #; Get name for important things that do have titles
        Else {          
            Set el = ..GetElementName(ccls)
        }
        #; Now get the label
        If (el '= "") {
            Set tLabel = ..GetElementLabel(el)
            If (tLabel '= "") {
                Set tLbl = "&nbsp;<span class=""ElLabel"">(" _ tLabel _ ")</span>"
            }
        }

        #; local heading
        Set head = ""
        If (ttl '= "") {
            Set head = ttl
        }
        ElseIf (ctitle '= "") {
            Set head = ctitle
        }
        ElseIf (ccontent '="") {
            Set head = ccontent
        }

        If (head '= "") {
            Set href = "DocBook.UI.Page.cls?KEY="
            If (pContainerKey'=ckey) {
                Set link = href_pContainerKey_"#"_ckey
            }
            Else {
                Set link = href_pContainerKey_"#"_paraKey
            }
            &html<<div class="subhead"><a href="#(link)#">#(head)#</a>#(tLbl)#</div>>
        }

        If (listing) {
            If (rtext = "") {
                Write "<pre>",text,"</pre>",!
            }
            Else {
                Write rtext,!
            }
        }
        Else {
            #; If we are returning too much data just display the relevant section
            If $length(text)>3000 {
                Set upper=$zconvert(text,"U"),upkeyword=$zconvert(keyword,"U")
                Set pos=1,len=$length(keyword)
                #; Special case for tables to try and preserve table formatting
                If $extract(upper,1,7)="<TGROUP",upper["</THEAD>" {
                    #; Find the table header
                    Set pos=$find(upper,"</THEAD>")
                    Set head=$extract(text,1,pos-1)
                    Set output=""
                    #; Now output this cut down table !!!
                    If output'="" Do ##class(DocBook.Renderer).RenderText(head_"<tbody>"_output_"</tbody></tgroup>","")
                }
                Else {
                    #; Set text=..StripTags(text)
                    #; Do ##class(DocBook.Renderer).RenderText(text)
                    Do ##class(DocBook.Renderer).RenderText(text,keyword,,,1)
                }
            }
            #; hide text that doesn't help, such as text from anchor elements
            ElseIf hidden {}
            Else {
                Do ##class(DocBook.Renderer).RenderText(text,keyword,,,1)
            }
        }
        &html<</div>>
    }
}

/// Remove markup from the given string.
ClassMethod StripTags(text As %String) As %String [ Internal ]
{
    Set output=""
    Set pos=$find(text,"<",1)
    While pos {
        Set pos2=$find(text,">",pos)
        Set pos=$find(text,"<",pos)
        Set output=output_$extract(text,pos2,pos-2)_" "
    }
    Quit output
}

/// Given the class name returned by an SQL statement (x__classname), return
/// the DocBook element name.
ClassMethod GetElementName(pClass As %String) As %String [ CodeMode = expression, Internal ]
{
$P($P(pClass,"~",$L(pClass,"~")-1),".",2)
}

/// Purge search items older than 14 days.
ClassMethod PurgeCache() [ Internal ]
{
    Set tNow = +$H
    If (tNow > +$G(^DocBook.SearchCacheIndex)) {
        #; remember time of last purge
        Set ^DocBook.SearchCacheIndex = $H
        Set tTime = $O(^DocBook.SearchCacheIndex("byTime",""))
        While (tTime'="") {
            If ((tNow - tTime) > 14) {
                Set tKey = $O(^DocBook.SearchCacheIndex("byTime",tTime,""))
                While (tKey '= "") {
                    Kill ^DocBook.SearchCacheIndex("byKey",tKey)
                    Kill ^DocBook.SearchCacheIndex("byTime",tTime,tKey)
                    Kill ^DocBook.SearchCache(tKey)
                    Set tKey = $O(^DocBook.SearchCacheIndex("byTime",tTime,tKey))
                }
            }
            Set tTime = $O(^DocBook.SearchCacheIndex("byTime",tTime))
        }
    }
}

/// Update the cache index for the given search key term.
ClassMethod UpdateCacheIndex(pSearchKey As %String) [ Internal ]
{
    If (pSearchKey="") {
        Quit
    }

    #; Index structure:
    #; ^DocBook.SearchCacheIndex("byKey",tSearchKey) = $H
    #; ^DocBook.SearchCacheIndex("byTime",+$H,tSearchKey) = ""

    Lock +^DocBook.SearchCacheIndex(pSearchKey):5
    If '$T Quit

    #; remove old entry
    If $D(^DocBook.SearchCacheIndex("byKey",pSearchKey)) {
        Set tThen = $G(^DocBook.SearchCacheIndex("byKey",pSearchKey))
        Kill:tThen'="" ^DocBook.SearchCacheIndex("byTime",+tThen,pSearchKey)
    }

    #; set new entry
    Set tNow = $H
    Set ^DocBook.SearchCacheIndex("byKey",pSearchKey) = tNow
    Set ^DocBook.SearchCacheIndex("byTime",+tNow,pSearchKey) = ""
    Lock -^DocBook.SearchCacheIndex(pSearchKey)
}

/// Clear out search cache.
ClassMethod ClearCache() [ Internal ]
{
    Kill ^DocBook.SearchCacheIndex
    Kill ^DocBook.SearchCache
}

/// This callback is called when a form on this page is submitted.
/// <var>pSubmit</var> is a <class>%ZEN.Submit</class> object
/// containing details of the form submit.<br>
/// Subclasses override this method.
ClassMethod %OnSubmit(pSubmit As %ZEN.Submit) As %Status [ Internal ]
{
    If (pSubmit.%GetValue("KeyWord")="") {
        Kill %response.Context("KeyWord")
    }
    Else {
        Set %response.Context("KeyWord") = pSubmit.%GetValue("KeyWord")
    }
    If (pSubmit.%GetValue("Book")="") {
        Kill %response.Context("Book")
    }
    Else {
        Set %response.Context("Book") = pSubmit.%GetValue("Book")
    }
    Quit $$$OK
}

/// List words in the index of words that start with <var>pKey</var>.
Query EnumerateSearchTerms(pKey As %String = "") As %Query(ROWSPEC = "Word:%String")
{
}

ClassMethod EnumerateSearchTermsExecute(ByRef qHandle As %Binary, pKey As %String = "") As %Status [ Internal ]
{
    Set qHandle("stem") = $P(pKey," ",1,$L(pKey," ")-1)
    Set pKey = $P(pKey," ",$L(pKey," ")) // last word only

    Set pKey = $TR(pKey,"""~!@#^&*()-+=/?,.<>","")
    Set:pKey="" pKey="a"
    Set qHandle("search") = " " _ $ZCVT(pKey,"U")

    Set qHandle("key") = " " _ $ZCVT(pKey,"U")
    Set qHandle("count") = 0
    Quit $$$OK
}

ClassMethod EnumerateSearchTermsFetch(ByRef qHandle As %Binary, ByRef Row As %List, ByRef AtEnd As %Integer = 0) As %Status [ Internal, PlaceAfter = EnumerateSearchTermsExecute ]
{
    Set qHandle("key") = $O(^DocBook.blockI("contentIdx",qHandle("key")))
    If ((qHandle("search")'=" ") && (qHandle("count")<300) && (qHandle("key")'="") && ($E(qHandle("key"),1,$L(qHandle("search"))) = qHandle("search"))) {
        Set qHandle("count") = qHandle("count") + 1
        Set Row = $LB($S(qHandle("stem")="":"",1:qHandle("stem")_" ") _ $ZCVT($E(qHandle("key"),2,*),"L"))
        Set AtEnd = 0
    }
    Else {
        Set Row = ""
        Set AtEnd = 1
    }
    Quit $$$OK
}

ClassMethod EnumerateSearchTermsClose(ByRef qHandle As %Binary) As %Status [ Internal, PlaceAfter = EnumerateSearchTermsExecute ]
{
   Quit $$$OK
}

/// Execute the word search algorithm.
/// Place the results into process private globals:<br>
/// ^||id(id) = -rank: contains ids (of containers) in ranked order.
/// ^||sample(tContainer,id) = "": contains a sample matching id.
ClassMethod GetRankedMatches(pPhrase As %String, pDebug As %Integer = 0) As %Status [ Internal ]
{
    Set tSC = $$$OK

    Try {
        Set tBookId = $P(pPhrase,":",1)
        Set pPhrase = $P(pPhrase,":",2)

        #; relative weight for different elements
        Set elwgt("book") =  300
        Set elwgt("reference") =  200
        Set elwgt("article") =  120
        Set elwgt("qandadiv") =  100
        Set elwgt("answer") =  100
        Set elwgt("question") =  100
        Set elwgt("refentry") =  80
        Set elwgt("chapter") =  80
        Set elwgt("appendix") =  80
        Set elwgt("sect1") =  70
        Set elwgt("sect2") =  60
        Set elwgt("sect3") =  50
        Set elwgt("figure") =  40
        Set elwgt("synopsis") =  35
        Set elwgt("refpurpose") =  15
        Set elwgt("programlisting") =  10
        Set elwgt("table") =  3  // hard to disambiguate table title from content!

        #; split phrase into words
        Set tWORDS = ""
        Set tTermList = ..MakeSearchTerms(pPhrase)
        Set tMaxTerms = 99
        Set tTermCnt = $LL(tTermList)
        Set:(tTermCnt > tMaxTerms) tTermCnt = tMaxTerms
        For i=1:1:tTermCnt {
            Set w = $LG(tTermList,i)
            Set w = $TR(w,"'""","") // make sure there are no 's in the word
            Set tWORDS = tWORDS _ $S(tWORDS'="":",",1:"")_"'"_w_"'"
        }

        #; test for quoted words
        Set tTitleContains = ""
        Set tContentContains = ""
        Do ..FindQuotedStrings(pPhrase, .tQuotes)
        Set k = $O(tQuotes(""))
        While (k '= "") {
            Set tTitleContains = tTitleContains _ $S(tTitleContains'="":" AND ",1:"")_"UPPER(title) ['"_$ZCVT(k,"U")_"'"
            Set tContentContains = tContentContains _ $S(tContentContains'="":" AND ",1:"")_"UPPER(content) ['"_$ZCVT(k,"U")_"'"
            Set k = $O(tQuotes(k))
        }
        Set:tTitleContains'="" tTitleContains = " AND (" _ tTitleContains _ ")"
        Set:tContentContains'="" tContentContains = " AND (" _ tContentContains _ ")"

        If (tWORDS '= "") {
            #; search on titles OR content
            Set:pDebug tStart = $ZH
            Set tRS = ##class(%ResultSet).%New()
            //Set tSQL = "SELECT TOP 10000 ID,x__classname,"_$S(pDebug>1:"title,",1:"")_"component compId,CASE WHEN title IS null then 'content' Else 'title' END source from DOCBOOK.block WHERE ((title %CONTAINSTERM("_tWORDS_")"_tTitleContains_") OR (content %CONTAINSTERM("_tWORDS_")"_tContentContains_"))"
            Set tSQL = "SELECT " _
                       "TOP 10000 " _
                       "ID, " _
                       "x__classname, " _
                       $S(pDebug>1:"title, ",1:"") _
                       "component compId, " _ 
                       "CASE WHEN title IS null then 'content' Else 'title' END " _ 
                       "source " _
                       "FROM " _
                       "DOCBOOK.block " _
                       "WHERE " _ 
                       "((title %CONTAINSTERM(" _ tWORDS _ ")" _ tTitleContains _ ") " _
                       "OR " _ 
                       "(content %CONTAINSTERM(" _ tWORDS _ ")" _ tContentContains _ "))"
            Set:tBookId'="" tSQL = tSQL _ " AND book->blockid = ?"
            Set tSC = tRS.Prepare(tSQL)
            If $$$ISERR(tSC) Quit
            Set tSC = tRS.Execute(tBookId)
            If $$$ISERR(tSC) Quit
    
            Set c = 0
            While (tRS.Next()) {
                Set c = c + 1
                Set source = tRS.Data("source")
                Set el = ..GetElementName(tRS.Data("x__classname"))
                Set:el="" el="Misc"
    
                Set tID = tRS.Data("ID")
                Set tBucket = tRS.Data("compId")
                Set:tBucket="" tBucket = tID
    
                If (source = "title") {
                    Set weight = $G(elwgt(el),20)
                    Write:(pDebug>1) "<tr><td>title: ",$G(tRS.Data("title")),"</td><td>",el,"</td><td>b: ",tBucket,"</td><td>wgt: ",weight,"</td><td>id: ",tID,"</td></tr>"

                    Set x = $I(^||ids(tBucket),-weight)
                    If (tBucket'=tID) {
                        Set ^||sample(tBucket,tID) = ""
                    }
                }
                Else {
                    Set weight = $G(elwgt(el),1)
                    Write:(pDebug>1) "<tr><td>cont: <pre>",$G(tRS.Data("content")),"</pre></td><td>",el,"</td><td>b: ",tBucket,"</td><td>wgt: ",weight,"</td><td>id: ",tID,"</td></tr>"

                    Set x = $I(^||ids(tBucket),-weight)
                    If ('$D(^||sample(tBucket))) {
                        Set ^||sample(tBucket,tID) = ""
                    }
                }
            }
            Write:pDebug "<tr><td>","Search:</td><td>",$ZH-tStart,"s</td><td>",$G(c),"</td><td>",$G(tSQL),"</td></tr>"
        }
    }
    Catch(ex) {
        Set tSC = ex.AsStatus()
    }

    Quit tSC
}

/// Find quoted strings with phrase.
ClassMethod FindQuotedStrings(pPhrase As %String, Output pWords) [ Internal ]
{
    #; look for quoted strings in phrase
    Set inquote = 0
    Set start = 0
    Set p = 0
    Set p = $Find(pPhrase,"""",p)
    While (p '= 0) {
        If (inquote) {
            Set w = $E(pPhrase,start,p-2)
            Set:w'="" pWords(w)=""
            Set inquote = 0
        }
        Else {
            Set start = p
            Set inquote = 1
        }
        Set p = $Find(pPhrase,"""",p)
    }
}

/// Wrapper for MakeSearchTerms method in text index class.
ClassMethod MakeSearchTerms(pPhrase As %String) As %List
{
    #; dispatch to run-time specified language class
    Set tLangClass = $G(^DocBook.Config("INDEXCLASS"),"DocBook.IndexedText")
    Quit $CLASSMETHOD(tLangClass,"MakeSearchTerms",pPhrase)
}

}
