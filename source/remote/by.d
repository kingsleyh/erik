module remote.by;

enum LocatorStrategy : string
{
    CLASS_NAME = "class name",
    CSS_SELECTOR = "css selector",
    ID = "id",
    NAME = "name",
    LINK_TEXT = "link text",
    PARTIAL_LINK_TEXT = "partial link text",
    TAG_NAME = "tag name",
    XPATH = "xpath"
}

struct SearchContext
{
    LocatorStrategy strategy;
    string value;
}

static class By
{

    public static SearchContext id(string value)
    {
        return SearchContext(LocatorStrategy.ID, value);
    }

    public static SearchContext className(string value)
    {
        return SearchContext(LocatorStrategy.CLASS_NAME, value);
    }

    public static SearchContext cssSelector(string value)
    {
        return SearchContext(LocatorStrategy.CSS_SELECTOR, value);
    }

}
