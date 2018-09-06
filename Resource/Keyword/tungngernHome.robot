*** setting ***
Library      Selenium2Library
Resource    /Users/tr.inpha/Documents/Robot/Resource/Repository/GoogleTest_repo.robot

*** keyword ***
Open Browser Google
    open browser   ${URLGoogle}    gc
    Maximize Browser Window

Verify Page
    Wait Until Element Is Visible    ${imgLogoGoogle}    60

Input Text Search
    input text    //*[@id="lst-ib"]    นมโต
    Press Key    //*[@id="lst-ib"]     \\13
    Click Element    ${btnImgsearch}
    Wait Until Element Is Visible     //*[@id="qbi"]
    Capture Page Screenshot    googlelogo.png

