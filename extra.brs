




'odqPps34ICSoMj8JfrgBJG1K2wr14Bqy


' sub init()

'     m.store = m.top.findNode("store")
'     m.store.ObserveField("catalog", "onGetCatalog")
'     m.store.observeField("orderStatus", "onOrderStatus")
'     m.store.ObserveField("purchases", "onGetPurchases")
'     m.store.ObserveField("userData", "onGetUserData")

'     m.store.ObserveField("storeChannelCredDataStatus", "onStoreChannelCredData")
'     m.store.ObserveField("channelCred", "onGetChannelCred")

'     m.productGrid = m.top.FindNode("productGrid")
'     m.productGrid.ObserveField("itemSelected", "onProductSelected")

'     m.productSelectScreen = m.top.FindNode("productSelectScreen")

'     ' Added account creation initial screens'
'     m.landingScreen = m.top.FindNode("landingScreen")
'     m.landingButtonGroup = m.top.FindNode("landingButtonGroup")

'     m.signInScreen = m.top.FindNode("signInScreen")
'     m.signInButtonGroup = m.top.FindNode("signInButtonGroup")

'     m.contentScreen = m.top.FindNode("contentScreen")
'     m.contentScreenRowList = m.top.FindNode("RowList")

'     ' TODO: this shouldn't need to be set visible/invisible
'     m.selectHint = m.top.FindNode("selectHint")
'     m.hint = m.top.FindNode("hint")

'     m.top.observeField("response", "onDataRequestResponse")

'     ' Specify RFI type when handling userData'
'     m.rfiType = "None"

'     m.uriFetcher = createObject("roSGNode", "UriFetcher")

'     m.registryTask = CreateObject("roSGNode", "regTask")
'     m.registryTask.control = "run"

'     'm.keyboard = CreateObject("roSGNode", "KeyboardDialog")
'     'm.keyboard.id = "KeyboardDialog"
'     'm.keyboard.observeField("buttonSelected","onConfirmEmail")

'     m.dialogBox = CreateObject("roSGNode", "Dialog")
'     m.dialogBox.id = "dialogBox"
'     m.dialogBox.observeField("buttonSelected", "dismissdialog")

'     m.init = true
'     m.publisherEntitlement = invalid
'     m.devEntitlement = invalid
'     m.publisherAccessToken = invalid
'     m.itemSelected = invalid
'     m.clearTokenReq = false
'     m.devAPIKey = "odqPps34ICSoMj8JfrgBJG1K2wr14Bqy"

'     ' check and see if any previous purchases have been made
'     m.store.command = "getPurchases"
' end sub

' function onGetPurchases() as void
'     ?"> onGetPurchases"
'     ' check with the current catalog to see if previous purchases exist
'     if m.init
'         m.store.command = "getCatalog"
'         return
'     end if

'     if (m.store.purchases.GetChildCount() > 0)
'         ' there exist purchases, do a quick check
'         ' already updated pre existing purchased products
'         ? "verifying access to content (during purchase)"
'         ' validate the publisher information and the developer information
'         verifyAccessToContent()

'         return
'     end if
'     ' no active subscriptions b/c no purchases made
'     ? "customer does NOT have active subscription through roku pay"
'     ' grab the access token (if any) from registry and verify with the publisher info
'     makeRequest("registry", { section: "sample", command: "read", key: "sample_access_token", value: "" }, "validateInactiveRokuSub")
' end function

' function onGetCatalog() as void
'     ? "> onGetCatalog"
'     data = CreateObject("roSGNode", "ContentNode")
'     if (m.store.catalog <> invalid)
'         count = m.store.catalog.GetChildCount()
'         for i = 0 to count - 1
'             productData = data.CreateChild("ChannelStoreProductData")
'             item = m.store.catalog.getChild(i)
'             productData.productCode = item.code
'             productData.productName = item.name
'             productData.productPrice = item.cost
'             productData.productBought = false

'             if m.init 'check catalog and purchases and see if any are already purchased
'                 for x = 0 to (m.store.purchases.GetChildCount() - 1)
'                     p_code = m.store.purchases.getChild(x).getFields().code
'                     if productData.productCode = p_code
'                         'already purchased, indicate it visually
'                         productData.productBought = true
'                         'break out of for loop
'                         x = m.store.purchases.GetChildCount() - 1
'                     end if
'                 end for
'             end if

