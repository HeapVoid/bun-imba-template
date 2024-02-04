import {serve} from './imba/core.imba'

serve 
	source: './src'
	public: './public'
	entry: 'index.imba'
	port: 8080