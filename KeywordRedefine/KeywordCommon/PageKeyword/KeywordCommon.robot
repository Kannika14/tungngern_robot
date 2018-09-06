*** Settings ***
Library    AppiumLibrary
#Library           ../../Library/AppiumEx.py
#Library           OperatingSystem
#Library           Collections
#Library           String
Resource          ../PageRepository/RepositoryCommon.robot
#Library           Selenium2Library
#Library           ../../Library/CSVLibrary.py
#Library           DateTime

*** Keywords ***
Open Application Android
    [Arguments]    ${remoteUrl}    ${platformName}    ${platformVersion}    ${udid}    ${appPackage}    ${appActivity}    ${noReset}
    Log    Open Test
    Open Application    http://${remoteUrl}/wd/hub    platformName=${platformName}    platformVersion=${platformVersion}    deviceName=${udid}    udid=${udid}    appPackage=${appPackage}
    ...    appActivity=${appActivity}    noReset=${noReset}
    Log    Open Success

Input Text via ADB Keyboard
    [Arguments]    ${Locator}    ${wording}    ${udid}
    [Documentation]    This Keyword for Input Text Thai language
    ...
    ...    Keyword Need ADB Keyboard Install On Mobile
    ...    https://arcadiaautomationteam.slack.com/files/storygu/F4ENYP17X/keyboardservice-debug.apk
    ...
    ...    http://www.mediafire.com/file/rgdia9vj0ib0q4q/ADB+Keyboard.apk
    AppiumEx.Click Element    ${Locator}
    ${setADB}=    Run And Return Rc    adb -s ${udid} shell ime set com.android.adbkeyboard/.AdbIME    # Set ADB Keyboard
    ${command}=    Set Variable    adb -s ${udid} shell am broadcast -a ADB_INPUT_TEXT --es msg "${keyword}"
    Log    ${command}
    ${rcInputText}=    Run And Return Rc    ${command}
    ${rcSearch}=    Run And Return Rc    adb -s ${udid} shell am broadcast -a ADB_EDITOR_CODE --ei code 3    # IME_ACTION_SEARCH
    ${rcSSKB}=    Run And Return Rc    adb -s ${udid} shell ime set com.sec.android.inputmethod/.SamsungKeypad    # Set Samsung Keyboard
    Run Keyword And Ignore Error    Hide Keyboard

ADB Keyboard Event Enter
    [Arguments]    ${udid}
    ${rc}=    Run And Return Rc    adb -s ${udid} shell input keyevent 66
    Log    ${rc}

mood Wait SMS
    [Arguments]    ${totalSms}    ${timeout}    ${sender}=all
    Log    In mood Wait SMS
    ${timeout}=    Convert To Integer    ${timeout}
    Run Keyword If    '${sender}'=='all'    Wait Until Keyword Succeeds    ${timeout} s    1 s    mood Wait SMS All Sender    ${totalSms}
    Run Keyword If    '${sender}'!='all'    Wait Until Keyword Succeeds    ${timeout} s    1 s    mood Wait SMS With Sender    ${totalSms}
    ...    ${sender}
    Log    Out mood Wait SMS

mood Open SMS App
    [Arguments]    ${remoteUrl}    ${platformName}    ${platformVersion}    ${udid}
    Log    In mood Open SMS App
    ${devices}    Open Application    http://${remoteUrl}/wd/hub    platformName=${platformName}    platformVersion=${platformVersion}    udid=${udid}    appPackage=com.calea.echo
    ...    appActivity=com.calea.echo.MainActivity    deviceName=${remoteUrl}    unicodeKeyboard=${True}    resetKeyboard=${True}    noReset=${True}    automationName=uiautomator2
    Log    Out mood Open SMS App
    [Return]    ${devices}

mood Wait SMS All Sender
    [Arguments]    ${totalSms}
    Comment    Log    In mood Wait SMS All Sender
    ${totalUnread}=    Set Variable    0
    @{unreadElements}    AppiumEx.Get Webelements    ${lblUnreadNumber}
    : FOR    ${eachUnread}    IN    @{unreadElements}
    \    ${number}=    Convert To Integer    ${eachUnread.get_attribute('text')}
    \    ${totalUnread}=    Evaluate    ${number} + ${totalUnread}
    Run Keyword If    ${totalUnread} < ${totalSms}    FAIL    waiting more sms...
    Comment    Log    out mood Wait SMS All Sender

mood Read SMS
    [Arguments]    ${sender}    ${totalSms}=1
    Log    In Mood Read SMS
    @{emptyList}=    Create List
    @{messages}=    Create List
    @{senderNameElements}    AppiumEx.Get Webelements    ${lblSenderName}
    : FOR    ${senderNameElement}    IN    @{senderNameElements}
    \    ${senderName}=    Convert To String    ${senderNameElement.get_attribute('text')}
    \    @{messages}=    Run Keyword If    '${senderName}' == '${sender}'    mood Collect SMS Message    ${senderNameElement}    ${totalSms}
    \    Run Keyword If    @{messages} != @{emptyList}    Exit For Loop
    Run Keyword If    @{messages} == @{emptyList}    FAIL    Not found sender to read SMS
    Comment    Mobile Capture Screen At Verify Point    Read SMS Mood
    Sleep    1
    Press Keycode    4
    Log    Out Mood Read SMS
    [Return]    ${messages}

mood Collect SMS Message
    [Arguments]    ${senderElement}    ${totalSms}
    Log    In mood Collect SMS Message
    Evaluate    '${senderElement.click()}'
    Sleep    2    Delay before read SMS
    ${totalSms}=    Convert To Integer    ${totalSms}
    ${counter}=    Set Variable    0
    @{messages}=    Create List
    @{messageElements}=    AppiumEx.Get Webelements    ${lblTextMessage}
    Convert To List    ${messageElements}
    Reverse List    ${messageElements}
    : FOR    ${messageElement}    IN    @{messageElements}
    \    ${message}    Convert To String    ${messageElement.get_attribute('text')}
    \    Run Keyword If    ${counter} < ${totalSms}    Append To List    ${messages}    ${message}
    \    ${counter}=    Evaluate    ${counter} + 1
    \    Run Keyword If    ${counter} >= ${totalSms}    Exit For Loop
    Log    Out mood Collect SMS
    [Return]    ${messages}

mood Clear All Unread SMS
    Log    Clear SMS
    ${status} =    Run Keyword And Return Status    AppiumEx.Get Webelements    ${fraUnreadFlag}
    Return From Keyword If    '${status}'== 'False'    ${status}
    @{unreadElements}=    AppiumEx.Get Webelements    ${fraUnreadFlag}
    Comment    @{unreadElements}=    Get Elements    ${fraUnreadFlag}
    : FOR    ${eachUnread}    IN    @{unreadElements}
    \    Log To Console    Unread detail: ${eachUnread}
    \    Evaluate    '${eachUnread.click()}'
    \    Sleep    2
    \    AppiumEx.Click Element    ${btnSmsBack}
    Log    End Clear SMS
    [Return]    ${status}

