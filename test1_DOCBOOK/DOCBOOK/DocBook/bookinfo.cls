Include DocBookMac

/// The instantiation of a book information block.  
/// This is a no-op as far as editing goes but is here because it can contain
/// sub-elements all of whose data must be ignored.
Class DocBook.bookinfo Extends DocBook.containerNull [ ClassType = persistent, ProcedureBlock ]
{

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
