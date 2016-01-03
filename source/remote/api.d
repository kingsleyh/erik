/**
D PhantomJS Driver

A simple wrapper around the JSON Wire Protocol used by GhostDriver
 */
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
    session.goForward();

    //    session.setTimeout(TimeoutType.IMPLICIT, 2000);
    //    session.setAsyncScriptTimeout(2000);
    //    session.getStatus();
    //    session.create();
    //    session.getCapabilities();
    //    writeln(session.sessionId);

    //    writeln(session.getSessions());

    //    session.getWindowHandles();
    //    session.visitUrl("http://www.autotrader.co.uk");
    //    Element ele = session.findElement(LocatorStrategy.ID, "home");
    //    Element ele = session.findElements(LocatorStrategy.CLASS_NAME, "mainNav-menu__item");
    //    Element[] eles = session.findElements(LocatorStrategy.CLASS_NAME, "mainNav-menu__item");
    //    writeln(eles[2].getText());
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

/**
 * Session:
 * --------------------
 *  Session session = new Session("http://localhost", 8910);
 * --------------------
 */
class Session
{

    string host;
    int port;
    Driver driver;
    string sessionId;
    string sessionUrl;

    /**
   Create a new PhantomJs session.
   Params:
        host = host of phantomjs server
        port = port of phantomjs server
   Examples:
       Session session = new Session("http://localhost", 8910);
   */
    this(string host, int port)
    {
        this.host = host;
        this.port = port;
        this.driver = new Driver(host, port);
        create();
    }

    private void create()
    {
        auto sessionDetails = RequestSession(Capabilities("phantomjs", "",
            "MAC"), Capabilities("phantomjs", "", "MAC"));
        JSONValue sessionData = toJSON!RequestSession(sessionDetails);

        HttpResponse response = driver.doPost("/session", sessionData);

        auto json = parseJSON(response.content);
        this.sessionId = json["sessionId"].str;
        this.sessionUrl = "/session/" ~ sessionId;
        log!(__FUNCTION__).info("creating new session with id: " ~ sessionId);
    }

    /**
    Returns a list of the currently active sessions
    Returns:
     An array of Sessions struct containing the session's capabilities.
    Example:
      session.getSessions();
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
    Query the server's current status. The server should respond with a general "HTTP 200 OK" response if it is alive and accepting commands. The response body should be a JSON object describing the state of the server. All server implementations should return two basic objects describing the server's current platform and when the server was built. All fields are optional; if omitted, the client should assume the value is uknown. Furthermore, server implementations may include additional fields not listed here.

    Key	                Type	    Description
    ----------------------------------------------
    build	            object
    build.version	    string	    A generic release label (i.e. "2.0rc3")
    build.revision	    string	    The revision of the local source control client from which the server was built
    build.time	        string	    A timestamp from when the server was built.
    os	                object
    os.arch	            string	    The current system architecture.
    os.name	            string	    The name of the operating system the server is currently running on: "windows", "linux", etc.
    os.version      	string	    The operating system version.

    Returns:
        {object} An object describing the general status of the server.
    */
    public ServerStatus getStatus()
    {
        string url = "/status";
        HttpResponse response = driver.doGet(url);
        handleFailedRequest(url, response);
        ServerStatusResponse serverStatusResponse = parseJSON(response.content).fromJSON!ServerStatusResponse;
        return serverStatusResponse.value;
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

    /*
    DELETE /session/:sessionId
        Delete the session.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    */
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

    /*
    /session/:sessionId/window_handles
    GET /session/:sessionId/window_handles
        Retrieve the list of all window handles available to the session.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    Returns:
        {Array.<string>} A list of window handles.
    */
    public WindowHandle[] getWindowHandles()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/window_handles");
        handleFailedRequest(sessionUrl, response);
        WindowHandlesResponse windowHandlesResponse = parseJSON(response.content).fromJSON!WindowHandlesResponse;
        return windowHandlesResponse.value.map!(id => WindowHandle(id)).array;
    }