mood Close SMS App
    [Arguments]    ${platformName}    ${udid}
    Log    In mood Close SMS App
    sleep    2
    Press Keycode    187
    sleep    2
    AppiumEx.Wait Until Page Contains Element    xpath=//android.widget.TextView[@text="Mood"]
    Comment    Click Mobile Element    xpath=(//*[@clickable='true' and (@content-desc='mood' or @text='mood')])
    AppiumEx.Click Element    xpath=(//*[(@class='android.widget.FrameLayout' and @content-desc='Mood')or (@class='android.widget.TextView' and @text='Mood' and @index="2")])
    sleep    1
    Close Application
    Log    after close application
    sleep    1
    ${command}=    Set Variable    adb -s ${udid} shell am kill com.calea.echo
    Log    ${command}
    ${rc}=    Run And Return Rc    ${command}
    Log    ${rc}

mood Read All Unread SMS
    Log    Clear SMS
    @{CollectMessage}    Create List
    ${index}    Set Variable    0
    sleep    2
    : FOR    ${index}    IN RANGE    1000
    \    ${status}    Run Keyword And Return Status    AISAppiumEx.Aisappium Element Should Be Enabled    ${lblUnreadNumber}
    \    sleep    2
    \    Log    ${status}
    \    Exit For Loop If    '${status}'=='False'
    \    @{UnreadElementNew}=    AppiumEx.Get Webelements    ${lblUnreadNumber}
    \    ${RealUnreadElement}=    Set Variable    @{UnreadElementNew}[0]
    \    Log    ${RealUnreadElement.get_attribute('text')}
    \    ${number}=    Convert To Integer    ${RealUnreadElement.get_attribute('text')}
    \    Log    ${RealUnreadElement}
    \    @{messages}=    mood Collect SMS Message    ${RealUnreadElement}    ${number}
    \    AppiumEx.Click Element    ${btnSmsBack}
    \    @{CollectMessage}=    Collect Many Message    ${CollectMessage}    ${messages}
    \    Log    ${CollectMessage}
    Log    End Clear SMS
    [Return]    ${CollectMessage}

mood Wait SMS With Sender
    [Arguments]    ${TotalSMS}    ${Sender}
    Log    In mood Wait SMS with Sender
    ${intUnread}    Set Variable    ${TotalSMS}
    @{unreadElements}    AppiumEx.Get Webelements    ${lblUnreadNumber}
    : FOR    ${eachUnread}    IN    @{unreadElements}
    \    ${number}=    Convert To Integer    ${eachUnread.get_attribute('text')}
    \    ${result}    Run Keyword If    ${number} >= ${intUnread}    check unread on sender    ${eachUnread.get_attribute('text')}    ${Sender}
    \    Exit For Loop If    ${result}==True
    Run Keyword If    ${result}==False    fail    SMS not found
    Log    Out mood Wait SMS with Sender

check unread on sender
    [Arguments]    ${TotalSMS}    ${Sender}
    Log    In check unread on sender
    ${tempLocatorFlag}    Replace String    ${tempLocatorUnreadWithSender}    -[totalMsg]-    ${TotalSMS}
    ${locatorSenderWithFlag}    Replace String    ${tempLocatorFlag}    -[Sender]-    ${Sender}
    ${result}    Run Keyword And Return Status    AppiumEx.Wait Until Page Contains Element    ${locatorSenderWithFlag}
    Log    Out check unread on sender
    [Return]    ${result}

Collect Many Message
    [Arguments]    ${CollectMessage}    ${messages}
    Comment    ${One}    Create List    a    b
    Comment    ${Two}    Create List    c    d
    Comment    ${messages}    Create List    ${One}    ${Two}
    Comment    Log    ${messages}
    ${Length}    Get Length    ${messages}
    ${index}    Set Variable    0
    : FOR    ${index}    IN RANGE    ${Length}
    \    Log    @{messages}[${index}]
    \    ${MessageOrder}    Set Variable    @{messages}[${index}]
    \    Log    ${MessageOrder}
    \    Append To List    ${CollectMessage}    ${MessageOrder}
    \    Log    ${CollectMessage}
    [Return]    ${CollectMessage}

Wait SMS
    [Arguments]    ${os}    ${totalSms}    ${timeout}    ${sender}=all
    Comment    Log    In Wait SMS
    Run Keyword If    '${os}' == 'Android'    mood Wait SMS    ${totalSms}    ${timeout}    ${sender}
    Run Keyword If    '${os}' == 'iOS'    ios Wait SMS    ${totalSms}    ${timeout}    ${sender}
    Comment    Log    Out Wait SMS

Open SMS App
    [Arguments]    ${remoteUrl}    ${platformName}    ${platformVersion}    ${udid}
    Log    In Open SMS App
    Log    ${remoteUrl}
    Log    ${platformName}
    Log    ${platformVersion}
    Log    ${udid}
    ${devices}    Run Keyword If    '${platformName}' == 'Android'    mood Open SMS App    ${remoteUrl}    ${platformName}    ${platformVersion}
    ...    ${udid}
    ${devices}    Run Keyword If    '${platformName}' == 'iOS'    ios Open SMS App    ${remoteUrl}    ${platformName}    ${platformVersion}
    ...    ${udid}
    Comment    Log    Out Open SMS App
    [Return]    ${devices}

Read SMS
    [Arguments]    ${os}    ${sender}    ${totalSms}
    Log    In Read SMS
    Comment    Log    ${os}
    @{messages}=    Create List
    @{messages}=    Run Keyword If    '${os}' == 'Android'    mood Read SMS    ${sender}    ${totalSms}
    ...    ELSE IF    '${os}' == 'iOS'    ios Read SMS    ${sender}    ${totalSms}
    Log List    ${messages}
    Log    Out Read SMS
    [Return]    ${messages}

Clear All Unread SMS
    [Arguments]    ${os}
    Log    In Clear All Unread SMS
    Log    ${os}
    Run Keyword If    '${os}' == 'Android'    mood Clear All Unread SMS
    ...    ELSE IF    '${os}' == 'iOS'    Log To Console    Welcome iOS
    Comment    Log    Out Read All SMS

Wait and Verify SMS
    [Arguments]    ${platformName}    ${platformSN}    ${totalSMS}    ${senderName}    ${messageExpect}    ${timeout}=10
    [Documentation]    You must Create List for send List to ${MessageExpect}
    ...    EX
    ...    @{MessageExpect} \ \ \ \ \ Create List ${MessageOne} \ \ \ \ ${MessageTwo}
    ...
    ...    Wait and Verify SMS | ${virtual_3PO_2_Platfrom_Name}| ${virtual_3PO_2_Platfrom_SN} |1 | ${SenderName} | @{MessageExpect} |15
    Log    In Wait and Verify SMS
    Comment    sleep    2
    Wait SMS    ${platformName}    ${totalSMS}    ${timeout}
    Comment    @{messages}=    Read All Unread SMS    ${platformName}
    @{messages}=    Read SMS    ${platformName}    ${senderName}    ${totalSMS}
    ${lengthOfMsgExpect}    Get Length    ${messageExpect}
    ${indexOfExpect}    Set Variable    0
    : FOR    ${indexOfExpect}    IN RANGE    ${lengthOfMsgExpect}
    \    Comment    Verify SMS    ${totalSMS}    ${messages}    ${indexOfExpect}    ${messageExpect}
    \    Verify SMS    ${messages}    @{messageExpect}[${indexOfExpect}]
    \    ${indexOfExpect}    Evaluate    ${indexOfExpect}+1
    Log    Out Wait and Verify SMS

Close SMS App
    [Arguments]    ${platformName}    ${udid}
    Run Keyword If    '${platformName}' == 'Android'    mood Close SMS App    ${platformName}    ${udid}
    Run Keyword If    '${platformName}' == 'iOS'    FAIL    Not Implement

Verify SMS
    [Arguments]    ${messages}    ${messageExpect}
    ${indexOfActual}    Set Variable    0
    ${totalSMS}    Get Length    ${messages}
    ${result}    Evaluate    ${totalSMS}-1
    : FOR    ${indexOfActual}    IN RANGE    ${totalSMS}
    \    Log    ${messageExpect}
    \    Log    @{messages}[${indexOfActual}]
    \    ${status}=    Run Keyword And Return Status    Should Be Equal    @{messages}[${indexOfActual}]    ${messageExpect}
    \    Run Keyword If    "${status}"=="True"    Exit For Loop
    \    Run Keyword If    ${indexOfActual}==${result}    Fail    Message did not match...
    \    ${indexOfActual}    Evaluate    ${indexOfActual}+1

Read All Unread SMS
    [Arguments]    ${platformName}
    Log    In Read All Unread SMS
    ${CollectMessage}=    Run Keyword If    '${platformName}' == 'Android'    mood Read All Unread SMS
    ${CollectMessage}=    Run Keyword If    '${platformName}' == 'iOS'    ios Read All Unread SMS
    Log    Out Read All Unread SMS
    [Return]    ${CollectMessage}

Wait and Verify Unread SMS
    [Arguments]    ${platformName}    ${platformSN}    ${totalSMS}    ${messageExpect}    ${timeout}=10
    [Documentation]    You must Create List for send List to ${MessageExpect}
    ...    EX
    ...    @{MessageExpect} \ \ \ \ \ Create List ${MessageOne} \ \ \ \ ${MessageTwo}
    Log    In Wait and Verify Unread SMS
    Comment    sleep    2
    Wait SMS    ${platformName}    ${totalSMS}    ${timeout}
    @{messages}=    Read All Unread SMS    ${platformName}
    ${lengthOfMsgExpect}    Get Length    ${messageExpect}
    ${indexOfExpect}    Set Variable    0
    : FOR    ${indexOfExpect}    IN RANGE    ${lengthOfMsgExpect}
    \    Verify SMS    ${messages}    @{messageExpect}[${indexOfExpect}]
    \    ${indexOfExpect}    Evaluate    ${indexOfExpect}+1
    Log    Out Wait and Verify Unread SMS

Wait And Verify Unread SMS By TimeOut
    [Arguments]    ${platformName}    ${platformSN}    ${senderName}    ${messageExpect}    ${timeout}
    Log    In Wait and Verify SMS By Time Out
    Sleep    ${timeout}
    Comment    Wait SMS    ${platformName}    ${totalSMS}    ${timeout}
    @{unreadElements}    AppiumEx.Get Webelements    ${lblUnreadNumber}
    : FOR    ${eachUnread}    IN    @{unreadElements}
    \    ${number}=    Convert To Integer    ${eachUnread.get_attribute('text')}
    Log To Console    'total sms:' ${number}
    @{messages}=    Read SMS    ${platformName}    ${senderName}    ${number}
    ${lengthOfMsgExpect}    Get Length    ${messageExpect}
    Log To Console    'Message Ex Amount:' ${lengthOfMsgExpect}
    ${indexOfExpect}    Set Variable    0
    : FOR    ${indexOfExpect}    IN RANGE    ${lengthOfMsgExpect}
    \    log    'SMS:'${messages}
    \    log    'Expect:'@{messageExpect}[${indexOfExpect}]
    \    Verify SMS With Regex    ${messages}    @{messageExpect}[${indexOfExpect}]
    \    ${indexOfExpect}    Evaluate    ${indexOfExpect}+1
    Log    Out Wait and Verify SMS By Time Out

Verify SMS With Regex
    [Arguments]    ${messages}    ${messageExpect}
    ${indexOfActual}    Set Variable    0
    ${totalSMS}    Get Length    ${messages}
    ${result}    Evaluate    ${totalSMS}-1
    Log To Console    result: ${result}
    : FOR    ${indexOfActual}    IN RANGE    ${totalSMS}
    \    Log To Console    message expect :${messageExpect}
    \    Log To Console    message: @{messages}[${indexOfActual}]
    \    Comment    Run Keyword If    '${messageExpect}'== '@{messages}[${indexOfActual}]'    Exit For Loop
    \    ${status}=    Run Keyword And Return Status    Should Match Regexp    @{messages}[${indexOfActual}]    ${messageExpect}
    \    Log To Console    ${status}
    \    Run Keyword If    '${status}'=='True'    Exit For Loop
    \    Run Keyword If    ${indexOfActual}==${result}    Fail    Message did not match with regex pattern...
    \    ${indexOfActual}    Evaluate    ${indexOfActual}+1

Android Switch App
    [Arguments]    ${AppName}
    Log    In Switch App
    Sleep    2
    Press Keycode    187
    Sleep    2
    @{ListAppName}    AppiumEx.Get Webelements    xpath=//*[@resource-id="com.android.systemui:id/activity_description"]
    ${Length}=    Get Length    ${ListAppName}
    ${index}    Set Variable    0
    : FOR    ${index}    IN RANGE    ${Length}
    \    ${locator}    Set Variable    xpath=//android.widget.FrameLayout[@index="${index}"]/*/*/android.widget.TextView
    \    ${GetAppName}    AppiumEx.Get Text    ${locator}
    \    Log    ${GetAppName}
    \    ${status}    Run Keyword And Return Status    Should Match Regexp    ${GetAppName}    ${AppName}
    \    Run Keyword If    '${status}'=='True'    Click Mobile Element    ${locator}
    \    Exit For Loop If    '${status}'=='True'
    Run Keyword If    '${status}'=='Flase'    Fail    Don't have ${AppName}...
    Log    Out Switch App

Click Web Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    ${result}    Run Keyword And Return Status    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Comment    Log    ${timeout}
    Comment    Log To Console    ${result}
    Comment    Log To Console    ${locator} from click web element
    Comment    Run Keyword If    '${result}'=='False'    Click Web Element By Wait Web Until Page Contains Element    ${locator}    ${timeout}
    ...    ELSE    Selenium2Library.Click Element    ${locator}
    Run Keyword If    '${result}'=='False'    Wait Web Until Page Contains Element    ${locator}    ${timeout}
    Selenium2Library.Click Element    ${locator}

Click Mobile Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Mobile Element Is Exist    ${locator}    ${timeout}
    AppiumEx.Click Element    ${locator}

Click Web Button
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    ${result}    Run Keyword And Return Status    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Comment    Log To Console    ${result}
    Comment    Log To Console    ${locator} from Click Web Button
    Run Keyword If    '${result}'=='False'    Wait Web Until Page Contains Element    ${locator}    ${timeout}
    Selenium2Library.Click Button    ${locator}

Click Mobile Button
    [Arguments]    ${index_or_name}    ${timeout}=${lo_general_timeout}
    Mobile Element Is Exist    ${index_or_name}    ${timeout}
    AppiumEx.Click Button    ${index_or_name}

Input Web Text
    [Arguments]    ${locator}    ${text}    ${timeout}=${lo_general_timeout}
    ${result}    Run Keyword And Return Status    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Comment    Log To Console    ${result}
    Comment    Log To Console    ${locator} from Input Web Text
    Run Keyword If    '${result}'=='False'    Wait Web Until Page Contains Element    ${locator}    ${timeout}
    Selenium2Library.Input Text    ${locator}    ${text}

Input Mobile Text
    [Arguments]    ${locator}    ${text}    ${timeout}=${lo_general_timeout}
    Mobile Element Is Exist    ${locator}    ${timeout}
    AppiumEx.Input Text    ${locator}    ${text}

Web Element Should Be Disabled
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Selenium2Library.Element Should Be Disabled    ${locator}

Web Element Should Be Enabled
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Selenium2Library.Element Should Be Enabled    ${locator}

Wait Web Until Page Contains Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Page Contains Element    ${locator}    ${timeout}

Wait Mobile Until Page Contains Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    AppiumEx.Wait Until Page Contains Element    ${locator}    ${timeout}

Get Web Text
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    ${result}    Run Keyword And Return Status    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Comment    Log To Console    ${result}
    Comment    Log To Console    ${locator} from Get Web Text
    Run Keyword If    '${result}'=='False'    Wait Web Until Page Contains Element    ${locator}    ${timeout}
    ${Text}    Selenium2Library.Get Text    ${locator}

Mobile Switch App
    [Arguments]    ${AppName}
    [Documentation]    You have to wait before opening the program.
    Press Keycode    187
    sleep    2
    Click Mobile Element    xpath=(//android.widget.TextView[@text='${AppName}'])

Web Element Should Be Visible
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Selenium2Library.Element Should Be Visible    ${locator}

Web Element Text Should Be
    [Arguments]    ${locator}    ${text}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Selenium2Library.Wait Until Element Contains    ${locator}    ${text}    ${timeout}
    Selenium2Library.Element Text Should Be    ${locator}    ${text}

Mobile element text should be
    [Arguments]    ${locator}    ${text}    ${timeout}=${lo_general_timeout}
    Mobile Element Is Exist    ${locator}    ${timeout}
    AppiumEx.Element Text Should Be    ${locator}    ${text}

Select From Web List By Value
    [Arguments]    ${locator}    ${Value}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Selenium2Library.Select From List By Value    ${locator}    ${Value}

Click Web Image
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    ${result}    Run Keyword And Return Status    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Comment    Log To Console    ${result}
    Comment    Log To Console    ${locator} from click Image
    Run Keyword If    '${result}'=='False'    Wait Web Until Page Contains Element    ${locator}    ${timeout}
    Selenium2Library.Click Image    ${locator}

Select From Web List By Label
    [Arguments]    ${locator}    ${label}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Selenium2Library.Select From List By Label    ${locator}    ${label}

Select From Web List
    [Arguments]    ${locator}    ${text}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}
    Selenium2Library.Select From List    ${locator}    ${text}

Get mobile text
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Mobile Element Is Exist    ${locator}    ${timeout}
    ${text}    AppiumEx.Get Text    ${locator}
    [Return]    ${text}

Get mobile attribute
    [Arguments]    ${locator}    ${attribute}    ${timeout}=${lo_general_timeout}
    Mobile Element Is Exist    ${locator}    ${timeout}
    ${attValue}    AppiumEx.Get Element Attribute    ${locator}    ${attribute}
    [Return]    ${attValue}

Capture ScreenShot
    ${screenshot_index}=    Get Variable Value    ${screenshot_index}    ${0}
    Set Global Variable    ${screenshot_index}    ${screenshot_index.__add__(1)}
    Comment    ${time}=    Evaluate    str(time.time())    time
    Selenium2Library.Capture Page Screenshot    screenshot-Selenium-${TEST NAME}-${screenshot_index}.png
    AppiumEx.Capture Page Screenshot    ${TEST_NAME}.png
    Comment    ${Appium}    Run Keyword And Return Status    AISAppiumEx.Capture Page Screenshot    screenshot-Appium-${ID_TestCase}-${Lang}.png
    Comment    ${Selenium}    Run Keyword And Return Status    Selenium2Library.Capture Page Screenshot    screenshot-Selenium-${ID_TestCase}-${Lang}.png

Mobile Get Elements
    [Arguments]    ${locator}
    ${elements}    AppiumEx.Get Webelements    ${locator}
    [Return]    ${elements}

Web get elements
    [Arguments]    ${locator}
    ${elements}    Selenium2Library.Get Webelements    ${locator}
    [Return]    ${elements}

Mobile element name should be
    [Arguments]    ${locator}    ${text}    ${timeout}=${lo_general_timeout}    ${is_regex}=${False}
    Wait Mobile Until Element Visible    ${locator}    ${timeout}
    ${Actual}=    Get mobile attribute    ${locator}    name
    Log    ${text}
    Run Keyword If    ${is_regex}==${False}    Should Be Equal    ${Actual}    ${text}
    Run Keyword If    ${is_regex}==${True}    Should Match Regexp    ${Actual}    ${text}

Click Mobile Element At Position
    [Arguments]    ${locator}    ${marginSide}=right    ${ratio}=0.1
    [Documentation]    *e.g. marginSide=top, below, left, right
    ...    (sensitive-case)
    Wait Mobile Until Page Contains Element    ${locator}
    &{size}    AppiumEx.Get Element Size    ${locator}
    &{location}    Get Element Location    ${locator}
    ${width}=    Get From Dictionary    ${size}    width
    ${height}=    Get From Dictionary    ${size}    height
    ${y}=    Get From Dictionary    ${location}    y
    ${x}=    Get From Dictionary    ${location}    x
    ${halfY}=    Evaluate    ${y}+(${height}/2)
    ${halfX}=    Evaluate    ${x}+(${width}/2)
    ${marginTop}=    Evaluate    ${y}+(${height}*${ratio})
    ${marginBelow}=    Evaluate    (${y}+${height})-(${height}*${ratio})
    ${marginLeft}=    Evaluate    ${x}+(${width}*${ratio})
    ${marginRight}=    Evaluate    ${width}-(${width}*${ratio})
    Run Keyword If    '${marginSide}'=='top'    Click A Point    ${halfX}    ${marginTop}
    Run Keyword If    '${marginSide}'=='below'    Click A Point    ${halfX}    ${marginBelow}
    Run Keyword If    '${marginSide}'=='left'    Click A Point    ${marginLeft}    ${halfY}
    Run Keyword If    '${marginSide}'=='right'    Click A Point    ${marginRight}    ${halfY}

Mobile Capture Screen At Verify Point
    [Arguments]    ${NameOfVerifyPoint}    ${SerialNumber}=${EMPTY}
    [Documentation]    Name of verify point cannot input / to name
    ...    ex. Payment/Topup cannot input \ but can input Payment and Topup
    Sleep    2
    ${screenshot_index}=    Get Variable Value    ${screenshot_index}    ${0}
    Set Global Variable    ${screenshot_index}    ${screenshot_index.__add__(1)}
    @{SplitCodeTestCase}    Split String    ${TEST_NAME}    ]
    Log    @{SplitCodeTestCase}[0]
    ${CodeTestCase}    Set Variable    @{SplitCodeTestCase}[0]
    ${result} =    Wait Until Keyword Succeeds    3x    1s    AppiumEx.Capture Page Screenshot    screenshot-${NameOfVerifyPoint}-${CodeTestCase}]-${SUITE_NAME}-${Lang}-${ar_NType}.png
    Log    ${result}
    @{imageName}    Create List
    Append To List    ${imageName}    screenshot-Selenium-${CodeTestCase}]-${SUITE_NAME}-${screenshot_index}-${Lang}-${ar_NType}.png
    Log    ${imageName}
    [Teardown]

