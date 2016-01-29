module erik.elements.text_input;

import erik.driver;
import erik.api;
import erik.webelement;
import erik.condition;
import erik.by;

import std.stdio;

class TextInput : WebElement
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

    public TextInput setValue(string value)
    {
        waitFor(cast(WebElement) this, Condition.isClickable());
        sendKeys(value);
        return this;
    }

    public TextInput clearValue()
    {
        waitFor(cast(WebElement) this, Condition.isClickable());
        clear();
        return this;
    }
}
