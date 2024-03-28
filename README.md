This is a readme expalining how to get desired compounds from the O'Meara Lab
Zinc-22 Mirror.

Email: limcaoco@umich.edu

Step By Step Guide:
1. For file management reasons, the compounds in the Zinc-22 Mirror are bundled
   in 100G tar balls. These tar balls are organized by heavy atom count in the
   following format: "tranch_{HEAVY_ATOM_COUNT}.tar" Some of these files are
   collections of smaller heavy atom count compounds for example "tranch_16_17.tar"
   would indicate that the tar ball contains compounds with heavy atom counts
   from 16 to 17.

   The first step to extract your compounds is to use the file transfer service
   Globus to transfer the desired compounds
   by heavy atom count to your working directory.

   you will need to email me at limcaoco@umich.edu so I can grant acess privilages
   to your umich email. 

   the globus source ID for the Zinc 22 Mirror is:

   06816b37-3761-4b05-9799-1947df5096e7
   

   the path to the mirror is

   /umms-maom/ZINC_mirror/published

   you can use the globus webpage to accomplish this.
   For convience, we also provide a simple script to use globus in terminal:
   1. First add your endpoint information in "setup_enviorment_dataden.sh" then
      run:

      source setup_enviorment_dataden.sh

   2. Then run the globus_zinc.sh script passing with it a list of tranches you want
      for an example of the list format see "tranch_to_move.txt":

      bash globus_zinc.sh tranch_to_move.txt

      then follow the authentication prompts as prompted by globus. Moving large
      amounts of data will take time for very large heavy atom count tranches assume
      at least 3-4 days for globus to transfer ~1T compound data. 


2. untar the transfered .tar files in the working directory with:

   tar -xvf *.tar

   The working directory should now contain several directories following this
   naming format: "zinc22-{SOME_LETTER}"
   
3. The .tar files contain compounds that can be further segregated via compound's
   logP. for convience, we provide "extract_mols.sh" to help extract a desired
   tranch of compounds based on the heavy atom count and LogP. the usage of
   extract_mols.sh is as follows in the working directory:

   bash extract_mols.sh heavy_atom_start \
   			heavy_atom_end \
			logp_start \
			logp_end \
			desired_file_type \
			output_directory

   #example usage
   bash ../extract_mols.sh 21 21 300 400 sdf ../output_sdf_files

   the extract_mols.sh script will automatically iterate the untar'd zinc-22
   directories and move every compound that falls within the Heavy Atom count and
   log P range specified into the specified output_directory.
   currently there are three supported file types: "db2" "smi" "sdf"

   if sdf or db2 are selected, files moved into this directory will be .tgz
   compressed.
   
4. After you're desired files are moved into the specified output directly feel
   free to remove leftover files you do not need or if tar balls are untar'd in
   the /scratch/ directory they will be deleted automatically after a period of time