/// This is a specialized datatype for properties that are word-search indexed.
Class DocBook.IndexedTextE Extends %Text.English
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

Parameter SEPARATEWORDS = 0;

/// Normally, the SeparateWords method is not called for
/// English text.  The parameter, SEPARATEWORDS, has been set so that 
/// DocBook-specific process can be done prior to building the value array.
/// 
ClassMethod SeparateWords(rawText As %String) As %String
{
	Set out = rawText

	Quit out
}

}
