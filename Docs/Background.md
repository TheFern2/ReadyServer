# Background

I wanted to take the time and explain how long this framework has been used, and reused within my job. And how it has helped us, and increased our testing productivity, and decreased time spent on each testing iteration. Saving money, and time is always a great thing. In addition to that, we're able to deliver a higher quality product to our customers.

## What exactly is being tested

I am part of a QC group where we test Controls and Automations software. We make sure products are high end quality both from the user endpoint and engineering endpoint. If you aren't sure what any of that means, industrial software is deployed on Programmable Logic Controllers essentially the equivalent of a raspberry pi or arduino but for Industrial use, brands like Siemens, Rockwell, Omron, and a few others provide PLCs, along with Software Packages to program these controllers. They also provide HMIs, human machine interface for operators to control equipment, they can be touch screen or with buttons.

That was a long and winded introduction, in order to do all of the above. A production environment needs servers for various reasons. Remote support from techs and engineers, historic and alarm databases, web apps, onsite tooling, and the list goes on.

We test servers from HP, Dell, Kontron, and a few others, and ensure everything that engineering says it supposed to do, and have installed is in fact true. I also test PLC code, and web apps, but for the purpose of this repo, we are strictly talking about the server images themselves.

## Testing iteration

A test iteration last one to two weeks. It goes from IT to OT (Operational Technology) back and forth, and then finally to QC (Me).

## What is a server image

If you've ever installed an OS in your pc or mac, then you already know what is an image, most often than not they come in ISO format or some other way. You can then install it, and run your OS, launch Word, a browser, etc. A production server is very much alike, we need an OS like VMWware Hypervisor ESXi, and then we add Virtual Machines. Each Virtual Machine or VM is crafted for a purpose following an architecture, one can be a SQL-SRV, a Workstation, etc.

## Problem statement

I've worked on two server images so far. Back in Nov 2019, I had the task of manually testing around 1000+ test cases not only for one brand of servers, but multiple brands, and several iterations. The initial brand is what we call the `golden image` the VMs are tested and 100% bulletproof, then a full image is taken from that server, and tested on my QC servers for Quality Assurance. During migration to other brands, certain things can break within ESXi, driver compatibility, etc, and for this reason each brand gets a sanity test. I wanted to make sure the VMs were in fact still the same too, but at the time I really didn't have the bandwidth to do a full test iteration. I needed a good way to automate this testing.

## The beginning of ServerLab v1 and v2

`ServerLab` had a humble beginning, in the beginning it was one powershell script, that would test the basic configuration of one VM. It would check Windows Settings, Firewall, Applications installed, Folder Permissions, and the list goes on. I wanted a way to configure test cases with json files, and run them through something like JUnit. That something like JUnit is Pester, a powershell unit testing framework. I wanted a clear separation between module functions, and test cases. In a Quality Control environment you want to make sure your testing module functions work. By having one powershell script I'd have to change functions here and there, so it wasn't the best plan. Another problem is that some functions needed to be tested on some VMs, and so the IF statements started to look like spaguetti code.

I started porting some of the spaguetti code to `Winster.psm1` module so it could be clean and reusable code. I then added a way to use those functions from `Winster` with json files, and added a few csv configuration files. The `TS_Main.ps1` script would be in charge of calling a json file based on IPs. Once I ran `TS_Main.ps1` I would transcribe the results from the console to my test plan which is a excel spreadsheet. This was still way faster than doing 60 test case on 15+ VMs.

## ServerLab v3

A few months passed, and we got word that a new image was being built from scratch, unlike the previous one. I spun up my servers when I got the new image, and ran ServerLab just to see what would happen. To my surprise most of the configuration test cases passed. That's when I knew I had built something good.

There was a major issue this time, we had a very short timeline. I had to come up with a soid test plan, and reconfigure the json configurations too. v2 isn't much different from v3 in terms of results. What change was the inner workings, I've added parameters to json files in order to clean up `TS_Main.ps1` and `TS_AutomatedTests.ps1` spaguetti code. I no longer had to manually change these scripts when a new json configuration was added, or a new function was added to `Winster`. I also added test results printed to xml for historic purposes.

Recap:
- v1 one script, good (2019 NOV)
- v2 configurable but still with some drawbacks, great (2020 MARCH)
- v3 configurable, maintainable and able to swap modules on the fly, super saiyan 4 (2020 OCT)

## Beta testing

I am proud to announce the servers were deployed to the field, and the image was solid, no major issues reported yet.