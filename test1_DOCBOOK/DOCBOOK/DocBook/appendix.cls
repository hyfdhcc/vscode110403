Include DocBookMac

/// This class represents a DocBook appendix.
Class DocBook.appendix Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
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
	Set info.chap = $$$T("Appendix")
	
	// find prev/next chapter
	If ($G(%tutorial) = 1) {
		Set info.prev = ":self.history.back();" // !!!
	}
	Else {
		Do ..GetNextPrevInfo(info)
	}
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
