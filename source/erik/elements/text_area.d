module erik.elements.text_area;

import erik.driver;
import erik.api;
import erik.webelement;
import erik.condition;
import erik.by;

import std.stdio;

class TextArea : WebElement
{

    this(string elementId, string sessionId, string sessionUrl, Driver driver, Session session)
    {
        super(elementId, sessionId, sessionUrl, driver, session);
    }

    public string getValue()
    {
        waitFor(cast(WebElement) this, Condition.isClickable());
        return getAttribute("value");
    }

    public TextArea setValue(string value)
    {
        waitFor(cast(WebElement) this, Condition.isClickable());
        sendKeys(value);
        return this;
    }

    public TextArea clearValue()
    {
        waitFor(cast(WebElement) this, Condition.isClickable());
        clear();
        return this;
    }
}
