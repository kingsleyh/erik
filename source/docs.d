import docs4d;

void main()
{

    auto cards = [
       Card("new", "Creates a Session instance with a new PhantomJS session based on the Capabilities provided. Only use in special cases. Use Session.start() for general use.",
         "Session",
         [
           Param("string","host","(e.g. http://localhost)", ParamType.INPUT),
           Param("int","port","( e.g. 8910)", ParamType.INPUT),
           Param("Capabilities","desiredCapability","", ParamType.INPUT),
           Param("Capabilities","requiredCapability","", ParamType.INPUT),
           Param("bool","deferCreate","", ParamType.INPUT)
         ],
         [
          Example(
            `auto session = new Session("http://localhost", 8910, Capabilities(), Capatilities(), false);`
          )
         ],
         [
           Link("Session.start()","#start"),
           Link("Capabilities","#Capabilities")
         ]
         ),

         Card("setGlobalTimeout", "Sets the global timeout for all actions in milliseconds.",
          "Session",
          [
            Param("int","timeout","(e.g. 10_000)", ParamType.INPUT)
          ],
          [
           Example(
             `session.setGlobalTimeout(10_000);`
           )
          ],[]
          ),

        Card("getGlobalTimeout", "Gets the global timeout for all actions in milliseconds.",
          "Session",
          [],
          [
           Example(
             `session.getGlobalTimeout(10_000);`
           )
          ],[]
          ),

        Card("start", "Creates a new Session and starts a new PhantomJS session using the provided capabilities",
         "Session",
         [
         Param("Capabilities","desiredCapability","",ParamType.INPUT),
         Param("Capabilities","requiredCapability","",ParamType.INPUT),
         Param("PhantomJsOptions","phantomJsOptions","(defaults to empty options)",ParamType.INPUT),
         Param("string","pathToPhantom","(defaults to /usr/local/bin/phantomjs)",ParamType.INPUT),
         Param("string","phantomPort","(defaults to random port)",ParamType.INPUT)
         ],
         [
          Example(
            `
auto session = Session.start(Capabilities(), Capabilities(),
               new PhantomJsOptions().setIgnoreSslErrors(true).setWebSecurity(false)
               .setSslProtocol(SSLProtocol.ANY));
            `
          )
         ],[
           Link("Capabilities","#Capabilities"),
           Link("PhantomJsOptions","#PhantomJsOptions")
         ]
         )

       ];

    auto links = [
        //         Link("Home","home.html"),
        Link("Documentation", "#", "active"),
        Link("Github", "https://github.com/kingsleyh/erik")
    ];

    new DocGen("Erik", "v0.0.1", "https://github.com/kingsleyh/erik/blob/master")
    .withLinks(links)
    .withCards(cards)
//    .withPages(pages)
    .generate();

}
