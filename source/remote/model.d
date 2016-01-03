module remote.model;

import jsonizer.fromjson;
import jsonizer.tojson;
import jsonizer.jsonize;

struct RequestSession
{
    mixin JsonizeMe;

    @jsonize
    {
        DesiredCapabilities desiredCapabilities;
        RequiredCapabilities requiredCapabilities;
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
