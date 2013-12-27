1. Download and install Squid version 3 using the command

			sudo apt-get install squid3
	
		This would install squid3 on your system and initialize the following default directories
			1. Access Log Files /var/log/squid3/
			2. Cache Store Log /var/log/squid3/ 
	
	2. Configuring Squid according to IIT Mandi Networks. 
 	(I had tested my system in the Kamand PC Lab)
	
		1. Add the access control list for the College network by adding this under the TAG: acl section of the squid.conf file	
		
			acl accesses src 10.8.0.0/16  # Note these are only for PC Lab 
			acl accesses src 10.6.0.0/16  
			acl accounts src 192.168.1.0/24
		
		2. Now to allow only these access control lists and blocking all the other requests out 
		
			http_access allow accesses accounts
			http_access deny all #This denies access to all other connections

		3. In case you need to declare a parent proxy server then add the following line under the cache parent section

			cache_peer “Parent Proxy” parent 8080 0 no-query no-digest default 
			never_direct allow all 
		
		Note : The Parent proxy will have also have to declare you as a child proxy in its own configuration file
		
	3. Setting up the Squid to use Web-mail Credentials based authentication to grant Internet 	access 

		1. First of all we need a script to check the user name and password against the web mail IMAP server and return OK in case of validation success and ERR in case of validation failure

		2. For this a simple script in Perl using the inbuilt modules can be used

			 Module Authen::Simple::IMAP will be used 
		
		It doesn't come pre installed in Ubuntu  
	
		3. Save the script in a directory of your choice . I would suggest making a directory /scripts and storing everything there

	
		4. Grant the script permissions 
				chmod +x imap.pl
				chmod 777 imap.pl


		5. Add the following lines in the squid.conf file 
			
				  auth_param basic program /scripts/imap.pl 
	
			Under the TAG: acl add
		
				acl users proxy_auth REQUIRED
		
			Under the http_access tag add
			
				http_access allow users
			
		
		6. For blocking Websites make a file and name it say blacklist
		Enter one website a line and save it 
 
		Add the following lines to the squid.conf file 

			acl blacklist dstdomain “path to the script” 
			http_access deny blacklist

 

	4. Setting up the quota management scripts 

		We will basically need two scripts to get the quota system working. 
		One script will check the usage of the user demanding the Internet access and allowing to his usage limit will grant him access or not. (Attached as sdq_redirector.pl)


		The second script reads from the squid access logs and updates the usage statistics of each and every user. (attached as rtparse.pl)
		(The script automatically initializes directories under the /var/db parent directory  


	5. Now the rtparse.pl script will be running in the background and will use the inbuilt tail command to keep reading from the access.log file in /etc/squid3/ directory
	
		Grant the rtparse.pl script permissions by running 
		
			chmod +x rtparse.pl
			chmod 777 rtparse.pl


		for this run the command the 

			tail -n1 -F /path/to/squid_access_log | rtparse.pl &
	
		This has started a background job that  will keep monitoring the access logs
 
	6. Now the redirect script should be granted executable permissions 
	using the commands 	
			chmod +x sdq_redirector.pl
			chmod 777 sdq_redirector.pl


	7. Complete the whole process by redirecting all the input squid receives to the redirect 	script by adding the following line in the squid.conf file

			redirect_program “path to redirect program” 

	8. Run the command 
			sudo squid3 -k reconfigure
			sudo service squid3 restart

