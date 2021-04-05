G_PDK_LIB_NAME = "tsmcN28"

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

procedure(
xxx()
prog(
()
); end of prog
); end of procedure
