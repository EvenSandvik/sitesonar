<!-- HTML and js functions for the Site Sonar web interface -->

<div style="font-family:Verdana,Helvetica,Arial,sans-serif;">
   <div style="display:flex; position:relative">
      <h3 style="color:#898989">WLCG Configuration Monitoring Tool</h3>
      <button onClick="toggleShareButton()" id="shareBtn" style="position:absolute; top:0; right:0; display:flex; align-items: center; height:fit-content; width:fit-content;border:none;background:none;">
         <img src="http://pngimg.com/uploads/share/share_PNG52.png" alt="" style="height:15px; padding: 0 2px 4px 0;"></img>
         <p style="color:#646464;margin:0;">Share</p>
      </button>
      <div id="shareModal" style="position: absolute;top: 1.5rem;border-radius: 0.5rem;right: 0;border: 1px solid #DDD;padding: 0.8rem 1rem;display: none;">Link: <input id="shareLinkElement" type="text" readonly style="width: 11rem;"/></div>
   </div>
   <div style="text-align: justify">
      <div id="contentwrapper" align=center" style="padding-bottom:30px, padding-left: 30px">
         <p style="margin:4px 0 2px 0; border-bottom: 1px solid #9B9B9B;"><button id="sitesBtn" class="pageButton" style="border-bottom: 3px solid #478BF2;">Sites</button><button id="nodesBtn" class="pageButton">All nodes</button></p>
         <div id="sitesPage" style="position:relative">
            <h3 style="margin:1rem 0 0.5rem 0;">Filter Sites</h3>
            <p style="color:#929292; font-size:12px;margin:0">Filter out results from fetched grid sites</p>
            <div style="position:absolute; right:0; top: 0; display:flex;">
               <div style="margin-right:1rem">
                  <p style="margin-bottom: 0">Covered</p>
                  <div class="flex-wrapper" style="width: 5rem">
                     <div class="single-chart">
                        <svg viewBox="0 0 36 36" class="circular-chart green">
                           <path class="circle-bg"
                              d="M18 2.0845
                              a 15.9155 15.9155 0 0 1 0 31.831
                              a 15.9155 15.9155 0 0 1 0 -31.831"
                              />
                           <path class="circle"
                           stroke-dasharray=<<:percentTotal:>> + ", 100"
                           d="M18 2.0845
                           a 15.9155 15.9155 0 0 1 0 31.831
                           a 15.9155 15.9155 0 0 1 0 -31.831"
                           />
                           <text x="18" y="20.35" class="percentage">
                              <<:percentTotal:>>%
                           </text>
                        </svg>
                     </div>
                  </div>
               </div>
               <div>
                  <p>Total</p>
                  <p>
                     <<:n_sites:>>
                  </p>
               </div>
            </div>
            <br></br>
            <div id="filterButtonWrapper" style="display: contents;">
               <button id="filterBtn" class="addfilter-button">Filter</button>
               <div style="display: flex; width: -moz-fit-content;position: absolute;background-color: #FFF;">
                  <div id="filterModal" class="dropdown-modal">
                     <ul class="filter-list">
                        <li id="liCustom" class="filter-category">Custom Parameter</li>
                        <li id="liHMD">
                           <p class="filter-category">HMD</p>
                        </li>
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
                  <div id="custom" class="filter-selected-menu" style="padding: 1rem;">
                     <p style="margin: 0;font-size: 0.8rem;color: #555;">Name</p>
                     <input id="customFilterParameter" type="text" />
                     <p style="margin: 0;font-size: 0.8rem;color: #555;">JSON parameter</p>
                     <input id="customFilterJSONParameter" type="text" />
                     <p style="margin: 0;font-size: 0.8rem;color: #555;margin-top: 1rem;">Value</p>
                     <input id="customFilterValueParameter" type="text" />
                     <button onClick="cancel()" class="cancelButton">Cancel</button>
                     <button onClick="customFiltering()" class="submitButton">Submit</button>
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
                        <li class="filter-category" onClick="setFilter('singularity', 'SUPPORTED')">Support singularity</li>
                        <li class="filter-category" onClick="setFilter('singularity', '')">Not support singularity</li>
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
            <div>
               <p id="filteringText" style="font-size: 0.85rem; color: #444; margin: 0;">
                  <<:filterParam:>> <<:filterValueParam:>>
               </p>
            </div>
            <br></br>
            <div id="groupButtonWrapper" style="display: contents;">
               <button id="groupBtn" class="addfilter-button">Add grouping +</button>
               <div style="display: flex;position: absolute;background-color: #FFF;">
                  <div id="groupModal" class="dropdown-modal">
                     <ul class="filter-list">
                        <li id="liCustomGroup" class="filter-category">Custom Parameter</li>
                        <li id="liHMDGroup">
                           <p class="filter-category">HMD</p>
                        </li>
                        <li id="liLoopGroup" class="filter-category">Loop devices</li>
                        <li id="liContainerGroup" class="filter-category">Container enables</li>
                        <li id="liUnameGroup" class="filter-category">Uname</li>
                        <li id="liSingularityGroup" class="filter-category">Singularity</li>
                        <li id="liTMPGroup" class="filter-category">TMP</li>
                        <li id="liUnderlayGroup" class="filter-category">Underlay</li>
                        <li id="liOverlayGroup" class="filter-category">Overlay</li>
                     </ul>
                  </div>

                  <!-- All menus -->
                  <div id="customGroup" class="filter-selected-menu" style="padding: 1rem;">
                     <p style="margin: 0;font-size: 0.8rem;color: #555;">Name</p>
                     <input id="customGroupParameter" type="text" />
                     <p style="margin: 0;font-size: 0.8rem;color: #555;">JSON</p>
                     <input id="customGroupJSONParameter" type="text" />
                     <p style="margin: 0;font-size: 0.8rem;color: #555;margin-top: 1rem;">Value</p>
                     <input id="customValueParameter" type="text" />
                     <button onClick="cancel()"  class="cancelButton">Cancel</button>
                     <button onClick="customGrouping()" class="submitButton">Add</button>
                  </div>
                  <br></br>
                  <div id="HMDGroup" class="filter-selected-menu">
                     <ul class="filter-list">
                        <li class="filter-category">Show home directory</li>
                     </ul>
                  </div>
                  <div id="loopDevicesGroup" class="filter-selected-menu">
                     <p>TODO: Loop devices, what is a loop device</p>
                  </div>
                  <div id="containerEnabledGroup" class="filter-selected-menu">
                     <ul class="filter-list">
                        <li class="filter-category">All</li>
                        <li class="filter-category">Docker</li>
                        <li class="filter-category">Singularity</li>
                        <li class="filter-category">No container</li>
                     </ul>
                  </div>
                  <div id="unameGroup" class="filter-selected-menu">
                     <ul class="filter-list">
                        <li class="filter-category">Show uname</li>
                     </ul>
                  </div>
                  <div id="singularityGroup" class="filter-selected-menu">
                     <ul class="filter-list">
                        <li class="filter-category">All</li>
                        <li class="filter-category" onclick="setParameters('singularity', 'SUPPORTED')">Support singularity</li>
                        <li class="filter-category" onclick="setParameters('singularity', '')">Not support singularity</li>
                     </ul>
                  </div>
                  <div id="TMPGroup" class="filter-selected-menu">
                     <ul class="filter-list">
                        <li class="filter-category">Show tmp folder</li>
                     </ul>
                  </div>
                  <div id="underlayGroup" class="filter-selected-menu">
                     <ul class="filter-list">
                        <li class="filter-category">All</li>
                        <li class="filter-category">Underlay enabled</li>
                        <li class="filter-category">Underlay disabled</li>
                     </ul>
                  </div>
                  <div id="overlayGroup" class="filter-selected-menu">
                     <ul class="filter-list">
                        <li class="filter-category">All</li>
                        <li class="filter-category">Don't enable overlay</li>
                        <li class="filter-category">Try enable overlay</li>
                     </ul>
                  </div>
               </div>
            </div>
            <div style="background-color: #EFEFEF; border-radius: 10rem; display: table; padding: 0.5rem 1rem;">
               <p id="groupingText" style="margin: 0; font-size: 0.7rem; color: #444;">
                  <<:groupParam:>>: <<:valueParam:>>
               </p>
            </div>
            <!-- <div style="display: flex;">
               <<:filters:>>
               </div> -->
            <button onclick="replace_search('grouping')" class="addfilter-button" style="position:absolute;right: 0; color: #5188CA;padding: 0.5rem 1rem;">Apply</button>
            <table style="width:100%; margin-top:3rem; border-spacing: 0;">
               <tr style="background-color: #c7daff;text-align: left;">
                  <th class="list-element" style="font-weight: bold; ">Site Name</th>
                  <<:list_header:>>
               </tr>
               <<:testList:>>
            </table>
            <p>
            <<:result_count:>> results
            </p>
         </div>
      </div>
      <div id="AllNodesPage" style="display: none;">
         <<:siteId:>>

         <p>TODO: Filter button</p>



         <table style="width:100%; margin-top:3rem; border-spacing: 0;">
               <tr style="background-color: #c7daff;text-align: left;">
                  <th class="list-element" style="font-weight: bold; ">Host name</th>
                  <th>Address</th>
                  <th class="list-element">Message</th>
               </tr>
               <<:nodeList:>>
            </table>
         
      </div>
   </div>
