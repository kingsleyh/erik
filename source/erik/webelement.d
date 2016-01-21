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

class WebElement
{

    string elementId;
    Driver driver;
    string sessionId;
    string sessionUrl;

    this(string elementId, string sessionId, string sessionUrl, Driver driver)
    {
        this.elementId = elementId;
        this.sessionId = sessionId;
        this.sessionUrl = sessionUrl ~ "/element/" ~ elementId;
        this.driver = driver;
    }

    public string getText()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/text");
        handleFailedRequest(sessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    public string getAttribute(string attribute)
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/attribute/" ~ attribute);
        handleFailedRequest(sessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    public void sendKeys(string keys)
    {
        string[] val = keys.map!(to!string).array;
        JSONValue apiElement = toJSON!RequestSendKeys(RequestSendKeys(val));
        HttpResponse response = driver.doPost(sessionUrl ~ "/value", apiElement);
        handleFailedRequest(sessionUrl, response);
    }

    public void click()
    {
        JSONValue apiElement = toJSON!RequestElementClick(RequestElementClick(elementId));
        HttpResponse response = driver.doPost(sessionUrl ~ "/click", apiElement);
        handleFailedRequest(sessionUrl, response);
    }

    public bool isEnabled()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/enabled");
        handleFailedRequest(sessionUrl, response);
        BooleanResponse booleanResponse = parseJSON(response.content).fromJSON!BooleanResponse;
        return booleanResponse.value;
    }

    public bool isDisplayed()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/displayed");
        handleFailedRequest(sessionUrl, response);
        BooleanResponse booleanResponse = parseJSON(response.content).fromJSON!BooleanResponse;
        return booleanResponse.value;
    }

    public string getName()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/name");
        handleFailedRequest(sessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;

    }

//    public string getLocation()
//    {
//        HttpResponse response = driver.doGet(sessionUrl ~ "/location");
//        handleFailedRequest(sessionUrl, response);
//        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
//        return stringResponse.value;
//    }

    public string asString()
    {
        return format(`
        elementId: %s
        name: %s
      `,
            elementId, getName());
    }

}
