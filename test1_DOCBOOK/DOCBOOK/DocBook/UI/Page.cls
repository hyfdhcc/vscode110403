Include DocBookMac

/// Server for standard DocBook page.
Class DocBook.UI.Page Extends DocBook.UI.StdPage [ ProcedureBlock ]
{

ClassMethod OnPage() As %Status [ Internal ]
{
	New %tutorial

	Set info = ##class(BannerInfo).%New()

	Set glo = $zu(67,9,$J)
	Set elap = $zh

	Set key = $G(%request.Data("KEY",1))
	Set frame = $G(%request.Data("FRAME",1))

	Set home = 0
	Set source = ""
	Set timestamp = ""
	Set container = ""
	Set %tutorial = 0
	
	If (key = "KNBASE") {
		Set container = ##class(DocBook.KNBase).%New()
		Set timestamp = $G(^DocBook.LoadTime)
	}
	ElseIf (key = "CATALOG") {
		Set container = ##class(DocBook.Catalog).%New()
		Set timestamp = $G(^DocBook.LoadTime)
	}
	ElseIf (key = "GettingStarted") {
		Set container = ##class(DocBook.GettingStarted).%New()
		Set timestamp = $G(^DocBook.LoadTime)
	}
	ElseIf (key '= "") {
		// open container object
		Set container = ##class(DocBook.container).OpenKey(key)
	}
	Else {
		// use Home container
		Set container = ##class(DocBook.Home).%New()
		Set home = 1
		Set timestamp = $G(^DocBook.LoadTime)
	}

	If (container = "") {
		Do ..Header($$$T("Error"))
		&html<<BODY>>

		Set info.title = $$$T("Error")
		Set info.booktitle = $$$T("InterSystems Online Documentation")

		Do ..RenderBanner(info)
		&html<<BR>>
		Write $$$T("Missing or Invalid Document"),!
	}
	ElseIf ($D(^DocBook.OffLine)) {
		Do ..Header($$$T("Documentation Unavailable"))
		&html<<BODY>>

		Set info.title = $$$T("Documentation Unavailable")
		Set info.booktitle = $$$T("InterSystems Online Documentation")

		Do ..RenderBanner(info)
		&html<<BR>>
		Write $$$T("The documentation server is currently unavailable."),!
	}
	Else {
		Set %tutorial = ($ZCVT(container.role,"U") = "TUTORIAL")
		Do ..Header(container.title,,home)
		&html<<BODY>>
	
		// find banner info
		Do container.GetBannerInfo(info)
		Set info.container = container

		Do ..RenderBanner(info,home)

		&html<<BR>>
		
		// now get container to render itself
		// No longer emitted
		// <TABLE WIDTH="100%" COLS="1" BORDER="0" CELLPADDING="0" CELLSPACING="0"><TR><TD>
		Do container.HTMLRender()
		// No longer emitted
		// </TD></TR></TABLE>

		// show time for container
		Set source = container.sourcefile
		Set:timestamp="" timestamp = container.sourcetime

	}

	Do ..Footer(1,timestamp,,source,info, $zu(67,9,$J)-glo,$zh-elap)
	
	&html<<SCRIPT LANGUAGE="JavaScript">
		if (parent != null && parent.TOCFrame != null) {
			parent.TOCFrame.updateLocation();
		}
	 </SCRIPT>>

	QUIT $$$OK
}

ClassMethod OnPreHTTP() As %Boolean [ Internal ]
{
	// Use ^DocBook.Config("EXPIRES") to set expiration date
	// Use ^DocBook.Config("VARYBYPARAM") to set VaryByParam

	// Make this page cacheable (for an hour, by default) if it belongs to the standard book set;
	// otherwise the page will not be cached, unless specified EXPIRES=n as a URL parameter (HCR321; HCR463)
	Set book = $P($G(%request.Data("KEY",1)),"_",1)
	If (book'="") && ($D(^DocBook.BookList(book))) {
		Set %response.Expires = ##class(DocBook.ConfigUtils).GetEXPIRES()
	}
	Else {
		If $G(%request.Data("EXPIRES",1))'="" {
			Set %response.Expires = +%request.Data("EXPIRES",1) // Custom number of seconds to expire
		}
		Else {
			Set %response.Expires = 0 // Expire immediately
		}
	}

	// Force any requests for home page to go to new Home page
	If ($G(%request.Data("KEY",1))="") {
		Set %response.ServerSideRedirect = "DocBook.UI.HomePageZen.cls"
		Quit 1
	}

	// Optional output caching
	Set present = ##class(DocBook.ConfigUtils).GetVARYBYPARAM()
	If (present '= "") {
		Set %response.VaryByParam = present
	}

	QUIT 1
}

}
