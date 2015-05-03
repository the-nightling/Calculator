
# PlanAhead Launch Script for Post-Synthesis floorplanning, created by Project Navigator

create_project -name Calculator -dir "/home/bluelabuser/Desktop/Calculator/planAhead_run_1" -part xc7a100tcsg324-3
set_property design_mode GateLvl [get_property srcset [current_run -impl]]
set_property edif_top_file "/home/bluelabuser/Desktop/Calculator/Calculator.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {/home/bluelabuser/Desktop/Calculator} {ipcore_dir} }
set_property target_constrs_file "Calculator.ucf" [current_fileset -constrset]
add_files [list {Calculator.ucf}] -fileset [get_property constrset [current_run]]
link_design
