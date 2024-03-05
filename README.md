<a name="readme-top"></a>


<!-- PROJECT SHIELDS -->
<!--
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
<!-- [![Golang][golang-shield]][golang-url] -->
![](https://img.shields.io/badge/Code-PowerShell-informational?style=flat&logo=PowerShell&logoColor=white&color=2bbc8a) 
![](https://img.shields.io/badge/Cloud-MicrosoftAzure-informational?style=flat&logo=MicrosoftAzure&logoColor=white&color=2bbc8a) 
[![Issues][issues-shield]][issues-url]
[![MIT][license-shield]][license-url] 
[![paulmuenzner github][github-shield]][github-url] 
[![Contributors][contributors-shield]][contributors-url]
[![paulmuenzner.com][website-shield]][website-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts">
    <img src="public/logo.png" alt="Logo" width="128" height="128">
  </a>

  <h3 align="center">Azure Powershell Scripts</h3>

  <p align="center">
    VMSS - WebApp - Azure AD
    <br />
    <a href="#about-the-project"><strong>EXPLORE DOCS</strong></a>
    <br />
    <br />
    <a href="#settings">Automation</a>
    ·
    <a href="https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts/issues">Report Bug</a>
    ·
    <a href="https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts/issues">Request Feature</a>
  </p>
</div>


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li><a href="#about-the-project">About The Project</a></li>
    <li><a href="#scripts">Scripts</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

Embark on an inspired Azure journey with this collection of meticulously crafted PowerShell scripts, developed during my free time with passion and dedication. Designed to make life easier, these scripts draw from real-world experiences, offering practical solutions to streamline and optimize your Azure resource management and deployment processes.


## Scripts

-   **Azure-Create-Secure-AzureAD-User**: Creates a user in Azure Active Directory (Azure AD) with comprehensive error handling and security considerations.

-   **Azure-Create-VM-Scale-Set**: Creates a virtual machine scale set with Ubuntu Server in Azure, utilizing a custom script extension stored in a container. Managed identity is enabled for the VMs, and network security groups are configured for SSH access from a specific IP and HTTP traffic.

-   **Azure-Create-WebApp-With-GitHub-Deployment**: Deploys an Azure Web App with GitHub integration.

-   **Azure-Custom-Script-Extension-Scale-Set**: Retrieves a secret from Azure Key Vault using managed identity and configures SSH to use it for GitHub deployments.

-   **Azure-Delete-Empty-Storage-Containers-AAD**: Deletes empty containers from a storage account protected with Azure Active Directory (AAD).

-   **Azure-Get-Storage-Container-TotalSize**: This PowerShell script calculates the total size of all blobs within a specified Azure storage container.

-   **Azure-Get-Vmss-InstancesIPs**: Lists IP addresses of all instances in an Azure VM scale set within a virtual network behind a load balancer.

-   **Azure-Provision-Daily-Containers-Past-Year**: Creates a storage account with system-assigned managed identity and a container for each day in the last year from today.

-   **Azure-Scan-Vmss-Ports-To-CSV**: Scans ports 1-1000 of a specified VM and writes open ports to a CSV file within an Azure storage container.

-   **Azure-Vmss-Add-Autoscale-Rule**: Configures a Windows VM Scale Set in Azure to use custom autoscale with a scaling rule based on CPU utilization.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- ROADMAP -->
## Roadmap
Adding Scripts for
-   ✅ Managing Storage Accounts
-   ✅ Handling WebApp
-   ⬜️ VM Software Installation and Updates
-   ⬜️ Log Collection and Analysis
-   ⬜️ Cost Management
-   ⬜️ Backup and Restore Operations
-   ⬜️ Resource Tagging and Management
-   ⬜️ Network Configuration Management
-   ⬜️ Data Migration

See the [open issues](https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts/issues) to report bugs or request fatures.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

Contributions are more than welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for
more info.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the MIT License. See [LICENSE](LICENSE.txt) for more information.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Paul Münzner: [https://paulmuenzner.com](https://paulmuenzner.com) 

Project Link: [https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts](https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts)

<p align="right">(<a href="#readme-top">back to top</a>)</p>



<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[github-shield]: https://img.shields.io/badge/paulmuenzner-black.svg?logo=github&logoColor=ffffff&colorB=000000
[github-url]: https://github.com/paulmuenzner
[contributors-shield]: https://img.shields.io/github/contributors/paulmuenzner/Azure-Powershell-Scripts-ts.svg
[contributors-url]: https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts/graphs/contributors
[issues-shield]: https://img.shields.io/github/issues/paulmuenzner/Azure-Powershell-Scripts-ts.svg
[issues-url]: https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts/issues
[license-shield]: https://img.shields.io/badge/MIT-license-blue.svg
[license-url]: https://github.com/paulmuenzner/Azure-Powershell-Scripts-ts/blob/master/LICENSE.txt
[website-shield]: https://img.shields.io/badge/www-paulmuenzner.com-blue
[website-url]: https://paulmuenzner.com 

