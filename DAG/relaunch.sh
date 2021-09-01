./generate_DAG.sh > workflow.dag
condor_submit_dag workflow.dag
condor_watch_q
