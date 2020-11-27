Include DocBookMac

/// Meta-information for a reference entry.
Class DocBook.refmeta Extends %Library.SerialObject [ ClassType = serial, ProcedureBlock ]
{

Property refentrytitle As cdata;

Storage Default
{
<Data name="refmetaState">
<Value name="1">
<Value>refentrytitle</Value>
</Value>
</Data>
<State>refmetaState</State>
<StreamLocation>^DocBook.refmetaS</StreamLocation>
<Type>%Library.CacheSerialState</Type>
}

}
