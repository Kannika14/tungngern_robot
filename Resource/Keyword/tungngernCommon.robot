*** Settings ***
Resource          ../../KeywordRedefine/KeywordCommon/PageKeyword/KeywordCommon.robot

*** Keywords ***
Open Tunggern
    [Arguments]    ${remoteUrl}    ${platformName}    ${platformVersion}    ${udid}   ${noReset} 
    Open Application Android    ${remoteUrl}    ${platformName}   ${platformVersion}    ${udid}     com.ktb.merchant.tungngern    com.ktb.merchant.tungngern.views.splashscreen.SplashActivity    ${noReset}