Mobile check existing text in name
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Wait Mobile Until Page Contains Element    ${locator}
    ${RealMessage}    Get mobile attribute    ${locator}    name
    Should Match Regexp    ${RealMessage}    .+
    Log    ${RealMessage}

Mobile check existing text
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Wait Mobile Until Page Contains Element    ${locator}
    ${RealMessage}    AppiumEx.Get Text    ${locator}
    Should Match Regexp    ${RealMessage}    .+
    Log    ${RealMessage}

Mobile element text should match regexp
    [Arguments]    ${locator}    ${MessageExpect}    ${timeout}=${lo_general_timeout}
    Wait Mobile Until Element Visible    ${locator}
    ${RealExpired}    AppiumEx.Get Text    ${locator}
    Log    Expect ${MessageExpect}
    Should Match Regexp    ${RealExpired}    ${MessageExpect}

Mobile element text should match regexp whole string
    [Arguments]    ${locator}    ${MessageExpect}    ${timeout}=${lo_general_timeout}
    Wait Mobile Until Element Visible    ${locator}
    ${acctual}    AppiumEx.Get Text    ${locator}
    Log    ${acctual}
    Should Match Regexp    ${acctual}    ^${MessageExpect}$

Mobile element text in name should match regexp whole string
    [Arguments]    ${locator}    ${ExpectMsg}    ${timeout}=${lo_general_timeout}
    Wait Mobile Until Element Visible    ${locator}
    ${RealMessage}    Get mobile attribute    ${locator}    name
    Log    ${RealMessage}
    Should Match Regexp    ${RealMessage}    ^${ExpectMsg}$
    [Teardown]

