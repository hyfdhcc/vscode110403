Include DocBookMac

/// This class represents an article.
Class DocBook.article Extends DocBook.component [ ClassType = persistent, ProcedureBlock ]
{

Index ARoleIdx On (role, title);

Index ATitleIdx On title;

Index ATimeIdx On sourcetime;

Method GetBannerInfo(info As DocBook.UI.BannerInfo) [ Internal ]
{

	Set info.title = ..title
	Set info.booktitle = $$$T("Technical Articles")

	Set info.isArticle = 1
}

Storage Default
{
<Type>%Library.CacheStorage</Type>
}

}