    /*
    /session/:sessionId/window_handle
    GET /session/:sessionId/window_handle
        Retrieve the current window handle.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    Returns:
        {string} The current window handle.
    Potential Errors:
        NoSuchWindow - If the currently selected window has been closed.
    */
    public WindowHandle getWindowHandle()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/window_handle");
        handleFailedRequest(sessionUrl, response);
        WindowHandleResponse windowHandleResponse = parseJSON(response.content).fromJSON!WindowHandleResponse;
        return WindowHandle(windowHandleResponse.value);
    }

    /*
    /session/:sessionId/url
    GET /session/:sessionId/url
        Retrieve the URL of the current page.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    Returns:
        {string} The current URL.
    Potential Errors:
        NoSuchWindow - If the currently selected window has been closed.
    */
    public string getUrl()
    {
        HttpResponse response = driver.doGet(sessionUrl ~ "/url");
        handleFailedRequest(sessionUrl, response);
        StringResponse stringResponse = parseJSON(response.content).fromJSON!StringResponse;
        return stringResponse.value;
    }

    /*
    /session/:sessionId/forward
    POST /session/:sessionId/forward
        Navigate forwards in the browser history, if possible.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    Potential Errors:
        NoSuchWindow - If the currently selected window has been closed.
    */
    public void goForward()
    {
        HttpResponse response = driver.doPost(sessionUrl ~ "/forward", parseJSON("{}"));
        handleFailedRequest(sessionUrl, response);
    }

    /*
  /session/:sessionId/back
  POST /session/:sessionId/back
      Navigate backwards in the browser history, if possible.
  URL Parameters:
      :sessionId - ID of the session to route the command to.
  Potential Errors:
      NoSuchWindow - If the currently selected window has been closed.
  */
    public void goBack()
    {
        HttpResponse response = driver.doPost(sessionUrl ~ "/back", parseJSON("{}"));
        handleFailedRequest(sessionUrl, response);
    }

    /**
    /session/:sessionId/refresh
    POST /session/:sessionId/refresh
        Refresh the current page.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    Potential Errors:
        NoSuchWindow - If the currently selected window has been closed.*/
    public void refresh()
    {
        HttpResponse response = driver.doPost(sessionUrl ~ "/refresh", parseJSON("{}"));
        handleFailedRequest(sessionUrl, response);
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
    /session/:sessionId/timeouts
    POST /session/:sessionId/timeouts
        Configure the amount of time that a particular type of operation can execute for before they are aborted and a |Timeout| error is returned to the client.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    JSON Parameters:
        type - {string} The type of operation to set the timeout for. Valid values are: "script" for script timeouts, "implicit" for modifying the implicit wait timeout and "page load" for setting a page load timeout.
        ms - {number} The amount of time, in milliseconds, that time-limited commands are permitted to run.
    */
    public void setTimeout(TimeoutType timeoutType, int milliseconds)
    {
        string _timeoutType = timeoutType;
        auto timeoutDetails = RequestTimeout(_timeoutType, milliseconds);
        JSONValue timeoutData = toJSON!RequestTimeout(timeoutDetails);

        HttpResponse response = driver.doPost(sessionUrl ~ "/timeouts", timeoutData);
        handleFailedRequest(sessionUrl, response);
    }

    /*
    /session/:sessionId/timeouts/async_script
    POST /session/:sessionId/timeouts/async_script
        Set the amount of time, in milliseconds, that asynchronous scripts executed by /session/:sessionId/execute_async are permitted to run before they are aborted and a |Timeout| error is returned to the client.
    URL Parameters:
        :sessionId - ID of the session to route the command to.
    JSON Parameters:
        ms - {number} The amount of time, in milliseconds, that time-limited commands are permitted to run.
    */
    public void setAsyncScriptTimeout(int milliseconds)
    {
        auto timeoutDetails = RequestTimeoutValue(milliseconds);
        JSONValue timeoutData = toJSON!RequestTimeoutValue(timeoutDetails);

        HttpResponse response = driver.doPost(sessionUrl ~ "/timeouts/async_script",
            timeoutData);
        handleFailedRequest(sessionUrl, response);
    }

    /*
    POST /session/:sessionId/timeouts/implicit_wait
        Set the amount of time the driver should wait when searching for elements. When searching for a single element, the driver should poll the page until an element is found or the timeout expires, whichever occurs first. When searching for multiple elements, the driver should poll the page until at least one element is found or the timeout expires, at which point it should return an empty list.
        If this command is never sent, the driver should default to an implicit wait of 0ms.

    URL Parameters:
        :sessionId - ID of the session to route the command to.
    JSON Parameters:
        ms - {number} The amount of time to wait, in milliseconds. This value has a lower bound of 0.
    */
    public void setImplicitWaitTimeout(int milliseconds)
    {
        auto timeoutDetails = RequestTimeoutValue(milliseconds);
        JSONValue timeoutData = toJSON!RequestTimeoutValue(timeoutDetails);

        HttpResponse response = driver.doPost(sessionUrl ~ "/timeouts/implicit_wait",
            timeoutData);
        handleFailedRequest(sessionUrl, response);
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

enum TimeoutType : string
{
    SCRIPT = "script",
    IMPLICIT = "implicit",
    PAGE_LOAD = "page load"
}
