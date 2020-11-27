Include DocBookMac

/// A preface: Introductory material before the start of a book.
Class DocBook.preface Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
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
	
	Set info.chap = ""
	
	// find prev/next chapter
	If ($G(%tutorial)'=1) {
		Do ..GetNextPrevInfo(info)
	}
}

Method GetGotoList(ByRef gtl As cdata) [ Internal ]
{

	Set id = ..%Id()

	// list all of the sect1 blocks
	&sql(DECLARE G1Cursor CURSOR FOR
		SELECT ID,blockid, title
		INTO :sid, :key, :title
		FROM sect1
		WHERE container = :id
	)

	&sql(OPEN G1Cursor)
	&sql(FETCH G1Cursor)

	Set num = 1
	While (SQLCODE = 0) {
		Set gtl(num) = $LB("#" _ key,title)
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
