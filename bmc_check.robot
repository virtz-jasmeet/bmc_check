*** Settings ***
Documentation                  Validate iDRAC/BMC for Hardware configuration
Library                        SSHLibrary
Suite Teardown                 Close All Connections


*** Variables ***
#@{ALLHOSTSBMC}=        10.189.153.21  10.189.153.22  10.189.153.23  10.189.153.24  10.189.153.25  10.189.153.26  10.189.153.27
@{ALLHOSTSBMC}=        10.189.153.21  10.189.153.22  10.189.153.23  10.189.153.24  10.189.153.26  10.189.153.27
@{CONTROLLERSBMC}=     10.189.153.21  10.189.153.22  10.189.153.23
@{COMPUTESBMC}=        10.189.153.24  10.189.153.25  10.189.153.26  10.189.153.27
#@{ALLHOSTS}=           10.189.153.69  10.189.153.70  10.189.153.71  10.189.153.72  10.189.153.73  10.189.153.74  10.189.153.75
@{ALLHOSTS}=           10.189.153.69  10.189.153.70  10.189.153.71  10.189.153.72  10.189.153.74  10.189.153.75
@{CONTROLLERS}=        10.189.153.69  10.189.153.70  10.189.153.71
@{COMPUTES}=           10.189.153.72  10.189.153.73  10.189.153.74  10.189.153.75
${USERNAME}            admin
${PASSWORD}            ADMIN
${ROOTUSERNAME}            root
${ROOTPASSWORD}            STRANGE-EXAMPLE-neither

*** Test Cases ***
Validate if Vitualization/VTD is Enabled
    [Documentation]			Validate if Vitualization/VTD is Enabled
    FOR  ${HOST}  IN  @{ALLHOSTSBMC}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  racadm get Bios.ProcSettings.ProcVirtualization
        Run Keyword And Continue On Failure     should contain    ${output}    Enabled
        close connection
    END

Validate if Hyperthreading is Enabled
    [Documentation]			Validate if Hyperthreading is Enabled
    FOR  ${HOST}  IN  @{ALLHOSTSBMC}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  racadm get Bios.ProcSettings.LogicalProc
        Run Keyword And Continue On Failure     should contain    ${output}    Enabled
        close connection
    END

Validate if SataMode is AHCI
    [Documentation]			Validate if SataMode is AHCI
    FOR  ${HOST}  IN  @{ALLHOSTSBMC}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  racadm get bios.SataSettings.EmbSata
        Run Keyword And Continue On Failure     should contain    ${output}    AhciMode
        close connection
    END

Validate if BootMode is Legacy/BIOS
    [Documentation]			Validate if BootMode is Legacy/BIOS
    FOR  ${HOST}  IN  @{ALLHOSTSBMC}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  racadm get bios.BiosBootSettings.BootMode
        Run Keyword And Continue On Failure     should contain    ${output}    BootMode=Bios
        close connection
    END

Check if Virtual Disks are present
    [Documentation]			Check if Virtual Disks are present
    FOR  ${HOST}  IN  @{ALLHOSTSBMC}
        open connection         ${HOST}
        login                   ${USERNAME}  ${PASSWORD}  False  True
        ${output}=              execute command  racadm storage get vdisks
        Run Keyword And Continue On Failure     Should Not Contain    ${output}    No virtual disks
        close connection
    END

Validate if PXE is enabled on NIC
    [Documentation]                     Validate if PXE is enabled on NIC
    FOR  ${SRV}  IN  @{ALLHOSTS}
        open connection         ${SRV}
        login                   ${ROOTUSERNAME}  ${ROOTPASSWORD}  False  True
        Put File                nic_pxe.sh  /root  mode=0750
        SSHLibrary.File Should Exist   /root/nic_pxe.sh
        execute command         /bin/bash /root/nic_pxe.sh | grep -i LegacyBootProto > /root/nic_output
        ${output}=              execute command  cat /root/nic_output | grep PXE | sort | uniq
        Should Be Equal         ${output}    LegacyBootProto=PXE
        execute command         rm -f /root/nic_pxe.sh /root/nic_output
        close connection
    END

*** Keywords ***