Mobile element name should match regexp ignore case sensitive
    [Arguments]    ${locator}    ${MessageExpect}    ${timeout}=${lo_general_timeout}
    Wait Mobile Until Element Visible    ${locator}    ${timeout}
    ${actual}=    Get mobile attribute    ${locator}    name
    Log    ${actual}
    Should Match Regexp    ${actual}    (?i)^${MessageExpect}$

Mobile element text should match regexp ignore case sensitive
    [Arguments]    ${locator}    ${MessageExpect}    ${timeout}=${lo_general_timeout}
    Wait Mobile Until Element Visible    ${locator}
    ${actual}    AppiumEx.Get Text    ${locator}
    Log    ${actual}
    Should Match Regexp    ${actual}    (?i)^${MessageExpect}$

Wait Mobile Until Element Visible
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    AppiumEx.Wait Until Element Is Visible    ${locator}    ${timeout}

Wait Mobile Until Page Does Not Contain Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    AppiumEx.Wait Until Page Does Not Contain Element    ${locator}    ${timeout}

Web Capture Screen At Verify Point
    [Arguments]    ${NameOfVerifyPoint}
    Sleep    2
    @{SplitCodeTestCase}    Split String    ${TEST_NAME}    ]
    Log    @{SplitCodeTestCase}[0]
    ${CodeTestCase}    Set Variable    @{SplitCodeTestCase}[0]
    ${result} =    Wait Until Keyword Succeeds    3x    1s    Selenium2Library.Capture Page Screenshot    screenshot-${NameOfVerifyPoint}-${CodeTestCase}]-${SUITE_NAME}-${Lang}-${ar_NType}.png
    Log    ${result}

