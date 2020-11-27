Include DocBookMac

/// This class represents a DocBook para.
Class DocBook.para Extends DocBook.container [ ClassType = persistent, ProcedureBlock ]
{

/// Render the contents of this block
Method HTMLRenderContent() [ Internal ]
{

    Set searchword = $G(%request.Data("KEYWORD",1))
    Set ancestors = "chapter,appendix,preface"
    
    Set mt = ""
    //Set:(%ie||%ie6) mt = "oncontextmenu=""if (!event.ctrlKey){showContextMenu();return false;} else {menu1.style.display='none'}"""
    
    // test for first paragraph in a chapter
    Set class = "para"
    /* JMD257
    If ((..blockpos = 0) && (ancestors [ ..container.%ClassName())) {
        Set class = "para1"
    }
    */
    
    // JMD257: test for first para on a page
    If (ancestors [ ..container.%ClassName()) {
        If (..blockpos = 0) { 
            Set class = "para1"
        }
        ElseIf (..blockpos = 1) {
            #; find out if the first block was a para
            Set cid = ..container.%Id()
            &sql(SELECT x__classname INTO :cls FROM block WHERE container=:cid AND blockpos = 0)
            If ($G(cls)'["~DocBook.para~") {
                Set class = "para1"
            }
        }
    }
    
    Set filteredcontent = ##class(DocBook.Renderer).FilterText(..content)
    // check for Latin-1 first character
    Set Chr1 = $ASCII($EXTRACT(filteredcontent, 1))
    Set OOB = ((Chr1 < 38) 
            + ((Chr1 >= 39) && (Chr1 <=47))
            + ((Chr1 >= 58) && (Chr1 <= 64)) 
            + ((Chr1 >= 91) && (Chr1 <= 96)) 
            + ((Chr1 >= 123) && (Chr1 <= 191)) 
            + ((Chr1 >= 204) && (Chr1 <= 207)) 
            + (Chr1 = 215) 
            + (Chr1 = 247))
    Set:(OOB > 0) class = "para" 

    If ($LENGTH(filteredcontent) > 0)
    {
    
        Write "<DIV CLASS=""",class,""" TEXTID=""",..id,""" ",mt,">"
    
        Write "<A name=""",..id,"""></A>",!
        Do ##class(Renderer).RenderText(filteredcontent,searchword)
        Write "</DIV>",!
        Write:(class [ "para1") "<BR CLEAR=""LEFT"">",!
    }
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
