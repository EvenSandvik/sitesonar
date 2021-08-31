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
     

    // ------------------- 
    // Sites drop-down

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

	//create DB request to site sonar values
    final DB db = new DB("SELECT DISTINCT ce_name FROM sitesonar_hosts");
    //final DB db = new DB("select name,contact_name,contact_email,version,java_ver,get_pledged(name, 2) AS ksi2k,ip from abping_aliases where name in (select name from alien_sites) order by lower(name) asc;");

    long lKSI2K=0;

    String sHostName = null;
    
    boolean bHostNameResolved = false;

    // save the site
    final Cookie cookie = new Cookie("sitesonar_site", sSite);
    cookie.setMaxAge(Integer.MAX_VALUE);
    cookie.setHttpOnly(true);
    response.addCookie(cookie); 
    // -------------

    pMaster.modify("title", "WLCG Configuration Monitoring Tool for "+sSite);
    pMaster.modify("bookmark", "/siteinfo/?site="+Format.encode(sSite));
    
    p.modify("site", sSite);

    // -------------------
	// Site ID
	Page siteId = new Page(null, "sitesonar/sonarDropdown.res");
	Page siteElement = new Page(null, "sitesonar/dropdownElement.res");
	siteId.modify("dTitle", "Site ID");
	siteId.modify("dHidden", "Select a site ID");

    ArrayList<String> sites = new ArrayList<String>();

    HashMap<String, int[]> siteCEs = new HashMap<String, int[]>();

    while (db.moveNext()){
        siteElement.modify("dValue", db.gets(1));

        //add list
        sites.add(db.gets(1));
		siteId.append("dropdownItem", siteElement);

        int init[] = {0,0};
        //Initialize siteCEs
        siteCEs.put(db.gets(1), init);
    }
    p.append("siteId", siteId);


    // -------------------

    //TODO: should this logic be in the index.res script?? Because it needs the button clicks on the page
	// List
    HashMap<String, Integer> hostIdsAndTests = new HashMap<String, Integer>();
    
	Page listElement = new Page(null, "sitesonar/sonar_list.res");
    Page filterElement = new Page(null, "sitesonar/filterItem.res");


    // Filters
    // Collect host_ids of tests that satisfy filter
    String[] filterCategory = {"test_name='singularity' AND test_message='SUPPORTED'"};


    String filterTestName = {"overlay"}
    String filterTestMessage = {"enable overlay = no"}    
    int filters = filterCategory.length;
    String filterString = "";


    //Put filters together
    for(int i = 0; i < filters; i++){
        filterString += filterCategory[i] + "OR";
    }
    //Render filters
    for(int i = 0; i < filters; i++){
        filterElement.modify("filter_name", filterCategory[i]);
        p.append("filters", filterElement);
    }


    final DB entireDB;

    //By default, grouping is set to singularity
    if(request.getParameter("grouping") == "" || request.getParameter("grouping") == null){
        entireDB = new DB("SELECT host_id, test_message, site_name FROM sitesonar_tests WHERE test_name='singularity';");
    }
    else{
        entireDB = new DB("SELECT host_id, test_message, site_name FROM sitesonar_tests WHERE test_name='" + request.getParameter("grouping") + "';");
    }
    

    // Group by
    String g = "singularity";
    String value = "SUPPORTED";
    if(request.getParameter("value") != null){
        value = request.getParameter("value");
        g = request.getParameter("grouping");
    }

    //test update
    //new DB("UPDATE sitesonar_tests SET site_name='' WHERE host_id = '1236838004' ;");

    


    //Key: Site name, Value: count of supported groupings
    HashMap<String, Integer> countSupportForSites = new HashMap<String, Integer>();
    HashMap<String, Integer> countNotSupportForSites = new HashMap<String, Integer>();
    // Initialize hostIdsAndTests hashmap
    while(entireDB.moveNext()){

        //Fill site_name field if empty. TODO: test comment out and speed increase
        /*if(entireDB.gets(3) == "" || entireDB.gets(3) == null || entireDB.gets(3).length() == 0){
            String key = entireDB.gets(1);
            DB stringName = new DB("SELECT ce_name FROM sitesonar_hosts WHERE host_id='" + key + "';");
            new DB("UPDATE sitesonar_tests SET site_name='" + stringName.gets(1) + "' WHERE host_id = '" + key + "' ;");
        }*/


        ////////TODO: Create new branch. drop hashmap, just go straight to counting. Maybe hashmap with [sitename, countWhichSupportGrouping]
        if(!countSupportForSites.containsKey(entireDB.gets(3))){
            countSupportForSites.put(entireDB.gets(3), 0);
            countNotSupportForSites.put(entireDB.gets(3), 0);
        }

        //add value to already existing row
        if(entireDB.gets(2).equals(value)){
            countSupportForSites.put(entireDB.gets(3), (countSupportForSites.get(entireDB.gets(3))+1));
        }
        else{
            countNotSupportForSites.put(entireDB.gets(3), (countNotSupportForSites.get(entireDB.gets(3))+1));
        }
    }

    // TODO: Add tests to site.
    //Loop over HashMap
        /*for (String key : hostIdsAndTests.keySet()){

            //Get ce name for this 
            //final DB ceNameDB = new DB("SELECT ce_name FROM sitesonar_hosts WHERE host_id=" + key + ";");
            String ceName = entireDB.gets(3);

            //Check if it is supported or not according to grouping
            final DB supportGrouping = new DB("SELECT test_message FROM sitesonar_tests WHERE host_id=" + key + " AND test_name='singularity';");
            
            //out.println(supportGrouping.gets(1));


            //TODO: bug here. It adds one to all arrays
            //For singularity
            if(supportGrouping.gets(1).equals("SUPPORTED")){
                //out.println(ceName);
                int[] ceArray = siteCEs.get(ceName);
                ceArray[0] += 1;
                siteCEs.put(ceName, ceArray);
                //out.println(ceName + ": " + siteCEs.get(ceName)[0]);
            }
            else{
                //out.println(ceName);
                int[] ceArray = siteCEs.get(ceName);
                ceArray[1] += 1;
                siteCEs.put(ceName, ceArray);
            }
        }*/


    //Render list
    Page listHeaderSupport = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderNotSupport = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderTotal = new Page(null, "sitesonar/listHeader.res");
    listHeaderSupport.modify("header_name", value);
    listHeaderNotSupport.modify("header_name", "CE's supported");
    listHeaderTotal.modify("header_name", "Total");
    
    p.append("list_header", listHeaderSupport);
    p.append("list_header", listHeaderNotSupport);
    p.append("list_header", listHeaderTotal);
    final DB listDB = new DB("SELECT host_id FROM sitesonar_tests");

    int totalCEs = 0;
    int totalSupportedCEs = 0;

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

        listElement.modify("site_name", sites.get(i));
        listElement.modify("group_by", countSupportForSites.get(sites.get(i)));
        listElement.modify("not_group_by", percentSupport + "%");
        listElement.modify("total", total);
        p.append("testList", listElement);
    }


    //TODO: change to total CE's
    p.modify("n_sites", totalCEs);
    float percentageTotal = (totalSupportedCEs * 100.0f) / (totalCEs);
    p.modify("percentTotal", (int) percentageTotal);
    p.modify("groupParam", g);
    p.modify("valueParam", value);

    pMaster.append(p);
    
    pMaster.write();
    
    out.println(new String(baos.toByteArray()));
    
    lia.web.servlets.web.Utils.logRequest("/siteinfo/index.jsp?site="+sSite, baos.size(), request);



//Very slow sql query for counting sites.
//SELECT COUNT (test.host_id) FROM sitesonar_tests AS test, sitesonar_hosts AS host WHERE ce_name='CERN';

    /*
 home
 container_enabled.sh
 cpu_info.sh
 cvmfs_version.sh
 singularity
 os
 overlay
 cpu_info
 isolcpus_checking
 cpuset_checking
 wlcg_metapackage
 tmp
 uname
 cvmfs_version
 running_container
 underlay
 gcc_version
 cgroups2_checking
 overlay.sh
 ram_info
 lhcbmarks
 gcc_version.sh
 home.sh
 lhcbmarks.sh
 loop_devices.sh
 lsb_release.sh
 max_namespaces.sh
 os.sh
 ram_info.sh
 cpulimit_checking
 lsb_release
 loop_devices
 get_jdl_cores
 taskset_other_processes
 max_namespaces
 taskset_own_process
    */
%>

<%!

    public void getFilteredList(Page p){
        
    }

%>