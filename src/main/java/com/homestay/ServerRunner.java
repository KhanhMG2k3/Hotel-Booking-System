package com.homestay;

import org.apache.catalina.Lifecycle;
import org.apache.catalina.WebResourceRoot;
import org.apache.catalina.core.StandardContext;
import org.apache.catalina.startup.Tomcat;
import org.apache.catalina.webresources.DirResourceSet;
import org.apache.catalina.webresources.StandardRoot;

import java.io.File;

/**
 * ServerRunner - Standalone Embedded Tomcat runner for Sogo Homestay.
 *
 * Features:
 * - Hot reload enabled (ctx.setReloadable(true))
 * - Dynamic static / JSP reload directly from src/main/webapp
 */
public class ServerRunner {

    private static final int PORT = 8080;

    /** Starts embedded Tomcat and waits for the server to stop. */
    public static void main(String[] args) throws Exception {
        // Enforce UTF-8 across JVM console and output streams
        System.setProperty("file.encoding", "UTF-8");
        System.setProperty("stdout.encoding", "UTF-8");
        System.setProperty("stderr.encoding", "UTF-8");
        try {
            System.setOut(new java.io.PrintStream(System.out, true, java.nio.charset.StandardCharsets.UTF_8));
            System.setErr(new java.io.PrintStream(System.err, true, java.nio.charset.StandardCharsets.UTF_8));
        } catch (Exception ignored) {
        }
        Tomcat tomcat = new Tomcat();
        tomcat.setPort(PORT);
        org.apache.catalina.connector.Connector connector = tomcat.getConnector(); // Initialize HTTP connector
        connector.setURIEncoding("UTF-8");
        connector.setUseBodyEncodingForURI(true);

        File baseDir = new File("target/tomcat-base");
        baseDir.mkdirs();
        tomcat.setBaseDir(baseDir.getAbsolutePath());

        File webappDir = new File("src/main/webapp");
        StandardContext ctx = (StandardContext) tomcat.addWebapp("", webappDir.getAbsolutePath());
        ctx.setParentClassLoader(ServerRunner.class.getClassLoader());

        // Bật tự động reload (Hot-Reload) khi class thay đổi trong target/classes
        ctx.setReloadable(true);
        tomcat.getHost().setBackgroundProcessorDelay(2); // Quét thay đổi class mỗi 2 giây

        // Configure DefaultServlet to read static assets with UTF-8
        ctx.addLifecycleListener(event -> {
            if (Lifecycle.BEFORE_START_EVENT.equals(event.getType()) || Lifecycle.START_EVENT.equals(event.getType())) {
                org.apache.catalina.Container defaultServlet = ctx.findChild("default");
                if (defaultServlet instanceof org.apache.catalina.Wrapper wrapper) {
                    wrapper.addInitParameter("fileEncoding", "UTF-8");
                }
            }
        });

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
        System.out.println("⚡ Hot-Reload (Auto Reload): ENABLED (Quét class mỗi 2s)");
        System.out.println("👉 Access Website at: http://localhost:" + PORT + "/");
        System.out.println("👉 Rooms Page at:     http://localhost:" + PORT + "/rooms");
        System.out.println("👉 Reservation Page:  http://localhost:" + PORT + "/reservation");
        System.out.println("===============================================================");

        tomcat.start();
        tomcat.getServer().await();
    }
}
