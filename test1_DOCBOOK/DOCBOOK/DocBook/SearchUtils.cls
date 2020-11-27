Include (%occSAX, DocBookMac)

/// This set of method implements a search paths facility for locating
/// DocBook documents.
/// <P>
/// The items under ^DocBook.Config("SOURCE",&lt;X&gt;) are assumed
/// to contains the pathnames of directories to look in when trying to
/// locate a file.
/// The actual values of &lt;X&gt; are unimportant but their relative
/// values are used to specify an ordering of the target directories
/// under the applicable collation.
/// <!-- <P>
/// Future enhancement(?)
/// <BR>
/// Any level of the directory may contain wildcards and they will be
/// handled in the obvious way.  An element consisting of *** is
/// interpreted as asking for indefinite recursion to the bottom
/// of the directory hierarchy. -->
/// 
Class DocBook.SearchUtils Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

Parameter DefaultOutput = "C:\SearchPaths.log";

/// Build a list of directory paths to search.  If the parameter specifiying
/// a particular directory is non-null, construct a singleton list
/// containing only that element.
ClassMethod BuildSearchList(SingletonDir As %String = "") As %Library.ArrayOfDataTypes [ Internal ]
{
	; allocate space to hold our results
	set results = ##class(%Library.ArrayOfDataTypes).%New()

	; were we given only a single directory
	if (SingletonDir '= "")
	{
		set realdirpath = ##class(%Library.File).NormalizeDirectory(SingletonDir)
		set status = results.SetAt(realdirpath, 1)
		if ($system.Status.IsError(status))
		{
			do $system.OBJ.DisplayError(status)
		}
	}
	else
	{
		set searchpathlist = ##class(DocBook.ConfigUtils).GetSOURCE()
		if ($LISTLENGTH(searchpathlist) = 0)
		{
			set sc =$$$ERROR($$$GeneralError, $$$T("Empty search directory list"))
			do $system.OBJ.DisplayError(sc)
		}
		else
		{
			set i = 0
			for n = 1 : 1 : $LISTLENGTH(searchpathlist)
			{
				set curpath = $LIST(searchpathlist, n)
				; translate into "canonical" form
				set curpath = ##class(%Library.File).NormalizeDirectory(curpath)
				; DEBUG

				; store it
				set i = i + 1
				set status = results.SetAt(curpath, i)
				if ($system.Status.IsError(status))
				{
					do $system.OBJ.DisplayError(status)
				}
			}
		}
	}

	quit results
}

/// Add a subdirectory name to every element of the path.
ClassMethod ExtendSearchList(SearchList As %Library.ArrayOfDataTypes, SubDirName As %String) As %Library.ArrayOfDataTypes [ Internal ]
{
	; allocate space to hold our results
	set results = ##class(%Library.ArrayOfDataTypes).%New()

	; iterate over the elements extending the list
	set curkey = SearchList.Next("")
	while (curkey '= "")
	{
		set dirpath = SearchList.GetAt(curkey)
		set newpath = ..SubDirectoryName(dirpath, SubDirName)
		;write "ExtKey: ", curkey, !
		;write "ExtVal: ", dirpath, !
		;write "ExtNew: ", newpath, !
		set status = results.SetAt(newpath, curkey)
		if ($system.Status.IsError(status))
		{
			do $system.OBJ.DisplayError(status)
		}
		set curkey = SearchList.Next(curkey)
	}

	quit results
}

/// Finds the specified files using the search paths given in the global.
/// All occurrences of the name are returned as full paths.
/// It is the responsibility of the
/// caller to eliminate duplicate and/or redundant entries.
/// <!-- <P>
/// The file name
/// may contain wildcards. -->
ClassMethod LocateFiles(SearchList As %Library.ArrayOfDataTypes, FileName As %String = "*") As %Library.ArrayOfDataTypes [ Internal ]
{
	; did we get anything to look for
	if (FileName = "")
	{
		quit $$$ERROR($$$GeneralError, $$$T("File name not specified"))
	}

	; get the file there
	set foundfiles = ..Collector(SearchList, FileName, "F")

	quit foundfiles
}

/// Finds the specified directories using the search paths given in the global.
/// All occurrences of the name are returned as full paths.
/// It is the responsibility of the
/// caller to eliminate duplicate and/or redundant entries.
/// <!-- <P>
/// The file name
/// may contain wildcards. -->
ClassMethod LocateDirectories(SearchList As %Library.ArrayOfDataTypes, DirName As %String = "*") As %Library.ArrayOfDataTypes [ Internal ]
{
	; did we get anything to look for
	if (DirName = "")
	{
		quit $$$ERROR($$$GeneralError, $$$T("Directory name not specified"))
	}

	; get the file there
	set founddirs = ..Collector(SearchList, DirName, "D")

	quit founddirs
}

/// Use the given directory list to find the matching items
ClassMethod Collector(DirList As %Library.ArrayOfDataTypes, Pattern As %Library.String, TypeCodes As %String) As %Library.ArrayOfDataTypes [ Internal ]
{
	; initialize the return value
	set itemcnt = 0
	set founditems =  ##class(%Library.ArrayOfDataTypes).%New()

	set typeswanted = $ZCONVERT(TypeCodes, "U")
	; loop over the directory list
	; write "Pattern: ", Pattern, !
	for i = 1 : 1 : DirList.Count()
	{
		set thisdir = DirList.GetAt(i)
		; DEBUG
		;write "Searching: ", thisdir, !
		If '##class(%File).DirectoryExists(thisdir) Continue
		set probe = ##class(%Library.ResultSet).%New("%Library.File:FileSet")
		set probestatus = probe.Execute(thisdir, Pattern, "", 1)
		if ($system.Status.IsError(probestatus))
		{
			do $system.OBJ.DisplayError(probestatus)
		}
		while (probe.Next() '= 0)
		{
			; DEBUG
			;write "Name: ", probe.GetData(1), !
			;write "Type: ", probe.GetData(2), !
			;write "Size: ", probe.GetData(3), !
			;write "DateCreated: ", probe.GetData(4), !
			;write "DateModified: ", probe.GetData(5), !
			;write "ItemName: ", probe.GetData(6), !
			if (typeswanted [ probe.GetData(2))
			{
				set itemcnt = itemcnt + 1
				set storestatus = founditems.SetAt(probe.GetData(1), itemcnt)
				if ($system.Status.IsError(probestatus))
				{
					do $system.OBJ.DisplayError(probestatus)
				}
			}
		}
		set probestatus = probe.Close()
		if ($system.Status.IsError(probestatus))
		{
			do $system.OBJ.DisplayError(probestatus)
		}
	}

	; finished
	quit founditems
}

/// This has been replaced a call to the functionality
/// in %Library.File
/// 
ClassMethod SubDirectoryName(DirName As %String, SubDirName As %String) As %String [ Internal ]
{
	Set newdir = ##class(%Library.File).SubDirectoryName(DirName, SubDirName)

	Quit newdir
}

/// If given a path ending in a filename, this returns the directory path
/// where the file is located.  Otherwise, it returns the path to the
/// directory containing the directory specified.
ClassMethod ContainingDir(GivenPath As %String) As %String [ Internal ]
{
    Set result = ##class(%Library.File).ParentDirectoryName(GivenPath)

	; finished
	quit result
}

/// Given a path, this returns the last directory name in that path.
ClassMethod GetDirectoryname(GivenPath As %String) As %String [ Internal ]
{
	Set dirpath = ##class(%Library.File).GetDirectory(GivenPath)
	Set dirlen = ##class(%Library.File).GetDirectoryLength(GivenPath)
	Set result = 0
	Set isdrive = 0
	Set dirname = ##class(%Library.File).GetDirectoryPiece(GivenPath, dirlen, .result, .isdrive)
	quit dirname
}

/// Writes the standard file header
ClassMethod ExportSearchPaths(OutTarget As %Library.String = "") As %Status [ Internal ]
{
    // Use the current datetime as part of the name
    Set filepath = ..#DefaultOutput
    Set:($LENGTH(OutTarget) > 0) filepath = OutTarget

    Set LogFile = ##class(%Library.File).%New(filepath)
    Do LogFile.Open("WSNK\UTF8\")

    set dirlist = ..BuildSearchList()

    ; write the Search Path data
    Set hdr = "### Search Paths Defined: " _ dirlist.Count()
    Do LogFile.WriteLine(hdr)
    Set hdr = "### Written: " _ $ZDATETIME($HOROLOG, 2, 1)
    Do LogFile.WriteLine(hdr)

    For i = 1 : 1 : dirlist.Count()
    {
        Do LogFile.WriteLine(dirlist.GetAt(i))
    }

    ; Done with the file
    Do LogFile.Close()

    Write $$$T("Wrote: "),LogFile.Name,!
    Quit $$$OK
}

}
