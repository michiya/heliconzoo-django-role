heliconzoo-django-role
======================
This is a simple scaffold powered by [Helicon Zoo](http://www.helicontech.com/zoo/)
for packaging Django applications to run on Windows Azure and SQL Azure.

Prerequisites
-------------

You will need to install the following software on your local computer.
You can use [Web Platform Installer](http://www.microsoft.com/web/downloads/platform.aspx)
to install them easily.

* Windows Azure SDK
* Python 2.7 
* Helicon Zoo Module
* SQL Server Express 2008 R2

And the following Python packages are also required on your Python installation, 
the script `WebRole/bin/install-requirements.cmd` in this scaffold may be helpful
when you install them.

* Django
* [pyodbc](http://code.google.com/p/pyodbc/)
* [django-pyodbc](http://code.google.com/p/django-pyodbc/)

Usage
-----

1. Create your Django applications into `WebRole/project` directory,
and add any other Python packages you use to `WebRole/requirements.txt`. 

2. Turn IIS feature on and run `run.cmd` on your Windows Azure Command Prompt
to run the application on your local emulator.

3. Run `pack.cmd` on your Windows Azure Command Prompt to output `heliconzoo-django-role.cspkg`.
That file, along with `ServiceConfiguration.Cloud.cscfg` is what you need to deploy
via the Windows Azure portal (or with some other tool) to get the applications running in the cloud.

License
-------

Licensed under the [Apache License, Version 2.0](http://www.apache.org/licenses/LICENSE-2.0)