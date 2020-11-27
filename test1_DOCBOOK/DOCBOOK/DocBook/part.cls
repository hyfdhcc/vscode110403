Include DocBookMac

/// This class represents a Part of a book.
Class DocBook.part Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
{

/// Intro for this part
Property intro As partintro;

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
	Set info.prev = ""
	Set info.next = ""
}

Method HTMLRender() [ Internal ]
{
	Set id = ..%Id()
	
	If (..intro '= "") {
		Do ..intro.HTMLRender()
	}
}

Storage Default
{
<Data name="partDefaultData">
<Subscript>"part"</Subscript>
<Value name="1">
<Value>intro</Value>
</Value>
</Data>
<DefaultData>partDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
