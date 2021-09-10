<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*" %><%
    final DB db = new DB();
    
    final RequestWrapper rw = new RequestWrapper(request);

    String hostname = rw.gets("hostname");
    String ce_name = rw.gets("ce_name");
    
    String test_name = rw.gets("test_name");
    int test_code = rw.geti("test_code", 0);
    String test_message = rw.gets("test_message");
    
    if (hostname.length()==0 || ce_name.length()==0 || test_name.length()==0){
	response.sendError(400, "Fields cannot be empty");
	return;
    }
    
    int host_id;
    
    db.query("select host_id, addr='"+Format.escSQL(request.getRemoteAddr())+"' from sitesonar_hosts where hostname='"+Format.escSQL(hostname)+"' and ce_name='"+Format.escSQL(ce_name)+"';");
    
    if (db.moveNext()){
	host_id = db.geti(1);
	
	if (!db.getb(2))
	    db.query("UPDATE sitesonar_hosts SET addr='"+Format.escSQL(request.getRemoteAddr())+"'::inet WHERE host_id="+host_id);
    }
    else{
	host_id = Math.abs((hostname+"@"+ce_name).hashCode());
	
	db.query("select host_id from sitesonar_hosts where host_id="+host_id);
	
	while (db.moveNext()){
	    host_id ++;
	    db.query("select host_id from sitesonar_hosts where host_id="+host_id);
	}
	
	db.syncUpdateQuery("INSERT INTO sitesonar_hosts (hostname, ce_name, host_id, addr) VALUES ('"+Format.escSQL(hostname)+"', '"+Format.escSQL(ce_name)+"', "+host_id+", '"+Format.escSQL(request.getRemoteAddr())+"'::inet);");
    }
    
    if (db.syncUpdateQuery("INSERT INTO sitesonar_tests (host_id, test_name, test_code, test_message) VALUES ("+host_id+", '"+Format.escSQL(test_name)+"', "+test_code+", '"+Format.escSQL(test_message)+"') ON CONFLICT (host_id, test_name) DO UPDATE SET test_code=EXCLUDED.test_code, test_message=EXCLUDED.test_message, last_updated=extract(epoch from now())::int;"))
	response.sendError(204);
    else
	response.sendError(500);
%>