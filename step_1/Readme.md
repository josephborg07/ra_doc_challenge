# Dockerizing the host metric app

## 1) General overview

The 3 components of the app are:
- Frontend: nginx serving a static react app which fetches data from the backend app using a simple GET request
- Backend: a standard python site listening on port 5000 which servers the FE app
- Web proxy: an nginx proxy catering for both FE and BE apps using the following logic:
    - Backdend: simply serve the backend on http://localhost:8080/be-stats;
    - Frontend: serve FE on http://localhost:8080/fe, sub_filter sytanx to change the response from the upstream FE endpoint to match the `/fe` syntax

## 2) Running the application
The entire application is funnt dockerized and can be built by simply running `docker-compose -f docker-compose.yml up -d` in the root directory. This will take care of building both FE and BE images, creating a network named **ra_test_network** creating containers for the 3 components mentioned above (FE app, BE app and nginx proxy)

## 3) Building the applications

Frontend build has 2 stages:
- Stage 1:
    1. Add the node_modules dir to the local path so that it's easily accessible by the container
    2. copying the contents of the `/sys-stats` directory to the node container
    3. Installing the dependencies
    4. Change the backend's endpoint from the react app's main App.js file
    5. Build the actual app

- Stage 2: 
    1. Use cdue/nginx-subs-filter:latest as the base image
    2. copy the output of the build from stage 1 to the default document root of nginx (`/usr/share/nginx/html/`)
    3. expose port 80
    4. run nginx

The end result would be a containerized nginx server, serving a static react app on port 80.


Backend build has 1 stage:
1. Use python:3.8.0 as the base iamge
2. Define the working directory and copy the contents of `api/` to it.
3. Expose port 5000
4. install the required modules
5. Run app.py using python


The end result would be a docker container listening internall on port 5000 and returning a json response with the CPU and memory metrics.


# 4) Service the application
The client will hit http://localhost:8080/fe in order to access the FE of the solution. That will hit the nginx service the react app which in turn, will request the metrics the the backend python on it's container's static IP (172.30.0.15).

Both applications can be access only through the nginx proxy:
- FE - http://localhost:8080/fe
- BE - http://localhost:8080/be-stats