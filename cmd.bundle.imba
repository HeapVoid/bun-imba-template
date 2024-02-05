import {bundle} from './imba/core.imba'

# more on bun building params here: 
# https://bun.sh/docs/bundler
bundle 
	entrypoints: ['./src/index.imba']
	outdir: './public'
	minify: true
	target: 'browser'
	sourcemap: 'none'