'         end for
'         m.productGrid.content = data
'     end if
'     if m.init
'         ' validate the publisher information and the developer information
'         verifyAccessToContent()
'     end if
'     m.init = false
'     ' Check content access if didn't purchase on Roku
' end function

' function onProductSelected() as void
'     ? "!----------------------new order---------------------!"
'     ? "> onProductSelected"
'     index = m.productGrid.itemSelected
'     m.itemSelected = m.productGrid.content.GetChild(index)
'     ? "> selected product code: " m.itemSelected.productCode

'     ' query the publisher server on information on the selected product
'     #if sampleHardCodedValues
'         ? "< getting publisher information"
'         m.publisherEntitlement = "true"
'         m.publisherAccessToken = "TOK8ZQEDDR8AWVJF8AH"
'         ?"< publisher is entitled " m.publisherEntitlement
'         ?"< publisher token: " m.publisherAccessToken
'         ' check roku side if this item has already been purchased
'         m.store.command = "getPurchases"
'     #else
'         makeRequest("url", { uri: "PUBLISHER ENTITLEMENT LINK GOES HERE" }, "getPublisherInfo")
'     #end if
' end function

' function getPublisherInfo(msg as object)
'     ? "< getting publisher information"
'     response = msg.getData()
'     m.publisherEntitlement = ParseJson(response.content).entitlement
'     ?"< publisher is entitled " m.publisherEntitlement
'     makeRequest("url", { uri: "PUBLISHER TOKEN KEY LINK GOES HERE" }, "getPublisherInfoComplete")
' end function

' function getPublisherInfoComplete(msg as object)
'     response = msg.getData()
'     m.publisherAccessToken = ParseJson(response.content).tokenKey
'     ?"< publisher token: " m.publisherAccessToken

'     ' check roku side if this item has already been purchased
'     m.store.command = "getPurchases"
' end function

' function verifyAccessToContent() as void
'     count = m.store.purchases.GetChildCount()
'     ? "[user already purchased " count " item(s)]"
'     ' find a match in the list of purchases made
'     for i = 0 to count - 1
'         #if sampleHardCodedValues
'             'xml = createObject("roXMLElement")
'             'xml.parse(response.content)
'             m.devEntitlement = true
'             ? "< dev is entitled: " m.devEntitlement
'             makeRequest("registry", { section: "sample", command: "read", key: "sample_access_token", value: "" }, "getDevInfoComplete")
'         #else
'             ' Is this check for purchased product code really needed?'
'             'if (m.store.purchases.getChild(i).getFields().code = m.itemSelected.productCode)
'             ? "customer has active subscription through roku pay"
'             'is an active subscription through Roku Pay
'             tid = m.store.purchases.getChild(i).getFields().purchaseId

'             'check device has valid access token and entitlment in publisher system, query apipublroku.com for entitlement info and the registry for access token
'             makeRequest("url", { uri: Substitute("https://apipub.roku.com/listen/transaction-service.svc/validate-transaction/{0}/{1}", m.devAPIKey, tid) }, "getDevInfo")
'             return
'             'end if
'         #end if
'     end for

'     ' not an active subscription b/c no matching products
'     ? "customer does NOT have active subscription through roku pay"
'     ' grab the access token (if any) from registry and verify with the publisher info
'     makeRequest("registry", { section: "sample", command: "read", key: "sample_access_token", value: "" }, "validateInactiveRokuSub")
' end function

' ' handle response from validate-transaction'
' function getDevInfo(msg as object) as void
'     ? "< getting device info: getDevInfo"
'     response = msg.getData()
'     if response.code <> 200
'         ? "Validate transaction failed, check if API key and transaction ID are valid"
'         ' dialogBox = CreateObject("roSGNode", "Dialog")
'         m.dialogBox.message = "Error: " + chr(10) + "Validate transaction failed: check if API key and transaction ID are valid"
'         m.dialogBox.buttons = ["Go back to Channel Add-ons UI"]
'         m.top.dialog = m.dialogBox
'         return
'     end if

'     xml = createObject("roXMLElement")
'     xml.parse(response.content)
'     m.devEntitlement = (xml.getNamedElements("isEntitled")[0].getText() = "true")
'     ? "< dev is entitled: " m.devEntitlement
'     makeRequest("registry", { section: "sample", command: "read", key: "sample_access_token", value: "" }, "getDevInfoComplete")
' end function

