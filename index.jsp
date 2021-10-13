<%@ page import="lia.Monitor.Store.Fast.DB,alimonitor.*,lazyj.*,java.util.*,java.io.*,java.text.SimpleDateFormat,lia.Monitor.Store.*,lia.web.utils.Formatare,lia.web.utils.DoubleFormat,lia.Monitor.monitor.*"%>

<%
    //Setup of Site Sonar page
    lia.web.servlets.web.Utils.logRequest("START /sitesonar/index.jsp", 0, request);

    final ServletContext sc = getServletContext();
    final String SITE_BASE = sc.getRealPath("/");
    final ByteArrayOutputStream baos = new ByteArrayOutputStream(10000);
    final Page pMaster = new Page(baos, "WEB-INF/res/masterpage/masterpage.res");
    final RequestWrapper rw = new RequestWrapper(request); 
    String sSite = rw.gets("site");
    final Cookie cookie = new Cookie("sitesonar_site", sSite);

    pMaster.comment("com_alternates", false);
    pMaster.modify("comment_refresh", "//");

    if (sSite.indexOf('\0') >= 0){
        System.err.println("/sitesonar/index.jsp: Somebody asked for site name `"+sSite+"`");
        return;
    }
    
    if (sSite.length()==0){ 
	    sSite = rw.getCookie("sitesonar_site");
    }

    long lKSI2K=0;
    String sHostName = null;
    boolean bHostNameResolved = false;
    
    cookie.setMaxAge(Integer.MAX_VALUE);
    cookie.setHttpOnly(true);
    response.addCookie(cookie); 
    pMaster.modify("title", "WLCG Configuration Monitoring Tool for "+sSite);
    pMaster.modify("bookmark", "/siteinfo/?site="+Format.encode(sSite));

    //Site sonar html page
    final Page p = new Page(null, "sitesonar/index.res");
    p.modify("site", sSite);


    //DB with all the unique sites
    final DB unique_ce_names = new DB("SELECT DISTINCT ce_name FROM sitesonar_hosts");

    //All necessary .res files
	Page siteId = new Page(null, "sitesonar/sonarDropdown.res");
	Page siteElement = new Page(null, "sitesonar/dropdownElement.res");
    Page listElement = new Page(null, "sitesonar/sonar_list.res");
    Page filterElement = new Page(null, "sitesonar/filterItem.res");
    Page nodeListElement = new Page(null, "sitesonar/nodeList.res");

    //List of all unique sites
    ArrayList<String> sites = new ArrayList<String>();

    //Add unique site names to the sites list, and append to the Site ID dropdown menu
    addUniqueSites(unique_ce_names, siteElement, sites, siteId, p);
    
    // Filters
    // Collect host_ids of tests that satisfy filter
    int filterLength;
    String filterString = "";
    List<String> filterTestName = new ArrayList<String>();
    List<String> filterTestMessage = new ArrayList<String>();

    int weekOld = 1;

    //If there aren't filter parameters
    if(request.getParameter("filterTestNames") == "" || request.getParameter("filterTestNames") == null){
        filterLength = 0;
        filterString = ";";
    }

    //Created to support multiple filters
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
        
        filterString += "AND last_updated > '" + weekOld + "';";

        //Render filters
        for(int i = 0; i < filterLength; i++){
            filterElement.modify("filter_name", filterTestName.get(i) + ": " + filterTestMessage.get(i));
            p.append("filters", filterElement);
        }
    }


    //Filter "All nodes" Page
    final DB nodeDB;

    //Fetch site from url
    String nodeSite = "Poznan";

    String nodeTestName = "singularity";

    String nodeMessage = "SUPPORTED";

    nodeDB = new DB("SELECT test_name, test_message, ce_name, addr, hostname FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE test_name='" +  nodeTestName + "' AND test_message='" + nodeMessage + "' AND ce_name='" + nodeSite + "';");

    while(nodeDB.moveNext()){
        //Append each node to list
        String hostname = nodeDB.gets(5);
        String addr = nodeDB.gets(4);
        nodeListElement.modify("host_name", hostname);
        nodeListElement.modify("address", addr);
        nodeListElement.modify("message", nodeMessage);
        p.append("nodeList", nodeListElement);

    }

    //Filter "Sites" Page
    final DB sitesDB;
    
    //Fetch tests for grouping and filters
    if(request.getParameter("grouping") == "" || request.getParameter("grouping") == null){
        //By default, grouping is set to singularity
        if(filterLength > 0){
             sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json, ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + weekOld + "' AND test_name='singularity' " + filterString);
             out.println("1");
             out.println(filterString);
        }
        else{
            //sitesDB = new DB("SELECT host_id, test_message, ce_name, test_name FROM sitesonar_tests WHERE test_name='singularity';");
            sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json, ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + weekOld + "' AND test_name='singularity';");
            
            //JSON EXAMPLE: SELECT * FROM sitesonar_tests WHERE test_message_json ->> 'SINGULARITY_CVMFS_SUPPORTED' ::text = 'TRUE';
            //sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message, ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE test_message_json ->> 'SINGULARITY_CVMFS_SUPPORTED' ::text = 'TRUE';");
            
            //With Inner Join
            out.println("2");
        }
        
    }
    else{
        if(filterLength > 0){
            sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json, ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + weekOld + "' AND test_name='" + request.getParameter("grouping") + "'" + filterString);
            out.println("3");
        }
        else{
            sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json, ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + weekOld + "' AND test_name='" + request.getParameter("grouping") + "';");
            out.println("4");
        }
        
    }
    
    // Group by
    String groupingName = "singularity";
    String groupMessage = "SUPPORTED";
    if(request.getParameter("value") != null){
        groupMessage = request.getParameter("value");
        groupingName = request.getParameter("grouping");
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
        while(sitesDB.moveNext()){
            out.println(sitesDB.gets(2).get("SINGULARITY_CVMFS_SUPPORTED"));
            //init the hashmaps
            if(!countSupportForSites.containsKey(sitesDB.gets(3))){
                countSupportForSites.put(sitesDB.gets(3), 0);
                countNotSupportForSites.put(sitesDB.gets(3), 0);
            }

            if(!filterSupportMap.containsKey(sitesDB.gets(1))){
                filterSupportMap.put(sitesDB.gets(1), 0);
            }

            //if test_name is grouping
            if(sitesDB.gets(4).equals(groupingName)){
                //If test_message is correct and not hostid not visited, add message to already existing row
                if(sitesDB.gets(2).equals(groupMessage) && filterSupportMap.get(sitesDB.gets(1)) == 0){
                    //Count match with message
                    countSupportForSites.put(sitesDB.gets(3), (countSupportForSites.get(sitesDB.gets(3))+1));

                    //Set hostid to visited
                    filterSupportMap.put(sitesDB.gets(1), 2);
                }
                else if(filterSupportMap.get(sitesDB.gets(1)) == 0){
                    //Count not matching with message
                    countNotSupportForSites.put(sitesDB.gets(3), (countNotSupportForSites.get(sitesDB.gets(3))+1));
                    
                    //set hostid to visited
                    filterSupportMap.put(sitesDB.gets(1), 3);
                }
            }

            //Filtering
            //If testname equals filter testname, and message not equals filter message
            if(sitesDB.gets(4).equals(filterTestName.get(0)) && !sitesDB.gets(2).equals(filterTestMessage.get(0))){
                //If was counted in support hashmap, remove it and add to notSupport hashmap
                if(filterSupportMap.get(sitesDB.gets(1)) == 2){
                    //Remove one count, because its filtered out
                    countSupportForSites.put(sitesDB.gets(3), (countSupportForSites.get(sitesDB.gets(3))-1));
                }
                if(filterSupportMap.get(sitesDB.gets(1)) == 3){
                    countNotSupportForSites.put(sitesDB.gets(3), (countNotSupportForSites.get(sitesDB.gets(3))-1));
                }

                filterSupportMap.put(sitesDB.gets(1), 1);
            }  
        }
    }
    else {
        // Iterate over sitesonar_tests with no filters
        while(sitesDB.moveNext()){

            //Fill ce_name field if empty
            if(!countSupportForSites.containsKey(sitesDB.gets(3))){
                countSupportForSites.put(sitesDB.gets(3), 0);
                countNotSupportForSites.put(sitesDB.gets(3), 0);
            }

            //If test_message is correct, add groupMessage to already existing row
            if(sitesDB.gets(2).equals(groupMessage)){
                countSupportForSites.put(sitesDB.gets(3), (countSupportForSites.get(sitesDB.gets(3))+1));
            }
            else{
                countNotSupportForSites.put(sitesDB.gets(3), (countNotSupportForSites.get(sitesDB.gets(3))+1));
            }
        }
    }  

    //Render list
    Page listHeaderSupport = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderPercent = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderOther = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderTotal = new Page(null, "sitesonar/listHeader.res");
    
    listHeaderSupport.modify("header_name", groupMessage);
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
    setValuesForSiteSonarHTML(p, totalCEs, totalSupportedCEs, groupingName, groupMessage, resultSites);
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
    //FUNCTIONS

    public void addUniqueSites(DB unique_ce_names, Page siteElement, ArrayList<String> sites, Page siteId, Page p){
        while (unique_ce_names.moveNext()){
            siteElement.modify("dValue", unique_ce_names.gets(1));
            sites.add(unique_ce_names.gets(1));
            siteId.append("dropdownItem", siteElement);
        }
        siteId.modify("dTitle", "Site ID");
	    siteId.modify("dHidden", "Select a site ID");
        p.append("siteId", siteId);
    }

    public void setValuesForSiteSonarHTML(Page p, int totalCEs, int totalSupportedCEs, String groupingName, String groupMessage, int resultSites){
        p.modify("n_sites", totalCEs);
        float percentageTotal = (totalSupportedCEs * 100.0f) / (totalCEs);
        p.modify("percentTotal", (int) percentageTotal);
        p.modify("groupParam", groupingName);
        p.modify("valueParam", groupMessage);
        p.modify("result_count", resultSites);
    }
%>