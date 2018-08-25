````
***********************************************************************
* Flexible Energy Scheduling Tool for Integrating Variable generation *
***********************************************************************
**   FFFFFF    EEEEEE    SSSSSS    TTTTTTTT    IIIIII    VV     VV   **
**   FF        EE        SS           TT         II       VV   VV    **
**   FFFFFF    EEEEEE    SSSSSS       TT         II        VV VV     **
**   FF        EE            SS       TT         II         VVV      **
**   FF        EEEEEE    SSSSSS       TT       IIIIII        V       **
***********************************************************************
**************** National Renewable  Energy Laboratory ****************
***********************************************************************
````

Welcome to the FESTIV GitHub Repo!

# Getting Started

## Setup

**Required Tools**

* MATLAB
* GAMS with MILP solver (CPLEX or Gurobi)

### One Time Configuration

*Note: these directions tested under Mac OSX*

1. Make sure the MATLAB-GAMS link is in your MATLAB path

   1. Open MATLAB

   2. From the `>>` prompt type `which wgdx`

      * You should see the path to the GAMS-MATLAB connector such as `

        ```
        >>which wgdx
        /Applications/GAMS25.0/sysdir/wgdx.mexmaci64
        ```

        In which case go on to the next step.

      * if instead you get ``'wgdx' not found` then you need to add the GAMS-MATLAB library:

        * From the GUI "Home" tab press the `Set Path` button.

        * Press `Add Folder...`

        * Select the location of the appropriate compiled wgdx library. This is typically the `sysdir/` directory within your GAMS install

        * Press the `Save` button to close the GUI

        * Double check that it works:

          ```
          >>which wgdx
          /Applications/GAMS25.0/sysdir/wgdx.mexmaci64
          ```

2. Make sure that the GAMS executable is accessible to the MATLAB shell:

   * Try `system('gams')` at the MATLAB prompt
     * If you get a bunch of text output, you are good to go
     * If you get a Command not found error you need to add it to the path in the environment that MATLAB creates for its shells (which is different than your computer's shell setup) using `setenv('PATH', [getenv('PATH') ':' '$PATH_TO_GAMS/sysdir'])`
     * Now recheck with `system('gams')`

3. Change to the FESTIV directory in MATLAB. e.g.: `cd ~/repos/FESTIV`

4. Double check FESTIV is in the path (b/c it is local file):

   ````
   >> which FESTIV
   /Users/bpalmint/repos/FESTIV/FESTIV.m
   ````

### Running an existing test case in FESTIV (in GUI)

2. run `FESTIV` at the MATLAB prompt. This will bring up a dialog box allowing you to select the input files and configure the simulation
   1. As an example, in the dialog select `Browse`
   2. Slect the desired input file (in HDF5 format, **.h5*), such as `FESTIV_DIR/Input/PJM_5_BUS.h5`
   3. Press the 'Go!' button
      * Contrary to the name, this simply creates all of the required variables to the local MALAB workshopace
3. Actually Start
   1. Back at the MATLAB command prompt, start: `>> FESTIV`
   2. If all goes well you see 