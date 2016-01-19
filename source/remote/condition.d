module remote.condition;

import std.array;

import remote.webelement;

public static abstract class Condition
{

    public bool isSatisfied(WebElement[] elements);

    public static TitleIsCondition titleIs(string expectedTitle)
    {
        return new TitleIsCondition(expectedTitle);
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

}