' function getDevInfoComplete(msg as object)
'     tok = msg.getData().regVal
'     ? "> dev access tok: " tok
'     ' obtained the dev access token and entitlement, now validate the info
'     validateAccessToken(tok, m.devEntitlement)
' end function

' function validateAccessToken(tok as object, entitled as boolean)
'     ' check for matching in the developer and publisher
'     if (tok <> "invalid")
'         if ((tok = m.publisherAccessToken) and (m.publisherEntitlement = "true"))
'             ? "device has valid access token and entitlement in publisher system"
'             ' get access token from publisher server and store on device
'             #if sampleHardCodedValues
'                 m.publisherAccessToken = "TOK8ZQEDDR8AWVJF8AH"
'                 writeAccessToken()
'             #else
'                 makeRequest("url", { uri: "PUBLISHER TOKEN KEY LINK GOES HERE" }, "getWriteAccessToken")
'             #end if

'             grantAccess()
'         end if
'     else 'either not valid access token or no entitlement in publisher
'         ? "device either doesn't have valid publisher access token and/or no entitlement in publisher system"
'         ' get publisher access token from publisher server and store on device
'         writeAccessToken()
'         grantAccess()

'     end if
' end function

' function createOrder() as void
'     ' create, process, and validate order
'     myOrder = CreateObject("roSGNode", "ContentNode")
'     itemPurchased = myOrder.createChild("ContentNode")
'     ? "creating order ..."
'     ? "> product code: " m.itemSelected.productCode
'     ? "> product name: " m.itemSelected.productName
'     itemPurchased.addFields({ "code": m.itemSelected.productCode, "name": m.itemSelected.productName, "qty": 1 })
'     m.store.order = myOrder
'     ? "processing order ..."
'     m.store.command = "doOrder"
' end function

' function validateInactiveRokuSub(msg as object)
'     ? "> validateInactiveRokuSub"
'     tok = msg.getData().regVal
'     ? "> dev access tok: " tok

'     ' validate purchaser access token and publisher system entitlement
'     if (tok <> "invalid")
'         'if ((tok = m.publisherAccessToken) and (m.publisherEntitlement = "true"))
'         ? "device has valid access token and entitlement in publisher system"
'         grantAccess()
'         'end if
'     else ' device registry does not have valid purchaser access token and publisher system has entitlement
'         ? "device either doesn't have valid access token and/or no entitlement in publisher system"
'         if m.itemSelected = invalid
'             m.store.command = "getChannelCred"
'         else
'             createOrder()
'         end if
'     end if
' end function

' function onGetChannelCred()
'     print "> is access token stored in Roku Cloud?"
'     ' if token matches - '
'     if (m.store.channelCred <> invalid)
'         if m.store.channelCred.status = 0
'             if m.store.channelCred.json <> invalid and m.store.channelCred.json <> "{}"
'                 json = parsejson(m.store.channelCred.json)
'                 if (json <> invalid) and (json.roku_pucid <> invalid and json.roku_pucid <> "{}")
'                     ' check that json.token_type is urn:roku:pucid:token_type:pucid_token'
'                     tok = json.channel_data
'                     print "channel cred= "; json
'                     if ((tok = m.publisherAccessToken) and (m.publisherEntitlement = "true"))
'                         'write publisher token to registry'
'                         print "Yes - token store in cloud"
'                         writeAccessToken()
'                     else
'                         'create new subscription through rokupay
'                         ' get customer's email address
'                         'print "No - go to create new subscription"
'                         'm.store.command = "getUserData"
'                         print "No - go to select sign up/in screen"
'                         displayLandingScreen()
'                     end if
'                 end if
'             end if
'         else
'             print "non-zero status = "; m.store.channelCred.status
'         end if
'     end if
' end function

' function displayLandingScreen()
'     print "Display Sign up and Sign in buttons"
'     m.landingButtonGroup.setFocus(true)

'     Buttons = ["Sign Up", "Sign In"]
'     m.landingButtonGroup.buttons = Buttons
'     m.landingButtonGroup.observeField("buttonSelected", "onLandingButtonSelected")
'     m.landingScreen.visible = true
' end function

