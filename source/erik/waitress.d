module erik.waitress;

import core.thread;

import erik.condition;
import erik.by;
import erik.webelement;
import erik.model;
import erik.api;
import erik.driver;
import std.conv;

class Waitress
{

    Session session;

    this(Session session)
    {
        this.session = session;
    }

    public void waitFor(WebElement element, Condition condition, int timeout)
    {
        int count = 0;
        waitForElementResult(element, count, condition, timeout);
    }

    public void waitFor(By by, Condition condition, int timeout)
    {
        int count = 0;
        waitForResult(by, count, condition, timeout);
    }

    public void waitFor(Result delegate() runnable, int timeout)
    {
      int count = 0;
      waitForFunction(runnable, timeout, count);
    }

    private void waitForFunction(Result delegate() runnable, int timeout, int count)
    {
      immutable auto result = runnable();
      if (count >= timeout)
        {
            throw new TimeoutException(
                "Timed out while waiting for function to evaluate: \n" ~ result.message);
        }
        else
        {
            Thread.sleep(dur!("msecs")(100));
            if (result.outcome)
            {
                return;
            }
            else
            {
                count = count + 100;
                waitForFunction(runnable, timeout, count);
            }

      }
    }

    private void waitForResult(By by, int count, Condition condition, int timeout)
    {
        if (count >= timeout)
        {
            throw new TimeoutException(
                "Timed out while waiting for condition: " ~ condition.asString() ~ " for: " ~ by.asString());
        }
        else
        {
            Thread.sleep(dur!("msecs")(100));
            WebElement[] elements = session.findElements(by);
            if (elements.length > 0 && condition.isSatisfied(elements))
            {
                return;
            }
            else
            {
                count = count + 100;
                waitForResult(by, count, condition, timeout);
            }

        }
    }

    private void waitForElementResult(WebElement element, int count,
        Condition condition, int timeout)
    {
        if (count >= timeout)
        {
            throw new TimeoutException(
                "Timed out while waiting for condition: " ~ condition.asString() ~ " for: " ~ element.asString());
        }
        else
        {
            Thread.sleep(dur!("msecs")(100));
            WebElement[] elements = [element];
            if (condition.isSatisfied(elements))
            {
                return;
            }
            else
            {
                count = count + 100;
                waitForElementResult(element, count, condition, timeout);
            }

        }
    }

}

struct Expectation(A,B)
{
  string name;
  A expected;
  B actual;

  string message(bool outcome) {
    return outcome ? to!string(actual) : "Error - actual <" ~ name ~ ">: " ~ to!string(actual) ~ " was not expected: " ~ to!string(expected);
  }

  Result result(bool outcome){
   return Result(outcome, message(outcome));
  }
}

struct Result
{
  bool outcome;
  string message;
}
