# --- VIVADO MASTER BUILD SCRIPT ---
set top_module "RISCV_SINGLE_CORE"
set part_num "xc7z020clg400-1"
set output_dir "./build"

file delete -force $output_dir
file mkdir $output_dir

puts "\n--- 1. READING FILES ---"
read_verilog -sv [glob ./src/*.sv]
read_xdc ./constraints/clock.xdc

puts "\n--- 2. SYNTHESIS ---"
synth_design -top $top_module -part $part_num
write_checkpoint -force $output_dir/post_synth.dcp

puts "\n--- 3. IMPLEMENTATION ---"
opt_design
place_design
route_design
write_checkpoint -force $output_dir/post_route.dcp

puts "\n--- 4. GENERATING REPORTS ---"
report_timing_summary -file $output_dir/timing_summary.txt
report_utilization -file $output_dir/utilization.txt

puts "\n--- BUILD COMPLETE ---"