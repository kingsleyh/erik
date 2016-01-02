//import libasync;
//import std.stdio;
//
//EventLoop g_evl;
//TCPConnection g_tcpConnection;
//bool g_closed;
//
//
//
//// curl -H "Content-Type: application/json" -X POST -d '{"id":"123","name":"visit","args":"www.google.com"}' http://localhost:8910
//// curl -H "Content-Type: application/json" -X POST -d '{"requiredCapabilities:{"browserName":'chrome',"version":"","platform":"MAC"},"desiredCapabilities":{"browserName":'chrome',"version":"","platform":"MAC"}}' http://localhost:8910/session
//
//// JSON API
//
//// start new session
//// curl -H "Content-Type: application/json" -X POST -d '{"requiredCapabilities":{"browserName":"chrome","version":"","platform":"MAC"},"desiredCapabilities":{"browserName":"chrome","version":"","platform":"MAC"}}' http://localhost:8910/session
//
//
//
//
///// This example creates a connection localhost:8081, sends a message and waits for a reply before closing
//void main() {
//    writeln("Here we go!");
//	g_evl = new EventLoop;
//	g_tcpConnection = new TCPConnection("localhost", 8910);
//
//	while(!g_closed)
//		g_evl.loop();
//	destroyAsyncThreads();
//}
//
//class TCPConnection {
//	AsyncTCPConnection m_conn;
//
//	this(string host, size_t port)
//	{
//		m_conn = new AsyncTCPConnection(g_evl);
//
//		if (!m_conn.host(host, port).run(&handler)) {
//			writeln(m_conn.status);
//		}
//	}
//
//	void onConnect() {
//	    writeln("About to connect");
//		onRead();
//		onWrite();
//	}
//
//	void onRead() {
//        writeln("waiting for read");
//		static ubyte[] bin = new ubyte[4092];
//		while (true) {
//			uint len = m_conn.recv(bin);
//
//			if (len > 0) {
//				string res = cast(string)bin[0..len];
//				writeln("Received data: ", res);
//				m_conn.kill();
//			}
//			if (len < bin.length)
//				break;
//		}
//
//
//	}
//
//	void onWrite() {
//        string msg = "{'id':'12345','name':'visit','args':'http://www.google.com'}";
//		m_conn.send(cast(ubyte[])msg);
//		writeln("Sent: My Message");
//	}
//
//	void onClose() {
//		writeln("Connection closed");
//		g_closed = true;
//	}
//
//	void handler(TCPEvent ev) {
//
//		try final switch (ev) {
//			case TCPEvent.CONNECT:
//				onConnect();
//				break;
//			case TCPEvent.READ:
//				onRead();
//				break;
//			case TCPEvent.WRITE:
//				onWrite();
//				break;
//			case TCPEvent.CLOSE:
//				onClose();
//				break;
//			case TCPEvent.ERROR:
//				assert(false, m_conn.error());
//		} catch (Exception e) {
//			assert(false, e.toString());
//		}
//		return;
//	}
//
//}