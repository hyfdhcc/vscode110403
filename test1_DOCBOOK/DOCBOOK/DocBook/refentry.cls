Include DocBookMac

/// Represents a reference entry.
Class DocBook.refentry Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
{

Property refmeta As refmeta;

Method GetGotoList(ByRef gtl As cdata) [ Internal ]
{
	Set id = ..%Id()

	// list all of the sect1 blocks
	&sql(DECLARE G1Cursor CURSOR FOR
		SELECT ID,blockid, title
		INTO :sid, :key, :title
		FROM refsect1
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

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = ..refmeta.refentrytitle
	If (..book '= "") {
		Set info.booktitle = ..book.title
	}
	Else {
		Set info.booktitle = ""
	}		

	If (..container = "") {
		Set info.chap = ""
		Quit
	}
	
	Set info.chap = ..container.title
	
	// find prev/next chapter

	If (..container = "") {
		Quit
	}
	Set cid = ..container.%Id()
	Set pos = ..blockpos
	
	&sql(SELECT blockid INTO :prev
		FROM refentry 
		WHERE (container = :cid) AND (blockpos < :pos)
		ORDER BY blockpos DESC)
		
	If (SQLCODE = 0) {
		Set info.prev = prev
	}
		
	&sql(SELECT blockid INTO :next
		FROM refentry 
		WHERE (container = :cid) AND (blockpos > :pos)
		ORDER BY blockpos)
		
	If (SQLCODE = 0) {
		Set info.next = next
	}
}

/// render any XML before children
Method XMLRenderPreChildren() [ Internal ]
{
	// assume class name is XML element name

	Set attr = ""
	If (..id '= "") {
		Set attr = attr _ " id=""" _ ..id _ """"
	}
	If (..role '= "") {
		Set attr = attr _ " role=""" _ ..role _ """"
	}
	
	Write "<",..%ClassName(),attr,">",!

	Write "<refmeta>",!
	If (..refmeta.refentrytitle '= "") {
		Write "<refentrytitle>", ..refmeta.refentrytitle, "</refentrytitle>",!
	}
	Write "</refmeta>",!
}

Storage Default
{
<Data name="refentryDefaultData">
<Subscript>"refentry"</Subscript>
<Value name="1">
<Value>refmeta</Value>
</Value>
</Data>
<DefaultData>refentryDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
