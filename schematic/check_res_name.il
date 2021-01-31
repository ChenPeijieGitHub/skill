; ***************************************************************************
; description: check res basename pattern
; ***************************************************************************

procedure(
check_res_name(@optional (cvID geGetEditCellView()))
prog(
(err_str insts name_pattern res_base_name match_result
inst1_name inst1_port inst2_name inst2_port ret
tmp_file_name h_out flg)
    err_str = ""
    insts = setof(x cvID~>instances x~>purpose=="cell" && x~>libName=="analogLib" && x~>cellName=="res")
    name_pattern = rexCompile("\\([a-zA-Z0-9]+\\)_\\([a-zA-Z0-9]+\\)_\\([a-zA-Z0-9]+\\)_to_\\([a-zA-Z0-9]+\\)_\\([a-zA-Z0-9]+\\)")
    foreach(m_inst insts
        res_base_name = m_inst~>name
        match_result = rexExecute(res_base_name)
        if(match_result
        then
            flg = 0
            inst1_name = rexSubstitute("\\2")
            inst1_port = rexSubstitute("\\3")
            inst2_name = rexSubstitute("\\4")
            inst2_port = rexSubstitute("\\5")
            ret = check_res_name_icheck(cvID inst1_name inst1_port)
            if(ret != "OK"
            then
                flg = 1
                err_str = sprintf(nil "%s%s/%s/%s:%s\n" err_str cvID~>libName cvID~>cellName 
                    m_inst~>name ret)
            )
            ret = check_res_name_icheck(cvID inst2_name inst2_port)
            if(ret != "OK"
            then
                flg = 1
                err_str = sprintf(nil "%s%s/%s/%s:%s\n" err_str cvID~>libName cvID~>cellName 
                    m_inst~>name ret)
            )
            if(flg == 0
            then
                println("0000000000000000000000000000000")
                res_net_names = m_inst~>instTerms~>net~>name
                ret = check_res_name_get_net_name(cvID inst1_name inst1_port)
                if(lindex(res_net_names ret)==nil
                then
                    err_str = sprintf(nil "%s%s/%s/%s:can not find path to %s/%s\n" err_str cvID~>libName cvID~>cellName 
                        m_inst~>name inst1_name inst1_port)
                )
                ret = check_res_name_get_net_name(cvID inst2_name inst2_port)
                if(lindex(res_net_names ret)==nil
                then
                    err_str = sprintf(nil "%s%s/%s/%s:can not find path to %s/%s\n" err_str cvID~>libName cvID~>cellName 
                        m_inst~>name inst2_name inst2_port)
                )
            )            
        else
            err_str = sprintf(nil "%s/%s/%s:res name dose not match the name rule.\n" cvID~>libName cvID~>cellName 
                    m_inst~>name)
        )
    )
    tmp_file_name = "./.check_res.log"
    h_out = outfile(tmp_file_name)
    if(err_str != ""
    then
        fprintf(h_out "%s" err_str)
        close(h_out)
        view(tmp_file_name)
        return(nil)
    else
        fprintf(h_out "OK")
        close(h_out)
        view(tmp_file_name)
        return(t)
    )
); end of prog
); end of procedure

procedure(
check_res_name_icheck(cvID name port)
prog(
(pins pins_name insts insts_name)
    if(name == "pin"
    then
        pins = setof(x cvID~>instances x~>purpose=="pin")
        pins_name = pins~>net~>name
        if(lindex(pins_name port)==nil
        then
            return(sprintf(nil "Can not find specified pin:%s." port))
        )
        return("OK")
    else
        insts = setof(x cvID~>instances x~>purpose=="cell" && x~>libName!="analogLib" && x~>cellName!="res")
        insts_name = insts~>name
        if(lindex(insts_name name)==nil
        then
            return(sprintf(nil "Can not find specified instance:%s" name))
        )
        return("OK")
    )
    
); end of prog
); end of procedure


procedure(
check_res_name_get_net_name(cvID name port)
prog(
(inst term)
    if(name == "pin"
    then
        return(port)
    else
        inst = car(setof(x cvID~>instances x~>name==name))
        term = car(setof(x inst~>instTerms x~>name==port))
        return(term~>net~>name)
    )
); end of prog
); end of procedure

check_res_name()