</div>
<script type="text/javascript">

   //Set these values
   var groupingParam = "<<:groupParam:>>";

   var groupJSONParam = "<<:groupJSONParam:>>";
   
   var valueParam = "<<:valueParam:>>";
   
   var filterArrayParam = "<<:filterParam:>>";

   var filterJSONParam = "<<:filterJSONParam:>>";
   
   var filterValueParam = "<<:filterValueParam:>>";
   
   
   function setParameters(group, val){
     groupingParam = group;
     valueParam = val;
   }
   
   function changeGroupText(){
     if(groupingParam != ""){
       document.getElementById("groupingText").innerHTML = groupingParam + ": " + valueParam;
     }
   }
   
   function changeFilterText(){
     if(filterArrayParam != ""){
       document.getElementById("filteringText").innerHTML = filterArrayParam + ": " + filterValueParam;
     }
   }
   
   
   
   function customGrouping() {
     groupingParam = document.getElementById("customGroupParameter").value;
     groupJSONParam = document.getElementById("customGroupJSONParameter").value;
     valueParam = document.getElementById("customValueParameter").value;
     changeGroupText();
     cancel();
   }
   
   function customFiltering() {
     filterArrayParam = document.getElementById("customFilterParameter").value;
     filterJSONParam = document.getElementById("customFilterJSONParameter").value;
     filterValueParam = document.getElementById("customFilterValueParameter").value;
     changeFilterText();
     cancel();
   }
   
   
   //add parameters to url when clicking apply
   function replace_search(name) {
     var url = "";
     /*if (new RegExp("[&?]"+name+"([=&].+)?$").test(url)) {
           url = url.replace(new RegExp("(?:[&?])"+name+"[^&]*", "g"), "")
       }*/
   
     if(groupingParam != ""){
       //Add grouping parameter
       url += "?grouping=" + groupingParam;

       url += "&JSONGroup=" + groupJSONParam;
   
       if(valueParam != ""){
         url += "&value=" + valueParam;
       }
       else{
         //Must have value
       }
   
       if(filterArrayParam != ""){
         url += "&filterTestNames=" + filterArrayParam;
         url += "&JSONFilter=" + filterJSONParam;
         if(filterValueParam != ""){
           url += "&filterTestMessages=" + filterValueParam;
         }
       }
       
     }
     else{
       //Must have grouping
       if(filterArrayParam != ""){
         url += "?filterTestNames=" + filterArrayParam;
         url += "&JSONFilter=" + filterJSONParam;
         if(filterValueParam != ""){
           url += "&filterTestMessages=" + filterValueParam;
         }
       }
   
     }
       // there is an official order for the query and the hash
       location.assign(location.origin + location.pathname + url + location.hash)
   };
   
   //function for hiding all list extensions
   /*function requestAndRefresh() {
     console.log("Clicked apply");
     var xhr = new XMLHttpRequest();
     xhr.open("POST", "http://localhost:8080/sitesonar/", true);
     xhr.setRequestHeader('Content-Type', 'application/json');
     xhr.send(JSON.stringify({
         value: "testValue"
     }));
   
     var xhr = new XMLHttpRequest();
     // we defined the xhr
   
     xhr.onreadystatechange = function () {
         if (this.readyState != 4) return;
   
         if (this.status == 200) {
             var data = JSON.parse(this.responseText);
   
             // we get the returned data
         }
   
         // end of state change: it can be after some time (async)
     };
   
     xhr.open('GET', "http://localhost:8080/sitesonar/", true);
     xhr.send();
   }*/
   
   var sitesButton = document.getElementById("sitesBtn");
   
   var nodesButton = document.getElementById("nodesBtn");
   
   var sitesPage = document.getElementById("sitesPage");
   
   var nodesPage = document.getElementById("AllNodesPage");
   
   var shareLinkElement = document.getElementById("shareLinkElement");
   shareLinkElement.value = location.origin + location.pathname  + location.search;
   
   groupingParamBox = document.getElementById("customGroupParameter");
   valueParamBox = document.getElementById("customValueParameter");
   
   //Change to sites page
   sitesButton.onclick = function () {
     sitesPage.style.display = "block";
     nodesPage.style.display = "none";
   
     nodesButton.style.borderBottom = "none";
     sitesButton.style.borderBottom = "3px solid #478BF2";
   };
   
   //Change to nodes page
   nodesButton.onclick = function () {
     sitesPage.style.display = "none";
     nodesPage.style.display = "block";
   
     sitesButton.style.borderBottom = "none";
     nodesButton.style.borderBottom = "3px solid #478BF2";
   };
   
   //Filter and group by menu modals
   var showModal = false;
   var showGroupByModal = false;
   
   // Get the modal
   var modal = document.getElementById("filterModal");
   
   var groupModal = document.getElementById("groupModal");
   
   // Get the button that opens the modal
   var filterButton = document.getElementById("filterBtn");
   
   // get group by button
   var groupBtn = document.getElementById("groupBtn");
   
   //Get custom parameter list items
   var liCustom = document.getElementById("liCustom");
   var liCustomGroup = document.getElementById("liCustomGroup");
   var customParameter = document.getElementById("custom");
   var customParameterGroup = document.getElementById("customGroup");
   
   //Get HMD list item
   var liHMD = document.getElementById("liHMD");
   var HMD = document.getElementById("HMD");
   
   //loop devices
   var liLoopDevices = document.getElementById("liLoop");
   var loopDevices = document.getElementById("loopDevices");
   var liLoopDevicesGroup = document.getElementById("liLoopGroup");
   var loopDevicesGroup = document.getElementById("loopDevicesGroup");
   
   //Container
   var liContainer = document.getElementById("liContainer");
   var container = document.getElementById("containerEnabled");
   var liContainerGroup = document.getElementById("liContainerGroup");
   var containerGroup = document.getElementById("containerEnabledGroup");

   
   //uname
   var liUname = document.getElementById("liUname");
   var uname = document.getElementById("uname");
   var liUnameGroup = document.getElementById("liUnameGroup");
   var unameGroup = document.getElementById("unameGroup");
   
   //Singularity
   var liSingularity = document.getElementById("liSingularity");
   var singularity = document.getElementById("singularity");
   var liSingularityGroup = document.getElementById("liSingularityGroup");
   var singularityGroup = document.getElementById("singularityGroup");
   
   //TMP
   var liTMP = document.getElementById("liTMP");
   var TMP = document.getElementById("TMP");
   var liTMPGroup = document.getElementById("liTMPGroup");
   var TMPGroup = document.getElementById("TMPGroup");
   
   //Underlay
   var liUnderlay = document.getElementById("liUnderlay");
   var underlay = document.getElementById("underlay");
   var liUnderlayGroup = document.getElementById("liUnderlayGroup");
   var underlayGroup = document.getElementById("underlayGroup");
   
   //Overlay
   var liOverlay = document.getElementById("liOverlay");
   var overlay = document.getElementById("overlay");
   var liOverlayGroup = document.getElementById("liOverlayGroup");
   var overlayGroup = document.getElementById("overlayGroup");
   
   
   //Hovering custom
   liCustom.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     customParameter.style.display = "block";
   });
   
   liCustomGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     customParameterGroup.style.display = "block";
   });
   
   //when hover over HMD
   liHMD.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     HMD.style.display = "block";
   });
   
   liHMDGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     HMDGroup.style.display = "block";
   });
   
   //when hover over loop devices
   liLoopDevices.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     loopDevices.style.display = "block";
   });

   liLoopDevicesGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     loopDevicesGroup.style.display = "block";
   });
   
   //Hovering Container 
   liContainer.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     container.style.display = "block";
   });

   liContainerGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     containerGroup.style.display = "block";
   });
   
   //Hovering Uname 
   liUname.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     uname.style.display = "block";
   });

   liUnameGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     unameGroup.style.display = "block";
   });
   
   //Hovering Singularity 
   liSingularity.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     singularity.style.display = "block";
   });

   
   //Hovering Singularity for Group
   liSingularityGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     singularityGroup.style.display = "block";
   });
   
   //Hovering TMP
   liTMP.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     TMP.style.display = "block";
   });

   liTMPGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     TMPGroup.style.display = "block";
   });
   
   //Hovering Underlay
   liUnderlay.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     underlay.style.display = "block";
   });

   liUnderlayGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     underlayGroup.style.display = "block";
   });
   
   //Hovering Overlay
   liOverlay.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     overlay.style.display = "block";
   });

   liOverlayGroup.addEventListener("mouseenter", function (event) {
     hideAllFilters();
     overlayGroup.style.display = "block";
   });
   
   // When the user clicks on the button, open the modal
   filterButton.onclick = function () {
     if (!showModal) {
       modal.style.display = "block";
       showModal = true;
     } else {
       hideAllFilters();
       modal.style.display = "none";
       showModal = false;
     }
   };
   
   // When the user clicks on the button, open the modal
   groupBtn.onclick = function () {
     if (!showGroupByModal) {
       groupModal.style.display = "block";
       showGroupByModal = true;
     } else {
       hideAllFilters();
       groupModal.style.display = "none";
       showGroupByModal = false;
     }
   };
   
   var filterModalWrapper = document.getElementById('filterButtonWrapper');
   document.addEventListener('click', function( event ) {
     if (filterModalWrapper !== event.target && !filterModalWrapper.contains(event.target)) {    
       console.log('clicking outside filter div');
       hideAllFilters();
       hideFilterModal();
     }
   });
   
   var groupButtonWrapper = document.getElementById('groupButtonWrapper');
   document.addEventListener('click', function( event ) {
     if (groupButtonWrapper !== event.target && !groupButtonWrapper.contains(event.target)) {    
       console.log('clicking outside group div');
       hideAllFilters();
       hideGroupModal();
     }
   });

   function setFilter(param1, param2){
      filterArrayParam = param1;
      filterValueParam = param2;
      changeFilterText();
      cancel();
   }
   
   function hideFilterModal(){
     showModal = false;
     modal.style.display = "none";
   }
   
   function hideGroupModal(){
     showGroupByModal = false;
     groupModal.style.display = "none";
   }
   
   //function for hiding all list extensions for filter button
   function hideAllFilters() {
      //Hide all filters
     customParameter.style.display = "none";
     HMD.style.display = "none";
     loopDevices.style.display = "none";
     container.style.display = "none";
     uname.style.display = "none";
     singularity.style.display = "none";
     singularityGroup.style.display = "none";
     TMP.style.display = "none";
     underlay.style.display = "none";
     overlay.style.display = "none";

     //Hide all groupings
     customGroup.style.display = "none";
     HMDGroup.style.display = "none";
     loopDevicesGroup.style.display = "none";
     containerGroup.style.display = "none";
     unameGroup.style.display = "none";
     TMPGroup.style.display = "none";
     underlayGroup.style.display = "none";
     overlayGroup.style.display = "none";
   }
   
   function cancel(){
      hideFilterModal();
      hideGroupModal();
      hideAllFilters();
   }
   
   //Share button functions
   
   var shareBtn = document.getElementById("shareBtn");
   var shareModal = document.getElementById("shareModal");
   var showShareModal = false;
   
   function toggleShareButton(){
      showShareModal = !showShareModal;
      if(showShareModal){
         shareModal.style.display = "block";
      }
      else{
         shareModal.style.display = "none";
      }
   }
   
   document.addEventListener('click', function( event ) {
     if (shareModal !== event.target && shareBtn !== event.target && !shareBtn.contains(event.target) && !shareModal.contains(event.target)) {    
       console.log('clicking outside share div');
       showShareModal = false;
       shareModal.style.display = "none";
     }
   });
   
   
