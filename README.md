# Water Auth Server Docker

[![Build Status](https://travis-ci.org/USGS-CIDA/docker-water-auth-server.svg?branch=master)](https://travis-ci.org/USGS-CIDA/docker-water-auth-server)

This Docker image implements the [USGS Water Auth Server](https://github.com/USGS-CIDA/Water-Auth-Server)

## Testing locally with CircleSSO

- Find out your Docker IP
  - If using Docker natively, it will be localhost (or 127.0.0.1)
  - If using Docker Machine, use `docker-machine ip <machine name>`
- Edit docker-compose-circlesso.env
  - Update samlAuthnRequestProviderName to be `https://<docker IP>:443/saml/`
  - Update samlAuthnRequestEntityId to be `https://<docker IP>:443/saml/`
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
