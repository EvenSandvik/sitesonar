<style type="text/css">
//percentage circle

.flex-wrapper {
  display: flex;
  flex-flow: row nowrap;
}

.single-chart {
  width: 100%;
  justify-content: space-around ;
}

.circular-chart {
  display: block;
  margin: 0 auto;
  max-width: 80%;
  max-height: 250px;
}

.circle-bg {
  fill: none;
  stroke: #eee;
  stroke-width: 3.8;
}

.circle {
  fill: none;
  stroke-width: 2.8;
  stroke-linecap: round;
  animation: progress 1s ease-out forwards;
}

@keyframes progress {
  0% {
    stroke-dasharray: 0 100;
  }
}

.circular-chart.orange .circle {
  stroke: #ff9f00;
}

.circular-chart.green .circle {
  stroke: #4CC790;
}

.circular-chart.blue .circle {
  stroke: #3c9ee5;
}

.percentage {
  fill: #666;
  font-family: sans-serif;
  font-size: 0.5em;
  text-anchor: middle;
}

//circle end


.sonar-title{
    font-family: Verdana,Arial,Helvetica,sans-serif;
    font-size: 12px;
    font-weight: bold;
    color: #000000;
    text-decoration: none;
}
.list-element{
    padding: 0.75rem;
}
.filter-button{
    background-color: #EBEBEB;
    color: #757575;
    border: none;
    font-size: 1rem;
    border-radius: 0.4rem;
    display: flex;
    outline: none;
}
.filter-button:hover{
    transition: 0.25s;
    background-color: #F8F8F8;
    color: #939393;
}

/*CSS for add filter button elements*/
    .dropdown-modal {
      display: none;
      z-index: 1;
      left: 2rem;
      top: 0rem;
      width: fit-content;
      height: fit-content;
      overflow: auto;
      box-shadow: 0px 2px 2px 2px rgb(0 0 0 / 10%);
      margin-right: 0.5rem;
    }

    .filter-category {
      padding: 0.25rem 0.5rem;
      font-size: 1rem;
      margin: 0;
      min-width: 8rem;
      height: 1rem;
    }
    .filter-category:hover {
      background-color: rgb(240, 240, 240);
    }
    .filter-list {
      list-style-type: none;
      padding: 0;
      margin: 0;
    }
    .addfilter-button {
      background: #ebebeb;
      border-radius: 6px;
      border: none;
      padding: 0.2rem 1rem;
      color: #727272;
      width: 7rem;
    }
    .addfilter-button:hover {
      transition: 200ms;
      background: #f5f5f5;
      color: #9c9c9c;
    }
    .addfilter-button:active {
      transition: 100ms;
      background: #f5f5f5;
      color: #d8d8d8;
    }

    .filter-selected-menu {
      display: none;
      min-width: 11rem;
      max-width: 20rem;
      height: fit-content;
      box-shadow: 0px 2px 2px 2px rgb(0 0 0 / 10%);
    }

    .pageButton {
      border: none;
      background: none;
      font-size: 1rem;
      margin-right: 1rem;
    }

</style>