Scroll Web To Element
    [Arguments]    ${locator}
    Wait Web Until Page Contains Element    ${locator}
    ${target}    Get Vertical Position    ${locator}
    ${width}    ${height}    Selenium2Library.Get Element Size    ${locator}
    ${element}    Evaluate    ${target}-150
    Run Keyword If    ${element}<0    Execute JavaScript    window.scrollTo(0, 0)
    ...    ELSE    Execute JavaScript    window.scrollTo(0, ${element})

Web check existing text
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Wait Web Until Page Contains Element    ${locator}
    ${RealMessage}    Selenium2Library.Get Text    ${locator}
    Should Match Regexp    ${RealMessage}    .+
    Log    ${RealMessage}

Mobile Element Is Exist
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Run Keyword If    "${ar_OS}"=="Android"    AppiumEx.Wait Until Element Is Visible    ${locator}    ${timeout}
    Run Keyword If    "${ar_OS}"=="iOS"    AppiumEx.Wait Until Page Contains Element    ${locator}    ${timeout}

Web Select Window
    [Arguments]    ${frame}    ${frameType}    ${timeout}=${lo_general_timeout}
    Wait Until Keyword Succeeds    3s    ${timeout}=${lo_general_timeout}    Select Frame    ${frameType}=${frame}

Web Mouse Over
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Page Contains Element    ${locator}    ${timeout}    Element is not visible on webpage
    Mouse Over    ${locator}

Get web attribute
    [Arguments]    ${locator}    ${attribute}    ${timeout}=${lo_general_timeout}
    [Documentation]    ${attribute} is key such as name, id
    ...
    ...    example
    ...
    ...    xpath=//div[@attribute="value"]
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}    Element is not visible on screen
    ${locator}=    Set Variable    ${locator}
    ${attribute}=    Set Variable    ${attribute}
    ${attValue}    Selenium2Library.Get Element Attribute    ${locator}@${attribute}
    [Return]    ${attValue}

Get Web Value
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Visible    ${locator}    ${timeout}    Element is not visible on screen
    ${value}    Get Value    ${locator}
    [Return]    ${value}

Wait Web Until Page Does Not Visible Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    Selenium2Library.Wait Until Element Is Not Visible    ${locator}    ${timeout}

Swipe to element
    [Arguments]    ${target}    ${Container}=screen    ${Direction}=up    ${ratio}=0.2    ${Round}=10    ${duration}=1000
    ...    ${swipe_range}=500    ${appium_info}="noinfo"
    Comment    Sleep    3
    Log    In swipe to element
    ${elementIsContain}    Run Keyword And Return Status    AppiumEx.Page Should Contain Element    ${target}
    Run Keyword If    ${ratio}>0.5 or ${ratio}<=0    fail    ratio are < 0 or > 0.5
    Comment    Run Keyword If    '${Container}' == 'screen' and '${elementIsContain}' == 'False'    swipe in screen to element    ${target}    ${Direction}    ${ratio}
    ...    ${Round}    ${duration}    ${appium_info}
    Run Keyword If    '${Container}' == 'screen' and '${elementIsContain}' == 'False'    swipe to element android test    ${target}    ${swipe_range}    ${Direction}    ${ratio}
    ...    ${Round}    ${duration}    ${appium_info}
    Run Keyword If    '${Container}' != 'screen' and '${elementIsContain}'== 'False'    swipe in container to element    ${target}    ${Container}    ${Direction}    ${ratio}
    ...    ${Round}    ${duration}    ${appium_info}
    Log    Out swipe to element

swipe in container to element
    [Arguments]    ${target}    ${Container}    ${Direction}=up    ${ratio}=0.2    ${Round}=10    ${duration}=500
    ...    ${appium_info}="noinfo"
    &{Location}    Get Element Location    ${Container}
    &{Size}    AppiumEx.Get Element Size    ${Container}
    ${x}    Get From Dictionary    ${Location}    x
    ${y}    Get From Dictionary    ${Location}    y
    ${width}    Get From Dictionary    ${Size}    width
    ${height}    Get From Dictionary    ${Size}    height
    ${x1}    Evaluate    ${x}+int(${width}*${ratio})
    ${y1}    Evaluate    ${y}+int(${height}*${ratio})
    ${x2}    Evaluate    ${x}+int(${width}*(1-${ratio}))
    ${y2}    Evaluate    ${y}+int(${height}*(1-${ratio}))
    @{listPosition}    Create List
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listPosition}    ${x1}    ${y2}    ${x1}
    ...    ${y1}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listPosition}    ${x1}    ${y1}    ${x1}
    ...    ${y2}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listPosition}    ${x2}    ${y1}    ${x1}
    ...    ${y1}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listPosition}    ${x1}    ${y1}    ${x2}
    ...    ${y1}
    : FOR    ${index}    IN RANGE    1    ${Round}
    \    ${elementIsContain}    Run Keyword And Return Status    AppiumEx.Page Should Contain Element    ${target}
    \    Run Keyword If    "${elementIsContain}"=="False"    Swipe    @{listPosition}[0]    @{listPosition}[1]    @{listPosition}[2]
    \    ...    @{listPosition}[3]
    \    Run Keyword If    "${elementIsContain}"=="True"    Exit For Loop
    Run Keyword If    "${elementIsContain}"=="False"    fail    cannot find element

