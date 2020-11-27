Include DocBookMac

/// This class represents a book.
Class DocBook.book Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

Relationship set As set [ Cardinality = one, Inverse = books, SqlFieldName = dbset ];

Index setIdx On set [ Type = bitmap ];

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{
	Set info.title = $$$T("Contents")
	Set info.booktitle = ..title
	Set info.chap = ""
	Set info.prev = ""
	Set info.next = ""
}

Method HTMLRender() [ Internal ]
{

	Set chapno = 1

	Set id = ..%Id()

	&html<<TABLE CELLPADDING="0" CELLSPACING="0" BORDER="0" WIDTH="100%">>
	&html<<TR>>
	&html<<TD ALIGN="RIGHT" WIDTH="20%">&nbsp;</TD>>
	&html<<TD><DIV CLASS="TOC"><B>>
	Write $$$T("Contents")
	&html<</B></DIV><HR></TD>>
	&html<</TR>>

	Do ..ShowComponents(id)

	&html<</TABLE>>
}

///  Provide info for the goto list 
Method GetGotoList(ByRef gtl As cdata) [ Internal ]
{

	Set id = ..%Id()

	// list all of the components
	&sql(DECLARE G1Cursor CURSOR FOR
		SELECT ID,blockid, title
		INTO :cid, :key, :title
		FROM component
		WHERE book = :id
		ORDER BY container, blockpos
	)

	&sql(OPEN G1Cursor)
	&sql(FETCH G1Cursor)

	Set num = 1
	While (SQLCODE = 0) {
		Set gtl(num) = $LB(key,title)
		&sql(FETCH G1Cursor)
		Set num = num + 1
	}
	&sql(CLOSE G1Cursor)
	
	Quit
}

