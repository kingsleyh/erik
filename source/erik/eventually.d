module erik.eventually;

import erik.driver;
import core.thread;
import std.conv;

class Eventually
{

    int millis;
    int count = 0;
    Exception ex;

    this(int millis = 5000)
    {
        this.millis = millis;
    }

    public void tryExecute(void delegate() runnable)
    {
        if (count >= this.millis)
        {
            throw new TimeoutException(
                "Timed out after " ~ to!string(millis) ~ " millis - waiting for process to complete without error, got exception: \n" ~ ex.toString());
        }
        try
        {
            runnable();
        }
        catch (Exception e)
        {
            ex = e;
            Thread.sleep(dur!("msecs")(100));
            count = count + 100;
            tryExecute(runnable);
        }

    }

}