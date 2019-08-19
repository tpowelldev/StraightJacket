# PowerShell DSC LCM Manager 

A collection of functions to install, configure, invoke and uninstall LCM Manager.

LCM Manager provides a method to schedule the activation of the DSC LCM to ensure that configuration changes can only take place during schedule maintenance windows. An override is provided to allow manual triggering of the LCM outside of configured maintenance windows.

---

## To do:

* Complete unit tests / increase code coverage
* Complete documentation / help text
* Allow defining specific dates for maintenance windows, rather than working with 7 day recurring week
