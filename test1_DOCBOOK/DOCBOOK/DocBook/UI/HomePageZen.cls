Include DocBookMac

/// A Zen-based Home page for DocBook.
Class DocBook.UI.HomePageZen Extends %ZEN.Component.page [ DependsOn = DocBook.UI.buttonViewX ]
{

/// Class name of application this page belongs to.
Parameter APPLICATION;

/// Displayed name of this page.
Parameter PAGENAME = "Documentation Home Page";

Parameter CSSINCLUDES = "docbookhtml.css";

/// Domain used for localization.
Parameter DOMAIN = "DOCBOOK";

/// This Style block contains page-specific CSS style definitions.
XData Style
{
<style type="text/css">

body {
	background: #FFFAE7;
}

.bvwTable {
	border: none;
	background: none;
}

/* local override */
div.para1 {
	margin-left: 20px;
}

.menuTable {
	border: none;
	border-bottom: 1px solid darkblue;
	background: #404040;
	background-image: url(images/grad-gray-10x100.png);
	background-repeat: repeat-x;
}

a.menuItem {
	font-size: 0.9em;
	padding: 1px 2px 1px 2px;
	color: black;
}

a.menuItem:hover {
	color: darkblue;
}

.TOCnomatch {
	color: #202020;
	font-style: italic;
	padding: 20px;
	text-align: center;
}

a.TOCChapter {
	font-size: 1.2em;
	margin-top: 0px;
	margin-bottom: 0px;
	padding-top: 0px;
	padding-bottom: 0px;
}

a.TOCRemove {
    text-align: right;
	font-size: 0.8em;
}

.TOCgroup {
	padding-top: 5px;
	padding-left: 15px;
	padding-bottom: 5px;
	padding-right: 40px;
	background: #404040;
	background-image: url(images/grad-gray-10x100.png);
	background-repeat: repeat-x;
	color: black;
	font-variant: small-caps;
	letter-spacing: 1px;
	text-align: center;
	font-size: 1.2em;
	border-top: 1px solid #808080;
}

.TOCgroupexplain {
	padding-top: 5px;
	padding-left: 15px;
	padding-bottom: 10px;
	padding-right: 40px;
	color: black;
	letter-spacing: 1px;
	text-align: center;
	font-size: 0.9em;
}

.TOCdiv {
	padding-top: 5px;
	padding-left: 15px;
	padding-bottom: 5px;
	padding-right: 40px;
	border-top: 1px solid silver;
}

.TOCdesc {
	color: black;
	font-size: 0.9em;
	padding-top: 0px;
	padding-left: 30px;
	padding-bottom: 0px;
	padding-right: 40px;
}

dd {
	font-size: 0.9em;
}

a.TOCChapter:hover {
	background: #FFEEAA;
}

#toc {
	background: white;
	border: 1px solid black;
	overflow: auto;
	padding: 0px;
	margin: 0px;
	margin-top: 4px;
	color: darkblue;
}

#filter {
}

</style>
}

/// This XML block defines the contents of this page.
XData Contents [ XMLNamespace = "http://www.intersystems.com/zen" ]
{
<page xmlns="http://www.intersystems.com/zen" 
xmlns:db="docbook"
title="Documentation Home Page">
<html id="title" OnDrawContent="DrawTitle"/>
<menu id="menuBar" width="100%">
<menuItem id="menuStart" caption="Getting Started" link="DocBook.UI.Page.cls?KEY=GettingStarted"/>
<!--    //AAH791
<menuItem id="menuIndex" caption="Master Index" link="DocBook.UI.Index.cls"/>
<menuItem id="menuMap" caption="Feature Map" link="featuremapCache.csp"/>
-->
<menuItem id="menuRef" caption="Class Reference" link="/csp/documatic/%25CSP.Documatic.cls" target="_blank"/>
<menuItem id="menuSearch" caption="Search Page" link="DocBook.UI.SearchPageZen.cls"/>
<spacer width="80%"/>
</menu>
<spacer height="10"/>
<hgroup width="100%" cellVAlign="top" cellAlign="left">
<spacer width="30"/>
<vgroup>
<buttonViewX id="filter" columns="2" 
onselect="zenPage.filterChange(value);"
OnGetButtonInfo="GetFilterList"/>
</vgroup>
<spacer width="10"/>
<html id="toc" OnDrawContent="DrawTOC"/>
</hgroup>
</page>
}

