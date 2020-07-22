# Puppet-Finland scripts

A collection of useful scripts (shell and Powershell) used for bootstrapping 
systems. In this context bootstrapping means getting the node to a state where a 
real configuration management system (e.g. Puppet) can take over it's 
configuration.

These scripts are particularly useful with tools such as Vagrant, Packer or
Terraform for provisioning virtual machines.

These scripts can be run standalone for the most part. One strategy is to 
distribute a single site-specific initialization script that fetches and runs 
other bootstrapping scripts to do things like setup OpenVPN and then run Puppet.

# Project structure

Currently the project structure is simple:

    .
    ├── bootstrap
    │   ├── linux
    │   │   └── ...
    │   └── windows
    │       ├── ...
    └── README.md

The "bootstrap" directory contains all bootstrapping scripts. Scripts aimed at 
bootstrapping Linux (or \*NIX) nodes are under "linux" and are typically (but not 
necessarily) written with sh shell in mind.

Powershell scripts and batch files used for bootstrapping Windows nodes are 
under the "windows" subdirectory. There are two special files: utils.ps1 and 
config.ps1. The former contains general purpose Powershell functions which are 
included in other Powershell scripts. The latter, config.ps1, contains common 
configuration for other Powershell scripts.

# License and copyrights

Unless otherwise stated the scripts use the BSD license (see LICENSE.BSD). Files 
taken from the packer-windows project use the MIT license (see LICENSE.MIT).
