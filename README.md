# Nexora Active Directory Red Team Lab

## 📌 Overview
This repository contains the lab build artifacts, evidence, and final penetration test report for the Nexora Systems Active Directory Red Team Simulation Lab. 

The objective of this project was to build an isolated Active Directory environment from scratch on consumer hardware (8GB RAM) and execute three independent, end-to-end attack paths to achieve full Domain Admin compromise.

## 🎯 Attack Paths Executed
*   **Path A (Credential Exposure):** Discovered cleartext administrative credentials inside a world-readable SMB share (`\\DC01\IT\deployment_config.txt`) and used them to gain a shell as Domain Admin.
*   **Path B (Kerberoasting):** Enumerated an account with a registered SPN (`svc_sql`), requested a Kerberos TGS ticket, and cracked the hash offline using John the Ripper.
*   **Path C (ACL Abuse):** Utilized BloodHound to identify that the `acluser` account had `GenericAll` permissions over the `Domain Admins` group. Abused this misconfiguration to escalate privileges.

## 🛠️ Tools & Technologies Used
*   **Virtualization:** Oracle VirtualBox
*   **Target:** Windows Server 2016 (Server Core), Active Directory Domain Services (AD DS)
*   **Attacker:** Kali Linux
*   **Offensive Tooling:** Impacket (wmiexec, GetUserSPNs, GetADUsers), BloodHound (SharpHound), John the Ripper, smbclient

## 📂 Repository Structure
*   `/Evidence` - Contains screenshots proving the successful execution of all three paths.
*   `/bh-data` - Contains the BloodHound JSON data collected during the engagement.
*   `Nexora_Pentest_Report.pdf` - The final, professional penetration test report detailing findings, business impact, MITRE ATT&CK mapping, and remediation strategies.

## 📄 Deliverables
*   [**View the Final Penetration Test Report**](Nexora_Pentest_Report.pdf)# Nexora Active Directory Red Team Lab 
