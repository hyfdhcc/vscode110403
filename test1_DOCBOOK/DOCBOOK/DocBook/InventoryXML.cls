Include DocBookMac

/// This class contains methods used to construct the inventory
/// of the database as an XML structure.  It counts the SETs, BOOKs,
/// and ARTICLEs, including tutorials.
/// 
Class DocBook.InventoryXML Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Parameter DefaultOutput = "C:\TEMP\DBInventory.xml";

/// This generates the inventory in the file path given
ClassMethod Generate(OutputPath As %String) As %Status
{
	; Set up the temp file
	Set Status = ..SetupFile(.File, OutputPath)
	If ($SYSTEM.Status.IsError(Status))
	{
		Do $SYSTEM.Status.DisplayError(Status)
		Quit
	}

	; write the standard file header
	Do ..WritePrologue(File)

	; write the book data
	Do File.WriteLine("<!-- Sets -->")
	Do ..WriteSets(File)

	; write the article data
	Do File.WriteLine("<!-- Articles -->")
	Do ..WriteArticles(File)

	; write the standard file trailer
	Do ..WriteEpilogue(File)

	; Done with the file
	Do File.Close()

	Write $$$T("Wrote: "),File.Name,!

	Quit $$$OK
}

/// Writes the standard file header
ClassMethod SetupFile(ByRef XMLFile As %Library.File, OutTarget As %Library.String) As %Status [ Internal ]
{
	// Use the current datetime as part of the name
	Set filepath = ..#DefaultOutput
	Set:($LENGTH(OutTarget) > 0) filepath = OutTarget

	Set XMLFile = ##class(%Library.File).%New(filepath)
	Do XMLFile.Open("WSNK\UTF8\")

	Quit $$$OK
}

/// Writes the standard file header
ClassMethod WritePrologue(XMLFile As %Library.File) As %Status [ Internal ]
{
	// the prologue for an inventory file
	Do XMLFile.WriteLine("<?xml version=""1.0"" encoding=""utf-8""?>")
	Do XMLFile.WriteLine("<!DOCTYPE inventory [")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT inventory (description*, sets?, articles?)>")
	Do XMLFile.WriteLine("<!ATTLIST inventory product CDATA #REQUIRED")
	Do XMLFile.WriteLine("                    version CDATA #REQUIRED")
	Do XMLFile.WriteLine("                    date CDATA #REQUIRED")
	Do XMLFile.WriteLine("                    time CDATA #REQUIRED>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT description (#PCDATA)>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT sets (set*)>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT set (title, subtitle, books*)>")
	Do XMLFile.WriteLine("<!ATTLIST set id CDATA #REQUIRED")
	Do XMLFile.WriteLine("              name CDATA #REQUIRED")
	Do XMLFile.WriteLine("              status CDATA #REQUIRED")
	Do XMLFile.WriteLine("              order CDATA #REQUIRED>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT books (book*)>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT book (title, subtitle)>")
	Do XMLFile.WriteLine("<!ATTLIST book id CDATA #REQUIRED")
	Do XMLFile.WriteLine("               name CDATA #REQUIRED")
	Do XMLFile.WriteLine("               status CDATA #REQUIRED")
	Do XMLFile.WriteLine("               order CDATA #REQUIRED")
	Do XMLFile.WriteLine("               role CDATA #REQUIRED>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT articles (role*)>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT role (article*)>")
	Do XMLFile.WriteLine("<!ATTLIST role category CDATA #REQUIRED>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT article (title, subtitle)>")
	Do XMLFile.WriteLine("<!ATTLIST article id CDATA #REQUIRED")
	Do XMLFile.WriteLine("                  name CDATA #REQUIRED")
	Do XMLFile.WriteLine("                  status CDATA #REQUIRED")
	Do XMLFile.WriteLine("                  order CDATA #REQUIRED")
	Do XMLFile.WriteLine("                  role CDATA #REQUIRED>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT title (#PCDATA)>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ELEMENT subtitle (#PCDATA)>")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("<!ENTITY % winansi SYSTEM ""winansi.entities"">")
	Do XMLFile.WriteLine("%winansi;")
	Do XMLFile.WriteLine("")
	Do XMLFile.WriteLine("]>")

	Do XMLFile.WriteLine("<!-- Generated file - Do Not Edit -->")

	Set FmtMaj = $SYSTEM.Version.GetMajor()
	Set FmtMin = $SYSTEM.Version.GetMinor()
	Set FmtPnt = $SYSTEM.Version.GetPoint()
	Set FmtBld = $SYSTEM.Version.GetBuildNumber()

	Set FmtVersion = FmtMaj
	    	        _ "."
	    	        _ FmtMin
	    	        _ "."
	    	        _ $SELECT($LENGTH(FmtPnt = 0):"0", 1:FmtPnt)
	    	        _ "."
	    	        _ FmtBld

	Set now = $ZUTIL(188)
	Set FmtDate = $ZDATE(now, 3)
	Set FmtTime = $ZTIME(now, 1)

	Do XMLFile.Write("<inventory")
	Do XMLFile.Write((" product=""" _ $SYSTEM.Version.GetProduct() _ """"))
	Do XMLFile.Write(" version=""" _ FmtVersion _ """")
	Do XMLFile.Write(" date=""" _ FmtDate _ """")
	Do XMLFile.Write(" time=""" _ FmtTime _ """")
	Do XMLFile.WriteLine(">")
	Do XMLFile.WriteLine("<description/>")

	Quit $$$OK
}

/// Writes the standard file trailer
ClassMethod WriteEpilogue(XMLFile As %Library.File) As %Status [ Internal ]
{
	// end the file
	Do XMLFile.WriteLine("</inventory>")
	Quit $$$OK
}

/// Get the SETs in the proper order
ClassMethod GetSets(ByRef SetData) As %Status [ Internal ]
{
	// collect the sets from the index
    Set setid = $O(^DocBook.blockI("setIdx",""))
    Set keyinx = 0

    While (setid '="")
    {
        Set set = ##class(DocBook.set).%OpenId(setid)

        If (set '="")
        {
            Set keyinx = $INCREMENT(keyinx)
            Set sortkey = set.remap
            If (sortkey = "")
            {
                Set sortkey = "~" _ (1000 + keyinx)
            }
            Set setorder(sortkey) = set

            Set set = ""
        }

        Set setid = $O(^DocBook.blockI("setIdx",setid))
    	;Write "SETID=",setid,!
    }

    Set setid = $ORDER(setorder(""))
    Set keyinx = 0
    While (setid '="")
    {
        Set set = $GET(setorder(setid))

    	; ignore tutorial material
    	;If ($ZCONVERT(set.id, "L") [ "tutorial")
    	;{
       	;	Set setid = $ORDER(setorder(setid))
    	;	continue
    	;}
    	Set keyinx = keyinx + 1
        Set SetData(keyinx, "ID") = set.%Id()
        Set SetData(keyinx, "name") = set.id
        Set SetData(keyinx, "title") = set.title
        Set SetData(keyinx, "subtitle") = set.subtitle
        Set SetData(keyinx, "status") = set.status
        Set SetData(keyinx, "order") = setid

        Set set = ""
        Set setid = $ORDER(setorder(setid))
    }
    Set SetData(0) = keyinx

	Quit $$$OK
}

/// Get the books belonging to the SET
ClassMethod GetBooks(SetID As %Integer, ByRef BookData) As %Status [ Internal ]
{
    ; loop over books
    &sql(DECLARE BookCursor CURSOR FOR
        SELECT ID, blockid, title, subtitle, dbstatus, dbrole, remap
        INTO :id, :bookKey, :title, :desc, :dbstatus, :role, :remap
        FROM DocBook.book
        WHERE container = :SetID
        ORDER BY remap, title
    )

    &sql(OPEN BookCursor)
    &sql(FETCH BookCursor)

    Set keyinx = 0
    While (SQLCODE = 0)
    {
    	Set keyinx = keyinx + 1
    	Set BookData(keyinx, "ID") = id
        Set BookData(keyinx, "name") = bookKey
        Set BookData(keyinx, "title") = title
        Set BookData(keyinx, "subtitle") = desc
        Set BookData(keyinx, "status") = dbstatus
        Set BookData(keyinx, "order") = remap
        Set BookData(keyinx, "role") = role

        &sql(FETCH BookCursor)
    }
    &sql(CLOSE BookCursor)

    Set BookData(0) = keyinx

	Quit $$$OK
}

/// Get the articles that have been loaded
ClassMethod GetArticles(ByRef ArticleData) As %Status [ Internal ]
{
    ; loop over articles within role
	&sql(DECLARE ArticleCursor CURSOR FOR
		SELECT ID, blockid, title, subtitle, dbstatus, dbrole, remap
		INTO :id, :key, :title, :desc, :dbstatus, :subj, :remap
		FROM DocBook.article
		ORDER BY dbrole, remap, title
	)

	&sql(OPEN ArticleCursor)
	&sql(FETCH ArticleCursor)

    Set keyinx = 0
    While (SQLCODE = 0)
    {
    	Set keyinx = keyinx + 1
    	Set ArticleData(keyinx, "ID") = id
        Set ArticleData(keyinx, "name") = key
        Set ArticleData(keyinx, "title") = title
        Set ArticleData(keyinx, "subtitle") = desc
        Set ArticleData(keyinx, "status") = dbstatus
        Set ArticleData(keyinx, "role") = subj
        Set ArticleData(keyinx, "order") = remap

        &sql(FETCH ArticleCursor)
    }
    &sql(CLOSE ArticleCursor)

    Set ArticleData(0) = keyinx

	Quit $$$OK
}

/// WHandle text appropriately
ClassMethod TEXT(text As %String) As %String [ Internal ]
{
	Quit (text)
	Quit ("<!" _ "[CDATA[" _ text _ "]" _ "]" _ ">")
}

/// Write the sets page, each of the books contents and then the articles
ClassMethod WriteSets(XMLFile As %Library.File) As %Status [ Internal ]
{
	// start the iventory
	Set Status = ..GetSets(.SETs)
	If ($SYSTEM.Status.IsError(Status))
	{
		Do $SYSTEM.Status.DisplayError(Status)
		Quit
	}

	Do XMLFile.WriteLine("<sets>")
	For i = 1 : 1 : SETs(0)
	{
		Do XMLFile.Write("<set")
		Do XMLFile.Write(" id=""" _ SETs(i, "ID") _ """")
		Do XMLFile.Write(" name=""" _ SETs(i, "name") _ """")
		Do XMLFile.Write(" status=""" _ SETs(i, "status") _ """")
		Do XMLFile.WriteLine(" order=""" _ SETs(i, "order") _ """>")

		Do XMLFile.WriteLine("<title>" _ ..TEXT(SETs(i, "title")) _ "</title>")
		Do XMLFile.WriteLine("<subtitle>" _ ..TEXT(SETs(i, "subtitle")) _ "</subtitle>")

		Do XMLFile.WriteLine("<books>")
		Do ..WriteBooks(XMLFile, SETs(i, "ID"))
		Do XMLFile.WriteLine("</books>")

		Do XMLFile.WriteLine("</set>")
	}
	Do XMLFile.WriteLine("</sets>")

	Quit $$$OK
}

/// Writes the books in the set
ClassMethod WriteBooks(XMLFile As %Library.File, setid As %Integer) As %Status [ Internal ]
{
	Set Status = ..GetBooks(setid, .BOOKs)
	If ($SYSTEM.Status.IsError(Status))
	{
		Do $SYSTEM.Status.DisplayError(Status)
		Quit
	}

	For i = 1 : 1 : BOOKs(0)
	{
		Do XMLFile.Write("<book")
		Do XMLFile.Write(" id=""" _ BOOKs(i, "ID") _ """")
		Do XMLFile.Write(" name=""" _ BOOKs(i, "name") _ """")
		Do XMLFile.Write(" status=""" _ BOOKs(i, "status") _ """")
		Do XMLFile.Write(" order=""" _ BOOKs(i, "order") _ """")
		Do XMLFile.WriteLine(" role=""" _ BOOKs(i, "role") _ """>")

		Do XMLFile.WriteLine("<title>" _ ..TEXT(BOOKs(i, "title")) _ "</title>")
		Do XMLFile.WriteLine("<subtitle>" _ ..TEXT(BOOKs(i, "subtitle")) _ "</subtitle>")

		Do XMLFile.WriteLine("</book>")
	}

	Quit $$$OK
}

/// Writes the page for the articles
ClassMethod WriteArticles(XMLFile As %Library.File) As %Status [ Internal ]
{
	Set Status = ..GetArticles(.ARTICLEs)
	If ($SYSTEM.Status.IsError(Status))
	{
		Do $SYSTEM.Status.DisplayError(Status)
		Quit
	}

	Do XMLFile.WriteLine("<articles>")

	Set lastrole = ""
	For i = 1 : 1 : ARTICLEs(0)
	{
		If (lastrole '= ARTICLEs(i, "role"))
		{
			If (i > 1)
			{
				Do:(lastrole '= "") XMLFile.WriteLine("</role>")
			}
			Do XMLFile.Write("<role")
			Do XMLFile.WriteLine(" category=""" _ ARTICLEs(i, "role") _ """>")
			Set lastrole = ARTICLEs(i, "role")
		}

		Do XMLFile.Write("<article")
		Do XMLFile.Write(" id=""" _ ARTICLEs(i, "ID") _ """")
		Do XMLFile.Write(" name=""" _ ARTICLEs(i, "name") _ """")
		Do XMLFile.Write(" status=""" _ ARTICLEs(i, "status") _ """")
		Do XMLFile.Write(" order=""" _ ARTICLEs(i, "order") _ """")
		Do XMLFile.WriteLine(" role=""" _ ARTICLEs(i, "role") _ """>")

		Do XMLFile.WriteLine("<title>" _ ..TEXT(ARTICLEs(i, "title")) _ "</title>")
		Do XMLFile.WriteLine("<subtitle>" _ ..TEXT(ARTICLEs(i, "subtitle")) _ "</subtitle>")

		Do XMLFile.WriteLine("</article>")
	}

	Do:(lastrole '= "") XMLFile.WriteLine("</role>")
	Do XMLFile.WriteLine("</articles>")

	Quit $$$OK
}

}
