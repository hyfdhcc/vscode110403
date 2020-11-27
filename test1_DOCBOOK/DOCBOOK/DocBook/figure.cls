Include DocBookMac

/// A figure.
Class DocBook.figure Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

/// Render the contents of this block
Method HTMLRenderContent() [ Internal ]
{
	Write "<DIV CLASS=""figure-title"">",..title,"</DIV>",!
	Write "<DIV CLASS=""figure"">"
	Write "<A name=""",..id,"""></A>",!
	Do ##class(Renderer).RenderText(..content)
	Write "</DIV>",!
}

/// Render the contents of this block as DocBook XML
Method XMLRender() [ Internal ]
{

	Set attrtext = ..FmtAttrs(..tagattrs)
	Set gensym = "label=" _ """" _ ..id _ """"
	
	If (attrtext '[ "label=")
	{
		Set attrtext = attrtext _ " " _ gensym
	}

	Write "<",..%ClassName()," ",attrtext,">"

	Write "<title>", ..title, "</title>", !
	Write ..content
	Write "</",..%ClassName(),">",!
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