' function onLandingButtonSelected()
'     m.landingScreen.visible = false
'     if m.landingButtonGroup.buttonSelected = 0
'         ' sign up button pressed'
'         print "Request sign up RFI"
'         m.rfiType = "signup"
'         m.store.requestedUserData = "email"
'         m.store.command = "getUserData"
'     else if m.landingButtonGroup.buttonSelected = 1
'         ' sign in button pressed'
'         print "Request sign in RFI"
'         m.rfiType = "signin"
'         ' Set sign-in context for RFI screen
'         info = CreateObject("roSGNode", "ContentNode")
'         info.addFields({ context: "signin" })
'         m.store.requestedUserDataInfo = info

'         m.store.requestedUserData = "email"
'         m.store.command = "getUserData"
'         'else
'         ' return to main screen'
'         'm.productSelectScreen.visible = "true"
'         'm.productGrid.SetFocus(true)
'     end if
' end function

' function displaySignInScreen(email as string)
'     print "Sign in screen - email= "; email
'     signinScreen = m.top.findNode("SignInScreen")
'     if signinScreen <> invalid
'         signinScreen.email = email
'         signinScreen.setup = true
'         signinScreen.visible = true
'     end if
'     'signinScreen.findNode("signinKeyboard").setFocus(true)
' end function

' function displaySignUpScreen(email as string)
'     print "Sign up screen - email= "; email
'     signupScreen = m.top.findNode("SignUpScreen")
'     if signupScreen <> invalid
'         signupScreen.email = email
'         signupScreen.setup = true
'         signupScreen.visible = true
'     end if
' end function

' sub onDataRequestResponse(msg)
'     print "entered onDataRequestResponse"
'     print "data= "; msg.getData()
'     ' handle the data and set focus on product markup grid'
'     'm.productGrid.SetFocus(true)
'     onConfirmEmail(msg)
' end sub

' ' This is the function that handles the RFI result'
' function onGetUserData()
'     if m.rfiType = "signup"
'         if (m.store.userData <> invalid)
'             email = m.store.userData.email
'             ? "email of user is: " email
'             hashedPass = hashThePassword("<RANDOMPASS>")
'             responseAA = { type: "signup", email: email, password: hashedPass }
'             'trigger confirm email path'
'             m.top.response = responseAA

'             ''? "> create new subscription through roku pay"

'             'm.keyboard.title = "Sign In"
'             ' m.keyboard.text = email
'             ' m.keyboard.buttons = ["Confirm"]
'             ' m.keyboard.opacity = 0.95
'             ' m.top.dialog = m.keyboard
'         else
'             ? "[user cancelled obtaining email, enter email manually]"
'             email = ""
'             displaySignUpScreen(email)
'         end if
'         ' Let user retry sign up or sign in'
'     else if m.rfiType = "signin"
'         if (m.store.userData <> invalid)
'             email = m.store.userData.email
'             ? "email of user is: " email
'         else
'             ? "[user cancelled obtaining email, returning to displaying channel UI]"
'             email = ""
'         end if
'         displaySignInScreen(email)
'     end if
'     m.rfiType = "None"
' end function




' 'trying the stedi api request

' ' Declare global variables



' ' Function to start the login process
' sub waitForLoginAndRetrieveToken()
'     ' Define the URL for the login page
'     loginUrl = "https://dev.stedi.me/"

'     ' Create a UriFetcher object
'     m.uriFetcher = CreateObject("roSGNode", "UriFetcher")

'     ' Set up the request parameters for the login page
'     loginRequestParams = {
'         uri: loginUrl,
'         verb: "GET" ' Use GET method to retrieve the login page
'     }

'     ' Set the callback function for handling the login page response
'     m.uriFetcher.ObserveField("response", "onLoginPageResponse")

'     ' Make the initial request to the login page
'     m.uriFetcher.Request = loginRequestParams
' end sub


' ' Function to handle the login page response
' sub onLoginPageResponse(loginResponseData as object)
'     ' Store the login response globally
'     loginResponse = loginResponseData

'     ' Check if the response status is 200 (OK) indicating a successful login page retrieval
'     if loginResponseData.GetResponseCode() = 200 then
'         ' Parse the response content and check if the user is logged in
'         responseContent = loginResponseData.GetData().response.content

