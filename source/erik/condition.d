module erik.condition;

import std.array;

import erik.webelement;

public static abstract class Condition
{

    public bool isSatisfied(WebElement[] elements);
    public string asString();

    public static TitleIsCondition titleIs(string expectedTitle)
    {
        return new TitleIsCondition(expectedTitle);
    }

    public static AttributeContainsCondition attributeContains(string attribute,
        string expectedValue)
    {
        return new AttributeContainsCondition(attribute, expectedValue);
    }

    public static IsClickableCondition isClickable()
    {
        return new IsClickableCondition();
    }

}

public class TitleIsCondition : Condition
{

    private string expectedTitle;

    this(string expectedTitle)
    {
        this.expectedTitle = expectedTitle;
    }

    override public bool isSatisfied(WebElement[] elements)
    {
        if (elements.length > 0)
        {
            WebElement element = elements.front;
            return element.getAttribute("text") == expectedTitle;
        }
        else
        {
            return false;
        }
    }

    override public string asString()
    {
        return "TitleIsCondition, expectedTitle: " ~ expectedTitle;
    }

}

public class AttributeContainsCondition : Condition
{

    private string attributeName;
    private string expectedValue;

    this(string attributeName, string expectedValue)
    {
        this.attributeName = attributeName;
        this.expectedValue = expectedValue;
    }

    override public bool isSatisfied(WebElement[] elements)
    {
        if (elements.length > 0)
        {
            WebElement element = elements.front;
            return element.getAttribute(attributeName) == expectedValue;
        }
        else
        {
            return false;
        }
    }

    override public string asString()
    {
        return "AttributeContainsCondition, attributeName: " ~ attributeName ~ ", expectedValue: " ~ expectedValue;
    }

}

public class IsClickableCondition : Condition
{

    override public bool isSatisfied(WebElement[] elements)
    {
        if (elements.length > 0)
        {
            WebElement element = elements.front;
            return element.isEnabled() && element.isDisplayed();
        }
        else
        {
            return false;
        }
    }

    override public string asString()
    {
        return "IsClickableCondition";
    }

}
