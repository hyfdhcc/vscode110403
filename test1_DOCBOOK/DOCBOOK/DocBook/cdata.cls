Include DocBookMac

/// A simple datatype corresponding to a CDATA string
Class DocBook.cdata [ ClassType = datatype, Not ProcedureBlock ]
{

/// Make id values case-insensitive
Parameter COLLATION = "SQLUPPER";

Parameter MAXLEN = 50;

}
