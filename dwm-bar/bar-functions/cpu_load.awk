#!/usr/bin/awk -f
 
function get_cpu_times() {
        while((getline l < "/proc/stat") > 0) {
                if(l~/^cpu /) {
                        close("/proc/stat")
                        $0 = l
                        idle = $5
                        total = $2+$3+$4+$5+$6+$7+$8+$9+$10+$11
                        diff_idle = idle-prev_idle
                        diff_total = total-prev_total
                        return idle total diff_idle diff_total
                        }
                }
}
 
function calc_cpu_load_prcnt() {
        get_cpu_times()
        prev_idle = idle
        prev_total = total
        system("sleep 1")
        get_cpu_times()
        load = (1000*(diff_total-diff_idle)/diff_total+5)/10
        return load
}
 
BEGIN{
        if(ARGC==1){calc_cpu_load_prcnt();printf "%.0f\n",load; exit}
        if(ARGC==2 && ARGV[1]=="m"){for(;;){calc_cpu_load_prcnt();printf "\r%.1f %%   ",load}}
}