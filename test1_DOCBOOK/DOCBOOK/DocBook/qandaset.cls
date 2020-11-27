Include DocBookMac

/// A question and answer set.
Class DocBook.qandaset Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method HTMLRenderPreChildren() [ Internal ]
{
	// show list of divisions
	Write "<DIV CLASS=""para"">", $$$T("This Question and Answer Set includes the following topics:"), "<MENU>", !
	
	Do ..ShowTopics()
	
	Write "</MENU></DIV><HR>"

	Write "<DIV CLASS=""qandaset"">"
	Write "<A name=""",..id,"""></A>",!
	Write ..title,"</DIV>",!
}

Method ShowTopics() [ Internal ]
{

	Set id = ..%Id()
	
	&sql(DECLARE sql1 CURSOR FOR
		SELECT ID,blockID,title 
		INTO :did,:bid, :title
		FROM qandadiv 
		WHERE container = :id
		ORDER BY title
	)

	&sql(OPEN sql1)

	&sql(FETCH sql1)
	While (SQLCODE = 0) {
		Write "<LI><A CLASS=""TOCSect1"" HREF=""#",bid,""">",title,"</A></LI>",!
		&sql(FETCH sql1)
	}
	&sql(CLOSE sql1)
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
