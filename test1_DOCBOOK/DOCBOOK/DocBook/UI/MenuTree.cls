/// This class renders a menu tree control.
Class DocBook.UI.MenuTree Extends %RegisteredObject [ ProcedureBlock ]
{

/// Expandor image.
Parameter EXPANDIMG = "plus.gif";

/// Spacer image; a transparent gif file.
Parameter SPACERIMG = "spacer.gif";

/// Contractor image.
Parameter CONTRACTIMG = "minus.gif";

/// Help text for expandor buttons.
Parameter BTNTITLE = "Expand/Contract this section";

/// Contains the contents of the tree control
/// in the following structure:<BR>
/// tree.Items(1) = $LB(caption,url,key,target)<BR>
/// tree.Items(1,1) = $LB(caption,url,key,target)<BR>
/// tree.Items(1,1,1) = $LB(caption,url,key,target)<BR>
Property Items As %String(TRUNCATE = 1) [ MultiDimensional ];

/// Localizer for message fragments
ClassMethod DBMsg(cls As %String, num As %String, args... As %List) As %String [ Internal ]
{
	Quit ##class(DocBook.L10N).DBMsg(cls, num, args...)
}

/// Render StyleSheet for tree
Method ShowStyle() [ Internal ]
{
	&html<<STYLE type="text/css">

	A.CSPExpandor { }

	A.CSPMenuItem1 { color: blue; font-size: 1.0em; 
							font-family: Verdana; 
							font-weight: bold;
							text-decoration: none; }

	A.CSPMenuItem2 { color: blue; font-size: 1.0em; 
							font-family: Verdana; 
							text-decoration: none; }

	A.CSPMenuItem3 { color: blue; font-size: 1.0em; 
							font-family: Verdana; 
							text-decoration: none; }

	</STYLE>>
}

/// Render JavaScript for tree
Method ShowJS() [ Internal ]
{
	&html<<SCRIPT Language=JavaScript>
	
	// remember the current highlighted item
	var CSPHighlightedItemKey = '';
	
	function expandItem(Id) {
		whichEl = eval("DIV" + Id);
		whichIm = eval("IMG" + Id);
		if (whichEl.style.display == 'none') {
			whichEl.style.display = '';
			whichIm.src = "#(..#CONTRACTIMG)#";
		}
		else {
			whichEl.style.display = 'none';
			whichIm.src = "#(..#EXPANDIMG)#";
		}
		return;
	}

	function highlightItem(key) {
		if (key != CSPHighlightedItemKey) {
			if (CSPHighlightedItemKey != '') {
				oldEl = self.document.all.item(CSPHighlightedItemKey);
				oldEl.style.background = self.document.bgColor;
			}
			newEl = self.document.all.item(key);
			if (newEl == null) {
				CSPHighlightedItemKey = '';
			}
			else {
				newEl.style.background = 'yellow';
				CSPHighlightedItemKey = key;
				self.document.location.hash = key;
			}
		}
		return;
	}

	</SCRIPT>>
}

/// Renders the contents of Items as a Tree Control.<BR>
Method ShowTree(currKey As %String = "") [ Internal ]
{
	//Do ..RenderTree(..isIE() || ..isNS7(), currKey)
	Do ..RenderTree(1, currKey)
}

Method RenderTree(dynamic As %Boolean = 1, currKey As %String = "") [ Internal, Private ]
{
	Set id = 0
	Set lastql = 1
	Set indent = 0
	Set expanded = 1
	
	If ('dynamic) {
		// non-dynamic is always expanded
		Set expanded = 1
	}

	// Workaround until Garen fixes GK949
	//Kill ^||ISCDocBookItems
	//Merge ^||ISCDocBookItems = ..Items
	//Set item = $Query(^||ISCDocBookItems(""))
	
	Set item = $Query(..Items(""))

	While (item '= "") {
		
		Set ql = $ql(item)
		
		// DIV wrappers
		While (lastql < ql) {
			Set id = id + 1
			Write "<DIV NOWRAP ID=""DIV",id,""" ",$S(expanded=0:"STYLE=""display:none""",1:""),">",!
			Set indent = indent + 1
			Set lastql = lastql + 1
		}
		While (lastql > ql) {
			Set indent = indent - 1
			Write "</DIV>",!
			Set lastql = lastql - 1
		}

		// menu choice
		Write "<DIV NOWRAP>",!
		Write:(indent>0) "<IMAGE SRC=""",..#SPACERIMG,""" BORDER=""0"" HEIGHT=""16"" WIDTH=""",16*indent,""">",!
		
		If ($D(@item)'<10) {
			If (dynamic) {
				Write "<A CLASS=""CSPExpandor"" TITLE=""",..#BTNTITLE,""" onclick=""expandItem('",id+1,"');"">",!
				Write "<IMAGE ID=""IMG",id+1,""" SRC=""",$S(expanded:..#CONTRACTIMG,1:..#EXPANDIMG),""" BORDER=""0"" WIDTH=""16"" ALIGN=""BOTTOM""></A>",!
			}
		}
		Else {
			Write "<IMAGE SRC=""",..#SPACERIMG,""" BORDER=""0"" HEIGHT=""16"" WIDTH=""",16,""">",!
		}

		Write "<A NAME=""",$LG(@item,3),""" CLASS=""CSPMenuItem",ql,""""

		Write:($LG(@item,2)'="") "HREF=""",$LG(@item,2),""""
		Write:($LG(@item,4)'="") "TARGET=""",$LG(@item,4),""""

		Write:dynamic " onmouseover=""this.style.color = 'red';"" onmouseout=""this.style.color = '';"""
		Write "><NOBR>"
		Write $LG(@item,1)
		Write "</NOBR></A>",!,"</DIV>",!
		
		// get next item
		Set item = $Query(@item)
	}

	While (lastql > 1) {
		Write "</DIV>",!
		Set lastql = lastql - 1
	}
	
	/* JMD257
	If (currKey '= "") {
		&html<
		<SCRIPT LANGUAGE="JavaScript">
		highlightItem('#(currKey)#');
		</SCRIPT>
		>
	}
	*/
}

/// Returns true if we are talking to an IE browser.
ClassMethod isIE() As %Boolean [ CodeMode = expression, Internal ]
{
%request.UserAgent["MSIE"
}

/// Returns true if we are talking to a NetScape 7 browser.
ClassMethod isNS7() As %Boolean [ CodeMode = expression, Internal ]
{
%request.UserAgent["Netscape/7"
}

}