swipe in screen to element
    [Arguments]    ${target}    ${Direction}=up    ${ratio}=0.2    ${Round}=10    ${duration}=500    ${appium_info}="noinfo"
    ${driver}=    Run Keyword If    ${appium_info}=="noinfo"    appium Get Driver Instance
    &{dict_size}    Run Keyword If    ${appium_info}=="noinfo"    Create Dictionary    &{driver.get_window_size()}
    ...    ELSE    Create Dictionary    &{appium_info.driver.get_window_size()}
    ${size}=    Get Dictionary Values    ${dict_size}
    ${x}=    Set Variable    @{size}[1]
    ${y}=    Set Variable    @{size}[0]
    ${less_x}=    Evaluate    int(${x}*${ratio})
    ${less_y}=    Evaluate    int(${y}*${ratio})
    ${more_x}=    Evaluate    int(${x}*(1-${ratio}))
    ${more_y}=    Evaluate    int(${y}*(1-${ratio}))
    @{listEndPosition}    Create List
    ${start_x}    ${start_y}=    set start point    ${Direction}    ${less_x}    ${more_x}    ${less_y}
    ...    ${more_y}
    log    ${Direction}
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listEndPosition}    ${start_x}    ${less_y}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listEndPosition}    ${start_x}    ${more_y}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listEndPosition}    ${less_x}    ${start_y}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listEndPosition}    ${more_x}    ${start_y}
    log    @{listEndPosition}[0]
    log    @{listEndPosition}[1]
    Comment    sleep    1
    : FOR    ${index}    IN RANGE    1    ${Round}
    \    ${elementIsContain}    Run Keyword And Return Status    AppiumEx.Page Should Contain Element    ${target}
    \    Run Keyword If    "${elementIsContain}"=="False"    Swipe    ${start_x}    ${start_y}    @{listEndPosition}[0]
    \    ...    @{listEndPosition}[1]
    \    Exit For Loop If    "${elementIsContain}"=="True"
    Run Keyword If    "${elementIsContain}"=="False"    fail    cannot find element

set start point
    [Arguments]    ${Direction}    ${less_x}    ${more_x}    ${less_y}    ${more_y}
    ${start_x}=    Set Variable If    "${Direction}" == "up"    ${less_x}
    ${start_y}=    Set Variable If    "${Direction}" == "up"    ${more_y}
    ${start_x}    Set Variable If    "${Direction}" == "down"    ${less_x}    ${start_x}
    ${start_y}=    Set Variable If    "${Direction}" == "down"    ${less_y}    ${start_y}
    ${start_x}=    Set Variable If    "${Direction}" == "left"    ${more_x}    ${start_x}
    ${start_y}=    Set Variable If    "${Direction}" == "left"    ${more_y}    ${start_y}
    ${start_x}=    Set Variable If    "${Direction}" == "right"    ${less_x}    ${start_x}
    ${start_y}=    Set Variable If    "${Direction}" == "right"    ${more_y}    ${start_y}
    [Return]    ${start_x}    ${start_y}

swipe in screen out from element
    [Arguments]    ${target}    ${Direction}=up    ${ratio}=0.2    ${Round}=10    ${duration}=500    ${appium_info}="noinfo"
    ${driver}=    Run Keyword If    ${appium_info}=="noinfo"    appium Get Driver Instance
    &{dict_size}    Run Keyword If    ${appium_info}=="noinfo"    Create Dictionary    &{driver.get_window_size()}
    ...    ELSE    Create Dictionary    &{appium_info.driver.get_window_size()}
    ${size}=    Get Dictionary Values    ${dict_size}
    ${x}=    Set Variable    @{size}[1]
    ${y}=    Set Variable    @{size}[0]
    ${less_x}=    Evaluate    int(${x}*${ratio})
    ${less_y}=    Evaluate    int(${y}*${ratio})
    ${more_x}=    Evaluate    int(${x}*(1-${ratio}))
    ${more_y}=    Evaluate    int(${y}*(1-${ratio}))
    @{listEndPosition}    Create List
    ${start_x}    ${start_y}=    set start point    ${Direction}    ${less_x}    ${more_x}    ${less_y}
    ...    ${more_y}
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listEndPosition}    ${start_x}    ${less_y}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listEndPosition}    ${start_x}    ${more_y}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listEndPosition}    ${less_x}    ${start_y}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listEndPosition}    ${more_x}    ${start_y}
    : FOR    ${index}    IN RANGE    1    ${Round}
    \    ${elementIsContain}    Run Keyword And Return Status    AppiumEx.Page Should Not Contain Element    ${target}
    \    Run Keyword If    "${elementIsContain}"=="False"    Swipe    ${start_x}    ${start_y}    @{listEndPosition}[0]
    \    ...    @{listEndPosition}[1]
    \    Exit For Loop If    "${elementIsContain}"=="True"
    Run Keyword If    "${elementIsContain}"=="False"    fail

swipe in container out from element
    [Arguments]    ${appium_info}    ${target}    ${Container}    ${Direction}=up    ${ratio}=0.2    ${Round}=10
    ...    ${duration}=500
    &{Location}    Get Element Location    ${Container}
    &{Size}    AppiumEx.Get Element Size    ${Container}
    ${x}    Get From Dictionary    ${Location}    x
    ${y}    Get From Dictionary    ${Location}    y
    ${width}    Get From Dictionary    ${Size}    width
    ${height}    Get From Dictionary    ${Size}    height
    ${x1}    Evaluate    ${x}+int(${width}*${ratio})
    ${y1}    Evaluate    ${y}+int(${height}*${ratio})
    ${x2}    Evaluate    ${x}+int(${width}*(1-${ratio}))
    ${y2}    Evaluate    ${y}+int(${height}*(1-${ratio}))
    @{listPosition}    Create List
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listPosition}    ${x1}    ${y2}    ${x1}
    ...    ${y1}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listPosition}    ${x1}    ${y1}    ${x1}
    ...    ${y2}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listPosition}    ${x2}    ${y1}    ${x1}
    ...    ${y1}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listPosition}    ${x1}    ${y1}    ${x2}
    ...    ${y1}
    : FOR    ${index}    IN RANGE    1    ${Round}
    \    ${elementIsContain}    Run Keyword And Return Status    AppiumEx.Page Should Not Contain Element    ${target}
    \    Run Keyword If    "${elementIsContain}"=="False"    Swipe    @{listPosition}[0]    @{listPosition}[1]    @{listPosition}[2]
    \    ...    @{listPosition}[3]
    \    Run Keyword If    "${elementIsContain}"=="True"    Exit For Loop
    Run Keyword If    "${elementIsContain}"=="False"    fail

Swipe out from element
    [Arguments]    ${appium_info}    ${target}    ${Container}=screen    ${Direction}=up    ${ratio}=0.2    ${Round}=10
    ...    ${duration}=1000
    Log    In swipe to element
    Run Keyword If    ${ratio}>0.5 or ${ratio}<=0    fail
    Run Keyword If    '${Container}' == 'screen'    swipe in screen out from element    ${appium_info}    ${target}    ${Direction}    ${ratio}
    ...    ${Round}    ${duration}
    Run Keyword If    '${Container}' != 'screen'    swipe in container out from element    ${appium_info}    ${target}    ${Container}    ${Direction}
    ...    ${ratio}    ${Round}    ${duration}
    Log    Out swipe to element

