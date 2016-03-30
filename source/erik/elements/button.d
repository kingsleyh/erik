module erik.elements.button;

import erik.driver;
import erik.api;
import erik.webelement;
import erik.condition;
import erik.by;

import std.stdio;

class Button : WebElement
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

     public string getValue()
     {
        waitFor(cast(WebElement) this, Condition.isClickable());
        return getAttribute("value");
     }

}