<div style="font-family:Verdana,Helvetica,Arial,sans-serif;">
    <div style="display:flex; position:relative">
    <h3 style="color:#898989">WLCG Configuration Monitoring Tool</h3>
    <button style="position:absolute; top:0; right:0; display:flex; align-items: center; height:fit-content; width:fit-content;border:none;background:none;">
        <img src="http://pngimg.com/uploads/share/share_PNG52.png" alt="" style="height:15px; padding: 0 2px 4px 0;"></img>
        <p style="color:#646464;margin:0;">Share</p>
    </button>
    </div>
    <div style="text-align: justify">
                    <div id="contentwrapper" align=center" style="padding-bottom:30px, padding-left: 30px">

                        <p style="margin:4px 0 2px 0; border-bottom: 1px solid #9B9B9B;"><button id="sitesBtn" class="pageButton" style="border-bottom: 3px solid #478BF2;">Sites</button><button id="nodesBtn" class="pageButton">All nodes</button></p>
                        <div id="sitesPage" style="position:relative">
                        <h3 style="margin:4px 0 2px 0;">Filter Sites</h3>
                        <p style="color:#929292; font-size:12px;margin:0">Filter out results from fetched grid sites</p>

                        <div style="position:absolute; right:0; top: 0; display:flex;">
                            <div style="margin-right:1rem">
                            <p style="margin-bottom: 0">Covered</p> 
                            <div class="flex-wrapper">
                                <div class="single-chart">
                                    <svg viewBox="0 0 36 36" class="circular-chart green">
                                    <path class="circle-bg"
                                        d="M18 2.0845
                                        a 15.9155 15.9155 0 0 1 0 31.831
                                        a 15.9155 15.9155 0 0 1 0 -31.831"
                                    />
                                    <path class="circle"
                                        stroke-dasharray="60, 100"
                                        d="M18 2.0845
                                        a 15.9155 15.9155 0 0 1 0 31.831
                                        a 15.9155 15.9155 0 0 1 0 -31.831"
                                    />
                                    <text x="18" y="20.35" class="percentage"> (<<:covered_count:>> / <<:result_count:>>) </text>
                                    </svg>
                                </div>
                                </div>
                            </div>
                            <div><p>Total</p> <p><<:n_sites:>></p></div>
                        </div>
                        <br></br>
                        <div>
                          <button id="myBtn" class="addfilter-button">Add filter +</button>

                          <div style="display: flex">
                            <div id="myModal" class="dropdown-modal">
                              <ul class="filter-list">
                                <li id="liCustom" class="filter-category">Custom Parameter</li>
                                <li id="liHMD"><p class="filter-category">HMD</p></li>
                                <li id="liLoop" class="filter-category">Loop devices</li>
                                <li id="liContainer" class="filter-category">Container enables</li>
                                <li id="liUname" class="filter-category">Uname</li>
                                <li id="liSingularity" class="filter-category">Singularity</li>
                                <li id="liTMP" class="filter-category">TMP</li>
                                <li id="liUnderlay" class="filter-category">Underlay</li>
                                <li id="liOverlay" class="filter-category">Overlay</li>
                              </ul>
                            </div>

                            <!-- All menus -->
                            <div id="custom" class="filter-selected-menu">
                              <p>Custom parameter</p>
                              <input type="text" />
                              <input type="submit" />
                            </div>
                            <div id="HMD" class="filter-selected-menu">
                              <ul class="filter-list">
                                <li class="filter-category">Show home directory</li>
                              </ul>
                            </div>
                            <div id="loopDevices" class="filter-selected-menu">
                              <p>TODO: Loop devices, what is a loop device</p>
                            </div>
                            <div id="containerEnabled" class="filter-selected-menu">
                              <ul class="filter-list">
                                <li class="filter-category">All</li>
                                <li class="filter-category">Docker</li>
                                <li class="filter-category">Singularity</li>
                                <li class="filter-category">No container</li>
                              </ul>
                            </div>
                            <div id="uname" class="filter-selected-menu">
                              <ul class="filter-list">
                                <li class="filter-category">Show uname</li>
                              </ul>
                            </div>
                            <div id="singularity" class="filter-selected-menu">
                              <ul class="filter-list">
                                <li class="filter-category">All</li>
                                <li class="filter-category">Support singularity</li>
                                <li class="filter-category">Not support singularity</li>
                              </ul>
                            </div>
                            <div id="TMP" class="filter-selected-menu">
                              <ul class="filter-list">
                                <li class="filter-category">Show tmp folder</li>
                              </ul>
                            </div>
                            <div id="underlay" class="filter-selected-menu">
                              <ul class="filter-list">
                              <li class="filter-category">All</li>
                                <li class="filter-category">Underlay enabled</li>
                                <li class="filter-category">Underlay disabled</li>
                              </ul>
                            </div>
                            <div id="overlay" class="filter-selected-menu">
                              <ul class="filter-list">
                                <li class="filter-category">All</li>
                                <li class="filter-category">Don't enable overlay</li>
                                <li class="filter-category">Try enable overlay</li>
                              </ul>
                            </div>
                          </div>
                        </div>
                        
                        <div style="display: flex;">
                          <<:filters:>>
                        </div>

                        <div>
                          <button class="addfilter-button">Group by</button>
                        </div>
                        <button class="addfilter-button" style="position:absolute;right: 0; color: #5188CA;padding: 0.5rem 1rem;">Apply</button>

                        <table style="width:100%; margin-top:3rem;">
                            <tr style="background-color: #F2F2F2;">
                                <th class="list-element" style="color: #757575; font-weight: bold; ">Site Name</th>
                                <<:list_header:>>
                            </tr>
                            <<:testList:>>
                        </table>
                        </div>
                        <p><<:result_count:>> results</p>
                    </div>

                    <div id="AllNodesPage" style=-"display: none;">
                      <<:siteId:>>
                    
                    </div>
                   
    </div>