</script>
<style type="text/css">
   //percentage circle
   .flex-wrapper {
   display: flex;
   flex-flow: row nowrap;
   width: 5rem;
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
   border-radius: 0.3rem;
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
   padding: 0.5rem 1rem;
   color: #727272;
   margin-bottom: 1rem;
   width: 9rem;
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
   width: min-content;
   display: none;
   min-width: 11rem;
   max-width: 20rem;
   height: fit-content;
   height: min-content;
   box-shadow: 0px 2px 2px 2px rgb(0 0 0 / 10%);
   border-radius: 0.3rem;
   }
   .pageButton {
   border: none;
   background: none;
   font-size: 1rem;
   margin-right: 1rem;
   }
   .cancelButton{
   padding: 0.5rem 0.7rem;
   border-radius: 3rem;
   border: none;
   margin: 1rem 1rem 0 0;
   }
   .cancelButton:hover{
   transition: 100ms;
   background-color: #f5f5f5;;
   }
   .cancelButton:active{
   transition: 100ms;
   background-color: #f5f5f5;
   color: #d8d8d8;
   }
   .submitButton{
   color: #FFF;
   float: right;
   border-radius: 3rem;
   padding: 0.5rem 0.7rem;
   border: none;
   margin: 1rem 1rem 0 0;
   background-color: #4798F9;
   }
   .submitButton:hover{
   transition: 100ms;
   background-color: #94BBEA;
   }
   .submitButton:active{
   transition: 100ms;
   background-color: #94BBEA;
   color: #d8d8d8;
   }
</style>

