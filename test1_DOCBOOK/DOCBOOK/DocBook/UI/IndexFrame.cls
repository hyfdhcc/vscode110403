Import DocBook

Include DocBookMac

/// Handles the indexing display
Class DocBook.UI.IndexFrame Extends %CSP.Page [ ProcedureBlock ]
{

/// Localizer for message fragments
ClassMethod DBMsg(cls As %String, num As %String, args... As %List) As %String [ Internal ]
{
	Quit ##class(DocBook.L10N).DBMsg(cls, num, args...)
}

ClassMethod OnPage() As %Status [ Internal ]
{
	// build tree
	Set tree = ##class(MenuTree).%New()
	
	&html<<html><head>>
	
	&html<<STYLE type="text/css">

	BODY			{ 
		background: #C0C0C0;
		background-image: url(images/grad-halfgray-10x500.png);
		background-repeat: repeat-x;
		font-family: Verdana; 
		line-height: 110%; }
	DIV.Title 	{ font-size: 10pt; color: darkblue; font-weight: bold; }
	
	A.CSPMenuItem1 { color: darkblue; font-size: 9pt; 
						font-weight: bold;
						font-family: Verdana; 
						text-decoration: none; 
						line-height: 120%; }
					
	A.CSPMenuItem2 { color: darkblue; font-size: 9pt; 
						font-family: Verdana; 
						text-decoration: none; 
						line-height: 120%; }

	A.CSPMenuItem3 { color: darkblue; font-size: 9pt; 
						font-family: Verdana; 
						text-decoration: none; 
						line-height: 120%; }

	A.CSPMenuItem1:hover, 
	A.CSPMenuItem2:hover, 
	A.CSPMenuItem3:hover { color: red; }

	A.CSPMenuItem1:visited, 
	A.CSPMenuItem2:visited, 
	A.CSPMenuItem3:visited { color: darkblue; }
	
	.Title A,
	.Title A:visited {
		color: darkblue;
		text-decoration: none;
		white-space: nowrap;
	}

	.Title A:hover {
		color: red;
		text-decoration: none; 
	}

	INPUT		{ color: darkblue; font-size: 0.8em; }
	
	</STYLE>>

	Set msgTop = $$$T("Go to main list")

	&html<<SCRIPT LANGUAGE="JavaScript">
	
	var CurrentBook = '';
	
	// find location of current page
	function updateLocation()
	{
		var key = '';
		var book = '';
		var query = '';
		
		if (parent != null && 
			 parent.PageFrame != null &&
			 parent.PageFrame.QuickSearch != null && 
			 parent.PageFrame.QuickSearch.KEY != null ) {

			key = parent.PageFrame.QuickSearch.KEY.value;
			
			if (key != "") {
				book = key.split("_")[0];
			}
			
			if (key != '') {
				query = '?KEY=' + key + '#' + key;
			}

			if (book != CurrentBook) {
				// reload
				CurrentBook = book;
				self.document.location = 'DocBook.UI.IndexFrame.cls' + query;
			}
			else {
				// just change highlight
				highlightItem(key);
			}
		}
		
		return true;
	}
	
	function goHome()
	{
		self.document.location = 'DocBook.UI.IndexFrame.cls';
		return true;
	}
	</SCRIPT>>

	Do tree.ShowJS()
	
	Set key = $G(%request.Data("KEY",1))
	Set book = ""
	Set bookKey = ""
	
	If ($E(key,1,1) = "A") {
		// !!!
		Set bookKey = key
		Set key = "KNBASE"
	}
	
	If ((key '= "") && (key '= "KNBASE")) {
		// pull out first part of key
		Set bookKey = $P(key,"_",1)
		Set book = ##class(book).OpenKey(bookKey)
	}

	If (book = "") {
		If (key = "KNBASE") {
			&html<<base target="PageFrame"></head><body>>
			Set bookKey = "KNBASE"
 
	 		// list all articles
			Set page = "DocBook.UI.Page.cls"
	
			Write "<DIV CLASS=""Title"">"
			Write "<A TARGET='TOCFrame' HREF='DocBook.UI.IndexFrame.cls' title='"_msgTop_"'>&laquo;</A> "
			Write "Technical Articles</DIV><HR>",!
	
			Do ..GetKNBase(.items, page)
		}
		Else {
			// main list
			&html<</head><body>>
			Set bookKey = ""
 
	 		// list all books
			Set page = "DocBook.UI.IndexFrame.cls"
	
			Write "<A name=""frametop""></A>",!
			Write "<DIV CLASS=""Title"">"_$$$T("InterSystems Documentation")_"</DIV><HR>",!
	
			Do ..GetSets(.items, page)
		}
	}
	Else {
				
		&html<<base target="PageFrame">
		</head>
		<body>>
		
		// TOC for current book
		Set page = "DocBook.UI.Page.cls"
	
		// fill in tree
		Write "<DIV CLASS=""Title"">"
		Write "<A TARGET='TOCFrame' HREF='DocBook.UI.IndexFrame.cls' title='"_msgTop_"'>&laquo;</A> "
		Write book.title,"</DIV>"
		Write "<HR>",!

		Do ..GetComponents(book.%Id(),.items,page)
	}

	Merge tree.Items = items
	Write "<A name=""TreeTop""></A>",!
	Do tree.ShowTree(key)
	
	&html<<SCRIPT LANGUAGE="JavaScript">
		CurrentBook = '#(bookKey)#';
	 </SCRIPT>>

	Write "<HR><DIV CLASS=""Title""><A HREF=""#TreeTop"" TARGET=""TOCFrame"">"_$$$T("[Top of List]")_"</A></DIV>",!

	&html<</body>
	</html>>
	Quit $$$OK
}

/// Show the list of components for a book
ClassMethod GetComponents(ctrid As id, ByRef tname As cdata, page As cdata, n As dbint = 0) [ Internal ]
{
	New %ISCDBCounter
	Set %ISCDBCounter = $INCREMENT(^||DocBook.CursorCount)
	Kill %DocBookCursor(%ISCDBCounter)
#EXECUTE Set %msqlvar = "%DocBookCursor(%ISCDBCounter"

	Set lastcls = ""
	Set introkey = ""

	// loop over components
	&sql(DECLARE CompCursor CURSOR FOR
		SELECT ID,blockid, title, x__classname
		INTO :compid,:key, :title, :cls
		FROM component
		WHERE container = :ctrid
		ORDER BY blockpos
	)
	
	&sql(OPEN CompCursor)
	&sql(FETCH CompCursor)

	Set n = n + 1
	While (SQLCODE = 0) {

		// error detection
		Set:title="" title = key _ " (untitled)"

		If (cls [ "part") {
			// link to intro for Part in menu
			
			&sql(SELECT intro->blockid INTO :introkey 
					FROM DocBook.part
					WHERE %ID = :compid)
			
			If (introkey '= "") {
				Set tname(n) = $LB(title,page_"?KEY="_introkey,introkey)
			}
			Else {
				Set tname(n) = $LB(title,"","")
			}
		}
		Else {
			Set tname(n) = $LB(title,page_"?KEY="_key,key)
		}
		
		If (cls [ "reference") {
			Do ..GetRefEntries(compid, .tname, page, n)
		}
		ElseIf (cls [ "part") {
			// recursively get sub-components
			Do ..GetComponents(compid, .subtname, page)
			Merge tname(n) = subtname
		}
		Else {
			Do ..GetSect1(compid, .tname, page, n)
		}
		
		Set n = n + 1

		&sql(FETCH CompCursor)
	}
	&sql(CLOSE CompCursor)
#EXECUTE Kill %msqlvar

	Quit
}

/// get the level 1 sections for the given chapter
ClassMethod GetSect1(chid As id, ByRef tname As cdata, page As cdata, number As dbint) [ Internal ]
{
	// list all of the sect1 blocks
	&sql(DECLARE S1Cursor CURSOR FOR
		SELECT ID,blockid, title, component->blockid
		INTO :sid,:key, :title, :chap
		FROM sect1
		WHERE container = :chid
	)

	&sql(OPEN S1Cursor)
	&sql(FETCH S1Cursor)
	Set n = 1
	While (SQLCODE = 0) {
		// error detection
		Set:title="" title = key _ " (untitled)"

		Set tname(number,n) = $LB(title,page_"?KEY="_chap_"#"_key,key)

		&sql(FETCH S1Cursor)
		Set n = n + 1
	}
 
	&sql(CLOSE S1Cursor)
}

ClassMethod GetRefEntries(id As id, ByRef tname As cdata, page As cdata, number As dbint) [ Internal ]
{
	&sql(DECLARE RECursor CURSOR FOR
		SELECT blockid, refmeta_refentrytitle
		INTO :key, :title
		FROM refentry
		WHERE container = :id
		ORDER BY refmeta_refentrytitle
	)

	&sql(OPEN RECursor)
	&sql(FETCH RECursor)
	Set n = 1

	While (SQLCODE = 0) {
		// error detection
		Set:title="" title = key _ " (untitled)"

		Set tname(number,n) = $LB(title,page_"?KEY="_key,key)
		Set n = n + 1

		&sql(FETCH RECursor)
	}

	&sql(CLOSE RECursor)
}

/// Get list of sets
ClassMethod GetSets(ByRef tname As cdata, page As cdata) [ Internal ]
{
	Set n = 0
	
	Set setid = $O(^DocBook.blockI("setIdx",""))
	While (setid '="") {
		Set set = ##class(DocBook.set).%OpenId(setid)
		If (set '="") {
			Set n = n + 1
			Set tname(n) = $LB(set.title)
		}
		
		Do ..GetBooks(setid,n,.tname,page)

		Set setid = $O(^DocBook.blockI("setIdx",setid))
	}

	Set n = n + 1
	Set tname(n) = $LB($$$T("Technical Articles"),page_"?KEY=KNBASE","KNBASE")
}

/// Get list of articles in KNBASE
ClassMethod GetKNBase(ByRef tname As cdata, page As cdata) [ Internal ]
{
	Set n = 0
	
	// loop over articles
	&sql(DECLARE TCursor CURSOR FOR
		SELECT blockid,title
		INTO :key,:title
		FROM DocBook.article
		ORDER BY title
	)
	
	&sql(OPEN TCursor)
	&sql(FETCH TCursor)

	While (SQLCODE = 0) {
		// error detection
		Set:title="" title = key _ " (untitled)"

		Set n = n + 1
		Set tname(n) = $LB(title,page _ "?KEY=" _ key)

		&sql(FETCH TCursor)
	}
	&sql(CLOSE TCursor)
}

/// Get list of books for the given set
ClassMethod GetBooks(setid As id, number As dbint, ByRef tname As cdata, page As cdata) [ Internal ]
{
	// loop over books
	&sql(DECLARE BookCursor CURSOR FOR
		SELECT ID,blockid,title,subtitle,dbrole
		INTO :id,:bookKey,:title,:desc, :role
		FROM DocBook.book
		WHERE container = :setid
	)

	Set n = 0
	
	&sql(OPEN BookCursor)
	&sql(FETCH BookCursor)

	While (SQLCODE = 0) {
		// error detection
		Set:title="" title = key _ " (untitled)"

		Set n = n + 1
		Set tname(number,n) = $LB(title,page_"?KEY="_bookKey,bookKey)
		&sql(FETCH BookCursor)
	}
	&sql(CLOSE BookCursor)
}

}
