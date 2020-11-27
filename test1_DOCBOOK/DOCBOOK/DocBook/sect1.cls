Include DocBookMac

/// A top-level section.
Class DocBook.sect1 Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = ..title
	If (..book '= "") {
		Set info.booktitle = ..book.title
	}
	Else {
		Set info.booktitle = ""
	}
	
	// find prev/next section
	Do ..GetNextPrevInfo(info)
}

Method HTMLRenderPreChildren() [ Internal ]
{
	If ($G(%tutorial) '= 1) {
		Write "<DIV CLASS=""sect1"">"
		Write "<A name=""",..id,"""></A>",!
		Write ##class(DocBook.Renderer).XFormEntity(..title),"</DIV>",!
	}
}

///  Find the next and prev component to this one
Method GetNextPrevInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	If (..component = "") {
		Quit
	}

	// find prev/next section

	Set cid = ..component.%Id()
	Set pos = ..blockpos

	// inefficient	
	//SELECT blockid INTO :prev
	//	FROM sect1
	//	WHERE (component = :cid) AND (blockpos < :pos)
	//	ORDER BY blockpos DESC
		
	// assume all components have sequential blockpos
	Set ppos = pos - 1
	&sql(SELECT blockid INTO :prev
		FROM sect1
		WHERE (component = :cid) AND (blockpos = :ppos)
	)
	
	If (SQLCODE = 0) {
		Set info.prev = prev
	}
		
	&sql(SELECT blockid INTO :next
		FROM sect1
		WHERE (component = :cid) AND (blockpos > :pos)
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
