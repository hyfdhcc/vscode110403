Include DocBookMac

/// An introduction to a Part of a Book.
Class DocBook.partintro Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
{

/// part this intro belongs to
Property part As part;

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = $$$T("Introduction")
	If (..book '= "") {
		Set info.booktitle = ..book.title
	}
	Else {
		Set info.booktitle = ""
	}
	
	Set info.chap = ""
	Set info.next = ""
	Set info.prev = ""
}

Storage Default
{
<Data name="partintroDefaultData">
<Subscript>"partintro"</Subscript>
<Value name="1">
<Value>part</Value>
</Value>
</Data>
<DefaultData>partintroDefaultData</DefaultData>
<Type>%Library.CacheStorage</Type>
}

}
