source ./property_reader.sh


test_change_var() {
    
    vars=( name type parent file command id )
    values=( test_value 3 back item 'exit' construct the command for replacing the old value with )
    numvalues=${#values[@]}
    printf "There are %s values\n" "${numvalues}"
    for var in ${vars[@]}
    do
        roulette=$(random 0 $((numvalues -1)))
        rval=${values[${roulette}]}
        printf "Picked Item %s %s\n" "${roulette}" "${rval}"
        change_var ${pname} ${var} ${rval}
    done


} 

test_add_to_list() {
    declare -a lst
    vars=( name type parent file command id )
    values=( test_value 3 back item 'exit' construct the command for replacing the old value with )
    numvalues=${#values[@]}
    printf "There are %s values\n" "${numvalues}"
    for var in ${vars[@]}
    do
        roulette=$(random 0 $((numvalues -1)))
        rval=${values[${roulette}]}
        printf "Picked Item %s %s\n" "${roulette}" "${rval}"
        lst+=( $(add_to_list ${pname} ${var} ${rval}) )
    done
    printf "Done Adding\n"
    printf "  + %s\n" "${lst[@]}"


} 
pname=testfile02
#new_property_file testfile01 menu yes
#test_change_var
# cat .menu/${pname}.ilist
#test_add_to_list
#return_index_value ${pname} 5

get_numbered_array ${pname}