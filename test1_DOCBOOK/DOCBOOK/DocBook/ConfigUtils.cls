Include DocBookMac

/// This abstracts the location of the configuration data the DocBook uses.
/// It is done this way so that we can localize all the configuration data
/// references and thereby ease the transition to Cache 5.1.
/// 

Class DocBook.ConfigUtils Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// This looks for the global data first in
/// ^DocBook.Config(...) and, failing that, in ^%SYS("DOCBOOK",...").
/// If it finds either, it returns the prefix of the first one it
/// finds as a string.  
/// If it does not find either, it returns an empty string.
ClassMethod LocateGlobal(Subscript As %String = "") As %String [ Internal ]
{
    ; construct each of the references
    set prefix50 = "^%SYS(""DOCBOOK"","
    set ref50 = prefix50 _ Subscript _ ")"

    set prefix51 = "^DocBook.Config("
    set ref51 = prefix51  _ Subscript _ ")"
    
    ; test each one
    quit:($DATA(@ref51) > 0) prefix51
    quit:($DATA(@ref50) > 0) prefix50
    quit ""
}

/// Collect the present settings of the various configuration parameters
/// 
ClassMethod CollectConfigParams(Sep As %String = "~") As %String [ Internal ]
{
    set result = ""

    set div = ","
    set params = "TRACE"
               _ div _ "WIDECHARCHECK"
               _ div _ "PDFCHECK"
               _ div _ "ENTITYCHECK"
               _ div _ "INCLREMARK"
               _ div _ "INDEXCLASS"
               _ div _ "IGNORECOLORERROR"
               _ div _ "SUPPRESSFRAMEWARNING"
               _ div _ "URL"
               _ div _ "EXPIRES"
               _ div _ "VARYBYPARAM"
    
    for i = 1 : 1 : $LENGTH(params, div)
    {
        set name = $PIECE(params, div, i)
        set:($LENGTH(result) > 0) result = result _ Sep
        set result = result _ name _ " = " _ $CLASSMETHOD("DocBook.ConfigUtils", ("Get" _ name))
    }
    quit result
}

/// This displays the present setings of the various configuration parameters
/// 
ClassMethod DisplayConfigParams()
{
    set separator = "~"
    set pieces = ..CollectConfigParams(separator)
    for i = 1 : 1 : $LENGTH(pieces, separator)
    {
        write $PIECE(pieces, separator, i), !
    }
    quit
}

/// Gets the value of the configuration variable.
ClassMethod VarValue(Name As %String) As %Integer [ Internal ]
{
    set subscript = """" _ Name _ """"

    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the TRACE variable.
ClassMethod GetTRACE() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """TRACE"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the WIDECHARCHECK variable.
ClassMethod GetWIDECHARCHECK() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """WIDECHARCHECK"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the PDFCHECK variable.
ClassMethod GetPDFCHECK() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """PDFCHECK"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the ENTITYCHECK variable.
ClassMethod GetENTITYCHECK() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """ENTITYCHECK"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the INCLREMARK variable.
ClassMethod GetINCLREMARK() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """INCLREMARK"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the INCLREMARK variable.
ClassMethod GetINDEXCLASS() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """INDEXCLASS"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") ""
    set ref = prefix _ subscript _ ")"
        
    quit $GET(@ref)
}

/// Gets the value of the IGNORECOLORERROR variable.
ClassMethod GetIGNORECOLORERROR() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """IGNORECOLORERROR"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the SUPPRESSFRAMEWARNING variable.
ClassMethod GetSUPPRESSFRAMEWARNING() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """SUPPRESSFRAMEWARNING"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") 0
    set ref = prefix _ subscript _ ")"
        
    quit +$GET(@ref)
}

/// Gets the value of the URL variable.
ClassMethod GetURL() As %String [ Internal ]
{
    ; init the subscript name
    set subscript = """URL"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") ""
    set ref = prefix _ subscript _ ")"
        
    quit $GET(@ref)
}

/// Gets the value of the EXPIRES variable.
ClassMethod GetEXPIRES() As %String [ Internal ]
{
    ; init the subscript name
    set subscript = """EXPIRES"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") "03600"
    set ref = prefix _ subscript _ ")"
        
    quit $GET(@ref)
}

/// Gets the value of the VARYBYPARAM variable.
ClassMethod GetVARYBYPARAM() As %String [ Internal ]
{
    ; init the subscript name
    set subscript = """VARYBYPARAM"""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") ""
    set ref = prefix _ subscript _ ")"
        
    quit $GET(@ref)
}

/// Converts the search paths into a list.
ClassMethod GetSOURCE() As %Integer [ Internal ]
{
    ; init the subscript name
    set subscript = """SOURCE"""
    
    ; init the result
    set result = ""
    
    ; find out where it is
    set prefix = ..LocateGlobal(subscript)
    quit:(prefix = "") result
    
    ; see if there are any
    set ref = prefix _ subscript _ ")"
    set state = $DATA(@ref)
    quit:($DATA(@ref) < 10) result
    
    ; iterate over them
    set curkey = """"""
    set ref = prefix _ subscript _ "," _ curkey _ ")"
    set curkey = $ORDER(@ref)
    while (curkey '= "")
    {
        set ref = prefix _ subscript _ "," _ """" _ curkey _ """" _ ")"
        set candidate = $GET(@ref)
        set curkey = $ORDER(@ref)
        
        set candidate = $ZSTRIP(candidate,"<>W")
        continue:($LENGTH(candidate) = 0)
        continue:($EXTRACT(candidate,1) = "#")
        set result = result _ $LISTBUILD(candidate)
    }
        
    quit result
}

}
