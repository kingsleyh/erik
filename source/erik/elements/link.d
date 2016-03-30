module erik.elements.link;

import erik.driver;
import erik.api;
import erik.webelement;
import erik.condition;
import erik.by;

import std.stdio;

class Link : WebElement
{

    this(string elementId, string sessionId, string sessionUrl, Driver driver, Session session)
    {
        super(elementId, sessionId, sessionUrl, driver, session);
    }

    override public void click()
    {
        waitFor(cast(WebElement) this, Condition.isClickable());
        super.click();
    }

    override public string getText()
    {
       waitFor(cast(WebElement) this, Condition.isClickable());
       return getAttribute("text");
    }
}
