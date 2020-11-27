Include DocBookMac

/// A list of errors found while loading the DocBook content.
Class DocBook.ErrorLog Extends %Persistent [ ClassType = persistent, ProcedureBlock ]
{

/// Source file containing the error
Property SourceFile As cdata(MAXLEN = 100);

/// Type of error
Property Type As cdata(MAXLEN = 100);

/// Content of the error block	
Property content As cdata(MAXLEN = 2000);

/// blockId of object containing error (if known)	
Property blockID As id;

/// Time of the error
Property ErrorTime As %TimeStamp [ InitialExpression = {$ZDT($H,3)} ];

/// Returns a count of errors
ClassMethod GetCount() As %Integer
{
	&sql(SELECT COUNT(*) INTO :count FROM ErrorLog)
	
	Quit count
}

/// Reset the error log
ClassMethod Reset()
{
	Kill ^DocBook.ErrorLogD
}

/// Reset the error log for a given file
ClassMethod ResetForFile(file As cdata)
{
	Set f = file // !!!

	&sql(DELETE FROM ErrorLog WHERE SourceFile = :f)
}

ClassMethod AddError(file As cdata, type As cdata, content As cdata = "", id As id = "") As %Integer [ Internal ]
{
	Set a = file,b = type, c = content, i = id  // !!!

	&sql(INSERT INTO ErrorLog (SourceFile, Type, content, blockID)
				VALUES (:a, :b, :c, :i))

	Quit SQLCODE
}

/// List the error log
ClassMethod List()
{
	&sql(DECLARE sql1 CURSOR FOR
			SELECT %ID,SourceFile,Type,ErrorTime,content,blockID
			INTO :id,:file,:type,:time,:content,:bid
			FROM ErrorLog )

	&sql(OPEN sql1)
	&sql(FETCH sql1)
	While (SQLCODE = 0) {
		Write !,"ERROR ",id," [",file,"] --",time,!
		Write type
		Write:bid'="" "(",bid,")"
		Write " ",$E(content,1,100),!
		&sql(FETCH sql1)
	}
	&sql(CLOSE sql1)
	
	Write !,$$$T("Errors found: "), ..GetCount(), !
}

Storage Default
{
<Data name="ErrorLogDefaultData">
<Value name="1">
<Value>%%CLASSNAME</Value>
</Value>
<Value name="2">
<Value>ErrorTime</Value>
</Value>
<Value name="3">
<Value>SourceFile</Value>
</Value>
<Value name="4">
<Value>Type</Value>
</Value>
<Value name="5">
<Value>content</Value>
</Value>
<Value name="6">
<Value>blockID</Value>
</Value>
</Data>
<DataLocation>^DocBook.ErrorLogD</DataLocation>
<DefaultData>ErrorLogDefaultData</DefaultData>
<IdLocation>^DocBook.ErrorLogD</IdLocation>
<IndexLocation>^DocBook.ErrorLogI</IndexLocation>
<StreamLocation>^DocBook.ErrorLogS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
