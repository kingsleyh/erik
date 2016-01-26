module app;

import std.stdio;

import erik.api;
import erik.by;
import erik.webelement;
import erik.condition;
import erik.model;
import erik.elements.text_input;

void main(string[] args)
{
    auto capability = Capabilities();
    PhantomJsOptions options = new PhantomJsOptions().setSslProtocol(SSLProtocol.ANY).setWebSecurity(
        false).setIgnoreSslErrors(true);

    Session session = Session.start(capability, capability, options);

    session.visitUrl("https://bwob-boost-sit-live.barcapint.com/cb/#login");

    session.waitFor(By.className("nav-state"),
        Condition.attributeContains("data-module-id", "viewmodels/login"));

    WebElement username = session.findElement(By.className("cb-username"));
    username.sendKeys("matt.cully@barclays.com");
    writeln(username.getAttribute("value"));

    //    TextInput input = cast(TextInput) username;
    //    input.getAttribute("value");
    //
    //    username.sendKeys("matt.cully@barclays.com");
    //    writeln("username: ", username.getAttribute("value"));

    //    WebElement password = session.findElement(By.className("cb-password"));
    //    password.sendKeys("Password1");
    //    writeln("password: ", password.getAttribute("value"));
    //
    //    WebElement loginButton = session.findElement(By.className("cb-login"));
    //    session.waitFor(loginButton, Condition.isClickable());
    //    loginButton.click();
    //
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id", "viewmodels/deals"));
    //
    //    // create deal if does not exist
    //    if (!session.elementExists(By.xpath("//*[text()='CoolDeal']")))
    //    {
    //        WebElement dealNameInput = session.findElement(By.cssSelector("input"));
    //        session.waitFor(dealNameInput, Condition.isClickable());
    //        dealNameInput.sendKeys("CoolDeal");
    //        WebElement createButton = session.findElement(By.xpath("//*[text()='Create new']"));
    //        session.waitFor(createButton, Condition.isClickable());
    //        createButton.click();
    //    }
    //
    //    WebElement detailsLink = session.findElement(By.xpath("//*[text()='CoolDeal']"));
    //    session.waitFor(detailsLink, Condition.isClickable());
    //    detailsLink.click();
    //
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id", "viewmodels/deal/deal-details/deal-details"));
    //
    //    WebElement dealInput = session.findElement(By.cssSelector("input[name='deal-name']"));
    //    writeln(dealInput.getAttribute("value"));

    //
    //    // go to entity
    //    WebElement entitiesLink = session.findElement(By.linkText("Entities"));
    //    session.waitFor(entitiesLink, Condition.isClickable());
    //    entitiesLink.click();
    //
    //    // create entity if does not exist
    //    if (!session.elementExists(By.xpath("//*[text()='CoolEntity']")))
    //    {
    //        WebElement entityNameInput = session.findElement(By.cssSelector("input"));
    //        session.waitFor(entityNameInput, Condition.isClickable());
    //        entityNameInput.sendKeys("CoolEntity");
    //        WebElement createButton = session.findElement(By.xpath("//*[text()='Create new']"));
    //        session.waitFor(createButton, Condition.isClickable());
    //        createButton.click();
    //    }
    //
    //    WebElement entityLink = session.findElement(By.xpath("//*[text()='CoolEntity']"));
    //    session.waitFor(entityLink, Condition.isClickable());
    //    entityLink.click();
    //
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id",
    //        "viewmodels/deal/entities/entity/about-your-business/about-your-business"));
    //
    //    // nagivate to CoolDeal then People
    //    WebElement dealsLink = session.findElement(By.xpath("//*[text()='CoolDeal']"));
    //    session.waitFor(dealsLink, Condition.isClickable());
    //    dealsLink.click();
    //
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id", "viewmodels/deal/deal-details/deal-details"));
    //
    //    WebElement peopleLink = session.findElement(By.xpath("//*[text()='People']"));
    //    session.waitFor(peopleLink, Condition.isClickable());
    //    peopleLink.click();
    //
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id", "viewmodels/deal/people/people"));
    //
    //    //create person if does not exist
    //    if (!session.elementExists(By.xpath("//*[text()='David Json']")))
    //    {
    //        WebElement createButton = session.findElement(By.className("create-new-person"));
    //        session.waitFor(createButton, Condition.isClickable());
    //        createButton.click();
    //
    //        session.waitFor(By.cssSelector("input[name='first-name']"), Condition.isClickable());
    //        session.findElement(By.cssSelector("input[name='first-name']")).sendKeys("David");
    //        session.findElement(By.cssSelector("input[name='last-name']")).sendKeys("Json");
    //        session.findElement(By.cssSelector("input[name='work-email']")).sendKeys(
    //            "david.json@example.com");
    //        WebElement createPersonButton = session.findElement(By.className("cb-inline-person-done"));
    //        session.waitFor(createPersonButton, Condition.isClickable());
    //        createPersonButton.click();
    //    }
    //
    //    // navigate to CoolEntity from People
    //    WebElement entitiesLink2 = session.findElement(By.xpath("//*[text()='Entities']"));
    //    session.waitFor(entitiesLink2, Condition.isClickable());
    //    entitiesLink2.click();
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id", "viewmodels/deal/entities/entities"));
    //
    //    WebElement coolEntityLink = session.findElement(By.xpath("//*[text()='CoolEntity']"));
    //    session.waitFor(coolEntityLink, Condition.isClickable());
    //    coolEntityLink.click();
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id",
    //        "viewmodels/deal/entities/entity/about-your-business/about-your-business"));
    //
    //    //navigate to key officials
    //    WebElement keyOfficialsLink = session.findElement(By.xpath("//*[text()='Key officials']"));
    //    session.waitFor(keyOfficialsLink, Condition.isClickable());
    //    keyOfficialsLink.click();
    //    session.waitFor(By.className("nav-state"),
    //        Condition.attributeContains("data-module-id",
    //        "viewmodels/deal/entities/entity/key-officials/key-officials"));
    //
    //    // delete existing people from key officials
    //    if (session.elementExists(By.className("cb-clevel-clear")))
    //    {
    //        session.waitFor(By.className("cb-clevel-clear"), Condition.isClickable());
    //        foreach (WebElement element; session.findElements(By.className("cb-clevel-clear")))
    //        {
    //            element.click();
    //        }
    //
    //    }
    //
    //    // select person from dropdown
    //    string keyOfficialFirstName = "David";
    //    string jquerySelector = ".cb-ceo .cb-people.selectized";
    //    import std.string;
    //
    //    string script = format(`
    //     var f=function(){ return $('%s')[0].selectize.setValue(_.find($('%s')[0].selectize.options, function(o){return o.firstName==='%s'}).id);};f();
    //    `,
    //        jquerySelector, jquerySelector, keyOfficialFirstName);
    //    session.executeScript(script);
    //
}
