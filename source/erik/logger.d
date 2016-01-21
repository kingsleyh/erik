module erik.logger;

import net.masterthought.rainbow;

import std.datetime;
import std.stdio;

template log(string func) {
  void info(string msg){
    auto timeString = Clock.currTime().toISOExtString();
    writefln("[%s] /%s/ %s : %s", timeString.rainbow.yellow, "INFO".rainbow.magenta, func.rainbow.cyan, msg);
   }
}