'         ' Implement logic to check if the user is logged in based on the responseContent
'         if userIsLoggedIn(responseContent) then
'             ' User is logged in, now you can proceed to retrieve the token
'             getToken()
'         else
'             ' User is not logged in yet, wait for a while and then check again
'             waitAndCheckLoginStatus()
'         end if
'     else
'         ' Handle the case where the request to the login page failed (e.g., non-200 status code)
'         ? "Login page request failed with status code: " + loginResponseData.GetResponseCode()
'     end if
' end sub

' ' Function to implement waiting and periodic login status checks
' sub waitAndCheckLoginStatus()
'     ' Implement a timer to periodically check the login status
'     ' Create a timer object
'     timer = CreateObject("roSGNode", "Timer")

'     ' Set the timer interval (e.g., every 10 seconds)
'     timer.Interval = 10000 ' 10 seconds

'     ' Set the callback function for the timer event
'     timer.ObserveField("timesup", "checkLoginStatus")

'     ' Start the timer
'     timer.control = "start"
' end sub

' ' Function to check login status periodically
' sub checkLoginStatus()
'     ' Implement logic to check the login status by making a request to the website
'     ' Similar to the logic in onLoginPageResponse
'     ' If the user is logged in, proceed to retrieve the token
'     ' If not, continue waiting or take appropriate action
'     ' Be sure to stop the timer when the user is logged in or when you want to stop waiting.

'     ' You can use the global loginResponse variable to make the request and check the response.
' end sub

' ' Function to check if the user is logged in based on response content
' function userIsLoggedIn(responseContent as string) as boolean
'     ' Implement logic to check if the user is logged in based on the responseContent
'     ' For example, you might look for specific HTML elements or content that indicates a successful login.

'     ' Return true if the user is logged in, false otherwise
'     ' Return true or false
' end function

' ' Function to retrieve the token
' function getToken()

'     ' Implement the logic to retrieve the token once the user is logged in
'     ' This logic should be similar to the original code for retrieving the token
'     ' Make the API request to get the token and handle the response accordingly

'     ' Assuming you have a reference to the loginResponse object from onLoginPageResponse
'     ' Check if the Set-Cookie header is present in the response headers
'     if loginResponse.headers.doesExist("Set-Cookie") then
'         ' Get the value of the Set-Cookie header, which contains the token
'         setCookieHeader = loginResponse.headers.lookup("Set-Cookie")

'         ' Parse the Set-Cookie header to extract the token value
'         token = extractTokenFromSetCookieHeader(setCookieHeader)

'         ' Now, you have the token and can use it for further API requests or processing
'         ? "Token: " + token
'     else
'         ' Handle the case where the Set-Cookie header is not present
'         ? "Set-Cookie header not found in response."
'     end if
' end function

' ' Function to extract the token from the Set-Cookie header
' function extractTokenFromSetCookieHeader(setCookieHeader as string) as string
'     ' Split the Set-Cookie header by semicolon to get individual cookie parts
'     cookieParts = splitString(setCookieHeader, ";")

'     ' Iterate through the cookie parts to find the part containing the token
'     For Each part In cookieParts
'         ' Trim any leading or trailing spaces
'         part = customTrim(part)

'         ' Check if the part starts with "stedi-token="
'         if Left(part, 11) = "stedi-token=" then
'             ' Extract the token value by removing "stedi-token=" from the part
'             token = Mid(part, 12)
'             ' Return the token value
'             return token
'         end if
'     end for

'     ' If the token is not found, return an empty string or handle the error as needed
'     return ""
' end function

' function customTrim(inputString as string) as string
'     startIndex = 1
'     endIndex = Len(inputString)

'     ' Find the start index for trimming
'     while startIndex <= endIndex and Asc(Mid(inputString, startIndex, 1)) <= 32
'         startIndex = startIndex + 1
'     end while

'     ' Find the end index for trimming
'     while endIndex >= startIndex and Asc(Mid(inputString, endIndex, 1)) <= 32
'         endIndex = endIndex - 1
'     end while

'     ' Extract the trimmed substring
'     trimmedString = Mid(inputString, startIndex, endIndex - startIndex + 1)

'     return trimmedString
' end function