Swipe To
    [Arguments]    ${target}="no_target"    ${Direction}=up    ${ratio}=0.3    ${Round}=10    ${appium_info}="noinfo"
    [Documentation]    Swipe to locator if that locator appear in UI but not in screen
    ...
    ...
    ...    target is locator that need to show in screen
    ${driver}=    Run Keyword If    ${appium_info}=="noinfo"    appium Get Driver Instance
    &{dict_size}    Run Keyword If    ${appium_info}=="noinfo"    Create Dictionary    &{driver.get_window_size()}
    ...    ELSE    Create Dictionary    &{appium_info.driver.get_window_size()}
    ${size}=    Get Dictionary Values    ${dict_size}
    ${x}=    Set Variable    @{size}[1]
    ${y}=    Set Variable    @{size}[0]
    ${less_x}=    Evaluate    int(${x}*${ratio})
    ${less_y}=    Evaluate    int(${y}*${ratio})
    ${more_x}=    Evaluate    int(${x}*(1-${ratio}))
    ${more_y}=    Evaluate    int(${y}*(1-${ratio}))
    @{listEndPosition}    Create List
    ${start_x}    ${start_y}=    set start point    ${Direction}    ${less_x}    ${more_x}    ${less_y}
    ...    ${more_y}
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listEndPosition}    ${start_x}    ${less_y}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listEndPosition}    ${start_x}    ${more_y}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listEndPosition}    ${less_x}    ${start_y}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listEndPosition}    ${more_x}    ${start_y}
    Run Keyword If    "${target}" != "no_target"    swipe to target    ${target}    ${Round}    ${start_x}    ${start_y}
    ...    ${listEndPosition}
    Run Keyword If    "${target}" == "no_target"    swipe without target    ${Round}    ${start_x}    ${start_y}    ${listEndPosition}

Swipe Element To Screen
    [Arguments]    ${target}    ${Container}=screen    ${Direction}=up    ${ratio}=0.2    ${Round}=10    ${appium_info}="noinfo"
    [Documentation]    Swipe to locator and show on screen.
    ...
    ...    Target no need to show on the screen.
    ...
    ...    EX:${target} | screen |up |0.2 | 10 | "noinfo"
    ...
    ...    up / down / left / right
    ${driver}=    Run Keyword If    ${appium_info}=="noinfo"    appium Get Driver Instance
    &{dict_size}    Run Keyword If    ${appium_info}=="noinfo"    Create Dictionary    &{driver.get_window_size()}
    ...    ELSE    Create Dictionary    &{appium_info.driver.get_window_size()}
    ${size}=    Get Dictionary Values    ${dict_size}
    ${x}=    Set Variable    @{size}[1]
    ${y}=    Set Variable    @{size}[0]
    ${less_x}=    Evaluate    int((${x}*${ratio})/2)
    ${less_y}=    Evaluate    int(${y}*${ratio})
    ${more_x}=    Evaluate    int((${x}*(1-${ratio}))/2)
    ${more_y}=    Evaluate    int(${y}*(1-${ratio}))
    ${CheckTarget}    Run Keyword And Return Status    Wait Mobile Until Element Visible    ${target}    5
    ${status}    Run keyword if    "${CheckTarget}"=="False"    Run Keyword And Return Status    Swipe to element    ${target}    ${Container}
    ...    ${Direction}    0.25    ${Round}
    ${status}    Run Keyword If    "${CheckTarget}"=="True"    Set Variable    True
    ...    ELSE    Set Variable    ${status}
    Log    ${status}
    ${start_x}    ${start_y}=    Run Keyword If    "${status}"=="True"    set start point of element to area    ${target}    ${Direction}
    @{listEndPosition}    Create List
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listEndPosition}    ${start_x}    ${less_y}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listEndPosition}    ${start_x}    ${more_y}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listEndPosition}    ${less_x}    ${start_y}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listEndPosition}    ${more_x}    ${start_y}
    Run Keyword If    "${status}"=="True"    Swipe    ${start_x}    ${start_y}    @{listEndPosition}[0]    @{listEndPosition}[1]
    Log    ${status}
    Wait Mobile Until Element Visible    ${target}    5

set start point of element to area
    [Arguments]    ${target}    ${Direction}
    &{element_Size}=    AppiumEx.Get Element Size    ${target}
    ${width}    Get From Dictionary    ${element_Size}    width
    ${height}    Get From Dictionary    ${element_Size}    height
    &{Location}    Get Element Location    ${target}
    ${rank_x_of_top_element}    Get From Dictionary    ${Location}    x
    ${rank_y_of_top_element}    Get From Dictionary    ${Location}    y
    ${Center}    Evaluate    ${rank_x_of_top_element}+(${width}/2)
    ${y_down}    Evaluate    int(${rank_y_of_top_element}+${height})
    ${x_right}    Evaluate    int(${rank_x_of_top_element}+${width})
    Comment    ${start_x}=    Set Variable If    "${Direction}" == "up"    ${rank_x_of_top_element}
    ${start_x}=    Set Variable If    "${Direction}" == "up"    ${Center}
    ${start_y}=    Set Variable If    "${Direction}" == "up"    ${rank_y_of_top_element}
    Comment    ${start_x}=    Set Variable If    "${Direction}" == "down"    ${rank_x_of_top_element}
    ${start_x}=    Set Variable If    "${Direction}" == "down"    ${Center}    ${start_x}
    ${start_y}=    Set Variable If    "${Direction}" == "down"    ${y_down}    ${start_y}
    ${start_x}=    Set Variable If    "${Direction}" == "left"    ${rank_x_of_top_element}    ${start_x}
    ${start_y}=    Set Variable If    "${Direction}" == "left"    ${rank_y_of_top_element}    ${start_y}
    ${start_x}=    Set Variable If    "${Direction}" == "right"    ${x_right}    ${start_x}
    ${start_y}=    Set Variable If    "${Direction}" == "right"    ${rank_y_of_top_element}    ${start_y}
    [Return]    ${start_x}    ${start_y}

swipe in container to element by wait until visible N time
    [Arguments]    ${target}    ${Container}    ${Round}=10    ${Direction}=up    ${ratio}=0.2    ${duration}=500
    ...    ${appium_info}="noinfo"
    [Documentation]    swipe N time and wait until that element visible
    ...
    ...
    ...    must input time to swipe
    &{Location}    Get Element Location    ${Container}
    &{Size}    AppiumEx.Get Element Size    ${Container}
    ${x}    Get From Dictionary    ${Location}    x
    ${y}    Get From Dictionary    ${Location}    y
    ${width}    Get From Dictionary    ${Size}    width
    ${height}    Get From Dictionary    ${Size}    height
    ${x1}    Evaluate    ${x}+int(${width}*${ratio})
    ${y1}    Evaluate    ${y}+int(${height}*${ratio})
    ${x2}    Evaluate    ${x}+int(${width}*(1-${ratio}))
    ${y2}    Evaluate    ${y}+int(${height}*(1-${ratio}))
    @{listPosition}    Create List
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listPosition}    ${x1}    ${y2}    ${x1}
    ...    ${y1}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listPosition}    ${x1}    ${y1}    ${x1}
    ...    ${y2}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listPosition}    ${x2}    ${y1}    ${x1}
    ...    ${y1}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listPosition}    ${x1}    ${y1}    ${x2}
    ...    ${y1}
    : FOR    ${index}    IN RANGE    0    ${Round}
    \    Run Keyword If    "${index}"!="${Round}"    Swipe    @{listPosition}[0]    @{listPosition}[1]    @{listPosition}[2]
    \    ...    @{listPosition}[3]
    \    Run Keyword If    "${index}"=="${Round}"    Exit For Loop
    \    sleep    0.5s
    ${elementIsContain}    Run Keyword And Return Status    Wait Mobile Until Element Visible    ${target}
    Run Keyword If    "${elementIsContain}"=="False"    fail    cannot find element