Method %OnAfterCreatePage() As %Status
{
    Set inEnsemble = ##class(DocBook.Utils).EnsembleLoaded()
    Set inHealthShare = ##class(DocBook.Utils).HealthShareLoaded()
    Set inTrakCare  = ##class(DocBook.Utils).TrakCareLoaded()

	If (inEnsemble) {
		#; point to correct feature map
		Set item = ..%GetComponentById("menuMap")
		If ($IsObject(item)) {
			Set item.link = "featuremapEnsemble.csp"
		}
	}

	If (inHealthShare) {
		#; point to correct feature map
		Set item = ..%GetComponentById("menuMap")
		If ($IsObject(item)) {
			Set item.link = "featuremapHealthShare.csp"
		}
	}

	If (inTrakCare) {
		#; point to correct feature map
		Set item = ..%GetComponentById("menuMap")
		If ($IsObject(item)) {
			Set item.link = "featuremapTrakCare.csp"
		}
	}
	Quit $$$OK
}

/// User change to filter buttons.
ClientMethod filterChange(list) [ Language = javascript ]
{
	var html = zenPage.getComponentById('toc');
	var div = html.getEnclosingDiv();
	div.scrollTop = 0;
	html.seed = list;
	html.refreshContents();
}

/// Draw contents of HTML title component.
ClassMethod DrawTitle(pSeed As %ZEN.Datatype.string) As %Status [ Internal ]
{
	Set info = ##class(DocBook.UI.BannerInfo).%New()
	Set info.title = $$$T("Documentation Home Page")
	Set info.booktitle = $$$T("InterSystems Online Documentation")
	New %noshowframes
	Set %noshowframes = 1
	Do ##class(DocBook.UI.StdPage).RenderBanner(info)
	Quit $$$OK
}

