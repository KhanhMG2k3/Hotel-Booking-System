package com.homestay;

import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

/**
 * ServerRunner - Standalone Embedded Tomcat runner for Sogo Homestay.
 */
public class ServerRunner {

    private static final int PORT = 8080;

    public static void main(String[] args) throws Exception {
        Tomcat tomcat = new Tomcat();
        tomcat.setPort(PORT);
        tomcat.getConnector(); // Initialize HTTP connector

        File baseDir = new File("target/tomcat-base");
        baseDir.mkdirs();
        tomcat.setBaseDir(baseDir.getAbsolutePath());

        File webappDir = new File("src/main/webapp");
        StandardContext ctx = (StandardContext) tomcat.addWebapp("", webappDir.getAbsolutePath());
        ctx.setParentClassLoader(ServerRunner.class.getClassLoader());

        // Set classloader resources
        File additionWebInfClasses = new File("target/classes");
        if (additionWebInfClasses.exists()) {
            WebResourceRoot resources = new StandardRoot(ctx);
            resources.addPreResources(new DirResourceSet(resources, "/WEB-INF/classes",
                    additionWebInfClasses.getAbsolutePath(), "/"));
            ctx.setResources(resources);
        }

        System.out.println("===============================================================");
        System.out.println("🚀 Sogo Homestay Server is starting...");
        System.out.println("👉 Access Website at: http://localhost:" + PORT + "/");
        System.out.println("👉 Rooms Page at:     http://localhost:" + PORT + "/rooms");
        System.out.println("👉 Reservation Page:  http://localhost:" + PORT + "/reservation");
        System.out.println("===============================================================");

        tomcat.start();
        tomcat.getServer().await();
    }
}