/// Show the list of components for this book
Method ShowComponents(ctrid As id) [ Internal, Private ]
{
	New %ISCDBCounter
	Set %ISCDBCounter = $INCREMENT(^||DocBook.CursorCount)
	Kill %DocBookCursor(%ISCDBCounter)
#EXECUTE Set %msqlvar = "%DocBookCursor(%ISCDBCounter"

	Set lastcls = ""

	// loop over components
	&sql(DECLARE CompCursor CURSOR FOR
		SELECT ID,blockid, title, subtitle, x__classname
		INTO :compid,:key, :title, :desc, :cls
		FROM component
		WHERE container = :ctrid
		ORDER BY blockpos
	)

	&sql(OPEN CompCursor)
	&sql(FETCH CompCursor)

	While (SQLCODE = 0) {
		// figure out what kind of component this is
		If (cls [ "chapter") {
			Set no(cls) = $G(no(cls),0) + 1
			Set no = no(cls)
			Set label = $$$T("Chapter ") _ no
		}
		ElseIf (cls [ "part") {
			Set no(cls) = $G(no(cls),0) + 1
			Set no = no(cls)
			Set label = $$$T("Part ") _ ..Roman(no)
		}
		ElseIf (cls [ "appendix") {
			Set no(cls) = $G(no(cls),0) + 1
			Set no = ..Letter(no(cls))
			Set label = $$$T("Appendix ") _ no
		}
		ElseIf (cls [ "glossary") {
			Set no(cls) = $G(no(cls),0) + 1
			Set no = ..Letter(no(cls))
			Set label = $$$T("Glossary ") _ no
		}
		ElseIf (cls [ "preface") {
			Set no(cls) = $G(no(cls),0) + 1
			Set no = ..Letter(no(cls))
			Set label = $$$T("Preface ") // !!!
		}
		ElseIf (cls [ "reference") {
			Set no(cls) = $G(no(cls),0) + 1
			Set no = ..Letter(no(cls))
			Set label = $$$T("Reference ") _ no
		}
		Else {
			Set no = ""
			Set label = ""
		}

		If ((lastcls '= "") && (lastcls '= cls)) {
			// draw a ruler between different types of components
			&html<<TR><TD ALIGN="RIGHT" WIDTH="20%">&nbsp;</TD><TD><HR></TD></TR>>
		}

		Set lastcls = cls
		
		&html<<TR><TD ALIGN="RIGHT" WIDTH="20%"><FONT SIZE="-1">>

		&html<#(label)#:&nbsp;</FONT></TD><TD><DIV CLASS="TOC">>
		
		If (cls [ "part") {
			&html<<DIV CLASS="Set">#(title)#</DIV>>
		}
		Else {
			&html<<A CLASS="TOCChapter" TITLE='#(desc)#' HREF='DocBook.UI.Page.cls?KEY=#($ZCVT(key,"O","URL"))#'>#(title)#</A>>
		}

		&html<</DIV>
			</TD></TR>
		>
		&html<<TR><TD>&nbsp;</TD><TD>>
		If (cls [ "reference") {
			Do ..ShowRefEntries(compid)
		}
		ElseIf (cls [ "part") {
			Do ..ShowComponents(compid)
		}
		Else {
			Do ..ShowSect1(compid,no)
		}
	
		&html<</TD></TR>>

		&sql(FETCH CompCursor)
	}
	&sql(CLOSE CompCursor)
#EXECUTE Kill %msqlvar

	Quit
}

/// Convert number to letter label
ClassMethod Letter(val As %Integer) As %String [ Internal ]
{
	// this handles up to 26 * 26 items

	Set lo = val - 1
	Set hi = lo \ 26
	Set lo = (lo # 26) + 1
	Quit:(hi = 0) $C(64 + lo)
	Quit ($C(64 + hi) _ $C(64 + lo))
}

/// Convert number to Roman numeral (incomplete)
ClassMethod Roman(val As %Integer) As %String [ Internal ]
{
	// this is only used for Part #s, so an incomplete
	// implementation is sufficient.
	If (val = 1) {
		Quit "I"
	}
	ElseIf (val = 2) {
		Quit "II"
	}
	ElseIf (val = 3) {
		Quit "III"
	}
	ElseIf (val = 4) {
		Quit "IV"
	}
	ElseIf (val = 5) {
		Quit "V"
	}
	ElseIf (val = 6) {
		Quit "VI"
	}
	ElseIf (val = 7) {
		Quit "VII"
	}
	ElseIf (val = 8) {
		Quit "VIII"
	}
	ElseIf (val = 9) {
		Quit "IX"
	}
	ElseIf (val = 10) {
		Quit "X"
	}
	ElseIf (val = 11) {
		Quit "XI"
	}
	ElseIf (val = 12) {
		Quit "XII"
	}

	Quit ""
}

/// Show the list of chapters for this container
Method ShowChapters(ctrid As id) [ Internal, Private ]
{

	Set chapno = 1

	// loop over chapters	
	&sql(DECLARE ChapCursor CURSOR FOR
		SELECT ID,blockid, title, subtitle
		INTO :chapid,:key, :title, :desc
		FROM chapter
		WHERE container = :ctrid
		ORDER BY blockpos
	)

	&sql(OPEN ChapCursor)
	&sql(FETCH ChapCursor)

	While (SQLCODE = 0) {
		&html<<TR><TD ALIGN="RIGHT" WIDTH="20%"><FONT SIZE="-1">>

		&html<Chapter #(chapno)#:&nbsp;</FONT></TD><TD><DIV CLASS="TOC">>
		
		&html<<A CLASS="TOCChapter" TITLE='#(desc)#' HREF='DocBook.UI.Page.cls?KEY=#($ZCVT(key,"O","URL"))#'>#(title)#</A>>

		&html<</DIV>
			</TD></TR>
		>
		&html<<TR><TD>&nbsp;</TD><TD>>
		Do ..ShowSect1(chapid,chapno)
	
		&html<</TD></TR>>

		Set chapno = chapno + 1
		&sql(FETCH ChapCursor)
	}
	&sql(CLOSE ChapCursor)
}

/// Show the list of references for this container
Method ShowReferences(ctrid As id) [ Internal, Private ]
{

	Set chapno = 1
	Set ruler = 1 // !!!

	// loop over references
	&sql(DECLARE RefCursor CURSOR FOR
		SELECT ID, blockid, title, subtitle
		INTO :refid, :key, :title, :desc
		FROM reference
		WHERE container = :ctrid
		ORDER BY blockpos
	)

	&sql(OPEN RefCursor)
	&sql(FETCH RefCursor)

	While (SQLCODE = 0) {
		If (ruler = 0) {
			// draw ruler before references
			&html<<TR><TD ALIGN="RIGHT" WIDTH="20%">&nbsp;</TD><TD><HR></TD></TR>>
			Set ruler = 1
		}

		&html<<TR><TD ALIGN="RIGHT" WIDTH="20%"><FONT SIZE="-1">>

		&html<Reference:</FONT></TD><TD><DIV CLASS="TOC">>

		&html<<A CLASS="TOCChapter" TITLE='#(desc)#'>#(title)#</A>>
		
		&html<</DIV>
			</TD></TR>
		>
		&html<<TR><TD>&nbsp;</TD><TD>>
		// have the reference display its entries
		Do ..ShowRefEntries(refid)	
		&html<</TD></TR>>

		Set chapno = chapno + 1
		&sql(FETCH RefCursor)
	}
	&sql(CLOSE RefCursor)
}

/// Show the list of appendices for this container
Method ShowAppendices(ctrid As id) [ Internal, Private ]
{

	Set chapno = 1
	Set ruler = 0

	// loop over appendices
	&sql(DECLARE AppCursor CURSOR FOR
		SELECT ID,blockid, title, subtitle
		INTO :chapid,:key, :title, :desc
		FROM appendix
		WHERE container = :ctrid
		ORDER BY blockpos
	)

	&sql(OPEN AppCursor)
	&sql(FETCH AppCursor)

	While (SQLCODE = 0) {
		Set desc = ##class(DocBook.Renderer).FilterText(desc)
		If (ruler = 0) {
			// draw ruler before appendices
			&html<<TR><TD ALIGN="RIGHT" WIDTH="20%">&nbsp;</TD><TD><HR></TD></TR>>
			Set ruler = 1
		}

		&html<<TR><TD ALIGN="RIGHT" WIDTH="20%"><FONT SIZE="-1">>

		&html<Appendix #($C(64+chapno))#:&nbsp;</FONT></TD><TD><DIV CLASS="TOC">>
		
		&html<<A CLASS="TOCChapter" TITLE='#(desc)#' HREF='DocBook.UI.Page.cls?KEY=#($ZCVT(key,"O","URL"))#'>#(title)#</A>>

		&html<</DIV>
			</TD></TR>
		>
		&html<<TR><TD>&nbsp;</TD><TD>>
		Do ..ShowSect1(chapid,chapno)
	
		&html<</TD></TR>>

		Set chapno = chapno + 1
		&sql(FETCH AppCursor)
	}
	&sql(CLOSE AppCursor)
}

/// display the level 1 sections for the given chapter
Method ShowSect1(id As id, label As dbint) [ Internal, Private ]
{

	Set num = 1

	// list all of the sect1 blocks
	&sql(DECLARE S1Cursor CURSOR FOR
		SELECT ID,blockid, title, component->blockid
		INTO :sid,:key, :title, :chap
		FROM sect1
		WHERE container = :id
	)

	&sql(OPEN S1Cursor)
	&sql(FETCH S1Cursor)

	Write "<MENU>",!
	While (SQLCODE = 0) {
		&html<<LI><A CLASS="TOCSect1" HREF='DocBook.UI.Page.cls?KEY=#($ZCVT(chap,"O","URL"))##("#"_key)#'>#(label _ "." _ num)# #(title)#</A></LI>>

		Do ..ShowSect2(sid,label _ "." _ num)
		&sql(FETCH S1Cursor)
		Set num = num + 1
	}
	Write "</MENU>",!

	&sql(CLOSE S1Cursor)
}

/// display the level 2 sections for the given chapter
Method ShowSect2(id As id, label As cdata) [ Internal, Private ]
{

	Set num = 1

	// list all of the sect2 blocks
	&sql(DECLARE S2Cursor CURSOR FOR
		SELECT ID,blockid, title, component->blockid
		INTO :sid,:key, :title, :chap
		FROM sect2
		WHERE container = :id
	)

	&sql(OPEN S2Cursor)
	&sql(FETCH S2Cursor)

	Write "<MENU>",!

	While (SQLCODE = 0) {
		&html<<LI><A CLASS="TOCSect2" HREF='DocBook.UI.Page.cls?KEY=#($ZCVT(chap,"O","URL"))##("#"_key)#'>#(label _ "." _ num)# #(title)#</A></LI>>
		&sql(FETCH S2Cursor)
		Set num = num + 1
	}

	Write "</MENU>",!

	&sql(CLOSE S2Cursor)
}

Method ShowRefEntries(id As id) [ Internal ]
{

	&sql(DECLARE RECursor CURSOR FOR
		SELECT %ID,blockid, refmeta_refentrytitle
		INTO :eid,:key, :title
		FROM refentry
		WHERE container = :id
		ORDER BY blockpos
	)

	&sql(OPEN RECursor)
	&sql(FETCH RECursor)

	Set last = ""

	// No longer emitted
	// <TABLE CELLPADDING="5" CELLSPACING="0" BORDER="0" WIDTH="100%">

	Write "<MENU>",!
	While (SQLCODE = 0) {
		
		// find refpurpose for this entry
		Set purpose = ""
		&sql(SELECT content INTO :purpose FROM refpurpose WHERE component = :eid)
		
		// look at first letter of string
		Set c = $ZCONVERT($E(title,1,1), "U")
		If ((c '= last)) {
			// special banner for start of new letter
			// No longer emitted
			// <TR><TD ALIGN="LEFT" CLASS="Letter">&#151; #(c)# &#151;</TD></TR>
		}
		Set last = c
		
		Set href = "DocBook.UI.Page.cls?KEY=" _ $ZCVT(key,"O","URL")
		
		//!!! (make it easier to find missing titles)
		Set:title="" title = "[" _ key _ "] (untitled)"
		
		Set purpose = ##class(DocBook.Renderer).FilterText(purpose)

		// add mdash
		Set:purpose'="" purpose = "&nbsp;&#151;&nbsp;" _ purpose
		
		&html<<LI><A CLASS="TOCRef" HREF='#(href)#'>#(title)#</A><SPAN CLASS="TOCrefpurpose">#(purpose)#</SPAN></LI>>

		// no longer emitted
		// <TR><TD ALIGN="LEFT"><DIV CLASS="TOC"><A CLASS="TOCRef" HREF='#(href)#'>#(title)#</A></DIV></TD></TR>
		
		&sql(FETCH RECursor)
	}
	Write "</MENU>",!

	// No longer emitted
	// </TABLE>
	&sql(CLOSE RECursor)
}

Storage Default
{
<Data name="bookDefaultData">
<Subscript>"book"</Subscript>
<Value name="1">
<Value>set</Value>
</Value>
</Data>
<DefaultData>bookDefaultData</DefaultData>
<Property name="blockpos"/>
<Property name="book"/>
<Property name="component"/>
<Property name="container"/>
<Property name="content"/>
<Property name="id"/>
<Property name="lang"/>
<Property name="lastChildPos"/>
<Property name="lastchange"/>
<Property name="remap"/>
<Property name="renderedContent"/>
<Property name="role"/>
<Property name="set"/>
<Property name="sourcefile"/>
<Property name="sourcetime"/>
<Property name="status"/>
<Property name="subtitle"/>
<Property name="tagattrs"/>
<Property name="title"/>
<Type>%Library.CacheStorage</Type>
}

}
