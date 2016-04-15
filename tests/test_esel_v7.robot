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
   ...               oem partial add command. It simulates sending partial add command with
   ...               wrong Reservation ID which is "0 0". BMC will reject it.
   
    ${rev_id_1} =    Run IPMI Command Returned   0x0a 0x42
    @{rev_id_list}    create list     ${rev_id_1}
    ${rev_id_ls} =     Convert to Integer    ${rev_id_list[0]}    16
    ${rev_id_ms} =     Convert to Integer    ${rev_id_list[1]}    16
    Run IPMI command   0x0a 0x42
    ${output} =    Check IPMI Oempartialadd Reject   0x32 0xf0 ${rev_id_ls} ${rev_id_ms} 0 0 0 0 0 1 2 3 4 5 6 7 8 9 0xa 0xb 0xc 0xd 0xe 0xf
    Should Contain   ${output}   Reservation cancelled

Test Correct Reservation_ID
   [Documentation]   This testcase is to test BMC can handle multi-requestor's
   ...               oem partial add command. It simulates sending partial add command with
   ...               wrong Reservation ID which is "0 0". BMC will reject it.
   
    Run IPMI command   0x0a 0x42
    ${rev_id_2} =    Run IPMI Command Returned   0x0a 0x42
    @{rev_id_list}    create list     ${rev_id_2}
    ${rev_id_ls} =     Convert to Integer    ${rev_id_list[0]}    16
    ${rev_id_ms} =     Convert to Integer    ${rev_id_list[1]}    16
    ${output} =    Check IPMI Oempartialadd Accept   0x32 0xf0 ${rev_id_ls} ${rev_id_ms} 0 0 0 0 0 1 2 3 4 5 6 7 8 9 0xa 0xb 0xc 0xd 0xe 0xf
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

