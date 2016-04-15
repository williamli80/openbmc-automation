*** Settings ***

Documentation   This suite is for testing esel's mechanism of checking Reservation_ID.

Resource        ../lib/rest_client.robot
Resource        ../lib/ipmi_client.robot

Suite Setup            Open Connection And Log In
Suite Teardown  Close All Connections

*** Variables ***

${IPMID_RESTART_INTERVAL}    10s

*** Test Cases ***

Test Wrong Reservation_ID
   [Documentation]   This testcase is to test BMC can handle multi-requestor's
   ...               oem partial add command with incorrect reservation id. 
   ...               It simulates sending partial add command with fake content
   ...                and wrong Reservation ID. This command will be rejected.
   
    ${rev_id_1} =    Run IPMI Command Returned   0x0a 0x42
    Run IPMI command   0x0a 0x42
    ${output} =      Check IPMI Oempartialadd Reject   0x32 0xf0 ${rev_id_1} 0 0 0 0 0 1 2 3 4 5 6 7 8 9 0xa 0xb 0xc 0xd 0xe 0xf
    Should Contain   ${output}   Reservation cancelled

Test Correct Reservation_ID
   [Documentation]   This testcase is to test BMC can handle multi-requestor's
   ...               oem partial add command with correct reservation id. It 
   ...               simulates sending partial add command with fake content
   ...               and correct Reservation ID. This command will be accepted.
   
    Run IPMI command   0x0a 0x42
    ${rev_id_2} =    Run IPMI Command Returned   0x0a 0x42
    ${output} =      Check IPMI Oempartialadd Accept   0x32 0xf0 ${rev_id_2} 0 0 0 0 0 1 2 3 4 5 6 7 8 9 0xa 0xb 0xc 0xd 0xe 0xf
    Should Be Empty    ${output}

*** Keywords ***

Run IPMI Command Returned
    [arguments]    ${args}
    ${output_1} =    Execute Command    /tmp/ipmitool -I dbus raw ${args}
    [return]    ${output_1}

Check IPMI Oempartialadd Reject
    [arguments]    ${args}
    ${stdout}    ${stderr}    ${output_2}=  Execute Command    /tmp/ipmitool -I dbus raw ${args}    return_stdout=True    return_stderr= True    return_rc=True
    [return]    ${stderr}

Check IPMI Oempartialadd Accept
    [arguments]    ${args}
    ${stdout}    ${stderr}    ${output_3} =    Execute Command    /tmp/ipmitool -I dbus raw ${args}    return_stdout=True    return_stderr= True    return_rc=True
    Should Be Equal    ${output_3}    ${0}    msg=${stderr}
    [return]    ${stderr}

response Should Be Equal
    [arguments]    ${args}
    Should Be Equal    ${OUTPUT}    ${args}