/// Draw a list of books.
/// <var>pSeed</var> is of the form "group:value;"
ClassMethod DrawTOC(pSeed As %String) As %Status
{
	Set tRemove = 0
	Set tCount = ""
	If (pSeed = "") {
		#; preface
		&html<<div style="padding-top: 10px; padding-bottom:20px;">>
		&html<<div class="para1">>
		Write $$$T("Welcome to the InterSystems online documentation."), !
		&html<<br/>>
		Write $$$T("Click on one of the documents below to find more information."), !
		&html<<br/>>
		Write $$$T("You can use combinations of the buttons on the left to find out about specific topics."), !
		&html<<br/>>
		Write $$$T("Press Reset to start again."), !
		&html<</div>>
		&html<<div>>

		Do ..OrderSETs(.setorder)

		Set setno = 0
		Set setid = $O(setorder(""))
	    While (setid '="") {
			Set set = $G(setorder(setid))
			If ($IsObject(set)) {
				Set tBookList($I(setno)) = $LISTBUILD(set.title, set.subtitle)
				//Set tBookList($I(setno)) = set.title
				Do ..GetBooksForSet(set.%Id(), setno, .tBookList)
			}
			Set setid = $O(setorder(setid))
		}
	}
	ElseIf (pSeed = ":Recent;") {
		Set tRemove = 1
		#; Make list of recent books, ordered by time
		Set tKey = $O(^DocBook.RecentList(""))
		While (tKey'="") {
			Set:$G(^DocBook.RecentList(tKey))'="" tList(^DocBook.RecentList(tKey),tKey) = ""
			Set tKey = $O(^DocBook.RecentList(tKey))
		}

		Set n = 0
		Set tTime = $O(tList(""),-1)
		While (tTime'="") {
			Set tKey = $O(tList(tTime,""))
			While (tKey '= "") {
				Set t = $ZDTH(tTime,3)
				Set tSlot = $Case($H-t,0:1,1:2,2:3,:4)
				Set tBookList(tSlot,$I(n)) = tKey
				Set tKey = $O(tList(tTime,tKey))
			}
			Set tTime = $O(tList(tTime),-1)
		}
		Set:$D(tBookList(1)) tBookList(1) = $$$Text("Today")
		Set:$D(tBookList(2)) tBookList(2) = $$$Text("Yesterday") 
		Set:$D(tBookList(3)) tBookList(3) = $$$Text("2 days ago")
		Set:$D(tBookList(4)) tBookList(4) = $$$Text("More than 2 days ago")
		If (n > 0) {
			&html<<div style="padding-top: 10px; padding-bottom:20px;">>
			&html<<div class="para1">>
			Write $$$FormatText($$$T("The set of most recently viewed documents is shown below."),tCount)
			&html<<br/>>
			Write $$$T("Click on one of the documents below to find more information."), !
			&html<<br/>>
			Write $$$T("Press Reset to start again."), !
			&html<</div>>
			&html<<div>>
		}
	}
	ElseIf (pSeed '= "") {
		#; make sure global book list is built
		#; copy top-node into tBooks
		Do ..GetBookList(.tBooks)

		#; assemble list using filters
		If (pSeed '= "*:All;") {
			#; loop over each value in seed
			For n = 1:1:$L(pSeed,";") {
				Set tFilterPair = $P(pSeed,";",n)
				Set tGroup = $P(tFilterPair,":",1)
				Set tFilterValue = $P(tFilterPair,":",2)

				#; test books, remove non-matches
				If (tGroup = "*") {
					#; ignore
				}
				ElseIf (tFilterValue '= "") {
					Set tBook = $O(tBooks(""))
					While (tBook '= "") {
						If (tGroup '= "") {
							If (('$D(^DocBook.BookList(tBook,tGroup,tFilterValue))) && ('$D(^DocBook.BookList(tBook,tGroup,"*")))) {
								Kill tBooks(tBook)
							}
						}
						Set tBook = $O(tBooks(tBook))
					}
				}
			}
		}

		#; arrange the list into categories
		#; sort by "title" (actually, remap)
		Set tKey = $O(tBooks(""))
		While (tKey '= "") {
			// !!!
			Set tTaxonomy = $ORDER(^DocBook.BookList(tKey, "book", ""))
			Set:($LENGTH(tTaxonomy) < 1) tTaxonomy = "Unknown"
			Set tCat = $Case($E(tTaxonomy,1,1),"G":1,"R":2,"T":3,"A":4,:1)
			Set tTitle = tBooks(tKey)
			Set:tTitle="" tTitle="zzz"
			Set tList(tCat,tTitle,tKey) = ""
			Set tKey = $O(tBooks(tKey))
		}

		#; build the final list
		Set n = 0
		Set tCat = $O(tList(""))
		While (tCat '= "") {
			Set tTitle = $O(tList(tCat,""))
			While (tTitle'="") {
				Set tKey = $O(tList(tCat,tTitle,""))
				While (tKey '= "") {

					Set tBookList(tCat,$I(n)) = tKey
					Set tKey = $O(tList(tCat,tTitle,tKey))
				}
				Set tTitle = $O(tList(tCat,tTitle))
			}
			Set tCat = $O(tList(tCat))
		}
		Set tCount = n
		Set:$D(tBookList(1)) tBookList(1) = $$$Text("Guides")
		Set:$D(tBookList(2)) tBookList(2) = $$$Text("References") 
		Set:$D(tBookList(3)) tBookList(3) = $$$Text("Tutorials")
		Set:$D(tBookList(4)) tBookList(4) = $$$Text("Articles")
	}

	If (tCount '= "") {
		If (tCount > 1) {
			&html<<div style="padding-top: 10px; padding-bottom:20px;">>
			&html<<div class="para1">>
			Write $$$FormatText($$$T("You have selected %1 documents."),tCount)
			&html<<br/>>
			Write $$$T("Click on one of the documents below to find more information."), !
			&html<<br/>>
			Write $$$T("Press Reset to start again."), !
			&html<</div>>
			&html<<div>>
		}
	}

	#; show the books
	Do ..DisplayBookList(.tBookList, tRemove)
	&html<<hr style="margin-right:120px;margin-left:120px;"/>>
	&html<<hr style="margin-right:140px;margin-left:140px;"/>>
	&html<<hr style="margin-right:160px;margin-left:160px;"/>>

	Quit $$$OK
}

