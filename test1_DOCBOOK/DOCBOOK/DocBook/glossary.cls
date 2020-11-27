Include DocBookMac

/// A glossary.
Class DocBook.glossary Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
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
	Set info.chap = $$$T("Glossary")
	Set info.prev = ""
	Set info.next = ""
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
