/// This is a special container that renders the Technical Articles index page for the Documentation system.
Class DocBook.KNBase Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = $$$T("Technical Articles")
	Set info.booktitle = $$$T("InterSystems Online Documentation")
	Set info.chap = ""
	Set info.prev = ""
	Set info.next = ""
}

Method HTMLRender() [ Internal ]
{
	Do ..ShowArticles()
}

/// Show list of articles
Method ShowArticles() [ Internal ]
{

	Set sort = "SUBJECT"
	Set sort = $G(%request.Data("Sort",1),sort)
	
	// preface
	&html<<DIV CLASS="para1">>
	Write $$$T("Welcome to the InterSystems technical articles for version ") _ $system.Version.GetNumber(), !
	Write $$$T("These are a compendium of material on specific technical topics."), !
	Write $$$T("The available articles are listed below."), !
	&html<</DIV>>
		
	// sort form
	&html<<DIV CLASS="para">>
	&html<<FORM NAME="SORT">>
	&html<<TABLE CLASS="SearchForm" CELLPADDING="2" BGCOLOR="silver" CELLSPACING="0" BORDER="0">>
	&html<<TR><TD><B>#($$$T("Sort articles by:"))#</B>&nbsp;>
	&html<<INPUT TYPE="HIDDEN" NAME="KEY" VALUE="KNBASE">>
	&html<<INPUT TYPE="RADIO" NAME="Sort" VALUE="SUBJECT" #($S(sort="SUBJECT":"CHECKED",1:""))# onclick="self.document.SORT.submit();">#($$$T("Subject"))#&nbsp;>
	&html<<INPUT TYPE="RADIO" NAME="Sort" VALUE="TITLE" #($S(sort="TITLE":"CHECKED",1:""))# onclick="self.document.SORT.submit();">#($$$T("Title"))#&nbsp;>
	&html<<INPUT TYPE="RADIO" NAME="Sort" VALUE="DATE" #($S(sort="DATE":"CHECKED",1:""))# onclick="self.document.SORT.submit();">#($$$T("Date"))#&nbsp;>
	&html<</TD></TR></TABLE>>
	&html<</FORM></DIV>>

	Do:sort="TITLE" ..ShowByTitle()
	Do:sort="SUBJECT" ..ShowBySubject()
	Do:sort="DATE" ..ShowByDate()
}

Method ShowByTitle() [ Internal ]
{

	// loop over articles
	&sql(DECLARE TCursor CURSOR FOR
		SELECT ID,blockid,title,subtitle,sourcetime,dbrole
		INTO :setid,:key,:title,:desc,:time,:subj
		FROM DocBook.article
		ORDER BY title
	)
	
	&sql(OPEN TCursor)
	&sql(FETCH TCursor)

	While (SQLCODE = 0) {
		
		Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(key,"O","URL") _ """"

		&html<<DIV CLASS="para"><UL><LI>
		<A CLASS="TOC" #(link)# TITLE='#($ZCVT(desc,"O","HTML"))#'>#(title)#</A>&#151;#(subj)#&#151;<SPAN CLASS="sourcetime">#(time)#</SPAN>
		</UL></DIV>>

		&sql(FETCH TCursor)
	}
	&sql(CLOSE TCursor)
}

Method ShowBySubject() [ Internal ]
{

	// loop over articles
	&sql(DECLARE SCursor CURSOR FOR
		SELECT ID,blockid,title,subtitle,sourcetime,dbrole,remap
		INTO :setid,:key,:title,:desc,:time,:subj,:remap
		FROM DocBook.article
		ORDER BY remap,dbrole,title
	)
	
	&sql(OPEN SCursor)
	&sql(FETCH SCursor)
	
	Set lastsubj = ""

	While (SQLCODE = 0) {
		
		Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(key,"O","URL") _ """"
		
		If (lastsubj '= subj) {
			&html<<DIV CLASS="set">#(subj)#</DIV>>
			Set lastsubj = subj
		}

		&html<<DIV CLASS="para"><UL><LI>
		<A CLASS="TOC" #(link)# TITLE='#($ZCVT(desc,"O","HTML"))#'>#(title)#</A>&#151;<SPAN CLASS="sourcetime">#(time)#</SPAN>
		</UL></DIV>>

		&sql(FETCH SCursor)
	}
	&sql(CLOSE SCursor)
}

Method ShowByDate() [ Internal ]
{

	// loop over articles
	&sql(DECLARE DCursor CURSOR FOR
		SELECT ID,blockid,title,subtitle,sourcetime,dbrole
		INTO :setid,:key,:title,:desc,:time,:subj
		FROM DocBook.article
		ORDER BY sourcetime DESC
	)
	
	&sql(OPEN DCursor)
	&sql(FETCH DCursor)

	While (SQLCODE = 0) {
		
		Set link = "HREF=""DocBook.UI.Page.cls?KEY=" _ $ZCVT(key,"O","URL") _ """"

		&html<<DIV CLASS="para"><UL><LI>
		<A CLASS="TOC" #(link)# TITLE='#($ZCVT(desc,"O","HTML"))#'>#(title)#</A>&#151;#(subj)#&#151;<SPAN CLASS="sourcetime">#(time)#</SPAN>
		</UL></DIV>>

		&sql(FETCH DCursor)
	}
	&sql(CLOSE DCursor)
}

///  Provide info for the goto list 
Method GetGotoList(ByRef gtl As cdata) [ Internal ]
{

	Set id = ..%Id()

	// list all of the articles
	&sql(DECLARE G1Cursor CURSOR FOR
		SELECT ID,blockid,title
		INTO :id,:key,:title
		FROM DocBook.article
		ORDER BY title
	)

	&sql(OPEN G1Cursor)
	&sql(FETCH G1Cursor)

	Set num = 1
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
