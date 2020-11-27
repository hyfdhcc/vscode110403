Import DocBook

Include DocBookMac

/// Information used to draw the banner on the various DocBook HTML pages.
Class DocBook.UI.BannerInfo Extends %Library.RegisteredObject [ ProcedureBlock ]
{

/// Book title displayed for this page
Property booktitle As cdata;

/// Title displayed for this page
Property title As cdata;

/// Chapter name for this page
Property chap As cdata;

/// id of next page (or "" if none)
Property next As id;

/// id of previous page (or "" if none)
Property prev As id;

/// Container object being displayed
Property container As container;

/// This page is in the KnBase
Property isArticle As dbint [ InitialExpression = 0 ];

}
