#!/bin/bash
echo "################################################################################"
echo "#                                                                              #"
echo "#        The Bigger Red Button Script - 22/1/18 P.K.Fyfe and F.Gastaldello     #"
echo "#                                                                              #"
echo "#   - Place script in /scripts directory                                       #"
echo "#                                                                              #"
echo "#   - It should automatically use xia2 to process with XDS (including          #"
echo "#     multi-sweep and data collected with an omega offset), followed by        #"
echo "#     dimple - molrep or refmac_rigid and refmac_restrained. Largely designed  #"
echo "#     for ligand soaks etc.                                                    #"
echo "#                                                                              #"
echo "#   - Your search model for dimple must be called input.pdb and placed         #"
echo "#     in supportingFiles directory                                             #"
echo "#                                                                              #"
echo "#   - If you wish to use a reference mtz to copy accross FreeR set you must    #"
echo "#     place the reference in the supportingFiles dir and name it freer.mtz.    #"
echo "#     Uncomment the line marked (***), and add the relevant flag to the Xia2   #"
echo "#      command (See list of useful command options below).                     #"
echo "#                                                                              #"
echo "#   - Please check the commands run are of relevance to your data. Points      #"
echo "#     where more individual preferences and requirements may be required are   #"
echo "#     marked within the script *** RELEVANT MESSAGE ***                        #"
echo "################################################################################"
echo ""
echo "  ** Setting up directory structure - Ignore file Exists error messages"
# Fetching current date for logfile
today=`date '+%d_%m_%Y'`
JOBDIR=/data/ddu_test
# Get list of user folders from the /ddu_test folder
user_dirs=($(ls /data/ddu_test/ | egrep -v 'logs|scripts'))
for u_dir in "${user_dirs[@]}"
do
        # Check if user folder is a folder
        if [ -d $JOBDIR/$u_dir/unprocessed_data ]
        then
                # Get list of job folders inside the user folder
                job_dirs=($(ls -1 $JOBDIR/$u_dir/unprocessed_data))
                for j_dir in "${job_dirs[@]}"
                do
                        if [ -d $JOBDIR/$u_dir/unprocessed_data/$j_dir ]
                        then
                                # Get list of run folders inside the job folder
                                run_dirs=($(ls -1 $JOBDIR/$u_dir/unprocessed_data/$j_dir ))
                                for r_dir in "${run_dirs[@]}"
                                do
                                        if [ -d $JOBDIR/$u_dir/unprocessed_data/$j_dir/$r_dir ]
                                        then
                                                # Create log file for the run and allocate it in the /logs folder
                                                touch /data/ddu_test/logs/log__$today.log
                                                for path in $JOBDIR/$u_dir/unprocessed_data/$j_dir/$r_dir/*
                                                do
                                                        echo $path
                                                        [ -d "${path}" ] || continue
                                                        echo "Folder is a directory" >> /data/ddu_test/logs/log__$today.log
                                                        # Check that there are more than 50 images and there is a .log file
                                                        count=($(ls -1 $path/images/* 2> /dev/null | wc -l))
                                                        if (($count > 50)) && [ -e $path/images/MSCServDetCCD.log ]
														then
                                                                echo "MSCServDetCCD.log is present" >> /data/ddu_test/logs/log__$today.log
                                                                count=($(ls -1 $JOBDIR/$u_dir/unprocessed_data/$j_dir/*.mtz 2> /dev/null | wc -l))
                                                                if (($count > 0))
                                                                then
                                                                        echo "run XIA2" >> /data/ddu_test/logs/log__$today.log
                                                                        xia2 pipeline=3dii atom=S  freer_file $JOBDIR/$u_dir/unprocessed_data/$j_dir/input.mtz reference_reflection_file $JOBDIR/$u_dir/unprocessed_data/$j_dir/input.mtz $p$
                                                                        #cp -a $JOBDIR/$u_dir/unprocessed_data/$j_dir/input.mtz $path
                                                                        cp -r $JOBDIR/$u_dir/unprocessed_data/$j_dir/input.mtz $path
                                                                else
                                                                        echo "run XIA2 without .mtz files" >> /data/ddu_test/logs/log__$today.log
                                                                        xia2 pipeline=3dii atom=S $path
                                                                fi
                                                                echo "moving ./DEFAULT/scale/AUTOMATIC_DEFAULT_free.mtz to working directory" >> /data/ddu_test/logs/log__$today.log
                                                                #mv ./DEFAULT/scale/AUTOMATIC_DEFAULT_free.mtz $path/images
                                                                cp -r ./DEFAULT/scale/AUTOMATIC_DEFAULT_free.mtz $path/images
                                                                count=($(ls -1 $JOBDIR/$u_dir/unprocessed_data/$j_dir/*.pdb 2> /dev/null | wc -l))
                                                                if (($count > 0))
                                                                then
                                                                        echo "PDB files in the directory for DIMPLE" >> /data/ddu_test/logs/log__$today.log
                                                                        touch $path/dimple_log.log
                                                                        dimple -f png $path/images/DEFAULT/scale/AUTOMATIC_DEFAULT_free.mtz $JOBDIR/$u_dir/unprocessed_data/$j_dir/dimple_input.pdb $path > $path/dimple_log.log
                                                                        #cp -a $JOBDIR/$u_dir/unprocessed_data/$j_dir/dimple_input.pdb $path
                                                                        cp -r $JOBDIR/$u_dir/unprocessed_data/$j_dir/dimple_input.pdb $path
                                                                else
                                                                        echo "No PDB files in the directory for DIMPLE, skip" >> /data/ddu_test/logs/log__$today.log
                                                                fi
                                                        else
                                                                echo "MSCServDetCCD.log is NOT present" >> /data/ddu_test/logs/log__$today.log
                                                        fi
														 echo "cleaning current directory from files" >> /data/ddu_test/logs/log__$today.log
                                                        ls | grep -v analysis_script.sh | xargs rm -rf
                                                        echo "Copy folder to /processed_data" >> /data/ddu_test/logs/log__$today.log
                                                        mkdir -p /data/ddu_test/$u_dir/processed_data/$j_dir/$r_dir
                                                        #cp -a $path /data/ddu_test/$u_dir/processed_data/$j_dir/$r_dir
                                                        cp -r $path /data/ddu_test/$u_dir/processed_data/$j_dir/$r_dir
                                                        echo "Remove folder from /unprocessed_data" >> /data/ddu_test/logs/log__$today.log
                                                        rm -rf $path
                                                done
                                        fi
                                done
                        fi
                done
        fi
done