/// Create global list of books with group/value information.
ClassMethod GetBookList(Output pBooks) As %Status
{
	Set tSC = $$$OK

	#; first build set of *all* books
	&sql(DECLARE ACursor CURSOR FOR
		SELECT ID,blockid,remap,title
		FROM DocBook.book
		UNION ALL
		SELECT ID,blockid,remap,title
		FROM DocBook.article
	)

	&sql(OPEN ACursor)
	&sql(FETCH ACursor INTO :setid,:key,:remap,:title)
	While (SQLCODE = 0) {
		Set pBooks(key) = $S(remap="":title,1:remap)
		&sql(FETCH ACursor INTO :setid,:key,:remap,:title)
	}
	&sql(CLOSE ACursor)

	#; now add additional info about books
	#; this goes into the ^DocBook.BookList global
	If '$D(^DocBook.BookList) {
		Set tSC = ##class(DocBook.Utils).Classify()
	}

	Quit tSC
}

/// Get list of books for the given set
ClassMethod GetBooksForSet(setid, pSetNo, ByRef pBookList) [ Internal ]
{
	// loop over books
	&sql(DECLARE BookCursor CURSOR FOR
		SELECT ID,blockid,title,remap
		INTO :id,:bookKey,:title,:remap
		FROM DocBook.book
		WHERE container = :setid
		ORDER BY remap, title
	)

	Set n = 0
	&sql(OPEN BookCursor)
	&sql(FETCH BookCursor)
	While (SQLCODE = 0) {
		Set pBookList(pSetNo,$I(n)) = bookKey	
		&sql(FETCH BookCursor)
	}
	&sql(CLOSE BookCursor)
}

/// Produce an array of set names in remap order
ClassMethod OrderSETs(ByRef SetList, ByRef SetIds) [ Internal ]
{
	Set setid = $O(^DocBook.blockI("setIdx",""))
	Set keyinx = 0
	While (setid '="") {
		Set set = ##class(DocBook.set).%OpenId(setid)
		If (set '="") {
			Set keyinx = $INCREMENT(keyinx)
			Set sortkey = set.remap
			If (sortkey = "") {
				Set sortkey = "~" _ (1000 + keyinx)
			}
			Set SetList(sortkey) = set
			Set SetIds(sortkey) = setid
			Set set = ""
		}
		Set setid = $O(^DocBook.blockI("setIdx",setid))
	}
	Quit
}

/// This is a test method;
/// This displays the list of known books organized by group and value.
ClassMethod Analyze()
{
	Do ..GetBookList(.pBooks)
	Set tBook = $O(pBooks(""))
	While (tBook '= "") {
		Set tGroup = $O(^DocBook.BookList(tBook,""))
		While (tGroup '= "") {
			Set tValue = $O(^DocBook.BookList(tBook,tGroup,""))
			While (tValue '= "") {

				Set tIndex(tGroup,tValue,tBook) = ""
	
				Set tValue = $O(^DocBook.BookList(tBook,tGroup,tValue))
			}

			Set tGroup = $O(^DocBook.BookList(tBook,tGroup))
		}
		Set tBook = $O(^DocBook.BookList(tBook))
	}

	#; print out index
	Set tGroup = $O(tIndex(""))
	While (tGroup '= "") {
		Write "----------------------",!,tGroup,!
		Set tValue = $O(tIndex(tGroup,""))
		While (tValue '= "") {
			Write ?2,tValue," ("
			Set c = 0
			Set tBook = $O(tIndex(tGroup,tValue,""))
			While (tBook '= "") {
				Write tBook," "
				Set c = c + 1

				Set tBook = $O(tIndex(tGroup,tValue,tBook))
			}
			Write "(",c,") )",!

			Set tValue = $O(tIndex(tGroup,tValue))
		}
		Set tGroup = $O(tIndex(tGroup))
	}
}