' ' Function to split a string into an array based on a delimiter
' function splitString(inputString as string, delimiter as string) as object
'     parts = []
'     startIndex = 0
'     endIndex = -1

'     while true
'         endIndex = InStr(startIndex + 1, inputString, delimiter)

'         if endIndex = -1
'             ' No more delimiters found, add the remaining part
'             part = Mid(inputString, startIndex + 1)
'             parts.Push(part)
'             exit while
'         else
'             ' Add the part between startIndex and endIndex
'             part = Mid(inputString, startIndex + 1, endIndex - startIndex - 1)
'             parts.Push(part)
'             startIndex = endIndex
'         end if
'     end while

'     return parts
' end function

' 'end of funcs













' function onConfirmEmail(msg as object)
'     ? "> confirming email ..."
'     'dismissdialog()
'     ' check if email address linked to active subscription in publisher's system, logic should be on the publisher side
'     #if sampleHardCodedValues
'         isLinkedEmail(msg)
'     #else
'         m.progressdialog = createObject("roSGNode", "ProgressDialog")
'         m.progressdialog.title = "Linking Email ..."
'         m.top.dialog = m.progressdialog

'         makeRequest("url", { uri: "PUBLISHER EMAIL VERIFICATION LINK GOES HERE" }, "isLinkedEmail")
'         'adjust isLinkedEmail to handle the response from publisher system'
'     #end if
' end function

' function isLinkedEmail(msg as object)
'     rspData = msg.getData()
'     if rspData.type = "signup" then
'         ' need to send to publisher system to create account
'         isLinked = "false"
'     else
'         ' type = "signin" - check with publisher system
'         'isLinked = msg.getData().content
'         isLinked = "true"
'     end if

'     if isLinked = "true" 'email is linked to active subscription
'         ? "email is linked to an active subscription in publisher system"
'         #if sampleHardCodedValues
'             m.publisherAccessToken = "TOK8ZQEDDR8AWVJF8AH"
'             writeAccessToken()
'         #else
'             ' get access token from publisher server and store on device
'             dismissdialog()
'             makeRequest("url", { uri: "PUBLISHER TOKEN KEY LINK GOES HERE" }, "getWriteAccessToken")
'         #end if
'         grantAccess()
'     else
'         ? "email not linked to active subscription in publisher system, create and process an order ..."
'         m.productSelectScreen.visible = "true"
'         m.hint.visible = "true"
'         m.selectHint.visible = "true"
'         m.productGrid.setFocus(true)
'     end if
' end function

' function onOrderStatus(msg as object)
'     status = msg.getData().status
'     if status = 1 ' order success
'         ? "> order success"
'         #if sampleHardCodedValues
'             m.publisherAccessToken = "TOK8ZQEDDR8AWVJF8AH"
'             writeAccessToken()
'         #else
'             tid = m.store.orderStatus.getChild(0).purchaseId
'             ' validate the order by checking if it is now entitled on the roku side
'             makeRequest("url", { uri: Substitute("https://apipub.roku.com/listen/transaction-service.svc/validate-transaction/{0}/{1}", m.devAPIKey, tid) }, "validateOrder")
'         #end if
'     else 'error in doing order
'         ? "> order error ..."
'         ? "> error status " status ": " msg.getData().statusMessage
'         m.dialogBox.message = "Order Error: " + chr(10) + msg.getData().statusMessage
'         m.dialogBox.buttons = ["Go back to Channel Add-ons UI"]
'         m.top.dialog = m.dialogBox
'         m.store.order = invalid 'clear order
'     end if
' end function

' function validateOrder(msg as object) as void
'     ? "validating order ..."
'     response = msg.getData()
'     if response.code <> 200
'         ? "Validate transaction failed, check if API key and transaction ID are valid"
'         ' dialogBox = CreateObject("roSGNode", "Dialog")
'         m.dialogBox.message = "Error: " + chr(10) + "Validate transaction failed: check if API key and transaction ID are valid"
'         m.dialogBox.buttons = ["Go back to Channel Add-ons UI"]
'         m.top.dialog = m.dialogBox
'         return
'     end if