</div>

<script type="text/javascript">

    function fetchCE() {
      HashMap<String, List<String>> hostIdsAndTests = new HashMap<String, List<String>>();
    
	    Page listElement = new Page(null, "sitesonar/sonar_list.res");
      Page filterElement = new Page(null, "sitesonar/filterItem.res");

      final DB filteredDB = new DB("SELECT host_id, test_name FROM sitesonar_tests;");

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
    }

    var sitesButton = document.getElementById("sitesBtn");
    
    var nodesButton = document.getElementById("nodesBtn");

    var sitesPage = document.getElementById("sitesPage");

    var nodesPage = document.getElementById("AllNodesPage");

   

    sitesButton.onclick = function () {
      console.log("clicked sites button");
      sitesPage.style.display = "block";
      nodesPage.style.display = "none";

      sitesButton.style.borderBottom = "3px solid ##478BF2";
      nodesPage.style.borderBottom = "none";
    };

    nodesButton.onclick = function () {
      console.log("clicked All nodes button");
      sitesPage.style.display = "none";
      nodesPage.style.display = "block";

      sitesButton.style.borderBottom = "none";
      nodesPage.style.borderBottom = "3px solid ##478BF2";
    };

    var showModal = false;

    // Get the modal
    var modal = document.getElementById("myModal");

    // Get the button that opens the modal
    var btn = document.getElementById("myBtn");

    //Get custom parameter list item
    var liCustom = document.getElementById("liCustom");

    var customParameter = document.getElementById("custom");

    //Get HMD list item
    var liHMD = document.getElementById("liHMD");

    var HMD = document.getElementById("HMD");

    //loop devices
    var liLoopDevices = document.getElementById("liLoop");

    var loopDevices = document.getElementById("loopDevices");

    //Container
    var liContainer = document.getElementById("liContainer");

    var container = document.getElementById("containerEnabled");

    //uname
    var liUname = document.getElementById("liUname");

    var uname = document.getElementById("uname");

    //Singularity
    var liSIngularity = document.getElementById("liSIngularity");

    var singularity = document.getElementById("singularity");

    //TMP
    var liTMP = document.getElementById("liTMP");

    var TMP = document.getElementById("TMP");

    //Underlay
    var liUnderlay = document.getElementById("liUnderlay");

    var underlay = document.getElementById("underlay");

    //Overlay
    var liOverlay = document.getElementById("liOverlay");

    var overlay = document.getElementById("overlay");

    //Hovering custom
    liCustom.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      customParameter.style.display = "block";
    });

    //when hover over HMD
    liHMD.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      HMD.style.display = "block";
    });

    //when hover over loop devices
    liLoopDevices.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      loopDevices.style.display = "block";
    });

    //Hovering Container
    liContainer.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      container.style.display = "block";
    });

    //Hovering Uname
    liUname.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      uname.style.display = "block";
    });

    //Hovering Singularity
    liSingularity.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      singularity.style.display = "block";
    });

    //Hovering TMP
    liTMP.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      TMP.style.display = "block";
    });

    //Hovering Underlay
    liUnderlay.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      underlay.style.display = "block";
    });

    //Hovering Overlay
    liOverlay.addEventListener("mouseenter", function (event) {
      hideAllFilters();
      overlay.style.display = "block";
    });

    // When the user clicks on the button, open the modal
    btn.onclick = function () {
      if (!showModal) {
        modal.style.display = "block";
        showModal = true;
      } else {
        hideAllFilters();
        modal.style.display = "none";
        showModal = false;
      }
    };

    // When the user clicks anywhere outside of the modal, close it
    window.onclick = function (event) {
      if (event.target != btn && event.target != modal) {
        hideAllFilters();
        modal.style.display = "none";
        showModal = false;
      }
    };

    //function for hiding all list extensions
    function hideAllFilters() {
      customParameter.style.display = "none";
      HMD.style.display = "none";
      loopDevices.style.display = "none";
      container.style.display = "none";
      uname.style.display = "none";
      singularity.style.display = "none";
      TMP.style.display = "none";
      underlay.style.display = "none";
      overlay.style.display = "none";
    }

</script>
