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
	// List
    HashMap<String, List<String>> hostIdsAndTests = new HashMap<String, List<String>>();
    
	Page listElement = new Page(null, "sitesonar/sonar_list.res");


    // Filters
    String[] filterCategory = {"test_name='singularity' AND test_message='SUPPORTED'"};
    int filters = filterCategory.length;
    String filterString = "";

    //TODO: put all filters together in for loop, to single string.
    for(int i = 0; i < filters; i++){
        filterString += filterCategory[i] + "OR";
    }

    Page filterElement = new Page(null, "sitesonar/filterItem.res");
    for(int i = 0; i < filters; i++){
        filterElement.modify("filter_name", filterCategory[i]);
        p.append("filters", filterElement);
    }

    final DB filteredDB = new DB("SELECT host_id, test_name FROM sitesonar_tests WHERE " + filterCategory[0] + ";");


    // Group by
    String grouping = "Support Singularity";


    // TODO: ERROR WITH f variable. How to add filters9
    // Fill hostIdsAndTests hashmap
    while(filteredDB.moveNext()){
        if(!hostIdsAndTests.containsKey(filteredDB.gets(1))){
            ArrayList<String> initList = new ArrayList<String>();
            initList.add(filteredDB.gets(2));
            hostIdsAndTests.put(filteredDB.gets(1), initList);
        }

        //add value to already existing row
        else{
            List<String> valueList = hostIdsAndTests.get(filteredDB.gets(1));
            valueList.add(filteredDB.gets(2));
            hostIdsAndTests.put(filteredDB.gets(1), valueList);
        }
    }

    //test hashmap
    HashMap<String, int[]> testHash = new HashMap<String, int[]>();
    int initA[] = { 1, 2, 3 };
    int initB[] = { 5, 5, 5 };
    testHash.put("A", initA);
    testHash.put("B",initB);
    out.println("A: " + testHash.get("A")[1]);
    out.println("B: " + testHash.get("B")[1]);

    // TODO: Add tests to site.
    //Loop over HashMap
        for (String key : hostIdsAndTests.keySet()){

            //Get ce name for this 
            final DB ceNameDB = new DB("SELECT ce_name FROM sitesonar_hosts WHERE host_id=" + key + ";");
            String ceName = ceNameDB.gets(1);
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
        }

    //out.println("CERN:" + siteCEs.get("CERN")[0]);
    //out.println("ISS:" + siteCEs.get("ISS")[0]);
    //Render list
    Page listHeaderSupport = new Page(null, "sitesonar/listHeader.res");
    Page listHeaderNotSupport = new Page(null, "sitesonar/listHeader.res");
    listHeaderSupport.modify("header_name", grouping);
    listHeaderNotSupport.modify("header_name", "Not supported");
    
    p.append("list_header", listHeaderSupport);
    p.append("list_header", listHeaderNotSupport);
    final DB listDB = new DB("SELECT host_id FROM sitesonar_tests");

    for(int i = 0; i < sites.size(); i++) {
        listElement.modify("site_name", sites.get(i));
        listElement.modify("group_by", siteCEs.get(sites.get(i))[0]);
        listElement.modify("not_group_by", siteCEs.get(sites.get(i))[1]);
        p.append("testList", listElement);
    }
    p.modify("n_sites", sites.size());

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
 container_enabled
 lsb_release
 os
 ram_info
 cpu_info
 wlcg_metapackage
 overlay
 uname
 cpu_info
 running_container
 cpuset_checking
 isolcpus_checking
 underlay
 uname
 max_namespaces
 lhcbmarks
 singularity
 taskset_own_process
 container_enabled
 cpuset_checking
 lsb_release
 cpuset_checking
 running_container
 cvmfs_version
 wlcg_metapackage
 wlcg_metapackage
 uname
 tmp
 max_namespaces
 uname
 lsb_release
 lhcbmarks
 underlay
 overlay
 get_jdl_cores
 max_namespaces
 cvmfs_version
 gcc_version
 container_enabled
 running_container
 singularity
 underlay
 overlay
 lsb_release
 gcc_version
 cgroups2_checking
 max_namespaces
 lsb_release
 os.sh
 overlay.sh
 ram_info
 overlay
 lsb_release
 lhcbmarks
 taskset_own_process
 lsb_release
 cpulimit_checking
 max_namespaces
 overlay
 gcc_version.sh
 home.sh
 lhcbmarks.sh
 loop_devices.sh
 lsb_release.sh
 max_namespaces.sh
 os.sh
 overlay.sh
 ram_info.sh
 lsb_release
 isolcpus_checking
 uname
 loop_devices
 get_jdl_cores
 cpulimit_checking
 cpu_info
 taskset_own_process
 wlcg_metapackage
 wlcg_metapackage
 tmp
 home
 lsb_release
 isolcpus_checking
 uname
 loop_devices
 get_jdl_cores
 taskset_other_processes
 max_namespaces
 cvmfs_version
 lhcbmarks
 singularity
 taskset_other_processes
 singularity
 overlay
 taskset_other_processes
 taskset_own_process
    */
%>

<%!

    public void getFilteredList(Page p){
        
    }

%>