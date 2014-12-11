<%@ page import="com.google.appengine.api.blobstore.BlobstoreServiceFactory" %>
<%@ page import="com.google.appengine.api.blobstore.BlobstoreService" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.appengine.api.users.User" %>
<%@ page import="com.google.appengine.api.users.UserService" %>
<%@ page import="com.google.appengine.api.users.UserServiceFactory" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page import="com.google.appengine.api.datastore.DatastoreServiceFactory"%>
<%@ page import="com.google.appengine.api.datastore.DatastoreService"%>
<%@ page import="com.google.appengine.api.datastore.Query"%>
<%@ page import="com.google.appengine.api.datastore.Query.Filter"%>
<%@ page import="com.google.appengine.api.datastore.Query.FilterPredicate"%>
<%@ page import="com.google.appengine.api.datastore.Query.FilterOperator"%>
<%@ page import="com.google.appengine.api.datastore.Entity"%>
<%@ page import="com.google.appengine.api.datastore.FetchOptions"%>
<%@ page import="com.google.appengine.api.datastore.Key"%>
<%@ page import="com.google.appengine.api.datastore.KeyFactory"%>


<%
	BlobstoreService blobstoreService = BlobstoreServiceFactory.getBlobstoreService(); // Create a new blob store service
%>
<html>
<head>
<title>Picture Box Main</title>
</head>
<body>
<center>
<img src="picturebox.jpg" alt="title" >
	<form action="<%= blobstoreService.createUploadUrl("/upload") %>" method="post" enctype="multipart/form-data">
            <input type="text" name="description">
            <input type="file" name="imageFile">
            <input type="submit" value="Submit">
	</form>
	<%
	
		String uploadImageFoo = "foo";

		DatastoreService datastore = DatastoreServiceFactory.getDatastoreService(); // Create a new datastore service to provide storage for our images
		Key uploadImageKey = KeyFactory.createKey("image", uploadImageFoo); // Create a primary Key for our datastore Entity
		Query ImageQuery = new Query("UploadImage", uploadImageKey).addSort("date", Query.SortDirection.DESCENDING); // A Query which sorts our images by descending order
		List<Entity> UploadImageEntitys = datastore.prepare(ImageQuery).asList(FetchOptions.Builder.withLimit(5)); // Create a collection of image entities

		if (UploadImageEntitys.isEmpty() == true) // If we have no images there is nothing to display
		{
	        %>
	        <p>Nothing to display</p>
	        <%
		} 
		else 
		{
			for (Entity UploadImage : UploadImageEntitys)  // otherwise iterate through our Entity list
			{
				pageContext.setAttribute("UploadImageImageURL",	UploadImage.getProperty("imageUrl")); // set the URL of image	
				pageContext.setAttribute("UploadImageDescription", UploadImage.getProperty("description")); // set the description of image		
				pageContext.setAttribute("imageBlobkey", UploadImage.getProperty("blobkey")); // gets the blobkey by its name
				UserService userService = UserServiceFactory.getUserService(); // create userService for logging out below
	            User user = userService.getCurrentUser();
					
			%>
			${fn:escapeXml(imagekey)}			
			${fn:escapeXml(UploadImageDescription)}			
			<img src=${fn:escapeXml(UploadImageImageURL) } /> <%-- Display image to user by its URL --%>
			
			<center>Comment:</center>
            <form action="/upload" method="post">
            <div><textarea name="content" rows="3" cols="50"></textarea></div>
            <div><input type="submit" value="Post Comment" /></div>
            </form>		
            <p>
              
              <p>Hello Admin!  
                    (You can
                    <a href="<%= userService.createLogoutURL(request.getRequestURI()) %>">sign out here</a>.)</p>
                    <%                     
			
					} // End of Entity Loop							
					
				}// End of else statement (else if UploadImageEntitys.isEmpty() == true )
	%>

</body>
</html>