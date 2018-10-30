# Water Auth Server Docker

[![Build Status](https://travis-ci.org/USGS-CIDA/docker-water-auth-server.svg?branch=master)](https://travis-ci.org/USGS-CIDA/docker-water-auth-server)

This Docker image implements the [USGS Water Auth Server](https://github.com/USGS-CIDA/Water-Auth-Server)

## Launchable Modes
This image supports running in two modes: Standard Mode and Local Dev Mode. The mode to be launched is toggled by the boolean ENV `LOCAL_DEV_MODE`. By default this value is `false`, thus starting Standard Mode (unless launching via docker-compose, in which case the value will be `true` and Local Dev Mode will start).

### Standard Mode
This is the mode that is run by default (unless the image is launched via docker-compose). This mode expects that you will have both a SAML IDP and Database available and configured. The application will not start unless both of these are accessible when run in this mode. This is the mode that should be run when
running this application outside of a local development environment.

### Local Dev Mode
This is the mode that will be run when doing `docker-compose up` without overriding the compose YAML. This mode uses the `localDev` Spring Profile built into Water Auth to allow the service to run without a SAML IDP or Database being accessible. This mode will create an in-memory user database and create a single user using the username and password supplied via the `localUserName` (default: `user`) and `localUserPassword` (default: `changeMe`) ENVs.

## Testing Standard Mode with CircleSSO
- Find out your Docker IP
  - If using Docker natively, it will be localhost (or 127.0.0.1)
  - If using Docker Machine, use `docker-machine ip <machine name>`
- Edit circlesso-config.env 
  - Update samlAuthnRequestProviderName to be `https://<docker IP>:443/saml/`
  - Update samlAuthnRequestEntityId to be some unqiue ID of your choosing. When uploading the metadata to SSOCircle if you get an error about the entity already existing then come back and change this to another value.
  - Update waterAuthUrlServerName to be your docker IP
- Start the WaterAuth Docker container via `docker-compose -f docker-compose-circlesso.yml up --build`
- When the server is running, in another terminal run the following command
  - `curl -k "https://<Docker IP>:8443/saml/metadata" > /some/file/on/your/localsystem.xml`
- Sign up for account @ https://idp.ssocircle.com/sso/UI/Login
- Navigate to https://idp.ssocircle.com/sso/hos/SPMetaInter.jsp
- Enter your Docker IP into the textbox requesting it
- Check LastName, EmailAddress and UserID
- Open the file that was created via the curl command in a text editor and paste the contents into the metadata textbox
- Click submit
- Log out

You can now try to navigate to `https://<Docker IP>/saml/login` and test whether or not you are able to perform the log in through CircleSSO back to your Docker service. If successful, you should see a message that says `You're logged in as <username>`

## Testing Oauth2 JWT Tokens (Standard Mode)
- Create a mock Oauth2 client application in the WaterAuth database. Example values provided below.
  - client_id: Some unique id
  - resource_ids: null
  - client_secert: Some secret passphrase
  - scope: read,write
  - authorized_grant_types: authorization_code,access_token,refresh_token
  - web_server_redirect_uri: Some URL that doesn't point to a running service. I.E: 127.0.0.1
  - authorities: null
  - access_token_validity: 36000
  - refresh_token_validity: 36000
  - additional_information: null
  - autoapprove: true

- Example mock Oauth2 Client SQL:
  - `insert into waterauth.oauth_client_details(client_id,resource_ids,client_secret,scope,authorized_grant_types,web_server_redirect_uri,authorities,access_token_validity,refresh_token_validity,additional_information,autoapprove) values ("test-id", null, "test-secret", "read,write", "authorization_code,access_token,refresh_token", "127.0.0.1", null, 36000, 36000, null, true);`

- Login through WaterAuth (if you aren't already logged in) and make sure you get to the page saying `You are logged in as <username>`.

- In a browser navigate to `https://<water auth host>/oauth/authorize?client_id=<client_id you created earlier>&redirect_uri=<redirect_uri you created earlier>&response_type=code`

- Wait a moment and you should be redirected to an error page or non-existing page. The URL in your browser's URL bar should have a query parameter called "code". Copy the value of this parameter.

- Open up a bash terminal and run the following:
  - `curl -k https://<client_id you created earlier>:<client_secert you created earlier>@<water auth host>/oauth/token -d grant_type=authorization_code -d code=<code you copied in step 4> -d redirect_uri=<redirect_uri you created earlier> --output <some file to output the resultant JSON to>`

- This command should execute give you a JSON document containing your generated JSON Web Token (JWT). Note that **the code you genrated in step 3 can only be used _once_** so if some error occurs during the the process (i.e the redirect uri does not match the one you specified in the DB) you will need to jump back up to step 3 and repeat from there.

- Grab the value of the "access_token" field from the JSON document you retrieved in step 6 and navigate a web brwoser to `https://jwt.io/`.

## Testing Oauth2 JWT Tokens (Local Dev Mode)
- Login through WaterAuth (if you aren't already logged in) using the username and password of the default user that was created and make sure you get to the page saying `You are logged in as <$localUserName>`.

- In a browser navigate to `https://<water auth host>/oauth/authorize?client_id=local-client&redirect_uri=<redirect_uri you created earlier>&response_type=code`

- Wait a moment and you should be redirected to an error page or non-existing page. The URL in your browser's URL bar should have a query parameter called "code". Copy the value of this parameter.

- Open up a bash terminal and run the following:
  - `curl -k https://local-client:changeMe@<water auth host>/oauth/token -d grant_type=authorization_code -d code=<code you copied in step 4> -d redirect_uri=<redirect_uri you created earlier> --output <some file to output the resultant JSON to>`

- This command should execute give you a JSON document containing your generated JSON Web Token (JWT). Note that **the code you genrated in step 3 can only be used _once_** so if some error occurs during the the process (i.e the redirect uri does not match the one you specified in the DB) you will need to jump back up to step 3 and repeat from there.

- Grab the value of the "access_token" field from the JSON document you retrieved in step 6 and navigate a web brwoser to `https://jwt.io/`.
