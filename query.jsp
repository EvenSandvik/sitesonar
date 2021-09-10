<%@ page import="lia.Monitor.Store.Fast.DB,lazyj.*,alimonitor.*,java.util.*,java.io.*,java.util.Date,java.text.SimpleDateFormat,lia.web.utils.ServletExtension,lia.Monitor.Store.Cache" %><%
    final DB db = new DB();
    
    final RequestWrapper rw = new RequestWrapper(request);

    response.setContentType("text/plain");
    
    db.query("select todo.test_name from sitesonar_todo todo left outer join (sitesonar_hosts h inner join sitesonar_tests t using (host_id)) on t.test_name=todo.test_name and hostname='"+Format.escSQL(rw.gets("hostname"))+"' and ce_name='"+Format.escSQL(rw.gets("ce_name", "unknown"))+"' WHERE extract(epoch from now())>coalesce(last_updated,0) + validity_seconds;");
    
    while (db.moveNext()){
	out.println(db.gets(1));
    }
%>