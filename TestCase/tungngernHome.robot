*** Settings ***
Resource    ../Resource/Keyword/tungngernCommon.robot
Resource    ../Config/LocalConfig.txt

*** Test Case ***
Test Tungngern
    [Tags]    demo
    Open Tunggern    ${lo_IPAppium}    ${lo_PlatformName}    ${lo_PlatformVersion}    ${lo_SerialNumber}    ${lo_NoReset}
    [Teardown]    Close Application