Swipe element to specific area
    [Arguments]    ${target}    ${Ratio_margin_up}=0    ${Ratio_margin_down}=0    ${Ratio_margin_left}=0    ${Ratio_margin_right}=0    ${Direction}=up
    ...    ${ratio}=0.25    ${Round}=10    ${appium_info}="noinfo"
    [Documentation]    Make sure that target element appear on \ page
    ...
    ...    default \ margin is full screen[0,0,0,0] if you need any area you must to input margin any side
    ...
    ...    **Important**
    ...
    ...    Make sure swipe ratio is relation with border that input
    ...
    ...    margin can input in range 0-1 and swipe ratio can input >0 but <0.5
    Run Keyword If    ${ratio}>0.5 or ${ratio}<=0    fail    ratio > 0.5 or <0
    Run Keyword If    ${Ratio_margin_up} >0.5 or ${Ratio_margin_up} <0    fail    margin_up >0.5 or <0
    Run Keyword If    ${Ratio_margin_down} >0.5 or ${Ratio_margin_down} <0    fail    margin_down >0.5 or <0
    Run Keyword If    ${Ratio_margin_left} >0.5 or ${Ratio_margin_left} <0    fail    margin_left >0.5 or <0
    Run Keyword If    ${Ratio_margin_right} >0.5 or ${Ratio_margin_right} <0    fail    margin_right >0.5 or <0
    ${driver}=    Run Keyword If    ${appium_info}=="noinfo"    appium Get Driver Instance
    &{dict_size}    Run Keyword If    ${appium_info}=="noinfo"    Create Dictionary    &{driver.get_window_size()}
    ...    ELSE    Create Dictionary    &{appium_info.driver.get_window_size()}
    ${size}=    Get Dictionary Values    ${dict_size}
    ${x}=    Set Variable    @{size}[1]
    ${y}=    Set Variable    @{size}[0]
    ${less_x}=    Evaluate    int(${x}*${ratio})
    ${less_y}=    Evaluate    int(${y}*${ratio})
    ${more_x}=    Evaluate    int(${x}*(1-${ratio}))
    ${more_y}=    Evaluate    int(${y}*(1-${ratio}))
    ${border_up}=    Evaluate    int(${y}*${Ratio_margin_up})
    ${border_down}=    Evaluate    int(${y}*(1-${Ratio_margin_down}))
    ${border_left}=    Evaluate    int(${x}*${Ratio_margin_left})
    ${border_right}=    Evaluate    int(${x}*(1-${Ratio_margin_right}))
    @{listEndPosition}    Create List
    ${start_x}    ${start_y}=    set start point    ${Direction}    ${less_x}    ${more_x}    ${less_y}
    ...    ${more_y}
    Run Keyword If    "${Direction}" == "up"    Append To List    ${listEndPosition}    ${start_x}    ${less_y}
    Run Keyword If    "${Direction}" == "down"    Append To List    ${listEndPosition}    ${start_x}    ${more_y}
    Run Keyword If    "${Direction}" == "left"    Append To List    ${listEndPosition}    ${less_x}    ${start_y}
    Run Keyword If    "${Direction}" == "right"    Append To List    ${listEndPosition}    ${more_x}    ${start_y}
    : FOR    ${index}    IN RANGE    1    ${Round}
    \    ${elementIsContain}    Run Keyword And Return Status    Wait Mobile Until Page Contains Element    ${target}    1s
    \    Run Keyword If    "${elementIsContain}"=="False"    fail    Cannot found Element
    \    ${location}=    Get Element Location    ${target}
    \    ${sizeTarget}=    AppiumEx.Get Element Size    ${target}
    \    ${height}=    Get From Dictionary    ${sizeTarget}    height
    \    ${location_y}=    Get From Dictionary    ${location}    y
    \    ${location_x}=    Get From Dictionary    ${location}    x
    \    Run Keyword If    ${border_up}<=${location_y}<=${border_down} and ${border_left}<=${location_x}<=${border_right} and ${height} >0    Exit For Loop
    \    ...    ELSE    Swipe    ${start_x}    ${start_y}    @{listEndPosition}[0]
    \    ...    @{listEndPosition}[1]

swipe to target
    [Arguments]    ${target}    ${Round}    ${start_x}    ${start_y}    ${listEndPosition}
    : FOR    ${index}    IN RANGE    1    ${Round}
    \    AppiumEx.Wait Until Page Contains Element    ${target}    5
    \    ${elementIsContain}    Run Keyword And Return Status    AppiumEx.Wait Until Page Contains Element    ${target}    5
    \    Run Keyword If    "${elementIsContain}"=="False"    fail
    \    ${element_Size}=    AppiumEx.Get Element Size    ${target}
    \    ${height}    Get From Dictionary    ${element_Size}    height
    \    Run Keyword If    "${height}"<="0"    Swipe    ${start_x}    ${start_y}    @{listEndPosition}[0]
    \    ...    @{listEndPosition}[1]
    \    Exit For Loop If    "${height}">"0"

swipe without target
    [Arguments]    ${round}    ${start_x}    ${start_y}    ${list_end_position}
    : FOR    ${index}    IN RANGE    0    ${round}
    \    Swipe    ${start_x}    ${start_y}    @{list_end_position}[0]    @{list_end_position}[1]

swipe to element android test
    [Arguments]    ${target}    ${swipe_range}    ${Direction}=up    ${ratio}=0.2    ${Round}=10    ${duration}=500
    ...    ${appium_info}="noinfo"
    ${driver}=    Run Keyword If    ${appium_info}=="noinfo"    appium Get Driver Instance
    &{dict_size}    Run Keyword If    ${appium_info}=="noinfo"    Create Dictionary    &{driver.get_window_size()}
    ...    ELSE    Create Dictionary    &{appium_info.driver.get_window_size()}
    ${size}=    Get Dictionary Values    ${dict_size}
    ${screen_width}=    Set Variable    @{size}[1]
    ${screen_height}=    Set Variable    @{size}[0]
    ${screen_center_x}    Evaluate    ${screen_width}/2
    ${screen_center_y}    Evaluate    ${screen_height}/2
    ${top_screen}    Evaluate    ${screen_height}*${ratio}
    ${below_screen}    Evaluate    ${screen_height}-(${screen_height}*${ratio})
    ${right_screen}    Evaluate    ${screen_width}-(${screen_width}*${ratio})
    ${left_screen}    Evaluate    ${screen_width}*${ratio}
    ${swipe_to_top}    Evaluate    ${below_screen}-${swipe_range}
    ${swipe_to_below}    Evaluate    ${top_screen}+${swipe_range}
    ${swipe_to_left}    Evaluate    ${right_screen}-${swipe_range}
    ${swipe_to_right}    Evaluate    ${left_screen}+${swipe_range}
    : FOR    ${index}    IN RANGE    1    ${Round}
    \    Run Keyword If    '${Direction}'=='up'    Swipe    ${screen_center_x}    ${below_screen}    ${screen_center_x}
    \    ...    ${swipe_to_top}    ${duration}
    \    ...    ELSE IF    '${Direction}'=='below'    Swipe    ${screen_center_x}    ${top_screen}
    \    ...    ${screen_center_x}    ${swipe_to_below}    ${duration}
    \    ...    ELSE IF    '${Direction}'=='left'    Swipe    ${right_screen}    ${screen_center_y}
    \    ...    ${swipe_to_left}    ${screen_center_y}    ${duration}
    \    ...    ELSE IF    '${Direction}'=='right'    Swipe    ${left_screen}    ${screen_center_y}
    \    ...    ${swipe_to_right}    ${screen_center_y}    ${duration}
    \    ${foundTarget}    Run Keyword And Return Status    Wait Mobile Until Element Visible    ${target}    1
    \    Exit For Loop If    '${foundTarget}'=='True'
    Run Keyword If    '${foundTarget}'=='False'    FAIL    This element is not found.

Mobile Page Should Contain Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    AppiumEx.Page Should Contain Element    ${locator}    ${timeout}

Mobile Page Should Not Contain Element
    [Arguments]    ${locator}    ${timeout}=${lo_general_timeout}
    AppiumEx.Page Should Not Contain Element    ${locator}    ${timeout}

    
