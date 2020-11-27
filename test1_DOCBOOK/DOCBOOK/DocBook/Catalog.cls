Include DocBookMac

/// This is a special container that renders the title of books and articles for the Documentation system.
Class DocBook.Catalog Extends DocBook.container [ ClassType = persistent, ProcedureBlock, SqlTableName = db_catalog ]
{

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = $$$T("Documentation Catalog")
	Set info.booktitle = $$$T("InterSystems Online Documentation")
	Set info.chap = ""
	Set info.prev = ""
	Set info.next = ""
}

Method HTMLRender() [ Internal ]
{
	Do ..ShowCatalog()
}

/// Display the catalog of titles
Method ShowCatalog() [ Internal ]
{

	// preface
	&html<<DIV CLASS="para1">>
	Write $$$T("Welcome to the InterSystems online documentation."), !
	Write $$$T("What follows is a list of all the available online books and articles."), !
	Write $$$T("Clicking on the title will take you directly to the document."), !
	&html<</DIV>>
    
    &html<<DIV CLASS="set">Books</DIV>>
	Do ..ShowBooks()

    &html<<DIV CLASS="set">Articles</DIV>>
	Do ..ShowArticles()
}

Method ShowBooks() [ Internal ]
{

	// loop over articles
	&sql(DECLARE BCursor CURSOR FOR
		SELECT ID,blockid,title,subtitle
		INTO :setid,:key,:title,:desc
		FROM DocBook.book
		ORDER BY title
	)
	
	&sql(OPEN BCursor)
	&sql(FETCH BCursor)

    &html<<DIV CLASS="para"><DL>>
    Set n = 0
	While (SQLCODE = 0) {
		Set n = n + 1

		Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(key,"O","URL") _ """"

		&html<<DT>
		<A CLASS="TOCChapter" #(link)#>#(title)#</A>
		</DT>
		>

		&html<<DD>
		#(desc)#&nbsp;&#151;&nbsp;(<SPAN CLASS="filename">#(key)#</SPAN>)
		</DD>>

		&html<<P>>

		&sql(FETCH BCursor)
	}
	&sql(CLOSE BCursor)
    &html<</DL></DIV>>
}

Method ShowArticles() [ Internal ]
{

	// loop over articles
	&sql(DECLARE ACursor CURSOR FOR
		SELECT ID,blockid,title,subtitle
		INTO :setid,:key,:title,:desc
		FROM DocBook.article
		ORDER BY title
	)
	
	&sql(OPEN ACursor)
	&sql(FETCH ACursor)

    &html<<DIV CLASS="para"><DL>>
    Set n = 0
	While (SQLCODE = 0) {
		Set n = n + 1

		Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(key,"O","URL") _ """"

		&html<<DT>
		<A CLASS="TOCChapter" #(link)#>#(title)#</A>
		</DT>>

		&html<<DD>
		#(desc)#&nbsp;&#151;&nbsp;(<SPAN CLASS="filename">#(key)#</SPAN>)
		</DD>>

		&html<<P>>

		&sql(FETCH ACursor)
	}
	&sql(CLOSE ACursor)
    &html<</DL></DIV>>
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
