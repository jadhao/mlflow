#Examples for STAR
#make DIR_PATH=AMB_P1 METHOD=local-run-parallel M=T NODESIZE=4 MPI_EXE=mpirun LAMMPS_EXE=lmp_daily
#make DIR_PATH=AMB_P1 METHOD=local-run-serial M=T LAMMPS_EXE=lmp_daily
#make DIR_PATH=AMB_P1 METHOD=submit M=T CLUSTER=bigred3
#make DIR_PATH=AMB_P2 METHOD=submit M=T CLUSTER=bigred3

#Examples for SQL
#make DIR_PATH=AMB_P1 METHOD=local-run-parallel M=S NODESIZE=4 MPI_EXE=mpirun LAMMPS_EXE=lmp_daily
#make DIR_PATH=AMB_P1 METHOD=local-run-serial M=S LAMMPS_EXE=lmp_daily
#make DIR_PATH=AMB_P1 METHOD=submit M=S CLUSTER=bigred3
#Cleaning
#make clean DIR_PATH=AMB_P1
#make clean DIR_PATH=AMB_P2

#This make file builds the sub folder make files

AMB = ambient
SHEAR = shearing
DIR_PATH = AMB_P1
METHOD = submit
M=T
NODESIZE=4
MPI_EXE=mpirun
LAMMPS_EXE=lmp_daily
CLUSTER=bigred3
RESTART_FILE_1:=star.gphase1.*

all:
	@echo "Starting build of the $(DIR_PATH) directory";
ifeq ($(M),T)
	@echo "STAR molecule is selected";
	export RESTART_FILE_1=star.gphase1.*
else ifeq ($(M),S)
	@echo "SQUALANE molecule is selected";
	export RESTART_FILE_1=sql.gphase1.*
endif

ifeq ($(DIR_PATH),AMB_P1)
	+$(MAKE) -C $(AMB)/phase1 $(METHOD) M=$(M) MPI_EXE=$(MPI_EXE) NODESIZE=$(NODESIZE) LAMMPS_EXE=$(LAMMPS_EXE) CLUSTER=$(CLUSTER)
else ifeq ($(DIR_PATH),AMB_P2)
	@echo "Searching for $(RESTART_FILE_1) restart file";
	if ! test -f $(AMB)/phase1/restart_files/$(RESTART_FILE_1) ; then echo "You need phase1 restart file in $(AMB)/phase1/restart_files/$(RESTART_FILE_1) folder to start phase2"; exit 1; fi
	@echo "Copying restart files from phase1 to phase2";
	cp -r $(AMB)/phase1/restart_files $(AMB)/phase2/
	+$(MAKE) -C $(AMB)/phase2 $(METHOD) M=$(M) MPI_EXE=$(MPI_EXE) NODESIZE=$(NODESIZE) LAMMPS_EXE=$(LAMMPS_EXE) CLUSTER=$(CLUSTER)
else
	+$(MAKE) -C $(SHEAR) $(METHOD) M=$(M) MPI_EXE=$(MPI_EXE) NODESIZE=$(NODESIZE) LAMMPS_EXE=$(LAMMPS_EXE) CLUSTER=$(CLUSTER)
endif
	@echo "Ending the build of the $(DIR_PATH) directory";

clean:
	@echo "Cleaning the $(DIR_PATH) directory";
ifeq ($(DIR_PATH),AMB_P1)
	+$(MAKE) -C $(AMB)/phase1 clean
else ifeq ($(DIR_PATH),AMB_P2)
	+$(MAKE) -C $(AMB)/phase2 clean
else
	+$(MAKE) -C $(SHEAR) clean
endif
	@echo "Cleaned the $(DIR_PATH) directory";

.PHONY: all clean