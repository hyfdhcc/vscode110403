Include DocBookMac

/// An index viewer page.
Class DocBook.UI.Index Extends DocBook.UI.StdPage [ ProcedureBlock ]
{

/// Background index building method
ClassMethod ABG() [ Internal ]
{
	Do ##class(DocBook.Utils).BuildIndex()
	Kill ^DocBook.Rebuild("Master")
	Quit
}

ClassMethod OnPage() As %Status [ Internal ]
{

	Set info = ##class(BannerInfo).%New()
	Set info.title = $$$T("Master Index")
	Set info.booktitle = $$$T("InterSystems Online Documentation Index")

	Do ..Header($$$T("Master Index"))

	&html<<BODY>>

	Do ..RenderBanner(info)
	&html<<BR>>
	
	/// Build an index into a temp global: 
	/// ^DocBook.Index(KEY,n) = $LB(entry,link)<br>
	/// Where KEY is the collated key and n is the entry number.

	If ('$D(^DocBook.Index)) {
		Do ..RebuildIndex()
	}
	Else {

		Set curr = $G(%request.Data("LETTER",1),"A")
		Do ..ShowLetterTable(curr)
	
		Set key = $Order(^DocBook.Index(" "_curr),-1)
		Set key = $Order(^DocBook.Index(key))

		&html<<UL>>

		/// Book titles (e.g. "book" and "article" titles) are currently barred
		/// from generating index entries, for unknown reasons. Leave those labels  
		/// here (actually add "article" as well) in case they come back later.
		/// Note that "block" is the name that DocBook.Utils.AddMarkedEntry() assigns to 
		/// subscript 3 when it puts <indexterm> entries into the ^DocBook.Index global.
		
		While ((key '= "") && ($E(key,2,2) = curr)) {
			Set n = $Order(^DocBook.Index(key,""))
			While (n '= "") {
				Set entry = $LG(^DocBook.Index(key,n),1)
				Set link = $LG(^DocBook.Index(key,n),2)
				Set s = $LG(^DocBook.Index(key,n),3)
				Set ctitle = $LG(^DocBook.Index(key,n),4)
				Set source = $SELECT((s = "article") : $$$T("Article Title"),
				                     (s = "book") : $$$T("Book Title"),
				                     (s = "chapter") : $$$T("Chapter Title"),
				                     (s = "sect1") : $$$T("Section Title"),
				                     (s = "sect2") : $$$T("Subsection Title"),
				                     (s = "refentry") : $$$T("Reference Page"),
				                     (s = "reference") : $$$T("Reference Title"),
				                     (s = "appendix") : $$$T("Appendix Title"),
				                     (s = "glossentry") : $$$T("Definition"),
				                     (s = "block") : $$$T("Index Entry"),
				                     1 : "")
			
				If (ctitle '= "") {
					Set source = "<SPAN CLASS=""IndexSourceTitle"">" _ ctitle _ "</SPAN>" _ $S(source'="":" (",1:"") _ source _ $S(source'="":")",1:"")
				}

				&html<<LI CLASS="IndexEntry"><A CLASS="IndexEntry" HREF="DocBook.UI.Page.cls?#(link)#">#(entry)#</A>>
				If (source '= "") {
					&html<<SPAN CLASS="IndexSource">&nbsp;&#151;&nbsp;#(source)#</SPAN>>
				}
				Set n = $Order(^DocBook.Index(key,n))
			}
			Set key = $Order(^DocBook.Index(key))
		}

		&html<</UL>>
		Do ..ShowLetterTable(curr)
	}
	
	Do ..Footer(,$G(^DocBook.IndexTime))

	Quit $$$OK
}

ClassMethod RebuildIndex() [ Internal ]
{
	// set up background process
	Set ^DocBook.Rebuild("Master") = 1
	Job zABG^DocBook.UI.Index.1()
	
	Write $$$T("Building Master Index")
	
	Set i = 0
	While ($D(^DocBook.Rebuild("Master"))) {
	    Set i = i + 1
		Write "."
		Write:((i#40)=0) "<BR>",!
		Do %response.Flush()
		Hang .5
	}
	
	&HTML<<script language="JavaScript">
		self.document.location = self.document.location;
	</script>
	>
}

ClassMethod ShowLetterTable(curr As %String) [ Internal ]
{

	&html<<TABLE CLASS="IndexLetterTable" CELLPADDING="5" CELLSPACING="0" BORDER="0">>
	For row = 0:1:0 {
		&html<<TR>>
		For col = 0:1:25 {
			Set letter = $C(((row * 13) + col) + $A("A"))
			If (letter = curr) {
				Set class = "IndexLetterCurr"
				Set mouse = "onmouseover=""this.className='IndexLetterCurrHi';"" onmouseout=""this.className='IndexLetterCurr';"""
			}
			Else {
				Set class = "IndexLetter"
				Set mouse = "onmouseover=""this.className='IndexLetterHi';"" onmouseout=""this.className='IndexLetter';"""
			}

			&html<<TD CLASS="#(class)#" ALIGN="CENTER" VALIGN="CENTER" 
					#(mouse)#
					onclick="self.document.location='DocBook.UI.Index.cls?LETTER=#(letter)#';return true;">
					<A CLASS="#(class)#" HREF="DocBook.UI.Index.cls?LETTER=#(letter)#">#(letter)#</A></TD>>
		}
		&html<</TR>>
	}
	
	&html<</TABLE>>
}

}