/// Display the list of books as HTML.<br>
/// <var>pBookList</var> is of the form:<br>
/// pBookList(group) = title or $LISTBUILD(title,subtitle)<br/>
/// pBookList(group,n) = key<br/>
ClassMethod DisplayBookList(ByRef pBookList, pRemove As %Boolean = 0) [ Internal ]
{
	If ('$D(pBookList)) {
		#; no choices
		Set tMsg1 = $$$Text("No documents match the current selection.")
		Set tMsg2 = $$$Text("Press Reset and try a different combination.")
	    &html<<div class="TOCnomatch">#(tMsg1)#</div>>
	    &html<<div class="TOCnomatch">#(tMsg2)#</div>>
		Quit
	}

	Set msgRemove = $$$Text("Remove")
	Set helpRemove = $$$Text("Remove this item from the Recent list")

    &html<<div class="para">>
	Set tGroup = $O(pBookList(""))
	While (tGroup '= "") {
		If ($G(pBookList(tGroup)) '= "") {
			&html<<div class="TOCgroup">>
			If ($LISTVALID(pBookList(tGroup)))
			{
				&html<<a title="#($LISTGET(pBookList(tGroup),2))#">>
				&html<#($LISTGET(pBookList(tGroup),1))#>
				&html<</a>>
				//&html<#($LISTGET(pBookList(tGroup),1))#>
				//&html<<br>>
				//&html<<span class="TOCgroupexplain">>
				//&html<#($LISTGET(pBookList(tGroup),2))#>
				//&html<</span>>
			}
			Else
			{
				&html<#(pBookList(tGroup))#>
			}
			&html<</div>>
		}

		Set n = $O(pBookList(tGroup,""))
		While (n '= "") {
			Set key = pBookList(tGroup,n)
			Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(key,"O","URL") _ """"
	
			&sql(SELECT title,subtitle INTO :title,:desc
				FROM DocBook.container
				WHERE blockid = :key)

			&html<<div class="TOCdiv">>
			&html<<a class="TOCChapter" #(link)# onclick="return zenPage.register('#(key)#');">>
			&html<#(title)#>
			&html<</a>>
			If (pRemove) {
				&html<<a class="TOCRemove" title="#(helpRemove)#" href="#" onclick="zenPage.removeItem('#(key)#');return false;">>
				&html<#(msgRemove)#>
				&html<</a>>
			}
	
			&html<<div class="TOCdesc">>
			&html<#(desc)#>
			&html<</div>>

			#; #&nbsp;&#151;&nbsp;(<span class="filename">#(key)#</span>)
	
			&html<</div>>
			Set n = $O(pBookList(tGroup,n))
		}
		Set tGroup = $O(pBookList(tGroup))
	}
    &html<</div>>
}

/// Note that user clicked a specific choice.
ClientMethod register(pKey As %String) [ Language = javascript ]
{
	var ok = zenPage.RegisterClick(pKey);
	return true;
}

/// Note that user clicked a specific choice.
ClassMethod RegisterClick(pKey As %String) As %Boolean [ ZenMethod ]
{
	Set ^DocBook.RecentList(pKey) = $ZDT($H,3)
	Quit 1
}

/// Remove item from the recent list.
ClassMethod RemoveRecentItem(pKey As %String) As %Boolean [ ZenMethod ]
{
	Kill ^DocBook.RecentList(pKey)
	Quit 1
}

/// Remove item from the recent list and update display.
ClientMethod removeItem(key) [ Language = javascript ]
{
	try {
		this.RemoveRecentItem(key);
		var html = zenPage.getComponentById('toc');
		var div = html.getEnclosingDiv();
		div.scrollTop = 0;
		html.refreshContents();
	} 
	catch(ex) {
		zenExceptionHandler(ex,arguments,'Error in removeItem');
	}
}

ClassMethod MakeList() [ Internal ]
{
	#; first build set of *all* books
	&sql(DECLARE TCursor CURSOR FOR
		SELECT ID,blockid
		FROM DocBook.book
		UNION ALL
		SELECT ID,blockid
		FROM DocBook.article
		ORDER BY blockid
	)

	Set n = 0
	&sql(OPEN TCursor)
	&sql(FETCH TCursor INTO :setid,:key)
	While (SQLCODE = 0) {
		Set n = n + 1
		Write n,":",?5,key,!
		&sql(FETCH TCursor INTO :setid,:key)
	}
	&sql(CLOSE TCursor)
}

ClientMethod onlayoutHandler(load) [ Language = javascript ]
{
	// find divs for title etc.
	var title = zenPage.getComponentById('title');
	var filter = zenPage.getComponentById('filter');
	var toc = zenPage.getComponentById('toc');
	var menu = zenPage.getComponentById('menuBar');
	var divTitle = title.getEnclosingDiv();
	var divFilter = filter.getEnclosingDiv();
	var divTOC = toc.getEnclosingDiv();
	var divMenu = menu.getEnclosingDiv();

	// find size of window
	var winHeight = zenGetWindowHeight();
	var winWidth = zenGetWindowWidth();

	// adjust size of filter, toc
	var h = winHeight - (parseInt(divTitle.offsetHeight) + parseInt(divMenu.offsetHeight)) - 50;

	var w = winWidth - (parseInt(divFilter.offsetWidth)) - 50;

	divTOC.style.width = w + 'px';
	//divTOC.style.height = h + 'px';
	//divFilter.style.height = h + 'px';
}

/// Get list of filters to display.
ClassMethod GetFilterList(pSeed As %String, ByRef pInfo) As %Status
{
	#; each entry has the form:
	#; pInfo(n) = $LB(category,caption,value,tooltip,disabled)
	
	Set InclEns = ##class(DocBook.Utils).EnsembleLoaded()
	Set InclHS = ##class(DocBook.Utils).HealthShareLoaded()
	Set InclTC = ##class(DocBook.Utils).TrakCareLoaded()

	#; special cases
	Set pInfo($I(pInfo)) = $LB("*",$$$Text("Group By Type"),"All",$$$Text("Show all documents"))
	Set pInfo($I(pInfo)) = $LB("",$$$Text("Recent Choices"),"Recent",$$$Text("Show recently viewed documents"))

	#; products
	Set BgnInx = pInfo
	Do ..Filter(.pInfo,"product",$$$Text("Cach&eacute;"),"Cache")
	Do:(InclEns) ..Filter(.pInfo,"product",$$$Text("Ensemble"),"Ensemble")
	Do:(InclHS) ..Filter(.pInfo,"product",$$$Text("HealthShare"),"HealthShare")
	Do:(InclTC) ..Filter(.pInfo,"product",$$$Text("TrakCare"),"TrakCare")
	Do ..Filter(.pInfo,"product",$$$Text("Internal"),"Internal","Style Guides")
	Do ..Filter(.pInfo,"product",$$$Text("Confidential"),"Confidential","InterSystems Only")
	#; remove only single product
	If (pInfo = (BgnInx + 1))
	{
		Set pInfo = BgnInx
	}

	#; roles
	Do ..Filter(.pInfo,"role",$$$Text("Administration"),"Administration")
	Do ..Filter(.pInfo,"role",$$$Text("Security"),"Security")
	Do ..Filter(.pInfo,"role",$$$Text("Development"),"Development")
	Do ..Filter(.pInfo,"role",$$$Text("Installation"),"Installation")
	Do ..Filter(.pInfo,"role",$$$Text("Tools"),"Tools")
	Do ..Filter(.pInfo,"role",$$$Text("General"),"General")
	Do ..Filter(.pInfo,"role",$$$Text("Implementation"),"Implementation")

	#; levels
	Do ..Filter(.pInfo,"level",$$$Text("Introductory"),"Introductory")
	Do ..Filter(.pInfo,"level",$$$Text("Intermediate"),"Intermediate")
	Do ..Filter(.pInfo,"level",$$$Text("Advanced"),"Advanced")
	Do ..Filter(.pInfo,"level",$$$Text("Draft"),"Draft","Not ready for publication")

	#; book types
	Do ..Filter(.pInfo,"book",$$$Text("Guides"),"Guides")
	Do ..Filter(.pInfo,"book",$$$Text("References"),"References")
	Do ..Filter(.pInfo,"book",$$$Text("Tutorials"),"Tutorials")
	Do ..Filter(.pInfo,"book",$$$Text("Articles"),"Articles")

	#; application type
	Do ..Filter(.pInfo,"app",$$$Text("Web"),"Web")
	Do ..Filter(.pInfo,"app",$$$Text("Client/Server"),"Client/Server")
	Do ..Filter(.pInfo,"app",$$$Text("Terminal"),"Terminal")
	Do ..Filter(.pInfo,"app",$$$Text("Integration"),"Integration")

	#; programming languages
	Do ..Filter(.pInfo,"lang",$$$Text("BASIC"),"BASIC")
	Do ..Filter(.pInfo,"lang",$$$Text("C++"),"CPP")
	Do ..Filter(.pInfo,"lang",$$$Text("Java"),"Java")
	Do ..Filter(.pInfo,"lang",$$$Text("JavaScript"),"JavaScript")
	Do ..Filter(.pInfo,"lang",$$$Text("MultiValue"),"MultiValue")
	Do ..Filter(.pInfo,"lang",$$$Text("ObjectScript"),"ObjectScript")
	Do ..Filter(.pInfo,"lang",$$$Text("Perl"),"PERL")
	Do ..Filter(.pInfo,"lang",$$$Text("Python"),"PYTHON")
	Do ..Filter(.pInfo,"lang",$$$Text("HTML"),"HTML")
	Do ..Filter(.pInfo,"lang",$$$Text("CSP"),"CSP")
	Do ..Filter(.pInfo,"lang",$$$Text("ZEN"),"ZEN")
	Do ..Filter(.pInfo,"lang",$$$Text(".NET"),"DOTNET")
	Do ..Filter(.pInfo,"lang",$$$Text("SOAP"),"SOAP")
	Do ..Filter(.pInfo,"lang",$$$Text("XML"),"XML")
	Do ..Filter(.pInfo,"lang",$$$Text("DeepSee"),"DeepSee")
	Do ..Filter(.pInfo,"lang",$$$Text("BPL"),"BPL")
	Do ..Filter(.pInfo,"lang",$$$Text("DTL"),"DTL")
	Do ..Filter(.pInfo,"lang",$$$Text("SQL"),"SQL")
	Do ..Filter(.pInfo,"lang",$$$Text("ISQL/TSQL"),"ISQL/TSQL")

	Quit $$$OK
}

/// Conditionally add a button to the list
ClassMethod Filter(ByRef pInfo, Name As %String, LocName As %String, Value As %String, ToolTip As %String = "") As %Status
{

	Set Ignores = $GET(^DocBook.Config("IGNORECATEGORIES"), "level,app")
	Set IgnoreThis = $ZCONVERT(Ignores, "L") [ $ZCONVERT(Name, "L")
	Quit:(IgnoreThis) $$$OK	
	
	Set Present = $GET(^DocBook.BookCategory(Name,Value), 0)
	If (Present > 0)
	{
		If ($LENGTH(ToolTip) > 0)
		{
			Set pInfo($I(pInfo)) = $LB(Name,LocName,Value,ToolTip)
		}
		Else
		{
			Set pInfo($I(pInfo)) = $LB(Name,LocName,Value)
		}
	}

	Quit $$$OK
}

/// Intercept xmlHTTP errors and reload page rather than
/// putting up alert box.
ClientMethod onServerMethodError(err) [ Language = javascript ]
{
	top.document.location.reload();
}

}
