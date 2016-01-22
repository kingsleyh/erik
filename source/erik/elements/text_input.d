module erik.elements.text_input;

import erik.driver;
import erik.api;
import erik.webelement;
import erik.condition;
import erik.by;

class TextInput : WebElement
{

    this(string elementId, string sessionId, string sessionUrl, Driver driver, Session session)
    {
        super(elementId, sessionId, sessionUrl, driver, session);
    }

    public string getValue()
    {
        session.waitFor(cast(WebElement) this, Condition.isClickable());
        return getAttribute("value");
    }

    public void setValue(string value)
    {
        session.waitFor(cast(WebElement) this, Condition.isClickable());
        sendKeys(value);
    }
}
