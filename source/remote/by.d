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

public class ByProvider : By
{
    private LocatorStrategy strategy;
    private string value;

    this(LocatorStrategy strategy, string value)
    {
        this.strategy = strategy;
        this.value = value;
    }


    override public LocatorStrategy getStrategy()
    {
        return this.strategy;
    }


    override public string getValue()
    {
        return this.value;
    }
    
    override public string asString(){
          return "locator:  " ~ strategy ~ ", value: " ~ value;

        }
    
    
}

public static abstract class By
{

    public LocatorStrategy getStrategy();
    public string getValue();
    public string asString();

    public static By id(string value)
    {
        return new ByProvider(LocatorStrategy.ID, value);
    }

    public static By className(string value)
    {
        return new ByProvider(LocatorStrategy.CLASS_NAME, value);
    }

    public static By cssSelector(string value)
    {
        return new ByProvider(LocatorStrategy.CSS_SELECTOR, value);
    }

    public static By tagName(string value)
    {
        return new ByProvider(LocatorStrategy.TAG_NAME, value);
    }

    public static By xpath(string value)
    {
        return new ByProvider(LocatorStrategy.XPATH, value);
    }

}

