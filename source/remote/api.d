module remote.api;

import jsonizer.fromjson;
import jsonizer.tojson;
import jsonizer.jsonize;

import std.json;
import std.stdio;
import std.array;

import remote.model;
import remote.driver;

void main(string[] args)
{

    Session session = new Session("http://localhost", 8910);
    session.create();
    writeln(session.sessionId);
//    writeln(session.getWindowHandles().content);
    writeln(session.visitUrl("http://www.autotrader.co.uk"));
        writeln(session.findElement(LocatorStrategy.ID, "coverImage"));
    writeln(session.getTitle().content);
    //    writeln(session.getSource().content);
    session.dispose();

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
        auto sessionDetails = RequestSession(DesiredCapabilities("phantomjs",
            "", "MAC"), RequiredCapabilities("phantomjs", "", "MAC"));
        JSONValue sessionData = toJSON!RequestSession(sessionDetails);

        HttpResponse response = driver.doPost("/session", sessionData);

        auto json = parseJSON(response.content);
        this.sessionId = json["sessionId"].str;
        this.sessionUrl = "/session/" ~ sessionId;
        writeln("creating new session: ", sessionId);
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
    public HttpResponse getSessions()
    {
        return driver.doGet("/sessions");
    }

    /*
    GET /session/:sessionId
        Retrieve the capabilities of the specified session.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    Returns:
        {object} An object describing the session's capabilities.
    */
    public HttpResponse getCapabilities()
    {
        return driver.doGet(sessionUrl);
    }

    public HttpResponse dispose()
    {
        return driver.doDelete(sessionUrl);
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
    public HttpResponse visitUrl(string url)
    {
        JSONValue apiUrl = toJSON!RequestUrl(RequestUrl(url));
        HttpResponse response = driver.doPost(sessionUrl ~ "/url", apiUrl);
        return response;
    }

    public HttpResponse getWindowHandles()
    {
        return driver.doGet(sessionUrl ~ "/window_handles");
    }

    public HttpResponse getUrl()
    {
        return driver.doGet(sessionUrl ~ "/url");
    }

    public HttpResponse getSource()
    {
        return driver.doGet(sessionUrl ~ "/source");
    }

    public HttpResponse getTitle()
    {
        return driver.doGet(sessionUrl ~ "/title");
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
    public HttpResponse findElement(LocatorStrategy strategy, string value)
    {
        string _strategy = strategy;
        JSONValue apiElement = toJSON!RequestFindElement(RequestFindElement(_strategy,
            value));
        HttpResponse response = driver.doPost(sessionUrl ~ "/element", apiElement);
        return response;
    }

}

class Element
{

    string elementId;

    this(string elementId)
    {
        this.elementId = elementId;
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
