/// This is a specialized datatype for properties that are word-search indexed.
Class DocBook.IndexedTextJ Extends %Text.Japanese
{

/// <PARAMETER>FILTERNOISEWORDS</PARAMETER> controls whether common-word filtering is enabled.  
/// Specifying a list of noise words can greatly reduce the size of a text index and the associated
/// index update time; however, to perform text search it is necessary to also remove noise words
/// from the search pattern, and this can produce some counter-intuitive results.  See example below.
/// <p>
/// Setting up noise word filtering is
/// a two-step process:  First enable noise word filtering by setting FILTERNOISEWORDS=1.  Second,
/// populate the noise word dictionary by calling the <METHOD>ExcludeCommonTerms</METHOD>
/// with the desired number of noise words to populate the corresponding DICTIONARY.  ExcludeCommonTerms
/// purges the previous set of noise words, so it may be called any number of times, but it is necessary
/// to rebuild all text indexes on the corresponding properties whenever the list of noise words is changed.
/// <p>
/// <b>Note:</b> The SQL predicate:
/// <EXAMPLE LANGUAGE=SQL>
/// SELECT myDocument FROM table t WHERE myDocument %CONTAINS ('to be or not to be')
/// </EXAMPLE>
/// will not find any qualifying rows if 'to, be, or, not' are all noise words; however, if <i>any</i>
/// of these terms are not noise words, then only the non-noise words will participate in the matching
/// process.
/// 
Parameter FILTERNOISEWORDS = 0;

/// <PARAMETER>NGRAMLEN</PARAMETER> is the maximum number of words that will be regarded as a single 
/// search term.  When NGRAMLEN=2, two-word combinations will be added to any
/// index, in addition to single words.  Consecutive words exclude noise words.
/// 
Parameter NGRAMLEN = 1;

/// MINWORDLEN specifies the minimum length word that will be retained
/// excluding ngram words and post-stemmed words.
/// 
/// <PARAMETER>MINWORDLEN</PARAMETER> provides a simple means of excluding terms based on their 
/// length, since it is usually the case that short words such as 'a', 'to', 'an', etc., are 
/// connectives that contain little information content.  The length refers to the number of 
/// characters in the original document.  Note that if stemming or thesaurus translation is 
/// enabled, then the length of the term in a text index may have fewer than MINWORDLEN 
/// characters.
/// <p>
/// <b>Note:</b> MINWORDLEN should typically be set to 3 or less when <PARAMETER>STEMMING</PARAMETER>=1,
/// since otherwise a word stem could be classified as a noise word even though alternate forms of the
/// word would not be classified as a noise word.  For example, with MINWORDLEN=5 "jump" would be discarded
/// as a noise word, whereas "jumps" would not.
///  
Parameter MINWORDLEN = 1;

/// <PARAMETER>WORDCHARS</PARAMETER> specifies the characters other than alphabetic that may 
/// appear in a word.  For example, to regard hyphenated words as terms, include "-" in WORDCHARS.
/// Note that characters that are not numbers or words are ignored for the purpose of comparison
/// with the %CONTAINS operator, therefore the search pattern "off-hand" will match "off hand"
/// if WORDCHARS="", but not if WORDCHARS="-"; conversely, "off-hand" will match "offhand" if 
/// WORDCHARS="-", but not if WORDCHARS="".
Parameter WORDCHARS = "$%";

/// This returns true is it's argument is an
/// ASCII alphanumeric character.  The argument is given as the 
/// code for the character.
/// 
ClassMethod DBIsAN(chrcode As %Integer) As %Boolean [ Internal ]
{
	// short-circuit
	//Quit 0
	
	// numbers
	Quit:((chrcode > 47) && (chrcode < 58)) 1
	
	// uppercase
	Quit:((chrcode > 64) && (chrcode < 91)) 1
	
	//lowercase
	Quit:((chrcode > 96) && (chrcode < 123)) 1
	
	// fail
	Quit 0
}

/// This checks for other miscellaneous
/// sequences where we do not want spaces inserted.
/// 
ClassMethod DBIsSpecial(chr1 As %Integer, chr2 As %Integer) As %Boolean [ Internal ]
{
	// short-circuit
	//Quit 0
	
	// pairs of sign characters: 43=plus, 45=minus
	Quit:(((chr1 = 43) || (chr1 = 45)) && ((chr2 = 43) || (chr2 = 45))) 1
	
	// signs preceding digits
	Quit:(((chr1 = 43) || (chr1 = 45)) && ((chr2 > 47) && (chr2 < 58))) 1
	
	// decimal preceding numbers: decimal=46
	Quit:((chr1 = 46) && ((chr2 > 47) && (chr2 < 58))) 1
	
	// numbers preceding decimal
	Quit:(((chr1 > 47) && (chr1 < 58)) && (chr2 = 46)) 1
	
	// fail
	Quit 0
}

/// This checks for Katakana characters
/// 
ClassMethod DBIsKatakana(chr1 As %Integer, chr2 As %Integer) As %Boolean [ Internal ]
{
	// short-circuit
	//Quit 0
	
	// limits are x30A0 - x30FF  (12448 - 12543)
	//x30FB (12539) is middle dot
	Quit:((chr1 = 122539)  ||  (chr2 = 12539)) 0
	
	// remaining character range
	Quit:(((chr1 > 12447) && (chr1 < 12544)) && ((chr2 > 12447) && (chr2 < 12544))) 1
	
	// fail
	Quit 0
}

/// This checks for diacritical marks
/// 
ClassMethod DBIsMarkup(chr As %Integer) As %Boolean [ Internal ]
{
	// short-circuit
	//Quit 0
	
	// half-width katakana voiced sound mark = xFF9E
	Quit:(chr = 65438) 1
		
	// half-width katakana semivoiced sound mark = xFF9F
	Quit:(chr = 65439) 1
		
	// katakana middle dot = x30FB
	Quit:(chr = 12539) 1
		
	// half-width katakana middle dot = xFF65
	Quit:(chr = 65381) 1
		
	// ideographic comma = x3001
	Quit:(chr = 12289) 1
		
	// ideographic full stop = x3002
	Quit:(chr = 12290) 1
	
	// fail
	Quit 0
}

/// Convert entities used in product names
/// 
ClassMethod ConvertNameEntities(text As %String) As %Integer [ Internal ]
{
	// short-circuit
	//Quit 0
	
	Set special = "eacute,Eacute,ntilde,Ntilde"
	Set replace = "e,E,n,N"
	
	For n = 1 : 1 : $LENGTH(special, ",")
	{
		Set pattern = "&" _ $PIECE(special, ",", n) _ ";"
		Set after = $FIND(text, pattern)
		While (after > 0)
		{
			Set $EXTRACT(text, (after - $LENGTH(pattern)), (after - 1)) = $PIECE(replace, ",", n)
			Set after = $FIND(text, pattern)
		}
	}
	
	// done
	Quit text
}

/// This checks for diacritical marks
/// 
ClassMethod EntitySize(text As %String) As %Integer [ Internal ]
{
	// short-circuit
	//Quit 0
	
	Set common = "amp,lt,gt"
	Set common = common _ ",eacute,Eacute,ntilde,Ntilde"
	Set common = common _ ",nbsp"
	Set common = common _ ",mdash,ndash"
	Set common = common _ ",quot,ldquo,rdquo,rsquo"
	Set common = common _ ",#39"
	
	// test common ones
	Set sz = 0
	For i = 1 : 1 : $LENGTH(common, ",")
	{
		Set entity = "&" _ $PIECE(common, ",", i) _ ";"
		If ($EXTRACT(text, 1, $LENGTH(entity)) [ entity)
		{
			Set sz = $LENGTH(entity)
			Quit
		}
	}
	Quit:(sz > 0) sz
	
	// find the end
	Set span = $FIND(text, ";")
	
	// too far
	Quit:(span > 9) 0
	Set span = span - 1
	
	// hexidecimal entity
	If ($ZCONVERT($EXTRACT(text, 2, 3), "U") [ "#X")
	{
		For i = 4 : 1 : (span - 1)
		{
			Set c = $ZCONVERT($EXTRACT(text, i), "U")
			If ('("ABCDEF0123456789" [ c))
				{
					Set span = 0
					Quit
				}
		}
		Quit span
	}
	
	// numeric entity
	If ($EXTRACT(text, 2) [ "#")
	{
		For i = 3 : 1 : (span - 1)
		{
			Set c = $EXTRACT(text, i)
			If ('("0123456789" [ c))
				{
					Set span = 0
					Quit
				}
		}
		Quit span
	}
	
	// arbitrary entity
	For i = 2 : 1 : (span - 1)
	{
		Set c = $ZCONVERT($EXTRACT(text, i), "U")
		If ('("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" [ c))
			{
				Set span = 0
				Quit
			}
	}
	Quit span
	
	// fail
	Quit 0
}

/// This is a copy of the default routine from %Text.Japanese
/// except that it does a better job at grouping characters.  For example, some ASCII 
/// strings are kept together.  Groups of katakana characters are kept together 
/// and only separated by the middle-dot (x30FB).  Also diacritical marks are removed
/// from words.
/// 
ClassMethod SeparateWords(rawText As %String) As %String
{
	Set filteredText = rawText
	
	// convert any katakana word separator (middle dot, x30FB) to space
	Set filteredText = $TRANSLATE(filteredText, $CHAR(12539), $CHAR(32))
	
	// convert product names
	Set filteredText = ..ConvertNameEntities(filteredText)
	
	Set out = ""
	Set lastc = 0
	Set N = 1
	While (N <= $LENGTH(filteredText))
	{	Set c = $EXTRACT(filteredText, N)
		Set sep = " "
		Set thisc = $ASCII(c)
		
		If (..DBIsMarkup(thisc))
		{
			Set lastc = 0
			Set N = N + 1
			Continue
		}
		
		// treat entities as units
		If (thisc = 38)
		{
			Set sz = ..EntitySize($EXTRACT(filteredText, N, *))
			If (sz > 0)
			{
				Set out = out _ sep _ $EXTRACT(filteredText, N, (N + sz - 1))
				Set lastc = 59
				Set N = N + sz
				Continue
			}
		}
		
		// other compact sequences
		If ((..DBIsAN(lastc)) && (..DBIsAN(thisc)))
		{
			Set sep = ""
		}
		ElseIf (..DBIsSpecial(lastc, thisc))
		{
			Set sep = ""
		}
		ElseIf (..DBIsKatakana(lastc, thisc))
		{
			Set sep = ""
		}
		ElseIf (thisc = 32)
		{
			Set sep = ""
		}
		
		Set out = out _ sep _ c
		Set lastc = thisc
		Set N = N + 1
	}
	Set $extract(out,1,2) = $extract(out,2,2)
	
	If (0)
	//If (($DATA(^CACHETEMPGB) > 0) && ($LENGTH(out) > 0) && ($LENGTH(rawText) > 0))
	{
		Set ^CACHETEMPGB = ^CACHETEMPGB + 1
		Set ^CACHETEMPGB(^CACHETEMPGB, "In") = rawText
		Set ^CACHETEMPGB(^CACHETEMPGB, "Ot") = out
	}

	Quit out
}

}
