Include DocBookMac

/// This class represents the chapter-like elements of a book.
Class DocBook.component Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

///  Find the next and prev component to this one
Method GetNextPrevInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	If (..book = "") {
		Quit
	}
	
	// find prev/next component

	Set ctrid = ..container.%Id()
	Set pos = ..blockpos
	
	// too inefficient!
	//SELECT blockid INTO :prev
	//	FROM component
	//	WHERE (book = :bid) AND (blockpos < :pos)
	//	ORDER BY blockpos DESC

	// assume all components have sequential blockpos
	Set ppos = pos - 1
	&sql(SELECT blockid INTO :prev
		FROM component
		WHERE (container = :ctrid) AND (blockpos = :ppos)
	)
		
	If (SQLCODE = 0) {
		Set info.prev = prev
	}

	&sql(SELECT blockid INTO :next
		FROM component
		WHERE (container = :ctrid) AND (blockpos > :pos)
		ORDER BY blockpos)
		
	If (SQLCODE = 0) {
		Set info.next = next
	}
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
