<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,lazyj.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lia.Monitor.Store.*,lia.web.utils.Formatare,lia.web.utils.DoubleFormat,lia.Monitor.monitor.*"%>

<%
    lia.web.servlets.web.Utils.logRequest("START /sitesonar/index.jsp", 0, request);

    final ServletContext sc = getServletContext();
    
    final String SITE_BASE = sc.getRealPath("/");

    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);

    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");

    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");
    
    final RequestWrapper rw = new RequestWrapper(request); 

    String sSite = rw.gets("site");

    
    if (sSite.indexOf('\0') >= 0){
        System.err.println("/sitesonar/index.jsp: Somebody asked for site name `"+sSite+"`");
        return;
    }
    
    if (sSite.length()==0){ 
	    sSite = rw.getCookie("sitesonar_site");
    }

    //Site sonar html page
    final Page p = new Page(null, "sitesonar/index.res");

	//DB with all the unique sites
    final DB db = new DB("SELECT DISTINCT ce_name FROM sitesonar_hosts");
    
    long lKSI2K=0;

    String sHostName = null;
    
    boolean bHostNameResolved = false;

    final Cookie cookie = new Cookie("sitesonar_site", sSite);
    cookie.setMaxAge(Integer.MAX_VALUE);
    cookie.setHttpOnly(true);
    response.addCookie(cookie); 

    pMaster.modify("title", "WLCG Configuration Monitoring Tool for "+sSite);
    pMaster.modify("bookmark", "/siteinfo/?site="+Format.encode(sSite));
    
    p.modify("site", sSite);

	Page siteId = new Page(null, "sitesonar/sonarDropdown.res");
	Page siteElement = new Page(null, "sitesonar/dropdownElement.res");
	siteId.modify("dTitle", "Site ID");
	siteId.modify("dHidden", "Select a site ID");

    //List of all unique sites
    ArrayList<String> sites = new ArrayList<String>();

    //Add unique sites to the sites list
    while (db.moveNext()){
        siteElement.modify("dValue", db.gets(1));
        sites.add(db.gets(1));
		siteId.append("dropdownItem", siteElement);
    }
    p.append("siteId", siteId);
    
	Page listElement = new Page(null, "sitesonar/sonar_list.res");
    Page filterElement = new Page(null, "sitesonar/filterItem.res");


    // Filters
    // Collect host_ids of tests that satisfy filter
    int filterLength;
    String filterString = "";
    List<String> filterTestName = new ArrayList<String>();
    List<String> filterTestMessage = new ArrayList<String>();

    //If there aren't filter parameters
    if(request.getParameter("filterTestNames") == "" || request.getParameter("filterTestNames") == null){
        filterLength = 0;
        filterString = ";";
    }
    else{
        filterTestName.add(request.getParameter("filterTestNames"));
        filterLength = filterTestName.size();

        String filterTestMessageVal = "";
        if(request.getParameter("filterTestMessages") != null){
            filterTestMessageVal = request.getParameter("filterTestMessages");
        }
    

        filterTestMessage.add(filterTestMessageVal); 
        
        //make filter string for fetching tests
        for(int i = 0; i < filterLength; i++){
            filterString += " OR test_name='" + filterTestName.get(i) + "'";
        }
        filterString += ";";
        //Render filters
        for(int i = 0; i < filterLength; i++){
            filterElement.modify("filter_name", filterTestName.get(i) + ": " + filterTestMessage.get(i));
            p.append("filters", filterElement);
        }
    }


    final DB entireDB;

    //Fetch tests for grouping and filters
    if(request.getParameter("grouping") == "" || request.getParameter("grouping") == null){
        //By default, grouping is set to singularity
        if(filterLength > 0){
             entireDB = new DB("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='singularity' " + filterString);
             //out.println("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='singularity' " + filterString);
        }
        else{
            entireDB = new DB("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='singularity';");
            //out.println("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='singularity';");
        }
        
    }
    else{
        if(filterLength > 0){
            entireDB = new DB("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='" + request.getParameter("grouping") + "'" + filterString);
            //out.println("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='" + request.getParameter("grouping") + "'" + filterString);
        }
        else{
            entireDB = new DB("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='" + request.getParameter("grouping") + "';");
            //out.println("SELECT host_id, test_message, site_name, test_name FROM sitesonar_tests WHERE test_name='" + request.getParameter("grouping") + "';");
        }
        
    }
    
    // Group by
    String g = "singularity";
    String value = "SUPPORTED";
    if(request.getParameter("value") != null){
        value = request.getParameter("value");
        g = request.getParameter("grouping");
    }

    //Key: Site name, Value: count of supported groupings
    HashMap<String, Integer> countSupportForSites = new HashMap<String, Integer>();
    HashMap<String, Integer> countNotSupportForSites = new HashMap<String, Integer>();

    //Hashmap for checking if all filters are ok for a host_id. Values explained below
    //3: counted in countNotSupportForSites
    //2: counted in countSupportForSites
    //1: false if it was 2 remove -1 from countSupportForSites and add +1 to not support, 
    //0: init
    HashMap<String, Integer> filterSupportMap = new HashMap<String, Integer>();

    //If there are filters, remove nodes that are filtered out
    if(filterLength > 0){

        // Iterate over sitesonar_tests
        while(entireDB.moveNext()){

            //init the hashmaps
            if(!countSupportForSites.containsKey(entireDB.gets(3))){
                countSupportForSites.put(entireDB.gets(3), 0);
                countNotSupportForSites.put(entireDB.gets(3), 0);
            }

            if(!filterSupportMap.containsKey(entireDB.gets(1))){
                filterSupportMap.put(entireDB.gets(1), 0);
            }

            //if test_name is grouping
            if(entireDB.gets(4).equals(g)){
                //If test_message is correct and not hostid not visited, add value to already existing row
                if(entireDB.gets(2).equals(value) && filterSupportMap.get(entireDB.gets(1)) == 0){
                    //Count match with value
                    countSupportForSites.put(entireDB.gets(3), (countSupportForSites.get(entireDB.gets(3))+1));

                    //Set hostid to visited
                    filterSupportMap.put(entireDB.gets(1), 2);
                }
                else if(filterSupportMap.get(entireDB.gets(1)) == 0){
                    //Count not matching with value
                    countNotSupportForSites.put(entireDB.gets(3), (countNotSupportForSites.get(entireDB.gets(3))+1));
                    
                    //set hostid to visited
                    filterSupportMap.put(entireDB.gets(1), 3);
                }
            }

            //Filtering
            //If testname equals filter testname, and message not equals filter message
            if(entireDB.gets(4).equals(filterTestName.get(0)) && !entireDB.gets(2).equals(filterTestMessage.get(0))){
                //If was counted in support hashmap, remove it and add to notSupport hashmap
                if(filterSupportMap.get(entireDB.gets(1)) == 2){
                    //Remove one count, because its filtered out
                    countSupportForSites.put(entireDB.gets(3), (countSupportForSites.get(entireDB.gets(3))-1));
                }
                if(filterSupportMap.get(entireDB.gets(1)) == 3){
                    countNotSupportForSites.put(entireDB.gets(3), (countNotSupportForSites.get(entireDB.gets(3))-1));
                }

                filterSupportMap.put(entireDB.gets(1), 1);
            }  
        }
    }
    else {
        // Iterate over sitesonar_tests with no filters
        while(entireDB.moveNext()){

            //Fill site_name field if empty
            if(!countSupportForSites.containsKey(entireDB.gets(3))){
                countSupportForSites.put(entireDB.gets(3), 0);
                countNotSupportForSites.put(entireDB.gets(3), 0);
            }

            //If test_message is correct, add value to already existing row
            if(entireDB.gets(2).equals(value)){
                countSupportForSites.put(entireDB.gets(3), (countSupportForSites.get(entireDB.gets(3))+1));
            }
            else{
                countNotSupportForSites.put(entireDB.gets(3), (countNotSupportForSites.get(entireDB.gets(3))+1));
            }
        }
    }  

    //token: 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
    //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
    //Render list
    Page listHeaderSupport = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderPercent = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderOther = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderTotal = new Page(null, "sitesonar/listHeader.res");
    
    listHeaderSupport.modify("header_name", value);
    listHeaderOther.modify("header_name", "Other nodes");
    listHeaderPercent.modify("header_name", "Nodes supported");
    listHeaderTotal.modify("header_name", "Total");
    
    p.append("list_header", listHeaderSupport);
    p.append("list_header", listHeaderOther);
    p.append("list_header", listHeaderPercent);
    p.append("list_header", listHeaderTotal);
    final DB listDB = new DB("SELECT host_id FROM sitesonar_tests");

    int totalCEs = 0;
    int totalSupportedCEs = 0;
    int resultSites = 0;

    for(int i = 0; i < sites.size(); i++) {
        //Calculates percentage of sites covered by grouping parameter
        float percentSupport = 0;
        int total = 0;

        //This is to avoid nullpointer error.
        if(countSupportForSites.get(sites.get(i)) != null && countNotSupportForSites.get(sites.get(i)) != null){
            percentSupport = (countSupportForSites.get(sites.get(i)) * 100.0f) / (countSupportForSites.get(sites.get(i)) + countNotSupportForSites.get(sites.get(i)));
            total = countSupportForSites.get(sites.get(i)) + countNotSupportForSites.get(sites.get(i));

            //Summarize all CEs for all sites
            totalCEs += total;
            totalSupportedCEs += countSupportForSites.get(sites.get(i));
        }

        
        //check that values are not null
        if(countSupportForSites.get(sites.get(i)) != null && countNotSupportForSites.get(sites.get(i)) != null){
            //Don't display sites that have no nodes
            if(countSupportForSites.get(sites.get(i)) != 0 || countNotSupportForSites.get(sites.get(i)) != 0){

                resultSites++;
                //Create list elements and put values for site-name, n supported nodes, n not supported nodes etc, then append the list element
                listElement.modify("site_name", sites.get(i));
                listElement.modify("supported_nodes", countSupportForSites.get(sites.get(i)));
                listElement.modify("not_supported_nodes", countNotSupportForSites.get(sites.get(i)));
                listElement.modify("percent_support", percentSupport + "%");
                listElement.modify("total", total);
                p.append("testList", listElement);
            }
        }
    }

    //set values in index.res and append to master page
    p.modify("n_sites", totalCEs);
    float percentageTotal = (totalSupportedCEs * 100.0f) / (totalCEs);
    p.modify("percentTotal", (int) percentageTotal);
    p.modify("groupParam", g);
    p.modify("valueParam", value);
    p.modify("result_count", resultSites);
    
    if(request.getParameter("filterTestNames") != null){
        p.modify("filterParam", request.getParameter("filterTestNames") + ": ");
    }
    if(request.getParameter("filterTestMessages") != null){
        p.modify("filterValueParam", request.getParameter("filterTestMessages"));
    }
    pMaster.append(p);
    
    pMaster.write();
    
    out.println(new String(baos.toByteArray()));
    
    lia.web.servlets.web.Utils.logRequest("/siteinfo/index.jsp?site="+sSite, baos.size(), request);
%>

<%!

    public void getFilteredList(Page p){
        
    }

%>