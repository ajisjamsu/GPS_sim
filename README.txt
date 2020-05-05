# GPS Receiver Simulation

## Repo Overview

This project includes a main script and functions for GPS C/A code generation, coarse acquisition, carrier tracking and code tracking. Code tracking, as it remains problematic, still has a standalone testing script which was used up to the point of converting the functionality that did work into a MATLAB function to be called on by the main script.

The Design Review presentations are attached to the repo as PDFs.

## Running the Receiver

To change perturbations and run the system, follow the steps below.

### Step 1: Making Constants

Constants shared across components are written to a .mat file by the script called make_constants.m. To change the number of input bits, plotting view or introduce a code phase offset, edit that file. make_constants.m must be run once before the first execution of the main script, and each time any constant is changed.

### Step 2: Running Main Script

The script titled all_main.m will call on each component to run acquisition, carrier tracking and code tracking, passing arguments from one function to another. Plots in the main script or member functions can be commented or uncommented if not desired to be seen.