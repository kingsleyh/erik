module remote.api;

import jsonizer.fromjson;
import jsonizer.tojson;
import jsonizer.jsonize;

import std.json;
import std.stdio;
import std.array;
import std.algorithm;

import remote.model;
import remote.driver;
import logger;

void main(string[] args)
{

    Session session = new Session("http://localhost", 8910);
    session.create();
    //    session.getCapabilities();
    //    writeln(session.sessionId);

    //    writeln(session.getSessions());

    //    session.getWindowHandles();
    session.visitUrl("http://www.autotrader.co.uk");
    //    Element ele = session.findElement(LocatorStrategy.ID, "home");
    //    Element ele = session.findElements(LocatorStrategy.CLASS_NAME, "mainNav-menu__item");
    Element[] eles = session.findElements(LocatorStrategy.CLASS_NAME, "mainNav-menu__item");
    writeln(eles[2].getText());
    //    writeln(ele.elementId);
    //    writeln(ele.getText());
    //    session.getTitle();
    //    session.getUrl();
    //    session.getSource();
    //    writeln(session.getSource().content);
    session.dispose();

}

void handleFailedRequest(string url, HttpResponse response)
{
    if (response.code != 200)
    {
        throw new APIResponseError(
            "request for " ~ url ~ " returned failed error code: " ~ to!string(response.code) ~ " with message: " ~ response
            .content);
    }
}

class APIResponseError : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

class Session
{

    string host;
    int port;
    Driver driver;
    string sessionId;
    string sessionUrl;

    this(string host, int port)
    {
        this.host = host;
        this.port = port;
        this.driver = new Driver(host, port);
    }

    /* Session
   POST /session
        Create a new session. The server should attempt to create a session that most closely matches the desired and required capabilities. Required capabilities have higher priority than desired capabilities and must be set for the session to be created.
   JSON Parameters:
        desiredCapabilities - {object} An object describing the session's desired capabilities.
        requiredCapabilities - {object} An object describing the session's required capabilities (Optional).
   Returns:
        {object} An object describing the session's capabilities.
   Potential Errors:
        SessionNotCreatedException - If a required capability could not be set.
   */
    public Session create()
    {
        auto sessionDetails = RequestSession(Capabilities("phantomjs", "",
            "MAC"), Capabilities("phantomjs", "", "MAC"));
        JSONValue sessionData = toJSON!RequestSession(sessionDetails);

        HttpResponse response = driver.doPost("/session", sessionData);

        auto json = parseJSON(response.content);
        this.sessionId = json["sessionId"].str;
        this.sessionUrl = "/session/" ~ sessionId;
        log!(__FUNCTION__).info("creating new session with id: " ~ sessionId);
        return this;
    }

    /* /sessions
    GET /sessions
        Returns a list of the currently active sessions. Each session will be returned as a list of JSON objects with the following keys:

    Key	           Type	    Description
    ------------------------------------
    id	           string	The session ID.
    capabilities   object	An object describing the session's capabilities.

    Returns:
        {Array.<Object>} A list of the currently active sessions.
    */
    public Sessions[] getSessions()
    {
        string url = "/sessions";
        HttpResponse response = driver.doGet(url);
        handleFailedRequest(url, response);
        SessionsResponse sessionResponse = parseJSON(response.content).fromJSON!SessionsResponse;
        return sessionResponse.value;
    }

    /*
    GET /session/:sessionId
        Retrieve the capabilities of the specified session.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    Returns:
        {object} An object describing the session's capabilities.
    */
    public Capabilities getCapabilities()
    {
        HttpResponse response = driver.doGet(sessionUrl);
        handleFailedRequest(sessionUrl, response);
        CapabilityResponse capabilityResponse = parseJSON(response.content).fromJSON!CapabilityResponse;
        return capabilityResponse.value;
    }

