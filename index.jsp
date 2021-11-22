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
    Page siteOption = new Page(null, "sitesonar/uniqueSiteOption.res");

    //List of all unique sites
    ArrayList<String> sites = new ArrayList<String>();

    //Add unique site names to the sites list, and append to the Site ID dropdown menu
    //addUniqueSites(unique_ce_names, siteElement, sites, siteId, p);
    
    // What CE's nodes the "All nodes" page should list ous
    String sitenameAllNodes = "PNPI";
    if(request.getParameter("nodeSite") != null){
        sitenameAllNodes = request.getParameter("nodeSite");
    } 
    p.modify("selectedNodeSite", sitenameAllNodes);

    while (unique_ce_names.moveNext()){
            sites.add(unique_ce_names.gets(1));
            siteOption.modify("cename", unique_ce_names.gets(1));
            p.append("uniqueSiteOption", siteOption);
    }

    // Filters
    // Collect host_ids of tests that satisfy filter
    int filterLength;
    String filterString = "";
    List<String> filterTestName = new ArrayList<String>();
    List<String> filterTestMessage = new ArrayList<String>();

    //Set test age
    long DAY_IN_MS = 1000 * 60 * 60 * 24;
    long testAge = (System.currentTimeMillis() - (7 * DAY_IN_MS)) / 1000l;
    if(request.getParameter("testAge") != null){
        switch(request.getParameter("testAge")) {
            case "0":
                // 1 week
                testAge = (System.currentTimeMillis() - (7 * DAY_IN_MS)) / 1000l;
                
                p.modify("ageOptionText", "1 week");
                p.modify("ageOptionValue", "0");
                break;
            case "1":
                // 2 weeks
                testAge = (System.currentTimeMillis() - (14 * DAY_IN_MS)) / 1000l;
                p.modify("ageOptionText", "2 weeks");
                p.modify("ageOptionValue", "1");
                break;
            case "2":
                // 1 month
                testAge = (System.currentTimeMillis() - (30 * DAY_IN_MS)) / 1000l;
                p.modify("ageOptionText", "1 month");
                p.modify("ageOptionValue", "2");
                break;
            case "3":
                // 6 months
                testAge = (System.currentTimeMillis() - (183 * DAY_IN_MS)) / 1000l;
                p.modify("ageOptionText", "6 months");
                p.modify("ageOptionValue", "3");
                break;
            case "4":
                // 1 year
                testAge = (System.currentTimeMillis() - (365 * DAY_IN_MS)) / 1000l;
                p.modify("ageOptionText", "1 year");
                p.modify("ageOptionValue", "4");
                break;
            default:
                // default to 1 week
                testAge = (System.currentTimeMillis() - (7 * DAY_IN_MS)) / 1000l;
                p.modify("ageOptionText", "Select option");
                p.modify("ageOptionValue", "0");
        }
    }
    //If there aren't filter parameters
    if(request.getParameter("filterTestNames") == "" || request.getParameter("filterTestNames") == null){
        filterLength = 0;
        filterString = ";";
    }

    //Created to support multiple filters. No longer possible without major changes to code
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
            filterString += " AND test_name='" + filterTestName.get(i) + "'";
        }
        
        filterString += "AND last_updated > '" + testAge + "';";

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

    String nodeTestName = "singularity.sh";

    String nodeMessage = "SUPPORTED";

    //Filter "Sites" Page
    final DB sitesDB;
    final DB filterDB;

    boolean isFiltering = false;
    if(filterLength > 0) isFiltering = true;

    
    //Fetch tests for grouping and filters
    if(request.getParameter("grouping") == "" || request.getParameter("grouping") == null){
        //By default, grouping is set to singularity

        //No grouping but filter
        if(isFiltering){
             sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json -> 'SINGULARITY_CVMFS_SUPPORTED', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + testAge + "' AND test_name='singularity.sh' " + filterString);
             filterDB = new DB("SELECT sitesonar_tests.host_id, test_message_json -> '" + request.getParameter("JSONFilter")  + "', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + testAge  + "' " +  filterString);
        }
        //No filter and no grouping
        else{
            sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json -> 'SINGULARITY_CVMFS_SUPPORTED', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + testAge + "' AND test_name='singularity.sh';");
            filterDB = new DB();//EMPTY
        }
        
    }
    else{
        //Grouping and filter
        if(isFiltering){
            //sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json, ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + testAge + "' AND test_name='" + request.getParameter("grouping") + "'" + filterString);
            
            sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json -> '" + request.getParameter("JSONGroup") + "', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + testAge + "' AND test_name='" + request.getParameter("grouping") + "'");
            filterDB = new DB("SELECT sitesonar_tests.host_id, test_message_json -> '" + request.getParameter("JSONFilter")  + "', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + testAge + "' " + filterString);
        }
        //Only grouping
        else{
            sitesDB = new DB("SELECT sitesonar_tests.host_id, test_message_json -> '" + request.getParameter("JSONGroup") + "', ce_name, test_name FROM sitesonar_tests INNER JOIN sitesonar_hosts ON sitesonar_hosts.host_id = sitesonar_tests.host_id WHERE last_updated > '" + testAge + "' AND test_name='" + request.getParameter("grouping") + "';");
            filterDB = new DB();//EMPTY
        }
    }
    
    // Group by
    String groupingName = "singularity.sh";
    String groupMessage = "TRUE";
    String groupJSON = "SINGULARITY_CVMFS_SUPPORTED";
    if(request.getParameter("grouping") != null){
        groupingName = request.getParameter("grouping");
        groupMessage = "";
    }
    if(request.getParameter("JSONGroup") != null) groupJSON = request.getParameter("JSONGroup");
    if(request.getParameter("value") != null) groupMessage = request.getParameter("value");

    //Key: Site name, Value: count of supported groupings
    HashMap<String, Integer> countSupportForSites = new HashMap<String, Integer>();
    HashMap<String, Integer> countNotSupportForSites = new HashMap<String, Integer>();

    //Hashmap for checking if all filters are ok for a host_id. Values explained below
    //3: counted in countNotSupportForSites
    //2: counted in countSupportForSites
    //1: false if it was 2 remove -1 from countSupportForSites and add +1 to not support, 
    //0: init
    HashMap<String, Integer> filterSupportMap = new HashMap<String, Integer>();



    //TODO filter is not working properly

    //If there are filters, remove nodes that are filtered out
    if(isFiltering){

        //Init site name
        while(filterDB.moveNext()){

            String hostID = filterDB.gets(1);
            String JSONMessage = filterDB.gets(2);
            String ceName  = filterDB.gets(3);

            //Init element in hashmap for counting sites
            if(!countSupportForSites.containsKey(ceName)){
                countSupportForSites.put(ceName, 0);
                countNotSupportForSites.put(ceName, 0);
            }

            //Init element in hashmap for hostID
            if(!filterSupportMap.containsKey(hostID)){
                filterSupportMap.put(hostID, 0);
            }

            
            //No longer used: If message not equals filter message, put 1 to indicate it should be filtered out
            /*if(!JSONMessage.contains(filterTestMessage.get(0))){
                filterSupportMap.put(filterDB.gets(1), 1);
            }*/

            //INCLUDE the ones that pass the filter
            if(JSONMessage.contains(filterTestMessage.get(0))){
                filterSupportMap.put(filterDB.gets(1), 3);
            }
        }

        // Add elements which by grouping
        while(sitesDB.moveNext()){
            String hostID = sitesDB.gets(1);
            String JSONMessage = sitesDB.gets(2);
            String ceName  = sitesDB.gets(3);

            //Put ce_name field if empty, init with 0
            if(!countSupportForSites.containsKey(ceName)){
                countSupportForSites.put(ceName, 0);
                countNotSupportForSites.put(ceName, 0);
            }

            if(!filterSupportMap.containsKey(hostID)){
                filterSupportMap.put(hostID, 0);
            }

            
            //If test_message is correct and not hostid not visited, add message to already existing row
                if(JSONMessage.contains(groupMessage) && filterSupportMap.get(hostID) == 3){

                    //Count match with message
                    countSupportForSites.put(ceName, (countSupportForSites.get(ceName)+1));
                    
                    if(ceName.contains(sitenameAllNodes)){
                        addToNodeList(p, hostID, ceName, JSONMessage);
                    }
                    
                    //Set hostid to visited
                    filterSupportMap.put(hostID, 2);
                }
                else if(filterSupportMap.get(hostID) == 3){

                    //Count not matching with message
                    countNotSupportForSites.put(ceName, (countNotSupportForSites.get(ceName)+1));
                }
        }
    }
    //Not filtering
    else {
        //UPDATED TO JSON
        // Iterate over sitesonar_tests with no filters
        while(sitesDB.moveNext()){
            String hostID = sitesDB.gets(1);
            String JSONMessage = sitesDB.gets(2);
            String ceName  = sitesDB.gets(3);

            //Put ce_name field if empty, init with 0
            if(!countSupportForSites.containsKey(sitesDB.gets(3))){
                countSupportForSites.put(sitesDB.gets(3), 0);
                countNotSupportForSites.put(sitesDB.gets(3), 0);
            }

            //If test_message is correct, add groupMessage to already existing row

            //Contains instead of equals, since some string values are written, e.g "TRUE" instead of TRUE
            if(sitesDB.gets(2).contains(groupMessage)){
                countSupportForSites.put(sitesDB.gets(3), (countSupportForSites.get(sitesDB.gets(3))+1));
                if(ceName.contains(sitenameAllNodes)){
                        addToNodeList(p, hostID, ceName, JSONMessage);
                }
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
    
    listHeaderSupport.modify("header_name", groupJSON + " = " + groupMessage);
    listHeaderOther.modify("header_name", "Other worker nodes");
    listHeaderPercent.modify("header_name", "Worker nodes supported");
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

                //Only two decimal for percent
                listElement.modify("percent_support",  (Math.floor(percentSupport * 100) / 100) + "%");
                listElement.modify("total", total);
                p.append("testList", listElement);
            }
        }
    }

    //set values in index.res and append to master page
    setValuesForSiteSonarHTML(p, totalCEs, totalSupportedCEs, groupingName, groupJSON, groupMessage, resultSites);
    if(request.getParameter("filterTestNames") != null){
        p.modify("filterParam", request.getParameter("filterTestNames"));
    }
    if(request.getParameter("JSONFilter") != null){
        p.modify("filterJSONParam", request.getParameter("JSONFilter"));
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

    public void setValuesForSiteSonarHTML(Page p, int totalCEs, int totalSupportedCEs, String groupingName, String groupJSON, String groupMessage, int resultSites){
        p.modify("n_sites", totalCEs);
        float percentageTotal = (totalSupportedCEs * 100.0f) / (totalCEs);
        p.modify("percentTotal", (int) percentageTotal);
        p.modify("groupParam", groupingName);
        p.modify("groupJSONParam", groupJSON);
        p.modify("valueParam", groupMessage);
        p.modify("result_count", resultSites);
    }

    public void addToNodeList(Page p, String hostName, String ceName, String message){
        Page nodeList = new Page(null, "sitesonar/nodeList.res");
        nodeList.modify("host_name", hostName);
        nodeList.modify("ceName", ceName);
        nodeList.modify("message", message);
        p.append("nodeList", nodeList);
    }
%>