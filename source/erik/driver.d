module erik.driver;

import erik.model;
import std.json;
import std.conv;
import std.stdio;
import std.net.curl;

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

class DriverError : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

class IllegalArgumentException : Exception
{
    this(string msg)
    {
        super(msg);
    }
}

class TimeoutException : Exception
{
    this(string msg)
    {
        super(msg);
    }
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

        try
        {
            client.perform();
            return HttpResponse(responseCode, to!string(responseBody));
        }
        catch (Exception e)
        {
            throw new DriverError("Error: " ~ e.msg);
        }
    }

    public HttpResponse doPost(string url, JSONValue value)
    {
        char[] responseBody;
        int responseCode;

        auto client = HTTP(phantomServer ~ url);

        client.method = HTTP.Method.post;
        
        //writeln(to!string(value));
        
        client.setPostData(to!string(value), "application/json");
        client.onReceive = (ubyte[] data) {
            responseBody ~= cast(const(char)[]) data;
            return data.length;
        };
        client.onReceiveStatusLine = (HTTP.StatusLine status) {
            responseCode = status.code;
        };

        try
        {
            client.perform();
            return HttpResponse(responseCode, to!string(responseBody));
        }
        catch (Exception e)
        {
            throw new DriverError("Error: " ~ e.msg);
        }
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

        try
        {
            client.perform();
            return HttpResponse(responseCode, to!string(responseBody));
        }
        catch (Exception e)
        {
            throw new DriverError("Error: " ~ e.msg);
        }
    }
}