    public void dispose()
    {
        HttpResponse response = driver.doDelete(sessionUrl);
        handleFailedRequest(sessionUrl, response);
    }

    /*
    POST /session/:sessionId/url
        Navigate to a new URL.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    JSON Parameters:
        url - {string} The URL to navigate to.
    Potential Errors:
        NoSuchWindow - If the currently selected window has been closed.
    */
    public void visitUrl(string url)
    {
        JSONValue apiUrl = toJSON!RequestUrl(RequestUrl(url));
        HttpResponse response = driver.doPost(sessionUrl ~ "/url", apiUrl);
        handleFailedRequest(sessionUrl, response);
    }

    public WindowHandle[] getWindowHandles()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/window_handles");
        handleFailedRequest(sessionUrl, response);
        WindowHandlesResponse windowHandlesResponse = parseJSON(response.content).fromJSON!WindowHandlesResponse;
        return windowHandlesResponse.value.map!(id => WindowHandle(id)).array;
    }

    public string getUrl()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/url");
        handleFailedRequest(sessionUrl, response);
        writeln(response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    public string getSource()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/source");
        handleFailedRequest(sessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    public string getTitle()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/title");
        handleFailedRequest(sessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    /*
    /session/:sessionId/element

    POST /session/:sessionId/element

    Search for an element on the page, starting from the document root. The located element will be returned as a WebElement JSON object. The table below lists the locator strategies that each server should support. Each locator must return the first matching element located in the DOM.

    Strategy	    Description
    --------------------------------------
    class name	        Returns an element whose class name contains the search value; compound class names are not permitted.
    css selector	    Returns an element matching a CSS selector.
    id	                Returns an element whose ID attribute matches the search value.
    name	            Returns an element whose NAME attribute matches the search value.
    link text	        Returns an anchor element whose visible text matches the search value.
    partial link text	Returns an anchor element whose visible text partially matches the search value.
    tag name	        Returns an element whose tag name matches the search value.
    xpath	            Returns an element matching an XPath expression.

    URL Parameters:
        :sessionId - ID of the session to route the command to.
    JSON Parameters:
        using - {string} The locator strategy to use.
        value - {string} The The search target.
    Returns:
        {ELEMENT:string} A WebElement JSON object for the located element.
    Potential Errors:
        NoSuchWindow - If the currently selected window has been closed.
        NoSuchElement - If the element cannot be found.
        XPathLookupError - If using XPath and the input expression is invalid.
    */
    public Element findElement(LocatorStrategy strategy, string value)
    {
        string _strategy = strategy;
        JSONValue apiElement = toJSON!RequestFindElement(RequestFindElement(_strategy,
            value));
        HttpResponse response = driver.doPost(sessionUrl ~ "/element", apiElement);
        handleFailedRequest(sessionUrl, response);
        ElementResponse elementResponse = parseJSON(response.content).fromJSON!ElementResponse;
        string elementId = elementResponse.value["ELEMENT"];
        return new Element(elementId, sessionId, sessionUrl, driver);
    }

    public Element[] findElements(LocatorStrategy strategy, string value)
    {
        string _strategy = strategy;
        JSONValue apiElement = toJSON!RequestFindElement(RequestFindElement(_strategy,
            value));
        HttpResponse response = driver.doPost(sessionUrl ~ "/elements", apiElement);
        handleFailedRequest(sessionUrl, response);
        ElementResponses elementResponses = parseJSON(response.content).fromJSON!ElementResponses;
        return elementResponses.value.map!(e => new Element(e["ELEMENT"],
            sessionId, sessionUrl, driver)).array;
    }

}

class Element
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

}

enum LocatorStrategy : string
{
    CLASS_NAME = "class name",
    CSS_SELECTOR = "css selector",
    ID = "id",
    NAME = "name",
    LINK_TEXT = "link text",
    PARTIAL_LINK_TEXT = "partial link text",
    TAG_NAME = "tag name",
    XPATH = "xpath"
}
