Include DocBookMac

/// A collection of books.
Class DocBook.set Extends DocBook.container [ ClassType = persistent, ProcedureBlock, SqlTableName = db_set ]
{

Relationship books As book [ Cardinality = many, Inverse = set ];

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = ..title
	Set info.booktitle = $$$T("InterSystems Online Documentation")
	Set info.chap = ""
	Set info.prev = ""
	Set info.next = ""
}

Method HTMLRender() [ Internal ]
{
	&html<<DIV CLASS="para1">#(..subtitle)#</DIV><BR>>

	Do ..ShowBooks(..%Id())
}

/// Show list of books for the this set
Method ShowBooks(setid) [ Internal ]
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

	&html<<TABLE CLASS="Home" BORDER="0" CELLPADDING="0" CELLSPACING="0" COLS="2">>
	&html<<TR CLASS="HomeGap"><TD COLSPAN="2">&nbsp;</TD></TR>>

	// list books
	While (SQLCODE = 0) {
		Set url = ""

		// if there is a preface, link to it (tutorial only!)
		If (role = "tutorial" && (##class(DocBook.preface).FindId(bookKey _ "_preface") '= ""))	{
			Set url = "DocBook.UI.Page.cls?KEY=" _ $ZCVT(bookKey,"O","URL") _ "_preface"
		}
		Else {
			// link to TOC
			Set url = "DocBook.UI.Page.cls?KEY=" _ $ZCVT(bookKey,"O","URL")
		}

		&html<<TR CLASS="Home">>
		&html<<TD CLASS="HomeTitle" NOWRAP 
				onclick="self.document.location='#(url)#';" 
				onmouseover="this.className = 'HomeTitleHi'; self.document.all.item('#(bookKey)#').className = 'HomeSubTitleHi';" 
				onmouseout="this.className='HomeTitle'; self.document.all.item('#(bookKey)#').className = 'HomeSubTitle';">>
		Write "<A HREF=""", url, """ TITLE=""", $$$T("Show contents of this book."), """>", title,"&nbsp;</A>"
		&html<</TD>>
		&html<<TD CLASS="HomeSubTitle" ID="#(bookKey)#">#(desc)#</TD></TR>>
		&html<<TR CLASS="HomeGap"><TD COLSPAN="2">&nbsp;</TD></TR>>

		&sql(FETCH BookCursor)
	}

	&html<</TABLE>>

	&sql(CLOSE BookCursor)
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
