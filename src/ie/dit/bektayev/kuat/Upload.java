package ie.dit.bektayev.kuat;

import java.io.IOException;
import java.util.Date;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.appengine.api.blobstore.BlobInfoFactory;
import com.google.appengine.api.blobstore.BlobKey;
import com.google.appengine.api.blobstore.BlobstoreService;
import com.google.appengine.api.blobstore.BlobstoreServiceFactory;
import com.google.appengine.api.datastore.Entity;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.KeyFactory;
import com.google.appengine.api.datastore.Key;

import com.google.appengine.api.images.*;

import com.google.appengine.api.users.User;
import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

public class Upload extends HttpServlet 

{
	private static final long serialVersionUID = 1L;
	private BlobstoreService blobstoreService =	BlobstoreServiceFactory.getBlobstoreService();
	private BlobInfoFactory bif = new BlobInfoFactory();

	public void doPost(HttpServletRequest req, HttpServletResponse resp)
			throws ServletException, IOException {

		@SuppressWarnings("deprecation")
		Map<String, BlobKey> blobs = blobstoreService.getUploadedBlobs(req);
		BlobKey blobKey = blobs.get("imageFile");
		
		//If upload fails return message
		if (blobKey == null) 
		{
			resp.sendRedirect("/index.hmtl");
		} 
		else
		{
			ImagesService ImageServiceObject = ImagesServiceFactory.getImagesService(); 
			DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();
	        UserService userService = UserServiceFactory.getUserService();
	        User user = userService.getCurrentUser();  	        
			String viewImages = "/index.jsp";
            Date date = new Date();	
            String description = req.getParameter("description");
            String imageUrl =ImageServiceObject.getServingUrl(blobKey);
            String imageName  = bif.loadBlobInfo(blobKey).getFilename();			        
            String uploadImageFoo = "foo";	

			Key uploadImageKey = KeyFactory.createKey("image", uploadImageFoo);
			
			Entity UploadImageEntity = new Entity("UploadImage", uploadImageKey);
						
			UploadImageEntity.setProperty("blobkey", blobKey);
			UploadImageEntity.setProperty("imageUrl", imageUrl);
			UploadImageEntity.setProperty("imageName", imageName);
			UploadImageEntity.setProperty("description", description);
			UploadImageEntity.setProperty("date", date);
			UploadImageEntity.setProperty("user", user);
			
			datastore.put(UploadImageEntity);

			resp.sendRedirect(viewImages); // redirect so that user is left on index.jsp when file is uploaded
		}

	}
}
