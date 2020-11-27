/// Utility class for localization
Class DocBook.L10N Extends %Library.RegisteredObject [ ClassType = "", ProcedureBlock ]
{

/// Localizer for message fragments
ClassMethod DBMsg(cls As %String, num As %String, args... As %List) As %String [ Internal ]
{
    // begin temp code used for testing
    Set msg = $GET(^DocBook.L10N(cls, num), "")
    If (msg = "")
    {
        // this avoids getting the test text tangled in the 
        // localization automation
        // Cannot{space}
        Set msg = $CHAR(67, 97, 110, 110, 111, 116, 32)
        // find{space}
        Set msg = msg _ $CHAR(102, 106, 110, 100, 32)
        // message:{space}
        Set msg = msg _ $CHAR(109, 101, 115, 115, 97, 103, 101, 58, 32)
        Set msg = msg _ cls _ %CHAR(95) _ num
    }
    Quit msg
    // end temp code used for testing
    
	// get the message

	Set id = cls _ "_" _ num
	Set msg = %response.GetText("","DocBookApp",id,id,args...)
	Quit msg
}

}
