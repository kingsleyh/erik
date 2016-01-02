module remote.api;

//import jsonizer : fromjson, tojson, jsonize;

import jsonizer.fromjson;
import jsonizer.tojson;
import jsonizer.jsonize;

import std.json;
import std.stdio;
import std.conv;
import std.net.curl;
import std.algorithm;
import std.array;
import core.thread;

void main(string[] args)
{
    Session session = new Session("http://localhost", 8910);
    session.useOrCreate();
//            session.create();
    writeln(session.sessionId);
    //    writeln(session.getWindowHandles().content);
    writeln(session.visitUrl("www.autotrader.co.uk").content);
    writeln(session.getTitle().content);
    writeln(session.getSource().content);

}

struct HttpResponse
{
    int code;
    string content;
}

class Driver
{

    string host;
    int port;
    string phantomServer;

    this(string host, int port)
    {
        this.host = host;
        this.port = port;
        this.phantomServer = host ~ ":" ~ to!string(port);
    }

    public HttpResponse doGet(string url)
    {
        char[] responseBody;
        int responseCode;

        auto client = HTTP(phantomServer ~ url);
        client.addRequestHeader("Content-Type", "application/json");

        client.method = HTTP.Method.get;
        client.onReceive = (ubyte[] data) {
            responseBody ~= cast(const(char)[]) data;
            return data.length;
        };
        client.onReceiveStatusLine = (HTTP.StatusLine status) {
            responseCode = status.code;
        };

        client.perform();
        return HttpResponse(responseCode, to!string(responseBody));
    }

    public HttpResponse doPost(string url, JSONValue value)
    {
        char[] responseBody;
        int responseCode;

        auto client = HTTP(phantomServer ~ url);

        client.method = HTTP.Method.post;
        client.setPostData(to!string(value), "application/json");
        client.onReceive = (ubyte[] data) {
            responseBody ~= cast(const(char)[]) data;
            return data.length;
        };
        client.onReceiveStatusLine = (HTTP.StatusLine status) {
            responseCode = status.code;
        };

        client.perform();
        return HttpResponse(responseCode, to!string(responseBody));
    }

    public HttpResponse doDelete(string url)
    {
        char[] responseBody;
        int responseCode;

        auto client = HTTP(phantomServer ~ url);
        client.addRequestHeader("Content-Type", "application/json");

        client.method = HTTP.Method.del;
        client.onReceive = (ubyte[] data) {
            responseBody ~= cast(const(char)[]) data;
            return data.length;
        };
        client.onReceiveStatusLine = (HTTP.StatusLine status) {
            responseCode = status.code;
        };

        client.perform();
        return HttpResponse(responseCode, to!string(responseBody));
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
        auto sessionDetails = ApiSession(DesiredCapabilities("phantomjs", "",
            "MAC"), RequiredCapabilities("phantomjs", "", "MAC"));
        JSONValue sessionData = toJSON!ApiSession(sessionDetails);

        HttpResponse response = driver.doPost("/session", sessionData);

        auto json = parseJSON(response.content);
        this.sessionId = json["sessionId"].str;
        this.sessionUrl = "/session/" ~ sessionId;
        writeln("creating new session: ", sessionId);
        return this;
    }

    public Session useOrCreate()
    {
        auto json = parseJSON(getSessions().content);
        auto sessions = json["value"].array;
        if (sessions.length > 0)
        {
            this.sessionId = sessions.front["id"].str;
            this.sessionUrl = "/session/" ~ sessionId;
            writeln("re-using session: ", this.sessionId);
        }
        else
        {
            create();
        }
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

    public HttpResponse deleteSession()
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
        JSONValue apiUrl = toJSON!ApiUrl(ApiUrl(url));
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

}

struct ApiUrl
{
    mixin JsonizeMe;

    @jsonize
    {
        string url;
    }
}

struct NewSessionResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
    }

}

struct DesiredCapabilities
{
    mixin JsonizeMe;

    @jsonize
    {
        string browserName;
        string platform;
    }
    @jsonize("version") string _version;

}

struct RequiredCapabilities
{
    mixin JsonizeMe;

    @jsonize
    {
        string browserName;
        string platform;
    }
    @jsonize("version") string _version;

}

struct ApiSession
{
    mixin JsonizeMe;

    @jsonize
    {
        DesiredCapabilities desiredCapabilities;
        RequiredCapabilities requiredCapabilities;
    }

}
