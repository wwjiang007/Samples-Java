<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<%@page import="com.stimulsoft.report.utils.data.StiXmlTableFieldsRequest"%>
<%@page import="com.stimulsoft.base.json.JSONObject"%>
<%@page import="com.stimulsoft.report.StiOptions"%>
<%@page import="java.io.FileOutputStream"%>
<%@page import="java.io.FileInputStream"%>
<%@page import="com.stimulsoft.report.utils.data.StiDataColumnsUtil"%>
<%@page import="com.stimulsoft.report.dictionary.StiDataColumnsCollection"%>
<%@page import="com.stimulsoft.report.dictionary.StiDataColumn"%>
<%@page import="com.stimulsoft.report.utils.data.StiSqlField"%>
<%@page import="com.stimulsoft.report.dictionary.dataSources.StiDataTableSource"%>
<%@page import="com.stimulsoft.report.utils.data.StiXmlTable"%>
<%@page import="com.stimulsoft.webdesigner.StiWebDesigerHandler"%>
<%@page import="com.stimulsoft.webdesigner.StiWebDesignerOptions"%>
<%@page
	import="com.stimulsoft.report.dictionary.databases.StiXmlDatabase"%>
<%@page import="java.io.File"%>
<%@page import="com.stimulsoft.report.StiSerializeManager"%>
<%@page import="com.stimulsoft.report.StiReport"%>
<%@page language="java" contentType="text/html; charset=utf-8"
	pageEncoding="UTF-8"%>
<%@taglib uri="http://stimulsoft.com/webdesigner" prefix="stiwebdesigner"%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Stimulsoft Webdesigner for Java</title>
<style type="text/css">
</style>
</head>
<body>
	<%
	            final String reportPath = request.getSession().getServletContext().getRealPath("/reports/Master-Detail.mrt");
				final String xmlPath = request.getSession().getServletContext().getRealPath("/data/Demo.xml");
				final String xsdPath = request.getSession().getServletContext().getRealPath("/data/Demo.xsd");
				final String savePath = request.getSession().getServletContext().getRealPath("/save/");
	
			    StiWebDesignerOptions options = new StiWebDesignerOptions();	
			    //options.setLocalization(request.getSession().getServletContext().getRealPath("/localization/de.xml"));		    
			    StiWebDesigerHandler handler = new StiWebDesigerHandler(){
			        //Occurred on loading webdesinger. Must return edited StiReport
			        public StiReport getEditedReport(HttpServletRequest request){
			            try{
			              StiReport report = StiSerializeManager.deserializeReport(new File(reportPath));
			              report.getDictionary().getDatabases().add(new StiXmlDatabase("Demo", xsdPath, xmlPath));
			              return report;
			            } catch (Exception e){
			                e.printStackTrace();
			            }
			            return null;
			        }
					//Occurred on opening StiReport. Method intended for populate report data.
			        public void onOpenReportTemplate(StiReport report, HttpServletRequest request){
			            report.getDictionary().getDatabases().add(new StiXmlDatabase("Demo", xsdPath, xmlPath));
			        }
					//Occurred on new StiReport. Method intended for populate report data.
			        public void onNewReportTemplate(StiReport report, HttpServletRequest request){
			            report.getDictionary().getDatabases().add(new StiXmlDatabase("Demo", xsdPath, xmlPath));
			            try{
			                StiXmlTableFieldsRequest tables = StiDataColumnsUtil.parceXSDSchema(new FileInputStream(xsdPath));
			                for (StiXmlTable table : tables.getTables()){
			                    StiDataTableSource tableSource = new StiDataTableSource("Demo." + table.getName(), table.getName(), table.getName());
			                    tableSource.setColumns(new StiDataColumnsCollection());
			                    for (StiSqlField field : table.getColumns()){
			                        StiDataColumn column = new StiDataColumn(field.getName(), field.getName(), field.getSystemType());
			                        tableSource.getColumns().add(column);
			                    }
			                    tableSource.setDictionary(report.getDictionary());
			                    report.getDictionary().getDataSources().add(tableSource);   
			                }	                
			            } catch (Exception e){
			             	e.printStackTrace();   
			            }	            
			        }
			        //Occurred on save StiReport. Method must implement saving StiReport
			        public void onSaveReportTemplate(StiReport report, String reportName, HttpServletRequest request){
			            try{
			            	FileOutputStream fos = new FileOutputStream(savePath + reportName);
			            	JSONObject parameters = new JSONObject(request.getParameter("MvcMobileDesignerParameters"));
			            	if (!report.isJsonReport()){
			            		if (parameters.has("encryptedPassword")){
			            	       String password = parameters.getString("encryptedPassword");
								   StiSerializeManager.serializeReport(report, fos, password);
								}else{
								   StiSerializeManager.serializeReport(report, fos);
								}
			            	}else {
			            	    if (parameters.has("encryptedPassword")){
			            	       String password = parameters.getString("encryptedPassword");
								   StiSerializeManager.serializeReportToJson(report, fos, password);
								}else{
								   StiSerializeManager.serializeReportToJson(report, fos);
								}			            	
			        		}
			        		fos.close();
			            } catch (Exception e){
			                e.printStackTrace();
			            }
			        }
			    };	   
			    pageContext.setAttribute("handler", handler);
			    pageContext.setAttribute("options", options);
	%>

	<stiwebdesigner:webdesigner
					handler="${handler}" options="${options}" />
</body>
</html>
