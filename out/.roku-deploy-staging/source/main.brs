
sub Main()
    screen = CreateObject("roSGScreen")
    m.port = CreateObject("roMessagePort")
    screen.setMessagePort(m.port)
    scene = screen.CreateScene("MainScene")
    screen.show()
    m.global = screen.getGlobalNode()

    ' ... (your existing code here) ...

    ' Create a TCP server socket and set up the server
    tcpListen = CreateObject("roStreamSocket")
    messagePort = CreateObject("roMessagePort")
    sendAddress = CreateObject("roSocketAddress")

    ' Set the address of the server you want to connect to
    sendAddress.SetAddress("devsocket.stedi.me:54321")
    socket = CreateObject("roStreamSocket")
    socket.setSendToAddress(sendAddress)

    ' Specify the IP address and port for the server
    addr = CreateObject("roSocketAddress")
    addr.setAddress("devsocket.stedi.me:54321") ' Change the IP address and port as needed

    tcpListen.setAddress(addr)

    tcpListen.setMessagePort(messagePort)
    tcpListen.notifyReadable(true)
    tcpListen.listen(4)


    if not tcpListen.eOK()
        print "Error creating listen socket"
        return
    end if

    if socket.Connect()
        print "Connected Successfully"
    else
        print "Connection Failed"
    end if



    ' Dictionary to store client connections
    connections = CreateObject("roAssociativeArray")

    while true
        msg = wait(0, m.port)
        msgType = type(msg)
        if msgType = "roSGScreenEvent"
            if msg.isScreenClosed() then return
        else if msgType = "roSocketEvent"
            changedID = msg.getSocketID()
            if changedID = tcpListen.getID() and tcpListen.isReadable()
                ' New client connection
                newConnection = tcpListen.accept()
                if newConnection = invalid
                    print "accept failed"
                else
                    print "accepted new connection " + newConnection.getID()
                    newConnection.notifyReadable(true)
                    newConnection.setMessagePort(messagePort)
                    connections[Stri(newConnection.getID())] = newConnection
                end if
            else
                ' Activity on an open connection
                connection = connections[Stri(changedID)]
                closed = false
                if connection.isReadable()
                    buffer = CreateObject("roByteArray")
                    buffer[512] = 0
                    received = connection.receive(buffer, 0, 512)
                    print "received is " + received
                    if received > 0
                        print "Echo input: '" + buffer.ToAsciiString() + "'"
                        ' If we are unable to send, just drop data for now.
                        ' You could use notifywritable and buffer data, but that is
                        ' omitted for clarity.
                        connection.send(buffer, 0, received)
                    else if received = 0 ' client closed
                        closed = true
                    end if
                end if
                if closed or not connection.eOK()
                    print "closing connection " + changedID
                    connection.close()
                    connections.delete(Stri(changedID))
                end if
            end if
        end if
    end while

    print "Main loop exited"
    tcpListen.close()
    for each id in connections
        connections[id].close()
    end for
end sub



' ' sub Main()
' '     screen = CreateObject("roSGScreen")
' '     m.port = CreateObject("roMessagePort")
' '     screen.setMessagePort(m.port)
' '     scene = screen.CreateScene("MainScene")
' '     screen.show()
' '     m.global = screen.getGlobalNode()

' '     ' m.global.addField("config", "assocarray", false)
' '     ' m.global.config = {
' '     '     publisherEntitlement: true,
' '     '     publisherTokenKey: "8ZQEDDR8AWVJF8AH",
' '     '     publisherRefreshToken: "MSEFAJ7A54SE3LBE",
' '     '     publisherEndPoint: "sample.com/endpoint/1234",
' '     ' }

' '     while(true)
' '         msg = wait(0, m.port)
' '         msgType = type(msg)
' '         if msgType = "roSGScreenEvent"
' '             if msg.isScreenClosed() then return
' '         end if
' '     end while
' ' end sub
