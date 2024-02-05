import {bundle} from './core.imba'

# more on bun building params here: 
# https://bun.sh/docs/bundler
bundle 
	//entrypoints: ['./src/index.imba']
	//outdir: './public'
	entrypoints: [import.meta.dir + '/src/index.imba']
	outdir: import.meta.dir + '/public'
	minify: true
	target: 'browser'
	sourcemap: 'none'