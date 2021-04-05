procedure(
sort_bbox(bbox)
prog(
(x1 x2 y1 y2)
    x1 = min(xCoord(xCoord(bbox)) xCoord(yCoord(bbox)))
    y1 = min(yCoord(xCoord(bbox)) yCoord(yCoord(bbox)))
    x2 = max(xCoord(xCoord(bbox)) xCoord(yCoord(bbox)))
    y2 = max(yCoord(xCoord(bbox)) yCoord(yCoord(bbox)))
    return(list(x1:y1 x2:y2))
); end of prog
); end of procedure

procedure(
get_max_bbox(l_bbox)
prog(
(tmp_bbox max_x1 max_y1 max_x2 max_y2 tmpx tmpy)
    tmp_bbox = nth(0 l_bbox)
    tmp_bbox = sort_bbox(tmp_bbox)
    max_x1 = xCoord(xCoord(nth(0 l_bbox)))
    max_y1 = yCoord(xCoord(nth(0 l_bbox)))
    max_x2 = xCoord(xCoord(nth(0 l_bbox)))
    max_y2 = yCoord(xCoord(nth(0 l_bbox)))
    foreach(m_bbox l_bbox
        foreach(m_point m_bbox
            tmpx = xCoord(m_point)
            tmpy = yCoord(m_point)
            if(tmpx < max_x1
            then
                max_x1 = tmpx
            )
            if(tmpx > max_x2
            then
                max_x2 = tmpx
            )
            if(tmpy < max_y1
            then
                max_y1 = tmpy
            )
            if(tmpy > max_y2
            then
                max_y2 = tmpy
            )
        )
    )
    return(list(max_x1:max_y1 max_x2:max_y2))
); end of prog
); end of procedure

procedure(
get_bbox_width(bbox)
prog(
()
    return(abs(xCoord(xCoord(bbox))-xCoord(yCoord(bbox))))
); end of prog
); end of procedure

procedure(
get_bbox_height(bbox)
prog(
()
    return(abs(yCoord(xCoord(bbox))-yCoord(yCoord(bbox))))
); end of prog
); end of procedure

procedure(
get_2bbox_distance(bbox1 bbox2 direction)
prog(
()
    bbox1 = sort_bbox(bbox1)
    bbox2 = sort_bbox(bbox2)
    case( direction
        ("up"
            return(yCoord(yCoord(bbox1))-yCoord(yCoord(bbox2)))
        )
        ("down"
            return(yCoord(xCoord(bbox1))-yCoord(xCoord(bbox2)))
        )
        ("left"
            return(xCoord(xCoord(bbox1))-xCoord(xCoord(bbox2)))
        )
        ("right"
            return(xCoord(yCoord(bbox1))-xCoord(yCoord(bbox2)))
        )
    )
    return(nil)
); end of prog
); end of procedure

procedure(
get_layer_map_name(layerName)
prog(
()
    if(GTech~>layerMap[layerName] !=nil
    then 
        return(GTech~>layerMap[layerName])
    else
        return(layerName)
    )
); end of prog
); end of procedure


procedure(
tech_init(lib_name)
prog(
(lib)
    if(boundp('GTech) == nil
    then
        lib = car(setof(x ddGetLibList() x~>name==lib_name))
        defstruct(TechStruct libName layerMap libID techID)
        GTech = make_TechStruct(
            ?libName lib_name
            ?libID lib
            ?techID techGetTechFile(lib)
            ?layerMap get_layer_map(lib_name)
        )
    )
);end of prog
);end of procedure

procedure(
get_layer_map(pdk_lib_name)
prog(
(lib tech layerDef layerMap layer_type)
    lib = car(setof(x ddGetLibList() x~>name==pdk_lib_name))
    tech = techGetTechFile(lib)
    layerDef = tech~>layers
    layerMap = makeTable("layerMap" list())
    foreach(m_layerDef layerDef
        layer_type = m_layerDef~>material
        if(layer_type != "unknown" 
        then
            layerMap[layer_type] = append1(layerMap[layer_type] m_layerDef~>name)
            layerMap[m_layerDef~>name] = layer_type
        )
    )
    return(layerMap)
); end of prog
); end of procedure


procedure(
get_mos_data(instID)
prog(
()
    println(get_layer_list(instID))
    get_mos_poly_data(instID)
); end of prog
); end of procedure

procedure(
get_layer_list(instID)
prog(
()
    lpp_list = list()
    foreach(m_lpp instID~>master~>lpps
        lpp_list = append1(lpp_list get_layer_map_name(m_lpp~>layerName))
    )
    return(lpp_list)
); end of prog
); end of procedure

procedure(
get_mos_poly_data(instID)
prog(
()
    poly_layer_name = GTech~>layerMap["poly"]
    println(poly_layer_name)
    poly_shapes = setof(x instID~>master~>shapes x~>layerName== poly_layer_name && x~>purpose == "drawing")
    poly_bboxes = poly_shapes~>bBox
); end of prog
); end of procedure

tech_init("tsmcN28")


get_mos_data(css())


