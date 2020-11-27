Include DocBookMac

/// This is a user comment.
Class DocBook.UserComment Extends %Library.Persistent [ ClassType = persistent, ProcedureBlock ]
{

Index BlockIdx On BlockId [ Type = index ];

Index UserIdx On UserName [ Type = index ];

/// The user who submitted this comment
Property UserName As cdata;

/// When this comment was created
Property CreateTime As %TimeStamp;

/// The user's comment
Property Comment As cdata(MAXLEN = 2000);

/// The reason associated with the comment
Property Reason As cdata;

/// The id of the text block this comment refers to
Property BlockId As id;

Storage Default
{
<Data name="DocBook.UserCommentClassName">
<Attribute>%%CLASSNAME</Attribute>
<Structure>node</Structure>
<Subscript>0</Subscript>
</Data>
<Data name="UserCommentDefaultData">
<Value name="1">
<Value>CreateTime</Value>
</Value>
<Value name="2">
<Value>UserName</Value>
</Value>
<Value name="3">
<Value>BlockId</Value>
</Value>
<Value name="4">
<Value>Comment</Value>
</Value>
<Value name="5">
<Value>Reason</Value>
</Value>
</Data>
<DataLocation>^DocBook.UserCommentD</DataLocation>
<DefaultData>UserCommentDefaultData</DefaultData>
<IdLocation>^DocBook.UserCommentD</IdLocation>
<IndexLocation>^DocBook.UserCommentI</IndexLocation>
<StreamLocation>^DocBook.UserCommentS</StreamLocation>
<Type>%Library.CacheStorage</Type>
}

}
