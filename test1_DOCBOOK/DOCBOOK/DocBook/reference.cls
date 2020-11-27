Include DocBookMac

/// The reference section of a book.
Class DocBook.reference Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
{

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = $$$T("Contents")
	Set info.booktitle = ..title
	Set info.chap = ""
	Set info.prev = ""
	Set info.next = ""
}

/// render this container's children
Method HTMLRender() [ Internal ]
{

	Set id = ..%Id()
	
	&sql(DECLARE PartIntroCursor CURSOR FOR
		SELECT ID
		INTO :partintrokey
		FROM partintro
		WHERE container = :id
	)

	&sql(OPEN PartIntroCursor)
	&sql(FETCH PartIntroCursor)
	if (SQLCODE = 0)
	{

		set partintroref = ##class(DocBook.partintro).%OpenId(partintrokey)
		do partintroref.HTMLRender()
	}
	else
	{
	}
	&sql(CLOSE PartIntroCursor)
	
	&sql(DECLARE REFCursor CURSOR FOR
		SELECT blockid, refmeta_refentrytitle
		INTO :key, :title
		FROM refentry
		WHERE container = :id
		ORDER BY refmeta_refentrytitle
	)

	&sql(OPEN REFCursor)
	&sql(FETCH REFCursor)

	// Show only top level for Reference books 
	Set last = ""

	&html<<TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0" WIDTH="100%">>
	If ..subtitle'="" { &html<<TR><TD ALIGN="RIGHT" WIDTH="20%">&nbsp;</TD><TD><DIV CLASS="subtitle">#(..subtitle)#</DIV></TD></TR>> }
	&html<<TR><TD ALIGN="RIGHT" WIDTH="20%">&nbsp;</TD><TD>>
	Write "<DIV CLASS=""TOC""><B>", $$$T("Contents"), "</B></DIV>",!
	&html<<HR></TD></TR>>

	While (SQLCODE = 0) {
		// look at first letter of string
		Set c = $ZCONVERT($E(title,1,1), "U")
		If (c = "&") {
		    If ($LENGTH(title, ";") > 1) {
		        Set c = $PIECE(title, ";") _ ";"
		    }
		}
		If ((c '= last)) {
			if (c?1ANP) {
				&html<<TR>>
				&html<<TD WIDTH="20%">&nbsp;</TD>>
				&html<<TD ALIGN="LEFT" CLASS="Letter">&#151; #(c)# &#151;</TD>>
				&html<</TR>>
			} else {
				// skip for Japanese
			}
		}
		
		Set last = c

		&html<<TR><TD ALIGN="RIGHT" WIDTH="20%">&nbsp;</TD><TD ALIGN="LEFT">
			<DIV CLASS="TOC">
			<A CLASS="TOCRef" HREF='DocBook.UI.Page.cls?KEY=#($ZCVT(key,"O","URL"))#'>#(title)#</A>
			</DIV>
			</TD></TR>
		>
		&sql(FETCH REFCursor)
	}

	&html<</TABLE>>
	&sql(CLOSE REFCursor)
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
