package ch.heigvd.cld.lab;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Enumeration;

@WebServlet(name = "DatastoreWrite", value = "/datastorewrite")
public class DatastoreWriteSimple extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("text/plain");
        PrintWriter pw = resp.getWriter();
        pw.println("Writing entity to datastore.");

        String kind = req.getParameter("_kind");
        String keyName = req.getParameter("_key");

        if (kind == null || kind.isEmpty()) {
            pw.println("Error: _kind parameter is missing or empty.");
            return;
        }

        DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

        //Create entity with ou without key defined by user.
        Entity entity;
        if (keyName != null && !keyName.isEmpty()) {
            entity = new Entity(kind, keyName);
        } else {
            entity = new Entity(kind);
        }

        Enumeration<String> parameterNames = req.getParameterNames();

        // Add each parameters
        while (parameterNames.hasMoreElements()) {
            String paramName = parameterNames.nextElement();
            if (!"_kind".equals(paramName) && !"_key".equals(paramName)) {
                String paramValue = req.getParameter(paramName);
                entity.setProperty(paramName, paramValue);
                pw.println("Added property: " + paramName + " = " + paramValue);
            }
        }

        datastore.put(entity);
    }
}
