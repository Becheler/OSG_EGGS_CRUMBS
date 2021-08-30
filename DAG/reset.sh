condor_rm -all
rm output_files/*
rm *.dag.*
condor_submit_dag workflow.dag
condor_watch_q
