
Class hyf
{


ClassMethod Interrupt(client As WebTerminal.Engine, data As %ZEN.proxyObject = "") As %Status
{
    // The interrupt behavior is implemented in Execute class method. When the user presses Ctrl+C
    // in normal mode, we will do *nothing*.
    return $$$OK
    //
}

}
