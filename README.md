# crystallography_unix_workflow
This page is for documenting the workflow that I've edited to automatize the dta analysis process for crystallography in the Drug Discovery Unit (University of Dundee).

This workflow has been initiated by Paul Fyfe. My role was to improve the structure and make it run on schedule.

Background
==========
The initial version of the script was developed by Paul Fyfe. In this first version, the script was launched inside a folder where images where collected from another machine and transfered over to the one where the analysis is carried on. 

The script looks if there are 50 or more images and if the MSCServDetCCD.log is present.
If this is the case, [XIA2](https://github.com/xia2) run with or wthout the presence of an .mtz file.

After this step, if a .pdb file of the protein is available in the working directory, [DIMPLE](http://ccp4.github.io/dimple/) runs and the log is saved into a log file. This last step wasn't tested in the first version.

Objectives
==========
1) Create an adeguate file system for all the projects where to store unproccessed and processed data.
2) Reinforce file checks and add all the different alternatives.
3) Test and run DIMPLE after the XIA2 run.
4) Schedule the analysis to run twice a day.

File System Layout
==================
The proposed file system is this:

```
~/data
	    |---------/project_folder
		            |----/user1
                      |----/unprocessed_data
                            |----------------/job1
                                             |---/run01
                                             |---/run02
                                             ...
                                             |---/runN
                             |----------------/job2
                                             |---/run01
                                             |---/run02
                                             ...
                                             |---/runN
                             ...
                             |----------------/jobN
                                             |---/run01
                                             |---/run02
                                             ...
                                             |---/runN
                      |----/processed_data
                ...
                |----/userN
                      |----/unprocessed_data
                            |----------------/job1
                                             |---/run01
                                             |---/run02
                                             ...
                                             |---/runN
                             |----------------/job2
                                             |---/run01
                                             |---/run02
                                             ...
                                             |---/runN
                             ...
                             |----------------/jobN
                                             |---/run01
                                             |---/run02
                                             ...
                                             |---/runN
                      |----/processed_data
```

A `working_folder` is placed inside the `jobN` folder. this contains the images colected from the previous machine.
An .mtz file and a .pdb file can be stored at the job-level folder. This is because each job can use the same crystal structure under different experiemntal conditions.

At the end of the run, the content of `/jobN/runM` is moved from the `unprocessed_data` folder to the `processed_data` one, where users can visualize and work on it.

Schedule
========
Two CRON jobs are set up to run at 12 am and 8 pm every day.

