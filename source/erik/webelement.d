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
import erik.elements.text_input;

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
        return new TextInput(elementId, sessionId, sessionUrl, driver, session);
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

    public void sendKeys(string keys)
    {
        string[] val = keys.map!(to!string).array;
        JSONValue apiElement = toJSON!RequestSendKeys(RequestSendKeys(val));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/value", apiElement);
        handleFailedRequest(elementSessionUrl, response);
    }

    public void click()
    {
        JSONValue apiElement = toJSON!RequestElementClick(RequestElementClick(elementId));
        HttpResponse response = driver.doPost(elementSessionUrl ~ "/click", apiElement);
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
