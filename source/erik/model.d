module erik.model;

import jsonizer.fromjson;
import jsonizer.tojson;
import jsonizer.jsonize;
import std.array;
import std.string;
import std.algorithm;
import std.conv;

struct RequestSession
{
    mixin JsonizeMe;

    @jsonize
    {
        Capabilities desiredCapabilities;
        Capabilities requiredCapabilities;
    }

}

struct Proxy
{
    mixin JsonizeMe;

    @jsonize
    {
        string proxyType;
        string proxyAutoconfigUrl;
        string ftpProxy;
        string httpProxy;
        string sslProxy;
        string socksProxy;
        string socksUsername;
        string socksPassword;
        string noProxy;
    }

}

struct Capabilities
{
    mixin JsonizeMe;

    @jsonize
    {
        string browserName;
        string platform;
        bool javascriptEnabled = true;
        bool takeScreenshot = true;
        bool handlesAlerts = true;
        bool databaseEnabled = true;
        bool locationContextEnabled = true;
        bool applicationCacheEnabled = true;
        bool browserConnectionEnabled = true;
        bool cssSelectorsEnabled = true;
        bool webStorageEnabled = true;
        bool rotatable = true;
        bool acceptSslCerts = true;
        bool nativeEvents = true;
        Proxy proxy;
    }
    @jsonize("version") string _version;

}

class PhantomJsOptions
{

    string cookiesFiles;
    string diskCache;
    string loadImages;
    string ignoreSslErrors;
    string webSecurity;
    string sslProtocol;

    string[] getOptions()
    {
        return [ignoreSslErrors, diskCache, loadImages, webSecurity, sslProtocol].filter!(
            s => !s.empty).array;
    }

    PhantomJsOptions setCookiesFiles(string pathToCookiesFile)
    {
        this.cookiesFiles = "--cookies-file=" ~ pathToCookiesFile;
        return this;
    }

    PhantomJsOptions setDiskCache(bool value)
    {
        this.diskCache = "--disk-cache=" ~ to!string(value);
        return this;
    }

    PhantomJsOptions setLoadImages(bool value)
    {
        this.loadImages = "--load-images=" ~to!string(value);
        return this;
    }

    PhantomJsOptions setIgnoreSslErrors(bool value)
    {
        this.ignoreSslErrors = "--ignore-ssl-errors=" ~ to!string(value);
        return this;
    }

    PhantomJsOptions setWebSecurity(bool value)
    {
        this.webSecurity = "--web-security=" ~ to!string(value);
        return this;
    }

    PhantomJsOptions setSslProtocol(SSLProtocol protocol)
    {
        this.sslProtocol = "--ssl-protocol=" ~ cast(string)(protocol);
        return this;
    }

}

enum SSLProtocol : string {
  SSLV3 = "sslv3",
  SSLV2 = "sslv2",
  TLSV1 = "tlsv1",
  ANY = "any"
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

struct RequestElementClear
{
    mixin JsonizeMe;

    @jsonize
    {
        string id;
        string sessionId;
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

struct BooleanResponse
{
    mixin JsonizeMe;

    @jsonize
    {
        string sessionId;
        int status;
        bool value;
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
