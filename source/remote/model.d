module remote.model;

import jsonizer.fromjson;
import jsonizer.tojson;
import jsonizer.jsonize;

struct RequestSession
{
    mixin JsonizeMe;

    @jsonize
    {
        Capabilities desiredCapabilities;
        Capabilities requiredCapabilities;
    }

}

struct Capabilities
{
    mixin JsonizeMe;

    @jsonize
    {
        string browserName;
        string platform;
    }
    @jsonize("version") string _version;

}

struct RequestFindElement
{
    mixin JsonizeMe;

    @jsonize
    {
        string using;
        string value;
    }
}

struct RequestUrl
{
    mixin JsonizeMe;

    @jsonize
    {
        string url;
    }
}

struct RequestSendKeys
{
    mixin JsonizeMe;

    @jsonize
    {
        string[] value;
    }
}


struct RequestElementClick
{
    mixin JsonizeMe;

    @jsonize
    {
        string id;
    }
}

struct HttpResponse
{
    int code;
    string content;
}

struct NewSessionResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
    }

}

struct SessionsResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        Sessions[] value;
    }
}

struct Sessions
{
    mixin JsonizeMe;

    @jsonize
    {
        string id;
        Capabilities capabilities;
    }
}

struct CapabilityResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        Capabilities value;
    }
}

struct WindowHandlesResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        string[] value;
    }
}

struct WindowHandleResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        string value;
    }
}

struct WindowHandle
{
    mixin JsonizeMe;

    @jsonize
    {
        string handleId;
    }
}

struct StringResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        string value;
    }
}

struct ElementResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        string[string] value;
    }
}

struct ElementResponses
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        string[string][] value;
    }
}

struct ServerStatusResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        ServerStatus value;
    }
}

struct ServerStatus
{
    mixin JsonizeMe;

    @jsonize
    {
        string[string] build;
        string[string] os;
    }

}

struct RequestTimeout
{
    mixin JsonizeMe;

    @jsonize
    {
        string type;
        int ms;
    }

}

struct RequestTimeoutValue
{

    mixin JsonizeMe;

    @jsonize
    {
        int ms;
    }

}

struct RequestExecuteScript
{

    mixin JsonizeMe;

    @jsonize
    {
        string script;
        string[] args;
    }

}

