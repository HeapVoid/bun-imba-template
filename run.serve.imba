import {serve} from './server.imba'

serve 
	source: import.meta.dir + '/src' # full path to source folder
	public: import.meta.dir + '/public' # full path to destination folder
	entry: '/index.imba' # the file path inside the source folder
	port: 8080 # the port at which http server serves compiled files
	chokidar: false # monitor file changes with chokidar (great for WSL on Windows)
	hmr:
		favicon: 'favicon.png' # the image that is used to check if server is online
		favon: true # change favicon to a green circle when live update is on