'     xml = createObject("roXMLElement")
'     xml.parse(response.content)
'     isEntitled = (xml.getNamedElements("isEntitled")[0].getText() = "true")
'     ? "< new purchase is entitled: " isEntitled
'     if isEntitled = true
'         print "order is entitled, store access token on device and grant access to user"
'         m.itemSelected.productBought = true
'         #if sampleHardCodedValues
'             m.publisherAccessToken = "TOK8ZQEDDR8AWVJF8AH"
'             writeAccessToken()
'         #else
'             makeRequest("url", { uri: "PUBLISHER TOKEN KEY LINK GOES HERE" }, "getWriteAccessToken")
'         #end if

'         'grantAccess()
'     else
'         ? "order is not entitled, create new subscription again"
'         ' dialogBox = CreateObject("roSGNode", "Dialog")
'         m.dialogBox.message = "Error: " + chr(10) + "device is not entitled"
'         m.dialogBox.buttons = ["Go back to Channel Add-ons UI"]
'         m.top.dialog = m.dialogBox
'     end if
' end function

' function getWriteAccessToken(msg as object)
'     ' get and write access token from publisher server and store on device
'     m.publisherAccessToken = ParseJson(msg.getData().content).tokenKey
'     ? "< writing access token from publisher server " m.publisherAccessToken
'     makeRequest("registry", { section: "sample", command: "write", key: "sample_access_token", value: m.publisherAccessToken }, "onAccessTokenWrite")
' end function

' function writeAccessToken()
'     ' write access token from publisher server and store on device
'     ? "< writing access token from publisher server " m.publisherAccessToken
'     makeRequest("registry", { section: "sample", command: "write", key: "sample_access_token", value: m.publisherAccessToken }, "onAccessTokenWrite")
'     print "  also write the access token in Roku Cloud"
'     m.store.channelCredData = m.publisherAccessToken
'     m.store.command = "storeChannelCredData"
' end function

' function onAccessTokenWrite(msg)
'     print "> finished writing access token" msg
' end function

' function onStoreChannelCredData() as void
'     print "> finished storing access token in Roku Cloud"
'     if (m.store.storeChannelCredDataStatus <> invalid)
'         print "- response: " m.store.storeChannelCredDataStatus.response
'         print "- status: " m.store.storeChannelCredDataStatus.status
'     end if
'     ' Grant access to the user'
'     if m.clearTokenReq = true
'         m.clearTokenReq = false
'     else
'         grantAccess()
'     end if
' end function

' sub dismissdialog()
'     m.top.dialog.close = true
' end sub

' function grantAccess()
'     m.dialogBox.message = "Success: " + chr(10) + "Access Granted!"
'     m.dialogBox.buttons = ["Continue"]
'     m.top.dialog = m.dialogBox
'     print "!-------------------access granted-------------------!"
'     ' hide product screen and display the content screen'
'     m.productSelectScreen.visible = false
'     m.selectHint.text = "Navigate content grid"
'     m.selectHint.visible = true
'     m.hint.visible = true
'     m.contentScreen.visible = true
'     m.contentScreenRowList.SetFocus(true)
' end function

' function makeRequest(requestType as string, parameters as object, callback as string)
'     context = createObject("RoSGNode", "Node")
'     if type(parameters) = "roAssociativeArray"
'         context.addFields({ parameters: parameters, response: {} })
'         context.observeField("response", callback) ' response callback is request-specific
'         if requestType = "url"
'             m.uriFetcher.request = { context: context }
'         else if requestType = "registry"
'             ? "< Accessing Registry for a " parameters.command
'             m.registryTask.request = { context: context }
'         end if
'     end if
' end function

' function onKeyEvent(key as string, press as boolean) as boolean
'     handled = false
'     if press then
'         if (key = "back") then
'             handled = false
'         else
'             if (key = "options") then
'                 makeRequest("registry", { section: "", command: "deleteRegistry", key: "", value: "" }, "")

'                 ' Delete the publisher access token from Roku Cloud
'                 m.clearTokenReq = true
'                 m.store.channelCredData = ""
'                 m.store.command = "storeChannelCredData"

'                 m.dialogBox.message = "Information: " + chr(10) + "Deleted the sample registry. To repurchase items, please void the transactions at:" + chr(10) + "https://developer.roku.com/developer > Manage Test Users > View (under transactions) > Void transactions"
'                 m.dialogBox.buttons = ["Understood"]
'                 m.top.dialog = m.dialogBox
'             end if
'             handled = true
'         end if
'     end if
'     return handled
' end function