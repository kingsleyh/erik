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
