G_PDK_LIB_NAME = "tsmcN28"
um = 1e-6
nm = 1e-9

procedure(
get_lib()
prog(
(pdk_lib lib)
    pdk_lib = setof(x ddGetLibList() x~>name==G_PDK_LIB_NAME)
    if(lindex(ddGetLibList()~>name "tmp_lib")==nil
    then
        lib = dbCreateLib("tmp_lib")
        techBindTechFile(lib G_PDK_LIB_NAME)
    else
        lib = car(setof(x ddGetLibList() x~>name=="tmp_lib"))
    )
    return(lib)
); end of prog
); end of procedure


procedure(
get_cellview()
prog(
(cvID lib i)
    lib = get_lib()
    i = 0
    cvID = nil
    while( (cvID == nil) && (i < 20)
        cvID = dbOpenCellViewByType(lib~>name sprintf(nil "tmp_cell_%d" i) "schematic" "schematic" "w")
        i = i + 1
    )
    return(cvID)
); end of prog
); end of procedure

type_table = makeTable("type_table" nil)

procedure(
get_inst_cdf_value_range(cell_name cdf_name)
prog(
(cvID tmp_inst inst_cdf grid lib)
    exclude_value = list()
    lib = get_lib()
    tech = techGetTechFile(lib)
    grid = techGetMfgGridResolution(tech)
    grid = grid * um
    cvID = get_cellview()
    tmp_inst = dbCreateParamInstByMasterName(cvID G_PDK_LIB_NAME cell_name "symbol" nil 0:0 "R0")
    inst_cdf = cdfGetInstCDF(tmp_inst)
    cdf_list = inst_cdf~>parameters
    if( lindex(cdf_list~>name cdf_name) then
        m_cdf = car(setof(x cdf_list x~>name==cdf_name))
        m_dv = m_cdf~>defValue
        value_type = m_cdf~>paramType
        if(value_type == "string"
        then
            if( (nindex(m_dv "n")!=nil) || (nindex(m_dv "u")!=nil)
            then
                m_step = grid
            )
        )
        pre_value = evalstring(m_dv)
        ; max value
        vfoSetParam(tmp_inst cdf_name "1000")
        max_value = dbGet(tmp_inst cdf_name)
        max_value = evalstring(max_value)
        i = 1
        while(max_value - pre_value > m_step * 0.1
            tmp_str = sprintf(nil "%A" evalstring(m_dv)+m_step*i)
            vfoSetParam(tmp_inst cdf_name tmp_str)
            new_value = dbGet(tmp_inst cdf_name)
            println(new_value)
            new_value = evalstring(new_value)
            if(new_value - pre_value > m_step-m_step*0.1
            then
                pre_value = new_value
            else
                exclude_value = append1(exclude_value sprintf(nil "%A" evalstring(tmp_str)/um))
            )
            i = i + 1
        )
    )
    printf("exclude value:%A" exclude_value)
); end of prog
); end of procedure
get_inst_cdf_value_range("nch_mac" "w")
