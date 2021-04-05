; ****************************************************************
; description: initialize a tech instance
; ****************************************************************
defclass(
Tech 
() ;end of instances derived
(
    (tech
        @initarg         tech
    )
    (metal_layers
        @initarg         metal_layers
    )
    (cut_layers
        @initarg         cut_layers
    )
    (poly
        @initarg         poly
    )
    (diff
        @initarg         diff
    )
    (nwell
        @initarg         nwell
    )
    (imp_p
        @initarg         imp_p
    )
    (imp_n
        @initarg         imp_n
    )
); end of member definition
); end of defclass



; ****************************************************************
; description: initialize a tech instance
; example:
; makeTech("M1" "VIA1")
; ****************************************************************
procedure(
makeTech(tech metal_layers cut_layers poly diff nwell imp_p imp_n)
prog(
(techObj)
    techObj = makeInstance(
        'Tech 
        ?tech tech
        ?metal_layers metal_layers
        ?cut_layers cut_layers
        ?poly poly
        ?diff diff
        ?nwell nwell
        ?imp_p imp_p
        ?imp_n imp_n
    )
    return(techObj)
); end of prog
); end of procedure


; ****************************************************************
; description: get pdk tech file id
; example:
; get_pdk_tech("tsmcN28")
; get_pdk_tech()
; ****************************************************************
procedure(
get_pdk_tech(@optional (lib_name nil))
prog(
(lib tech)
    if(lib_name
    then
        lib = car(setof(x ddGetLibList() x~>name==lib_name))
        tech = techGetTechFile(lib)
    else
        tech = car(setof(x techGetOpenTechFiles() x~>libName != "cdsDefTechLib"))
    )
    return(tech)
); end of prog
); end of procedure


; ****************************************************************
; extract tech info
; ****************************************************************
procedure(
get_info_from_tech(tech)
prog(
(via_layer metal_layer final_metal_layer final_via_layer poly diff imp_p imp_n
nwell pwell)
    via_layer = techGetViaLayers(tech)
    metal_layer = setof(x tech~>layers x~>material=="metal")~>name
    final_metal_layer = list()
    final_cut_layer = list()
    foreach(m_item via_layer
        m_layer = car(last(m_item))
        m_cut = nth(1 m_item)
        if(lindex(metal_layer m_layer)!=nil && lindex(final_metal_layer m_layer)==nil
        then
            final_metal_layer = append1(final_metal_layer m_layer)
        )
        if(lindex(final_via_layer m_cut)==nil
        then
            final_cut_layer = append1(final_cut_layer m_cut)
        )
    )
    poly = car(setof(x tech~>layers x~>material=="poly")~>name)
    diff = car(setof(x tech~>layers x~>material=="diff")~>name)
    nwell = car(setof(x tech~>layers x~>material=="nwell")~>name)
    imp_p = car(setof(x tech~>layers x~>material=="pplus")~>name)
    imp_n = car(setof(x tech~>layers x~>material=="nplus")~>name)
    GTech = makeTech(tech final_metal_layer final_cut_layer poly diff nwell imp_p imp_n)
); end of prog
); end of procedure

procedure(
tech_info_init(lib_name)
prog(
(tech)
    tech = get_pdk_tech("tsmcN28")
    get_info_from_tech(tech)
); end of prog
); end of procedure
