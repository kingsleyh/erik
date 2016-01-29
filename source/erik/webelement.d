module erik.webelement;

import std.array;
import std.json;
import std.stdio;
import std.array;
import std.algorithm;
import std.file;
import std.base64;
import std.conv;
import std.string;
import core.thread;

import jsonizer.fromjson;
import jsonizer.tojson;
import jsonizer.jsonize;

import erik.model;
import erik.driver;
import erik.api;
import erik.by;
import erik.condition;
import erik.waitress;
import erik.keys;
import erik.elements.text_input;
import erik.elements.button;
import erik.elements.link;

class WebElement
{

    string elementId;
    Driver driver;
    string sessionId;
    string sessionUrl;
    string elementSessionUrl;
    Session session;

    this(string elementId, string sessionId, string sessionUrl, Driver driver, Session session)
    {
        this.elementId = elementId;
        this.sessionId = sessionId;
        this.sessionUrl = sessionUrl;
        this.elementSessionUrl = sessionUrl ~ "/element/" ~ elementId;
        this.driver = driver;
        this.session = session;
    }

    public TextInput toTextInput()
    {
        if (!isTextInput())
        {
            throw new IncorrectElementException(
                "WebElement was not a TextInput. It is a: " ~ getName());
        }
        return new TextInput(elementId, sessionId, sessionUrl, driver, session);
    }

    public Button toButton()
    {
        if (!isButton())
        {
            throw new IncorrectElementException("WebElement was not a Button. It is a: " ~ getName());
        }
        return new Button(elementId, sessionId, sessionUrl, driver, session);
    }

    public Link toLink()
    {
        if (!isLink())
        {
            throw new IncorrectElementException("WebElement was not a Link. It is a: " ~ getName());
        }
        return new Link(elementId, sessionId, sessionUrl, driver, session);
    }

    private bool isTextInput()
    {
        return getName() == "input" && (getAttribute("type") == "text"
            || getAttribute("type") == "password" || getAttribute("type") == "email");
    }

    private bool isButton()
    {
        return (getName() == "button" || (getName() == "input" && getAttribute("type") == "submit"));
    }

    private bool isLink()
    {
        return (getName() == "a");
    }

    public string getText()
    {
        HttpResponse response = driver.doGet(elementSessionUrl ~ "/text");
        handleFailedRequest(elementSessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    public string getAttribute(string attribute)
    {
        HttpResponse response = driver.doGet(elementSessionUrl ~ "/attribute/" ~ attribute);
        handleFailedRequest(elementSessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    public WebElement sendKeys(string keys)
    {
        string[] val = keys.map!(to!string).array;
        JSONValue apiElement = toJSON!RequestSendKeys(RequestSendKeys(val));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/value", apiElement);
        handleFailedRequest(elementSessionUrl, response);
        return this;
    }

    public WebElement sendKeys(Keys key)
    {
        string stringKey = cast(string) key;
        string[] val = [stringKey];
        JSONValue apiElement = toJSON!RequestSendKeys(RequestSendKeys(val));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/value", apiElement);
        handleFailedRequest(elementSessionUrl, response);
        return this;
    }

    public void click()
    {
        JSONValue apiElement = toJSON!RequestElementClick(RequestElementClick(elementId));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/click", apiElement);
        handleFailedRequest(elementSessionUrl, response);
    }

    public void clear()
    {
        JSONValue apiElement = toJSON!RequestElementClear(RequestElementClear(elementId,
            sessionId));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/clear", apiElement);
        handleFailedRequest(elementSessionUrl, response);
    }

    public bool isEnabled()
    {
        HttpResponse response = driver.doGet(elementSessionUrl ~ "/enabled");
        handleFailedRequest(elementSessionUrl, response);
        BooleanResponse booleanResponse = parseJSON(response.content).fromJSON!BooleanResponse;
        return booleanResponse.value;
    }

    public bool isDisplayed()
    {
        HttpResponse response = driver.doGet(elementSessionUrl ~ "/displayed");
        handleFailedRequest(elementSessionUrl, response);
        BooleanResponse booleanResponse = parseJSON(response.content).fromJSON!BooleanResponse;
        return booleanResponse.value;
    }

    public bool isPresent()
    {
        return isEnabled && isDisplayed();
    }

    public string getName()
    {
        HttpResponse response = driver.doGet(elementSessionUrl ~ "/name");
        handleFailedRequest(elementSessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;

    }

    //    public string getLocation()
    //    {
    //        HttpResponse response = driver.doGet(elementSessionUrl ~ "/location");
    //        handleFailedRequest(elementSessionUrl, response);
    //        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
    //        return stringResponse.value;
    //    }

    public WebElement findElement(By by)
    {
        JSONValue apiElement = toJSON!RequestFindElement(
            RequestFindElement(by.getStrategy(), by.getValue()));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/element", apiElement);
        handleFailedRequest(elementSessionUrl, response);
        ElementResponse elementResponse = parseJSON(response.content).fromJSON!ElementResponse;
        string _elementId = elementResponse.value["ELEMENT"];
        return new WebElement(_elementId, sessionId, elementSessionUrl, driver, session);
    }

    public WebElement[] findElements(By by)
    {
        JSONValue apiElement = toJSON!RequestFindElement(
            RequestFindElement(by.getStrategy(), by.getValue()));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/elements", apiElement);
        handleFailedRequest(elementSessionUrl, response);
        ElementResponses elementResponses = parseJSON(response.content).fromJSON!ElementResponses;
        return elementResponses.value.map!(e => new WebElement(e["ELEMENT"],
            sessionId, elementSessionUrl, driver, session)).array;
    }

    public void waitFor(WebElement element, Condition condition, int timeout = 5000)
    {
        return new Waitress(session).waitFor(element, condition, timeout);
    }

    public string asString()
    {
        return format(`
        elementId: %s
        name: %s
      `, elementId,
            getName());
    }

}
