Include DocBookMac

/// A special parser for SetList documents.
Class DocBook.SetListParser Extends %XML.SAX.ContentHandler [ ProcedureBlock ]
{

Method error(error As %Library.String) [ Internal ]
{
  Write "SAX Error: ",error,!
}

/// Error handler
Method fatalError(fatalerror As %Library.String) [ Internal ]
{
 Write $$$T("SAX Fatal Error: "),fatalerror,!
}

Method startElement(uri As %Library.String, localname As %Library.String, qname As %Library.String, attrs As %Library.List) [ Internal ]
{

	Do ..UnpackAttrs(attrs,.arr)
	Set key = $G(arr("id"))

	// the only thing we care about is <set>
	If (localname = "set") {
		// add a set to the database
		Set set = ##class(set).OpenKey(key)
		If (set = "") {
			Set set = ##class(set).%New()
			Set set.id = key
			Write "Creating set: ",key,!
		}
		Else {
			Write "Updating set: ",key,!
		}
		Do set.%Save()
	}
}

/// Converts list of attrs into an array keyed by attr name
Method UnpackAttrs(attrs As %List, ByRef array As cdata) [ Internal ]
{

	For i = 1:5:$LL(attrs) {
		If ($LG(attrs,i+1) '= "") {
			Set array($LG(attrs,i+1)) = $LG(attrs,i+4)
		}
	}
}

}
