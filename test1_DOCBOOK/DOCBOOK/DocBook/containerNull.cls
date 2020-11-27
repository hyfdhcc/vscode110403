Include DocBookMac

/// A container is a specialized block that can contain one or more blocks.
/// This one functions like a container but never displays anything.
Class DocBook.containerNull Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

/// render this container's children
Method %OnBeforeSave(insert As %Boolean) As %Status [ Internal ]
{
	If ($LENGTH(..content) > 0)
	{
		Write "Content truncated", ! 
		Set ..content = ""
	}
	
	Do ..DeleteDependents(..%Id())
	
	Set ..lastChildPos = 0

	Quit $$$OK
}

/// render this container's children
Method HTMLRender() [ Internal ]
{
	// HTML rendering is null

	Quit
}

Method XMLRender() [ Internal ]
{
	// XML rendering is null
	Quit
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
